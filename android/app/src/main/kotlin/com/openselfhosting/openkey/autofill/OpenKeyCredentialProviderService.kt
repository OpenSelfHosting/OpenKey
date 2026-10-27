package com.openselfhosting.openkey.autofill

import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.CancellationSignal
import android.os.OutcomeReceiver
import androidx.annotation.RequiresApi
import androidx.credentials.exceptions.ClearCredentialException
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.CreateCredentialUnknownException
import androidx.credentials.exceptions.GetCredentialException
import androidx.credentials.exceptions.GetCredentialUnknownException
import androidx.credentials.provider.BeginCreateCredentialRequest
import androidx.credentials.provider.BeginCreateCredentialResponse
import androidx.credentials.provider.BeginCreatePublicKeyCredentialRequest
import androidx.credentials.provider.BeginGetCredentialRequest
import androidx.credentials.provider.BeginGetCredentialResponse
import androidx.credentials.provider.BeginGetPublicKeyCredentialOption
import androidx.credentials.provider.CreateEntry
import androidx.credentials.provider.CredentialProviderService
import androidx.credentials.provider.ProviderClearCredentialStateRequest
import androidx.credentials.provider.PublicKeyCredentialEntry
import org.json.JSONObject

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
class OpenKeyCredentialProviderService : CredentialProviderService() {
    override fun onBeginGetCredentialRequest(
        request: BeginGetCredentialRequest,
        cancellationSignal: CancellationSignal,
        callback: OutcomeReceiver<BeginGetCredentialResponse, GetCredentialException>,
    ) {
        try {
            if (!AutofillCredentialCache.isUnlocked(this)) {
                callback.onResult(BeginGetCredentialResponse())
                return
            }
            val entries = mutableListOf<PublicKeyCredentialEntry>()
            var reqCode = 2000
            for (option in request.beginGetCredentialOptions) {
                if (option !is BeginGetPublicKeyCredentialOption) continue
                val parsed = parseGetRequest(option.requestJson)
                val matches = AutofillCredentialCache.matchPasskeys(
                    this,
                    rpId = parsed.rpId,
                    allowCredentialIds = parsed.allowCredentialIds,
                )
                for (match in matches) {
                    val intent = Intent(this, PasskeyGetActivity::class.java).apply {
                        putExtra(EXTRA_ENTRY_UUID, match.uuid)
                        putExtra(EXTRA_OPTION_ID, option.id)
                    }
                    val pending = PendingIntent.getActivity(
                        this,
                        reqCode++,
                        intent,
                        PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                    )
                    val userName = match.passkey?.userName?.takeIf { it.isNotEmpty() }
                        ?: match.username.takeIf { it.isNotEmpty() }
                        ?: match.title
                    entries.add(
                        PublicKeyCredentialEntry.Builder(
                            this,
                            userName,
                            pending,
                            option,
                        ).setDisplayName(match.title.ifBlank { match.passkey?.rpId })
                            .build(),
                    )
                }
            }
            callback.onResult(BeginGetCredentialResponse(credentialEntries = entries))
        } catch (e: Exception) {
            callback.onError(GetCredentialUnknownException(e.message))
        }
    }

    override fun onBeginCreateCredentialRequest(
        request: BeginCreateCredentialRequest,
        cancellationSignal: CancellationSignal,
        callback: OutcomeReceiver<BeginCreateCredentialResponse, CreateCredentialException>,
    ) {
        try {
            if (request !is BeginCreatePublicKeyCredentialRequest) {
                callback.onError(CreateCredentialUnknownException("Unsupported create type"))
                return
            }
            if (!AutofillCredentialCache.isUnlocked(this)) {
                callback.onError(CreateCredentialUnknownException("OpenKey vault is locked"))
                return
            }
            val intent = Intent(this, PasskeyCreateActivity::class.java)
            val pending = PendingIntent.getActivity(
                this,
                3100,
                intent,
                PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            val entry = CreateEntry.Builder("OpenKey", pending)
                .setDescription("Save passkey to OpenKey vault")
                .build()
            callback.onResult(
                BeginCreateCredentialResponse(createEntries = listOf(entry)),
            )
        } catch (e: Exception) {
            callback.onError(CreateCredentialUnknownException(e.message))
        }
    }

    override fun onClearCredentialStateRequest(
        request: ProviderClearCredentialStateRequest,
        cancellationSignal: CancellationSignal,
        callback: OutcomeReceiver<Void?, ClearCredentialException>,
    ) {
        callback.onResult(null)
    }

    private data class ParsedGet(
        val rpId: String?,
        val allowCredentialIds: List<String>?,
    )

    private fun parseGetRequest(requestJson: String): ParsedGet {
        return try {
            val obj = JSONObject(requestJson)
            val publicKey = obj.optJSONObject("publicKey") ?: obj
            val rpId = publicKey.optString("rpId").ifEmpty { null }
            val allow = publicKey.optJSONArray("allowCredentials")
            val ids = if (allow == null) {
                null
            } else {
                buildList<String> {
                    for (i in 0 until allow.length()) {
                        val id = allow.getJSONObject(i).optString("id")
                        if (id.isNotEmpty()) add(id)
                    }
                }
            }
            ParsedGet(rpId, ids)
        } catch (_: Exception) {
            ParsedGet(null, null)
        }
    }

    companion object {
        const val EXTRA_ENTRY_UUID = "openkey.passkey.uuid"
        const val EXTRA_OPTION_ID = "openkey.passkey.option_id"
    }
}
