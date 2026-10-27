import Foundation
import CryptoKit
import Security

/// Shared between the main iOS app and the AutoFill Credential Provider extension.
struct AutofillPendingSave: Codable, Equatable {
  var username: String
  var password: String
  var uri: String
  var packageName: String
  /// Optional display title suggested by the system (iOS 26.2+).
  var title: String?

  func asBridgeMap() -> [String: String] {
    var map = [
      "username": username,
      "password": password,
      "uri": uri,
      "package": packageName,
    ]
    if let title, !title.isEmpty {
      map["title"] = title
    }
    return map
  }
}

struct AutofillPasskeyPayload: Codable, Equatable {
  var rpId: String
  var credentialId: String
  var userHandle: String?
  var privateKeyCipher: String?
  var publicKey: String?
  var alg: Int?
  var signCount: Int?
  var userName: String?
  var displayName: String?

  func asBridgeMap() -> [String: Any] {
    var map: [String: Any] = [
      "rpId": rpId,
      "credentialId": credentialId,
    ]
    if let userHandle { map["userHandle"] = userHandle }
    if let privateKeyCipher { map["privateKeyCipher"] = privateKeyCipher }
    if let publicKey { map["publicKey"] = publicKey }
    if let alg { map["alg"] = alg }
    if let signCount { map["signCount"] = signCount }
    if let userName { map["userName"] = userName }
    if let displayName { map["displayName"] = displayName }
    return map
  }

  static func fromBridgeMap(_ map: [String: Any]) -> AutofillPasskeyPayload? {
    guard let rpId = map["rpId"] as? String, !rpId.isEmpty,
          let credentialId = map["credentialId"] as? String, !credentialId.isEmpty
    else { return nil }
    return AutofillPasskeyPayload(
      rpId: rpId,
      credentialId: credentialId,
      userHandle: map["userHandle"] as? String,
      privateKeyCipher: map["privateKeyCipher"] as? String,
      publicKey: map["publicKey"] as? String,
      alg: map["alg"] as? Int ?? Int("\(map["alg"] ?? "")"),
      signCount: map["signCount"] as? Int ?? Int("\(map["signCount"] ?? "")"),
      userName: map["userName"] as? String,
      displayName: map["displayName"] as? String
    )
  }
}

struct AutofillPendingPasskeySave: Codable, Equatable {
  var uuid: String
  var title: String
  var username: String
  var urls: [String]
  var passkey: AutofillPasskeyPayload

  func asBridgeMap() -> [String: Any] {
    [
      "uuid": uuid,
      "title": title,
      "username": username,
      "urls": urls,
      "passkey": passkey.asBridgeMap(),
    ]
  }
}

struct AutofillPendingSignCount: Codable, Equatable {
  var uuid: String
  var signCount: Int

  func asBridgeMap() -> [String: Any] {
    ["uuid": uuid, "signCount": signCount]
  }
}

enum AutofillSharedConfig {
  /// Preferred App Group when the app is signed with a development team.
  static let appGroupId = "group.com.openselfhosting.openkey"
  static let credentialsKey = "openkey.autofill.credentials"
  static let unlockedKey = "openkey.autofill.unlocked"
  static let requireBiometricKey = "openkey.autofill.require_biometric"
  static let pendingSaveKey = "openkey.autofill.pending_save"
  static let pendingUnlockKey = "openkey.autofill.pending_unlock"
  static let pendingPasskeySavesKey = "openkey.autofill.pending_passkey_saves"
  static let pendingSignCountsKey = "openkey.autofill.pending_sign_counts"

  /// Shared-container file when App Groups are provisioned; otherwise a local temp file.
  static var fileURL: URL {
    if let container = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupId
    ) {
      return container.appendingPathComponent("openkey-autofill-creds.json")
    }
    return FileManager.default.temporaryDirectory
      .appendingPathComponent("openkey-autofill-creds.json")
  }

  static var pendingSaveFileURL: URL {
    if let container = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupId
    ) {
      return container.appendingPathComponent("openkey-autofill-pending-save.json")
    }
    return FileManager.default.temporaryDirectory
      .appendingPathComponent("openkey-autofill-pending-save.json")
  }
}

struct AutofillCredentialRecord: Codable, Equatable {
  var uuid: String
  var title: String
  var username: String
  var password: String
  var urls: [String]
  var passkey: AutofillPasskeyPayload?

  var hasPasswordLogin: Bool {
    !username.isEmpty || !password.isEmpty
  }

  var hasUsablePasskey: Bool {
    guard let passkey else { return false }
    return !(passkey.privateKeyCipher?.isEmpty ?? true)
  }
}

private struct AutofillDiskPayload: Codable {
  var unlocked: Bool
  var credentials: [AutofillCredentialRecord]
}

enum AutofillCredentialStore {
  private static var defaults: UserDefaults? {
    UserDefaults(suiteName: AutofillSharedConfig.appGroupId)
  }

  static var isUnlocked: Bool {
    if let defaults, defaults.object(forKey: AutofillSharedConfig.unlockedKey) != nil {
      return defaults.bool(forKey: AutofillSharedConfig.unlockedKey)
    }
    return loadDisk()?.unlocked ?? false
  }

  static var requireBiometric: Bool {
    defaults?.bool(forKey: AutofillSharedConfig.requireBiometricKey) ?? false
  }

  static func setRequireBiometric(_ value: Bool) {
    guard let defaults else { return }
    defaults.set(value, forKey: AutofillSharedConfig.requireBiometricKey)
    defaults.synchronize()
  }

  static func loadCredentials() -> [AutofillCredentialRecord] {
    guard isUnlocked else { return [] }
    if let defaults,
       let data = defaults.data(forKey: AutofillSharedConfig.credentialsKey),
       let decoded = try? JSONDecoder().decode([AutofillCredentialRecord].self, from: data)
    {
      return decoded
    }
    return loadDisk()?.credentials ?? []
  }

  static func sync(credentials: [AutofillCredentialRecord]) {
    if let defaults {
      defaults.set(true, forKey: AutofillSharedConfig.unlockedKey)
      if let data = try? JSONEncoder().encode(credentials) {
        defaults.set(data, forKey: AutofillSharedConfig.credentialsKey)
      }
      defaults.synchronize()
    }
    writeDisk(AutofillDiskPayload(unlocked: true, credentials: credentials))
  }

  static func clear() {
    let keepBiometric = requireBiometric
    if let defaults {
      defaults.set(false, forKey: AutofillSharedConfig.unlockedKey)
      defaults.removeObject(forKey: AutofillSharedConfig.credentialsKey)
      defaults.synchronize()
    }
    writeDisk(AutofillDiskPayload(unlocked: false, credentials: []))
    if keepBiometric {
      setRequireBiometric(true)
    }
  }

  static func upsertPasskey(_ record: AutofillCredentialRecord) {
    var all = loadCredentials()
    if let idx = all.firstIndex(where: { $0.uuid == record.uuid }) {
      all[idx] = record
    } else if let credId = record.passkey?.credentialId,
              let idx = all.firstIndex(where: { $0.passkey?.credentialId == credId })
    {
      all[idx] = record
    } else {
      all.append(record)
    }
    sync(credentials: all)
  }

  static func updatePasskeySignCount(uuid: String, signCount: Int) {
    var all = loadCredentials()
    guard let idx = all.firstIndex(where: { $0.uuid == uuid }),
          var pk = all[idx].passkey
    else { return }
    pk.signCount = signCount
    all[idx].passkey = pk
    sync(credentials: all)
    enqueueSignCountUpdate(AutofillPendingSignCount(uuid: uuid, signCount: signCount))
  }

  // MARK: - Pending save / unlock (mirrors Android Autofill handoff)

  static func setPendingSave(_ save: AutofillPendingSave) {
    if let defaults, let data = try? JSONEncoder().encode(save) {
      defaults.set(data, forKey: AutofillSharedConfig.pendingSaveKey)
      defaults.synchronize()
    }
    if let data = try? JSONEncoder().encode(save) {
      try? data.write(to: AutofillSharedConfig.pendingSaveFileURL, options: .atomic)
    }
  }

  static func takePendingSave() -> AutofillPendingSave? {
    var save: AutofillPendingSave?
    if let defaults,
       let data = defaults.data(forKey: AutofillSharedConfig.pendingSaveKey)
    {
      save = try? JSONDecoder().decode(AutofillPendingSave.self, from: data)
      defaults.removeObject(forKey: AutofillSharedConfig.pendingSaveKey)
      defaults.synchronize()
    }
    if save == nil,
       let data = try? Data(contentsOf: AutofillSharedConfig.pendingSaveFileURL)
    {
      save = try? JSONDecoder().decode(AutofillPendingSave.self, from: data)
    }
    try? FileManager.default.removeItem(at: AutofillSharedConfig.pendingSaveFileURL)
    return save
  }

  static func setPendingUnlock(_ value: Bool) {
    if let defaults {
      defaults.set(value, forKey: AutofillSharedConfig.pendingUnlockKey)
      defaults.synchronize()
    }
  }

  static func takePendingUnlock() -> Bool {
    guard let defaults else { return false }
    let value = defaults.bool(forKey: AutofillSharedConfig.pendingUnlockKey)
    defaults.set(false, forKey: AutofillSharedConfig.pendingUnlockKey)
    defaults.synchronize()
    return value
  }

  static func enqueuePasskeySave(_ save: AutofillPendingPasskeySave) {
    var list = loadPendingPasskeySaves()
    list.removeAll { $0.passkey.credentialId == save.passkey.credentialId }
    list.append(save)
    savePendingPasskeySaves(list)
  }

  static func takePendingPasskeySaves() -> [AutofillPendingPasskeySave] {
    let list = loadPendingPasskeySaves()
    savePendingPasskeySaves([])
    return list
  }

  static func enqueueSignCountUpdate(_ bump: AutofillPendingSignCount) {
    var list = loadPendingSignCounts()
    list.removeAll { $0.uuid == bump.uuid }
    list.append(bump)
    savePendingSignCounts(list)
  }

  static func takePendingSignCountUpdates() -> [AutofillPendingSignCount] {
    let list = loadPendingSignCounts()
    savePendingSignCounts([])
    return list
  }

  /// Match website hosts against stored URLs. Does not dump the whole vault.
  static func match(serviceIdentifiers: [String]) -> [AutofillCredentialRecord] {
    let hosts = serviceIdentifiers.compactMap { normalizeHost(from: $0) }
    guard !hosts.isEmpty else { return [] }

    let all = loadCredentials()
    var exact: [AutofillCredentialRecord] = []
    var fuzzy: [AutofillCredentialRecord] = []

    for credential in all {
      if !credential.hasPasswordLogin { continue }
      var matchedExact = false
      var matchedFuzzy = false
      for raw in credential.urls {
        guard let host = hostFromUrl(raw) else { continue }
        for serviceHost in hosts {
          if host == serviceHost {
            matchedExact = true
            break
          }
          if serviceHost.hasSuffix(".\(host)") {
            matchedFuzzy = true
          }
        }
        if matchedExact { break }
      }
      if matchedExact {
        exact.append(credential)
      } else if matchedFuzzy {
        fuzzy.append(credential)
      }
    }
    return exact + fuzzy
  }

  /// Match passkeys by relying party ID against service hosts / rpId.
  static func matchPasskeys(rpId: String?, serviceIdentifiers: [String]) -> [AutofillCredentialRecord] {
    let all = loadCredentials().filter(\.hasUsablePasskey)
    let hosts = serviceIdentifiers.compactMap { normalizeHost(from: $0) }
    let rp = rpId.flatMap { normalizeHost(from: $0) }

    return all.filter { record in
      guard let stored = record.passkey.flatMap({ normalizeHost(from: $0.rpId) }) else {
        return false
      }
      if let rp, stored == rp || rp.hasSuffix(".\(stored)") {
        return true
      }
      for host in hosts {
        if stored == host || host.hasSuffix(".\(stored)") {
          return true
        }
      }
      return false
    }
  }

  private static func loadPendingPasskeySaves() -> [AutofillPendingPasskeySave] {
    guard let defaults,
          let data = defaults.data(forKey: AutofillSharedConfig.pendingPasskeySavesKey),
          let decoded = try? JSONDecoder().decode([AutofillPendingPasskeySave].self, from: data)
    else { return [] }
    return decoded
  }

  private static func savePendingPasskeySaves(_ list: [AutofillPendingPasskeySave]) {
    guard let defaults else { return }
    if let data = try? JSONEncoder().encode(list) {
      defaults.set(data, forKey: AutofillSharedConfig.pendingPasskeySavesKey)
    } else {
      defaults.removeObject(forKey: AutofillSharedConfig.pendingPasskeySavesKey)
    }
    defaults.synchronize()
  }

  private static func loadPendingSignCounts() -> [AutofillPendingSignCount] {
    guard let defaults,
          let data = defaults.data(forKey: AutofillSharedConfig.pendingSignCountsKey),
          let decoded = try? JSONDecoder().decode([AutofillPendingSignCount].self, from: data)
    else { return [] }
    return decoded
  }

  private static func savePendingSignCounts(_ list: [AutofillPendingSignCount]) {
    guard let defaults else { return }
    if let data = try? JSONEncoder().encode(list) {
      defaults.set(data, forKey: AutofillSharedConfig.pendingSignCountsKey)
    } else {
      defaults.removeObject(forKey: AutofillSharedConfig.pendingSignCountsKey)
    }
    defaults.synchronize()
  }

  private static func loadDisk() -> AutofillDiskPayload? {
    if let encrypted = try? Data(contentsOf: AutofillSharedConfig.fileURL) {
      if let payload = decryptDiskPayload(encrypted) {
        return payload
      }
      if let legacy = try? JSONDecoder().decode(AutofillDiskPayload.self, from: encrypted) {
        writeDisk(legacy)
        return legacy
      }
    }
    return nil
  }

  private static func writeDisk(_ payload: AutofillDiskPayload) {
    guard let json = try? JSONEncoder().encode(payload),
          let encrypted = encryptDiskPayload(json)
    else { return }
    try? encrypted.write(to: AutofillSharedConfig.fileURL, options: .atomic)
  }

  private static let diskKeychainAccount = "openkey.autofill.disk.encryption.key"

  private static func diskEncryptionKey() -> SymmetricKey {
    if let data = readKeychainData(account: diskKeychainAccount) {
      return SymmetricKey(data: data)
    }
    let key = SymmetricKey(size: .bits256)
    let data = key.withUnsafeBytes { Data($0) }
    writeKeychainData(account: diskKeychainAccount, data: data)
    return key
  }

  private static func encryptDiskPayload(_ data: Data) -> Data? {
    guard let sealed = try? AES.GCM.seal(data, using: diskEncryptionKey()) else {
      return nil
    }
    return sealed.combined
  }

  private static func decryptDiskPayload(_ data: Data) -> AutofillDiskPayload? {
    guard let sealed = try? AES.GCM.SealedBox(combined: data),
          let json = try? AES.GCM.open(sealed, using: diskEncryptionKey()),
          let payload = try? JSONDecoder().decode(AutofillDiskPayload.self, from: json)
    else { return nil }
    return payload
  }

  private static func readKeychainData(account: String) -> Data? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecAttrService as String: "com.openselfhosting.openkey.autofill",
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status == errSecSuccess, let data = item as? Data else { return nil }
    return data
  }

  private static func writeKeychainData(account: String, data: Data) {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrAccount as String: account,
      kSecAttrService as String: "com.openselfhosting.openkey.autofill",
    ]
    let attrs: [String: Any] = [
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
    ]
    if SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess {
      SecItemUpdate(query as CFDictionary, attrs as CFDictionary)
    } else {
      let add = query.merging(attrs) { _, new in new }
      SecItemAdd(add as CFDictionary, nil)
    }
  }

  private static func hostFromUrl(_ raw: String) -> String? {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty { return nil }
    if trimmed.lowercased().hasPrefix("androidapp://") { return nil }
    let withScheme = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
    guard let components = URLComponents(string: withScheme),
          let host = components.host
    else {
      return nil
    }
    return normalizeHost(from: host)
  }

  private static func normalizeHost(from value: String) -> String? {
    var host = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    while host.hasPrefix(".") { host.removeFirst() }
    while host.hasSuffix(".") { host.removeLast() }
    if host.hasPrefix("www.") {
      host = String(host.dropFirst(4))
    }
    return host.isEmpty ? nil : host
  }
}

enum AutofillPasswordGenerator {
  static func generate(length: Int = 20) -> String {
    let lower = "abcdefghijklmnopqrstuvwxyz"
    let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let digits = "0123456789"
    let symbols = "!@#$%^&*()-_=+[]{};:,.?"
    let sets = [lower, upper, digits, symbols]
    let size = max(length, sets.count)
    var chars: [Character] = []
    chars.reserveCapacity(size)
    for set in sets {
      chars.append(set.randomElement()!)
    }
    let pool = sets.joined()
    while chars.count < size {
      chars.append(pool.randomElement()!)
    }
    chars.shuffle()
    return String(chars)
  }
}
