package com.openselfhosting.openkey.autofill

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.annotation.RequiresApi
import androidx.credentials.GetCredentialResponse
import androidx.credentials.PublicKeyCredential
import androidx.credentials.provider.PendingIntentHandler
import org.json.JSONObject

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
class PasskeyGetActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            val providerRequest = PendingIntentHandler.retrieveProviderGetCredentialRequest(intent)
                ?: error("Missing get credential request")
            val uuid = intent.getStringExtra(OpenKeyCredentialProviderService.EXTRA_ENTRY_UUID)
            val match = AutofillCredentialCache.credentials(this)
                .firstOrNull { it.uuid == uuid && it.hasUsablePasskey }
                ?: error("Passkey not found")
            val passkey = match.passkey!!

            val option = providerRequest.credentialOptions
                .filterIsInstance<androidx.credentials.GetPublicKeyCredentialOption>()
                .firstOrNull()
                ?: error("No public key option")

            val requestJson = JSONObject(option.requestJson)
            val publicKey = requestJson.optJSONObject("publicKey") ?: requestJson
            val challenge = publicKey.optString("challenge")
            val clientDataHash = option.clientDataHash
            val origin = CallingAppOrigin.resolve(
                this,
                providerRequest.callingAppInfo,
                passkey.rpId,
            )

            val asserted = if (clientDataHash != null) {
                PasskeyAuthenticator.assert(passkey, clientDataHash)
            } else {
                PasskeyAuthenticator.assertWithOrigin(passkey, challenge, origin)
            }

            AutofillCredentialCache.updatePasskeySignCount(
                this,
                match.uuid,
                asserted.nextSignCount,
            )

            val clientDataJSON = asserted.clientDataJSON
                ?: // Privileged flow: placeholder clientDataJSON; hash was provided.
                "{}".toByteArray(Charsets.UTF_8)

            val responseJson = PasskeyAuthenticator.buildPublicKeyCredentialJson(
                id = passkey.credentialId,
                rawId = asserted.credentialId,
                clientDataJSON = clientDataJSON,
                authenticatorData = asserted.authenticatorData,
                signature = asserted.signature,
                userHandle = asserted.userHandle,
            )

            val result = Intent()
            PendingIntentHandler.setGetCredentialResponse(
                result,
                GetCredentialResponse(PublicKeyCredential(responseJson)),
            )
            setResult(RESULT_OK, result)
        } catch (e: Exception) {
            val result = Intent()
            PendingIntentHandler.setGetCredentialException(
                result,
                androidx.credentials.exceptions.GetCredentialUnknownException(e.message),
            )
            setResult(RESULT_OK, result)
        }
        finish()
    }
}
