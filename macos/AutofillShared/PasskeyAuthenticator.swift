import Foundation
import CryptoKit
import Security

/// Software WebAuthn authenticator (ES256) matching openkey_extension/src/passkey/webauthn.ts.
enum PasskeyAuthenticator {
  static let es256Alg = -7

  struct CreateResult {
    var passkey: AutofillPasskeyPayload
    var credentialId: Data
    var attestationObject: Data
  }

  struct AssertResult {
    var authenticatorData: Data
    var signature: Data
    var nextSignCount: Int
    var userHandle: Data?
    var credentialId: Data
  }

  enum AuthError: Error {
    case unsupportedAlgorithm
    case missingPrivateKey
    case invalidKey
    case cryptoFailure
    case invalidRpId
  }

  // MARK: - Public API

  /// Create a new ES256 passkey. `clientDataHash` is provided by Apple / Android when available.
  static func create(
    rpId: String,
    userName: String,
    displayName: String,
    userHandle: Data,
    clientDataHash _: Data?
  ) throws -> CreateResult {
    let keys = try generateEs256KeyPair()
    var credentialId = Data(count: 32)
    _ = credentialId.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) }

    let signCount = 0
    let rpIdHash = sha256(Data(rpId.utf8))
    let aaguid = Data(count: 16)
    let attested = concat(
      aaguid,
      be16(UInt16(credentialId.count)),
      credentialId,
      keys.cosePublicKey
    )
    let authenticatorData = concat(
      rpIdHash,
      Data([flagsByte(userPresent: true, userVerified: true, attested: true, backupEligible: true, backupState: true)]),
      be32(UInt32(signCount)),
      attested
    )
    let attestationObject = encodeNoneAttestationObject(authenticatorData)

    let passkey = AutofillPasskeyPayload(
      rpId: rpId,
      credentialId: toB64Url(credentialId),
      userHandle: toB64Url(userHandle),
      privateKeyCipher: toB64Url(keys.privatePkcs8),
      publicKey: toB64Url(keys.cosePublicKey),
      alg: es256Alg,
      signCount: signCount,
      userName: userName,
      displayName: displayName
    )
    return CreateResult(
      passkey: passkey,
      credentialId: credentialId,
      attestationObject: attestationObject
    )
  }

  /// Assert with a system-provided `clientDataHash` (Apple Credential Provider / Android privileged).
  static func assert(
    passkey: AutofillPasskeyPayload,
    clientDataHash: Data
  ) throws -> AssertResult {
    guard let pkcs8B64 = passkey.privateKeyCipher, !pkcs8B64.isEmpty else {
      throw AuthError.missingPrivateKey
    }
    let nextSignCount = (passkey.signCount ?? 0) + 1
    let rpIdHash = sha256(Data(passkey.rpId.utf8))
    let authenticatorData = concat(
      rpIdHash,
      Data([flagsByte(userPresent: true, userVerified: true, attested: false, backupEligible: true, backupState: true)]),
      be32(UInt32(nextSignCount))
    )
    let privateKey = try importPrivateKey(fromB64Url(pkcs8B64))
    let signature = try signAssertion(
      privateKey: privateKey,
      authenticatorData: authenticatorData,
      clientDataHash: clientDataHash
    )
    return AssertResult(
      authenticatorData: authenticatorData,
      signature: signature,
      nextSignCount: nextSignCount,
      userHandle: passkey.userHandle.map { fromB64Url($0) },
      credentialId: fromB64Url(passkey.credentialId)
    )
  }

  /// Browser-style assert: build clientDataJSON then sign.
  static func assertWithOrigin(
    passkey: AutofillPasskeyPayload,
    challengeB64Url: String,
    origin: String
  ) throws -> (AssertResult, clientDataJSON: Data) {
    let clientDataJSON = try buildClientDataJSON(
      type: "webauthn.get",
      challenge: challengeB64Url,
      origin: origin
    )
    let hash = sha256(clientDataJSON)
    let result = try assert(passkey: passkey, clientDataHash: hash)
    return (result, clientDataJSON)
  }

  static func createWithOrigin(
    rpId: String,
    userName: String,
    displayName: String,
    userHandle: Data,
    challengeB64Url: String,
    origin: String
  ) throws -> (CreateResult, clientDataJSON: Data) {
    let created = try create(
      rpId: rpId,
      userName: userName,
      displayName: displayName,
      userHandle: userHandle,
      clientDataHash: nil
    )
    let clientDataJSON = try buildClientDataJSON(
      type: "webauthn.create",
      challenge: challengeB64Url,
      origin: origin
    )
    return (created, clientDataJSON)
  }

  // MARK: - Encoding helpers

  static func toB64Url(_ data: Data) -> String {
    data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }

  static func fromB64Url(_ s: String) -> Data {
    var b64 = s.replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
    let pad = (4 - b64.count % 4) % 4
    if pad > 0 { b64 += String(repeating: "=", count: pad) }
    return Data(base64Encoded: b64) ?? Data()
  }

  // MARK: - Internals

  private struct KeyPair {
    var privatePkcs8: Data
    var cosePublicKey: Data
    var privateKey: SecKey
  }

  private static func generateEs256KeyPair() throws -> KeyPair {
    let attrs: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: false,
      ],
    ]
    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(attrs as CFDictionary, &error),
          let publicKey = SecKeyCopyPublicKey(privateKey)
    else {
      throw AuthError.cryptoFailure
    }
    guard let pkcs8 = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
      throw AuthError.cryptoFailure
    }
    // SecKeyCopyExternalRepresentation for EC private key returns 04||x||y||d (ANSI X9.63).
    // We need PKCS#8 for storage compatibility with the browser extension.
    let privatePkcs8 = try ansiX963ToPkcs8(pkcs8)
    guard let pubRep = SecKeyCopyExternalRepresentation(publicKey, &error) as Data?,
          pubRep.count == 65, pubRep[0] == 0x04
    else {
      throw AuthError.cryptoFailure
    }
    let x = pubRep.subdata(in: 1..<33)
    let y = pubRep.subdata(in: 33..<65)
    return KeyPair(
      privatePkcs8: privatePkcs8,
      cosePublicKey: encodeCoseEs256PublicKey(x: x, y: y),
      privateKey: privateKey
    )
  }

  private static func importPrivateKey(_ pkcs8: Data) throws -> SecKey {
    // Prefer PKCS#8; fall back to raw X9.63 if needed.
    let attrs: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
      kSecAttrKeySizeInBits as String: 256,
    ]
    var error: Unmanaged<CFError>?
    if let key = SecKeyCreateWithData(pkcs8 as CFData, attrs as CFDictionary, &error) {
      return key
    }
    // PKCS#8 wrap → extract raw if needed
    if let raw = try? pkcs8ToAnsiX963(pkcs8),
       let key = SecKeyCreateWithData(raw as CFData, attrs as CFDictionary, &error)
    {
      return key
    }
    throw AuthError.invalidKey
  }

  private static func signAssertion(
    privateKey: SecKey,
    authenticatorData: Data,
    clientDataHash: Data
  ) throws -> Data {
    let toSign = concat(authenticatorData, clientDataHash)
    var error: Unmanaged<CFError>?
    guard let sig = SecKeyCreateSignature(
      privateKey,
      .ecdsaSignatureMessageX962SHA256,
      toSign as CFData,
      &error
    ) as Data?
    else {
      throw AuthError.cryptoFailure
    }
    // SecKey already returns DER for X962; WebAuthn expects DER — good.
    return sig
  }

  private static func sha256(_ data: Data) -> Data {
    Data(SHA256.hash(data: data))
  }

  private static func concat(_ parts: Data...) -> Data {
    parts.reduce(into: Data()) { $0.append($1) }
  }

  private static func be32(_ n: UInt32) -> Data {
    Data([
      UInt8((n >> 24) & 0xff),
      UInt8((n >> 16) & 0xff),
      UInt8((n >> 8) & 0xff),
      UInt8(n & 0xff),
    ])
  }

  private static func be16(_ n: UInt16) -> Data {
    Data([UInt8((n >> 8) & 0xff), UInt8(n & 0xff)])
  }

  private static func flagsByte(
    userPresent: Bool,
    userVerified: Bool,
    attested: Bool,
    backupEligible: Bool,
    backupState: Bool
  ) -> UInt8 {
    var f: UInt8 = 0
    if userPresent { f |= 0x01 }
    if userVerified { f |= 0x04 }
    if backupEligible { f |= 0x08 }
    if backupState { f |= 0x10 }
    if attested { f |= 0x40 }
    return f
  }

  private static func buildClientDataJSON(
    type: String,
    challenge: String,
    origin: String
  ) throws -> Data {
    let obj: [String: Any] = [
      "type": type,
      "challenge": challenge,
      "origin": origin,
      "crossOrigin": false,
    ]
    return try JSONSerialization.data(withJSONObject: obj, options: [])
  }

  // MARK: - CBOR (minimal)

  private static func cborUint(_ n: Int) -> Data {
    if n < 24 { return Data([UInt8(n)]) }
    if n < 256 { return Data([0x18, UInt8(n)]) }
    if n < 65536 {
      return Data([0x19, UInt8((n >> 8) & 0xff), UInt8(n & 0xff)])
    }
    return Data([
      0x1a,
      UInt8((n >> 24) & 0xff),
      UInt8((n >> 16) & 0xff),
      UInt8((n >> 8) & 0xff),
      UInt8(n & 0xff),
    ])
  }

  private static func cborNint(_ n: Int) -> Data {
    let v = -1 - n
    if v < 24 { return Data([UInt8(0x20 | v)]) }
    if v < 256 { return Data([0x38, UInt8(v)]) }
    if v < 65536 {
      return Data([0x39, UInt8((v >> 8) & 0xff), UInt8(v & 0xff)])
    }
    return Data([
      0x3a,
      UInt8((v >> 24) & 0xff),
      UInt8((v >> 16) & 0xff),
      UInt8((v >> 8) & 0xff),
      UInt8(v & 0xff),
    ])
  }

  private static func cborInt(_ n: Int) -> Data {
    n >= 0 ? cborUint(n) : cborNint(n)
  }

  private static func cborBytes(_ data: Data) -> Data {
    let header: Data
    if data.count < 24 {
      header = Data([UInt8(0x40 | data.count)])
    } else if data.count < 256 {
      header = Data([0x58, UInt8(data.count)])
    } else {
      header = Data([0x59, UInt8((data.count >> 8) & 0xff), UInt8(data.count & 0xff)])
    }
    return header + data
  }

  private static func cborText(_ s: String) -> Data {
    let enc = Data(s.utf8)
    let header: Data
    if enc.count < 24 {
      header = Data([UInt8(0x60 | enc.count)])
    } else if enc.count < 256 {
      header = Data([0x78, UInt8(enc.count)])
    } else {
      header = Data([0x79, UInt8((enc.count >> 8) & 0xff), UInt8(enc.count & 0xff)])
    }
    return header + enc
  }

  private static func cborMap(_ entries: [(Any, Data)]) -> Data {
    let header: Data
    if entries.count < 24 {
      header = Data([UInt8(0xa0 | entries.count)])
    } else {
      header = Data([0xb8, UInt8(entries.count)])
    }
    var out = header
    for (k, v) in entries {
      if let n = k as? Int {
        out.append(cborInt(n))
      } else if let s = k as? String {
        out.append(cborText(s))
      }
      out.append(v)
    }
    return out
  }

  private static func encodeCoseEs256PublicKey(x: Data, y: Data) -> Data {
    cborMap([
      (1, cborInt(2)),
      (3, cborInt(-7)),
      (-1, cborInt(1)),
      (-2, cborBytes(x)),
      (-3, cborBytes(y)),
    ])
  }

  private static func encodeNoneAttestationObject(_ authData: Data) -> Data {
    cborMap([
      ("fmt", cborText("none")),
      ("attStmt", cborMap([])),
      ("authData", cborBytes(authData)),
    ])
  }

  private static func derLength(_ n: Int) -> Data {
    if n < 0x80 { return Data([UInt8(n)]) }
    if n < 0x100 { return Data([0x81, UInt8(n)]) }
    return Data([0x82, UInt8((n >> 8) & 0xff), UInt8(n & 0xff)])
  }

  private static func derSeq(_ contents: Data) -> Data {
    Data([0x30]) + derLength(contents.count) + contents
  }

  private static func derOctet(_ contents: Data) -> Data {
    Data([0x04]) + derLength(contents.count) + contents
  }

  /// Wrap ANSI X9.63 private key (04||x||y||d) into PKCS#8.
  private static func ansiX963ToPkcs8(_ raw: Data) throws -> Data {
    guard raw.count == 97, raw[0] == 0x04 else {
      // Already PKCS#8-ish — return as-is.
      if raw.count > 64 { return raw }
      throw AuthError.invalidKey
    }
    let d = raw.subdata(in: 65..<97)
    let oid = Data([0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07])
    let pubBit = Data([0x03, 0x42, 0x00]) + raw.prefix(65)
    var ecPriv = Data([0x02, 0x01, 0x01]) + derOctet(d)
    ecPriv.append(Data([0xa0]) + derLength(oid.count) + oid)
    ecPriv.append(Data([0xa1]) + derLength(pubBit.count) + pubBit)
    let ecSeq = derSeq(ecPriv)

    let algId = Data([
      0x30, 0x13,
      0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01,
      0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07,
    ])
    let version = Data([0x02, 0x01, 0x00])
    let body = version + algId + derOctet(ecSeq)
    return derSeq(body)
  }

  private static func pkcs8ToAnsiX963(_ pkcs8: Data) throws -> Data {
    // Find 32-byte private scalar after OCTET STRING 0x04 0x20 inside ECPrivateKey,
    // and reconstruct 04||x||y||d from public key BIT STRING if present.
    // Simpler path: search for uncompressed point 0x04 followed by 64 bytes near end.
    if let range = pkcs8.range(of: Data([0x04, 0x20])) {
      let dStart = range.upperBound
      guard dStart + 32 <= pkcs8.count else { throw AuthError.invalidKey }
      let d = pkcs8.subdata(in: dStart..<(dStart + 32))
      // Look for public key bitstring: 03 42 00 04 ...
      if let pub = pkcs8.range(of: Data([0x03, 0x42, 0x00, 0x04])) {
        let pointStart = pub.lowerBound + 3
        let point = pkcs8.subdata(in: pointStart..<(pointStart + 65))
        return point + d
      }
      throw AuthError.invalidKey
    }
    throw AuthError.invalidKey
  }
}
