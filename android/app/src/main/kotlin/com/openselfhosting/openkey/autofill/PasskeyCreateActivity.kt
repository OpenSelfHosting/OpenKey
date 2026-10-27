package com.openselfhosting.openkey.autofill

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.RequiresApi
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CreatePublicKeyCredentialResponse
import androidx.credentials.provider.PendingIntentHandler
import org.json.JSONObject
import java.util.UUID

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
class PasskeyCreateActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            val providerRequest =
                PendingIntentHandler.retrieveProviderCreateCredentialRequest(intent)
                    ?: error("Missing create credential request")
            val calling = providerRequest.callingRequest
            if (calling !is CreatePublicKeyCredentialRequest) {
                error("Unsupported create request")
            }

            val requestJson = JSONObject(calling.requestJson)
            val publicKey = requestJson.optJSONObject("publicKey") ?: requestJson
            val rp = publicKey.optJSONObject("rp") ?: JSONObject()
            val user = publicKey.optJSONObject("user") ?: JSONObject()
            val rpId = rp.optString("id").ifEmpty {
                CallingAppOrigin.webHostOrNull(this, providerRequest.callingAppInfo).orEmpty()
            }
            val userName = user.optString("name").ifEmpty { "user" }
            val displayName = user.optString("displayName").ifEmpty { userName }
            val userIdB64 = user.optString("id")
            val userHandle = if (userIdB64.isNotEmpty()) {
                PasskeyAuthenticator.fromB64Url(userIdB64)
            } else {
                ByteArray(16).also { java.security.SecureRandom().nextBytes(it) }
            }
            val challenge = publicKey.optString("challenge")
            val origin = CallingAppOrigin.resolve(this, providerRequest.callingAppInfo, rpId)
            val clientDataHash = calling.clientDataHash

            val created = PasskeyAuthenticator.create(
                rpId = rpId,
                userName = userName,
                displayName = displayName,
                userHandle = userHandle,
                challengeB64Url = challenge.ifEmpty { null },
                origin = origin,
                clientDataHash = clientDataHash,
            )

            val uuid = UUID.randomUUID().toString()
            val credential = AutofillCredential(
                uuid = uuid,
                title = rpId,
                username = userName,
                password = "",
                urls = listOf("https://$rpId"),
                passkey = created.passkey,
            )
            AutofillCredentialCache.upsertPasskey(this, credential)
            AutofillCredentialCache.enqueuePasskeySave(
                this,
                JSONObject()
                    .put("uuid", uuid)
                    .put("title", rpId)
                    .put("username", userName)
                    .put("urls", org.json.JSONArray(listOf("https://$rpId")))
                    .put("passkey", created.passkey.toJson()),
            )

            // Notify main app to persist when it next wakes.
            startActivity(
                Intent(this, com.openselfhosting.openkey.MainActivity::class.java).apply {
                    action = com.openselfhosting.openkey.MainActivity.ACTION_AUTOFILL_PASSKEY
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                },
            )

            val clientDataJSON = created.clientDataJSON
                ?: "{}".toByteArray(Charsets.UTF_8)
            val responseJson = PasskeyAuthenticator.buildPublicKeyCredentialJson(
                id = created.passkey.credentialId,
                rawId = created.credentialId,
                clientDataJSON = clientDataJSON,
                attestationObject = created.attestationObject,
                publicKey = PasskeyAuthenticator.fromB64Url(created.passkey.publicKey ?: ""),
            )

            val result = Intent()
            PendingIntentHandler.setCreateCredentialResponse(
                result,
                CreatePublicKeyCredentialResponse(responseJson),
            )
            setResult(RESULT_OK, result)
        } catch (e: Exception) {
            val result = Intent()
            PendingIntentHandler.setCreateCredentialException(
                result,
                androidx.credentials.exceptions.CreateCredentialUnknownException(e.message),
            )
            setResult(RESULT_OK, result)
        }
        finish()
    }
}
