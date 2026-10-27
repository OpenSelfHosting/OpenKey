package com.openselfhosting.openkey.autofill

import org.json.JSONArray
import org.json.JSONObject
import java.math.BigInteger
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.MessageDigest
import java.security.SecureRandom
import java.security.Signature
import java.security.interfaces.ECPrivateKey
import java.security.interfaces.ECPublicKey
import java.security.spec.ECGenParameterSpec
import java.security.spec.ECPoint
import java.security.spec.PKCS8EncodedKeySpec
import java.util.Base64

/** Software WebAuthn authenticator (ES256) matching the browser extension. */
object PasskeyAuthenticator {
    const val ES256_ALG = -7

    data class PasskeyPayload(
        val rpId: String,
        val credentialId: String,
        val userHandle: String? = null,
        val privateKeyCipher: String? = null,
        val publicKey: String? = null,
        val alg: Int? = ES256_ALG,
        val signCount: Int? = 0,
        val userName: String? = null,
        val displayName: String? = null,
    ) {
        fun toJson(): JSONObject = JSONObject().apply {
            put("rpId", rpId)
            put("credentialId", credentialId)
            if (userHandle != null) put("userHandle", userHandle)
            if (privateKeyCipher != null) put("privateKeyCipher", privateKeyCipher)
            if (publicKey != null) put("publicKey", publicKey)
            if (alg != null) put("alg", alg)
            if (signCount != null) put("signCount", signCount)
            if (userName != null) put("userName", userName)
            if (displayName != null) put("displayName", displayName)
        }

        companion object {
            fun fromJson(obj: JSONObject?): PasskeyPayload? {
                if (obj == null) return null
                val rpId = obj.optString("rpId")
                val credentialId = obj.optString("credentialId")
                if (rpId.isEmpty() || credentialId.isEmpty()) return null
                return PasskeyPayload(
                    rpId = rpId,
                    credentialId = credentialId,
                    userHandle = obj.optString("userHandle").ifEmpty { null },
                    privateKeyCipher = obj.optString("privateKeyCipher").ifEmpty { null },
                    publicKey = obj.optString("publicKey").ifEmpty { null },
                    alg = if (obj.has("alg")) obj.optInt("alg") else ES256_ALG,
                    signCount = if (obj.has("signCount")) obj.optInt("signCount") else 0,
                    userName = obj.optString("userName").ifEmpty { null },
                    displayName = obj.optString("displayName").ifEmpty { null },
                )
            }
        }
    }

    data class CreateResult(
        val passkey: PasskeyPayload,
        val credentialId: ByteArray,
        val attestationObject: ByteArray,
        val clientDataJSON: ByteArray?,
    )

    data class AssertResult(
        val authenticatorData: ByteArray,
        val signature: ByteArray,
        val nextSignCount: Int,
        val userHandle: ByteArray?,
        val credentialId: ByteArray,
        val clientDataJSON: ByteArray?,
    )

    fun create(
        rpId: String,
        userName: String,
        displayName: String,
        userHandle: ByteArray,
        challengeB64Url: String?,
        origin: String?,
        clientDataHash: ByteArray?,
    ): CreateResult {
        val kpg = KeyPairGenerator.getInstance("EC")
        kpg.initialize(ECGenParameterSpec("secp256r1"), SecureRandom())
        val pair = kpg.generateKeyPair()
        val privateKey = pair.private as ECPrivateKey
        val publicKey = pair.public as ECPublicKey

        val credentialId = ByteArray(32).also { SecureRandom().nextBytes(it) }
        val privatePkcs8 = privateKey.encoded
        val cosePublicKey = encodeCoseEs256PublicKey(publicKey.w)

        val signCount = 0
        val rpIdHash = sha256(rpId.toByteArray(Charsets.UTF_8))
        val aaguid = ByteArray(16)
        val attested = concat(
            aaguid,
            be16(credentialId.size),
            credentialId,
            cosePublicKey,
        )
        val authenticatorData = concat(
            rpIdHash,
            byteArrayOf(
                flagsByte(
                    userPresent = true,
                    userVerified = true,
                    attested = true,
                    backupEligible = true,
                    backupState = true,
                ),
            ),
            be32(signCount),
            attested,
        )
        val attestationObject = encodeNoneAttestationObject(authenticatorData)
        val clientDataJSON = if (clientDataHash == null && challengeB64Url != null && origin != null) {
            buildClientDataJSON("webauthn.create", challengeB64Url, origin)
        } else {
            null
        }

        val passkey = PasskeyPayload(
            rpId = rpId,
            credentialId = toB64Url(credentialId),
            userHandle = toB64Url(userHandle),
            privateKeyCipher = toB64Url(privatePkcs8),
            publicKey = toB64Url(cosePublicKey),
            alg = ES256_ALG,
            signCount = signCount,
            userName = userName,
            displayName = displayName,
        )
        return CreateResult(passkey, credentialId, attestationObject, clientDataJSON)
    }

    fun assert(
        passkey: PasskeyPayload,
        clientDataHash: ByteArray,
        clientDataJSON: ByteArray? = null,
    ): AssertResult {
        val pkcs8 = fromB64Url(
            passkey.privateKeyCipher ?: error("Passkey has no private key"),
        )
        val nextSignCount = (passkey.signCount ?: 0) + 1
        val rpIdHash = sha256(passkey.rpId.toByteArray(Charsets.UTF_8))
        val authenticatorData = concat(
            rpIdHash,
            byteArrayOf(
                flagsByte(
                    userPresent = true,
                    userVerified = true,
                    attested = false,
                    backupEligible = true,
                    backupState = true,
                ),
            ),
            be32(nextSignCount),
        )
        val signature = signAssertion(pkcs8, authenticatorData, clientDataHash)
        return AssertResult(
            authenticatorData = authenticatorData,
            signature = signature,
            nextSignCount = nextSignCount,
            userHandle = passkey.userHandle?.let { fromB64Url(it) },
            credentialId = fromB64Url(passkey.credentialId),
            clientDataJSON = clientDataJSON,
        )
    }

    fun assertWithOrigin(
        passkey: PasskeyPayload,
        challengeB64Url: String,
        origin: String,
    ): AssertResult {
        val clientDataJSON = buildClientDataJSON("webauthn.get", challengeB64Url, origin)
        val hash = sha256(clientDataJSON)
        return assert(passkey, hash, clientDataJSON)
    }

    fun toB64Url(bytes: ByteArray): String =
        Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)

    fun fromB64Url(s: String): ByteArray {
        var b64 = s.replace('-', '+').replace('_', '/')
        val pad = (4 - b64.length % 4) % 4
        if (pad > 0) b64 += "=".repeat(pad)
        return Base64.getDecoder().decode(b64)
    }

    fun buildPublicKeyCredentialJson(
        id: String,
        rawId: ByteArray,
        clientDataJSON: ByteArray,
        authenticatorData: ByteArray? = null,
        signature: ByteArray? = null,
        userHandle: ByteArray? = null,
        attestationObject: ByteArray? = null,
        publicKey: ByteArray? = null,
    ): String {
        val response = JSONObject()
        response.put("clientDataJSON", toB64Url(clientDataJSON))
        if (attestationObject != null) {
            response.put("attestationObject", toB64Url(attestationObject))
            if (publicKey != null) {
                response.put("publicKey", toB64Url(publicKey))
                response.put("publicKeyAlgorithm", ES256_ALG)
            }
            response.put("transports", JSONArray(listOf("internal", "hybrid")))
        }
        if (authenticatorData != null) response.put("authenticatorData", toB64Url(authenticatorData))
        if (signature != null) response.put("signature", toB64Url(signature))
        if (userHandle != null) {
            response.put("userHandle", toB64Url(userHandle))
        } else if (authenticatorData != null) {
            response.put("userHandle", JSONObject.NULL)
        }
        return JSONObject()
            .put("id", id)
            .put("rawId", toB64Url(rawId))
            .put("type", "public-key")
            .put("authenticatorAttachment", "cross-platform")
            .put("clientExtensionResults", JSONObject())
            .put("response", response)
            .toString()
    }

    private fun signAssertion(
        pkcs8: ByteArray,
        authenticatorData: ByteArray,
        clientDataHash: ByteArray,
    ): ByteArray {
        val key = KeyFactory.getInstance("EC")
            .generatePrivate(PKCS8EncodedKeySpec(pkcs8)) as ECPrivateKey
        val toSign = concat(authenticatorData, clientDataHash)
        val sig = Signature.getInstance("SHA256withECDSA")
        sig.initSign(key)
        sig.update(toSign)
        return sig.sign() // DER
    }

    private fun buildClientDataJSON(type: String, challenge: String, origin: String): ByteArray {
        val json = JSONObject()
            .put("type", type)
            .put("challenge", challenge)
            .put("origin", origin)
            .put("crossOrigin", false)
            .toString()
        return json.toByteArray(Charsets.UTF_8)
    }

    private fun sha256(data: ByteArray): ByteArray =
        MessageDigest.getInstance("SHA-256").digest(data)

    private fun concat(vararg parts: ByteArray): ByteArray {
        val out = ByteArray(parts.sumOf { it.size })
        var off = 0
        for (p in parts) {
            System.arraycopy(p, 0, out, off, p.size)
            off += p.size
        }
        return out
    }

    private fun be32(n: Int): ByteArray = byteArrayOf(
        ((n ushr 24) and 0xff).toByte(),
        ((n ushr 16) and 0xff).toByte(),
        ((n ushr 8) and 0xff).toByte(),
        (n and 0xff).toByte(),
    )

    private fun be16(n: Int): ByteArray = byteArrayOf(
        ((n ushr 8) and 0xff).toByte(),
        (n and 0xff).toByte(),
    )

    private fun flagsByte(
        userPresent: Boolean,
        userVerified: Boolean,
        attested: Boolean,
        backupEligible: Boolean,
        backupState: Boolean,
    ): Byte {
        var f = 0
        if (userPresent) f = f or 0x01
        if (userVerified) f = f or 0x04
        if (backupEligible) f = f or 0x08
        if (backupState) f = f or 0x10
        if (attested) f = f or 0x40
        return f.toByte()
    }

    private fun encodeCoseEs256PublicKey(point: ECPoint): ByteArray {
        val x = bigIntToFixed(point.affineX, 32)
        val y = bigIntToFixed(point.affineY, 32)
        return cborMap(
            listOf(
                1 to cborInt(2),
                3 to cborInt(-7),
                -1 to cborInt(1),
                -2 to cborBytes(x),
                -3 to cborBytes(y),
            ),
        )
    }

    private fun encodeNoneAttestationObject(authData: ByteArray): ByteArray =
        cborMap(
            listOf(
                "fmt" to cborText("none"),
                "attStmt" to cborMap(emptyList()),
                "authData" to cborBytes(authData),
            ),
        )

    private fun bigIntToFixed(v: BigInteger, size: Int): ByteArray {
        var bytes = v.toByteArray()
        if (bytes.size > size && bytes[0] == 0.toByte()) {
            bytes = bytes.copyOfRange(1, bytes.size)
        }
        if (bytes.size > size) return bytes.copyOfRange(bytes.size - size, bytes.size)
        if (bytes.size == size) return bytes
        val out = ByteArray(size)
        System.arraycopy(bytes, 0, out, size - bytes.size, bytes.size)
        return out
    }

    private fun cborUint(n: Int): ByteArray = when {
        n < 24 -> byteArrayOf(n.toByte())
        n < 256 -> byteArrayOf(0x18, n.toByte())
        n < 65536 -> byteArrayOf(0x19, ((n shr 8) and 0xff).toByte(), (n and 0xff).toByte())
        else -> byteArrayOf(
            0x1a,
            ((n ushr 24) and 0xff).toByte(),
            ((n ushr 16) and 0xff).toByte(),
            ((n ushr 8) and 0xff).toByte(),
            (n and 0xff).toByte(),
        )
    }

    private fun cborNint(n: Int): ByteArray {
        val v = -1 - n
        return when {
            v < 24 -> byteArrayOf((0x20 or v).toByte())
            v < 256 -> byteArrayOf(0x38, v.toByte())
            else -> byteArrayOf(0x39, ((v shr 8) and 0xff).toByte(), (v and 0xff).toByte())
        }
    }

    private fun cborInt(n: Int): ByteArray = if (n >= 0) cborUint(n) else cborNint(n)

    private fun cborBytes(data: ByteArray): ByteArray {
        val header = when {
            data.size < 24 -> byteArrayOf((0x40 or data.size).toByte())
            data.size < 256 -> byteArrayOf(0x58, data.size.toByte())
            else -> byteArrayOf(0x59, ((data.size shr 8) and 0xff).toByte(), (data.size and 0xff).toByte())
        }
        return concat(header, data)
    }

    private fun cborText(s: String): ByteArray {
        val enc = s.toByteArray(Charsets.UTF_8)
        val header = when {
            enc.size < 24 -> byteArrayOf((0x60 or enc.size).toByte())
            enc.size < 256 -> byteArrayOf(0x78, enc.size.toByte())
            else -> byteArrayOf(0x79, ((enc.size shr 8) and 0xff).toByte(), (enc.size and 0xff).toByte())
        }
        return concat(header, enc)
    }

    private fun cborMap(entries: List<Pair<Any, ByteArray>>): ByteArray {
        val header = if (entries.size < 24) {
            byteArrayOf((0xa0 or entries.size).toByte())
        } else {
            byteArrayOf(0xb8.toByte(), entries.size.toByte())
        }
        var out = header
        for ((k, v) in entries) {
            out = concat(
                out,
                when (k) {
                    is Int -> cborInt(k)
                    is String -> cborText(k)
                    else -> error("bad cbor key")
                },
                v,
            )
        }
        return out
    }
}
