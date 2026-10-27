package com.openselfhosting.openkey.autofill

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Hot cache of vault logins for Autofill + Credential Provider.
 *
 * Flutter writes via MethodChannel when the vault unlocks and clears on lock.
 */
object AutofillCredentialCache {
    private const val PREFS_NAME = "openkey_autofill_creds"
    private const val KEY_CREDENTIALS = "credentials"
    private const val KEY_UNLOCKED = "unlocked"
    private const val KEY_REQUIRE_BIOMETRIC = "require_biometric"
    private const val KEY_SHOW_INLINE = "show_inline"
    private const val KEY_SHOW_POPUP = "show_popup"
    private const val KEY_PENDING_PASSKEY_SAVES = "pending_passkey_saves"
    private const val KEY_PENDING_SIGN_COUNTS = "pending_sign_counts"

    private val memory = CopyOnWriteArrayList<AutofillCredential>()
    @Volatile
    private var sessionUnlocked: Boolean = false

    private fun prefs(context: Context): SharedPreferences {
        val masterKey = MasterKey.Builder(context.applicationContext)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()
        return EncryptedSharedPreferences.create(
            context.applicationContext,
            PREFS_NAME,
            masterKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
        )
    }

    fun isUnlocked(context: Context): Boolean {
        if (sessionUnlocked && memory.isNotEmpty()) return true
        return try {
            prefs(context).getBoolean(KEY_UNLOCKED, false) && loadFromPrefs(context).isNotEmpty()
        } catch (_: Exception) {
            false
        }
    }

    fun requireBiometric(context: Context): Boolean {
        return try {
            prefs(context).getBoolean(KEY_REQUIRE_BIOMETRIC, false)
        } catch (_: Exception) {
            false
        }
    }

    fun setRequireBiometric(context: Context, value: Boolean) {
        try {
            prefs(context).edit().putBoolean(KEY_REQUIRE_BIOMETRIC, value).apply()
        } catch (_: Exception) {
        }
    }

    /** Suggestions in the IME / keyboard strip. Defaults to on. */
    fun showInline(context: Context): Boolean {
        return try {
            prefs(context).getBoolean(KEY_SHOW_INLINE, false)
        } catch (_: Exception) {
            false
        }
    }

    /** Dropdown / fill dialog over the input field. Defaults to on. */
    fun showPopup(context: Context): Boolean {
        return try {
            prefs(context).getBoolean(KEY_SHOW_POPUP, true)
        } catch (_: Exception) {
            true
        }
    }

    fun setPresentation(context: Context, inline: Boolean, popup: Boolean) {
        var showPopup = popup
        var showInline = if (showPopup) false else inline
        if (!showInline && !showPopup) showPopup = true
        try {
            prefs(context).edit()
                .putBoolean(KEY_SHOW_INLINE, showInline)
                .putBoolean(KEY_SHOW_POPUP, showPopup)
                .apply()
        } catch (_: Exception) {
        }
    }

    fun hasCredentials(context: Context): Boolean = credentials(context).isNotEmpty()

    fun credentials(context: Context): List<AutofillCredential> {
        if (memory.isNotEmpty()) return memory.toList()
        val loaded = loadFromPrefs(context)
        if (loaded.isNotEmpty()) {
            memory.clear()
            memory.addAll(loaded)
            sessionUnlocked = true
        }
        return loaded
    }

    fun sync(context: Context, credentials: List<AutofillCredential>) {
        memory.clear()
        memory.addAll(credentials)
        sessionUnlocked = true
        try {
            persistCredentials(context, credentials, includeIcons = true)
        } catch (_: Exception) {
            try {
                persistCredentials(context, credentials, includeIcons = false)
            } catch (_: Exception) {
                // Memory cache still usable for this process.
            }
        }
        AutofillAuthCoordinator.notifyUnlocked()
    }

    private fun persistCredentials(
        context: Context,
        credentials: List<AutofillCredential>,
        includeIcons: Boolean,
    ) {
        val array = JSONArray()
        for (c in credentials) {
            val obj = JSONObject()
                .put("uuid", c.uuid)
                .put("title", c.title)
                .put("username", c.username)
                .put("password", c.password)
                .put("urls", JSONArray(c.urls))
            c.passkey?.let { obj.put("passkey", it.toJson()) }
            if (includeIcons) {
                c.iconPng?.takeIf { it.isNotBlank() }?.let { obj.put("iconPng", it) }
            }
            array.put(obj)
        }
        prefs(context).edit()
            .putString(KEY_CREDENTIALS, array.toString())
            .putBoolean(KEY_UNLOCKED, true)
            .apply()
    }

    fun clear(context: Context) {
        memory.clear()
        sessionUnlocked = false
        try {
            val requireBiometric = requireBiometric(context)
            val showInline = showInline(context)
            val showPopup = showPopup(context)
            prefs(context).edit().clear().apply()
            if (requireBiometric) {
                setRequireBiometric(context, true)
            }
            setPresentation(context, showInline, showPopup)
        } catch (_: Exception) {
        }
    }

    fun upsertPasskey(context: Context, credential: AutofillCredential) {
        val all = credentials(context).toMutableList()
        val idx = all.indexOfFirst { it.uuid == credential.uuid }
            .takeIf { it >= 0 }
            ?: all.indexOfFirst { it.passkey?.credentialId == credential.passkey?.credentialId }
                .takeIf { it >= 0 }
        if (idx != null) {
            all[idx] = credential
        } else {
            all.add(credential)
        }
        sync(context, all)
    }

    fun updatePasskeySignCount(context: Context, uuid: String, signCount: Int) {
        val all = credentials(context).toMutableList()
        val idx = all.indexOfFirst { it.uuid == uuid }
        if (idx < 0) return
        val current = all[idx]
        val pk = current.passkey ?: return
        all[idx] = current.copy(passkey = pk.copy(signCount = signCount))
        sync(context, all)
        enqueueSignCountUpdate(context, uuid, signCount)
    }

    fun matchPasskeys(context: Context, rpId: String?, allowCredentialIds: List<String>?): List<AutofillCredential> {
        val all = credentials(context).filter { it.hasUsablePasskey }
        val rp = rpId?.lowercase()?.trim('.').orEmpty()
        return all.filter { record ->
            val stored = record.passkey?.rpId?.lowercase()?.trim('.').orEmpty()
            if (stored.isEmpty()) return@filter false
            val rpOk = rp.isEmpty() ||
                stored == rp ||
                rp.endsWith(".$stored") ||
                stored.endsWith(".$rp")
            if (!rpOk) return@filter false
            if (allowCredentialIds.isNullOrEmpty()) return@filter true
            allowCredentialIds.contains(record.passkey?.credentialId)
        }
    }

    fun enqueuePasskeySave(context: Context, payload: JSONObject) {
        try {
            val p = prefs(context)
            val arr = JSONArray(p.getString(KEY_PENDING_PASSKEY_SAVES, "[]") ?: "[]")
            // replace same credentialId
            val credId = payload.optJSONObject("passkey")?.optString("credentialId").orEmpty()
            val next = JSONArray()
            for (i in 0 until arr.length()) {
                val item = arr.getJSONObject(i)
                val id = item.optJSONObject("passkey")?.optString("credentialId").orEmpty()
                if (id != credId) next.put(item)
            }
            next.put(payload)
            p.edit().putString(KEY_PENDING_PASSKEY_SAVES, next.toString()).apply()
        } catch (_: Exception) {
        }
    }

    fun takePendingPasskeySaves(context: Context): List<Map<String, Any?>> {
        return try {
            val p = prefs(context)
            val arr = JSONArray(p.getString(KEY_PENDING_PASSKEY_SAVES, "[]") ?: "[]")
            p.edit().remove(KEY_PENDING_PASSKEY_SAVES).apply()
            buildList {
                for (i in 0 until arr.length()) {
                    add(jsonToMap(arr.getJSONObject(i)))
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    fun enqueueSignCountUpdate(context: Context, uuid: String, signCount: Int) {
        try {
            val p = prefs(context)
            val arr = JSONArray(p.getString(KEY_PENDING_SIGN_COUNTS, "[]") ?: "[]")
            val next = JSONArray()
            for (i in 0 until arr.length()) {
                val item = arr.getJSONObject(i)
                if (item.optString("uuid") != uuid) next.put(item)
            }
            next.put(JSONObject().put("uuid", uuid).put("signCount", signCount))
            p.edit().putString(KEY_PENDING_SIGN_COUNTS, next.toString()).apply()
        } catch (_: Exception) {
        }
    }

    fun takePendingSignCountUpdates(context: Context): List<Map<String, Any?>> {
        return try {
            val p = prefs(context)
            val arr = JSONArray(p.getString(KEY_PENDING_SIGN_COUNTS, "[]") ?: "[]")
            p.edit().remove(KEY_PENDING_SIGN_COUNTS).apply()
            buildList {
                for (i in 0 until arr.length()) {
                    val o = arr.getJSONObject(i)
                    add(mapOf("uuid" to o.optString("uuid"), "signCount" to o.optInt("signCount")))
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun loadFromPrefs(context: Context): List<AutofillCredential> {
        return try {
            val raw = prefs(context).getString(KEY_CREDENTIALS, null) ?: return emptyList()
            val array = JSONArray(raw)
            buildList {
                for (i in 0 until array.length()) {
                    val obj = array.getJSONObject(i)
                    val urlsJson = obj.optJSONArray("urls") ?: JSONArray()
                    val urls = buildList {
                        for (j in 0 until urlsJson.length()) {
                            add(urlsJson.getString(j))
                        }
                    }
                    add(
                        AutofillCredential(
                            uuid = obj.optString("uuid"),
                            title = obj.optString("title"),
                            username = obj.optString("username"),
                            password = obj.optString("password"),
                            urls = urls,
                            passkey = PasskeyAuthenticator.PasskeyPayload.fromJson(
                                obj.optJSONObject("passkey"),
                            ),
                            iconPng = obj.optString("iconPng").takeIf { it.isNotBlank() },
                        ),
                    )
                }
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    private fun jsonToMap(obj: JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        val keys = obj.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            when (val v = obj.get(key)) {
                is JSONObject -> map[key] = jsonToMap(v)
                is JSONArray -> {
                    map[key] = buildList {
                        for (i in 0 until v.length()) {
                            val item = v.get(i)
                            add(if (item is JSONObject) jsonToMap(item) else item)
                        }
                    }
                }
                JSONObject.NULL -> map[key] = null
                else -> map[key] = v
            }
        }
        return map
    }
}
