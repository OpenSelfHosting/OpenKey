package com.openselfhosting.openkey.autofill

import android.content.Context
import androidx.credentials.provider.CallingAppInfo
import com.openselfhosting.openkey.R
import java.security.MessageDigest
import java.util.Base64

/**
 * Resolves WebAuthn clientData `origin` from [CallingAppInfo].
 *
 * The credentials library keeps [CallingAppInfo.origin] internal; providers must use
 * [CallingAppInfo.getOrigin] with a privileged-browser allowlist, or derive
 * `android:apk-key-hash:…` for native callers.
 */
object CallingAppOrigin {
    @Volatile
    private var allowlistCache: String? = null

    fun privilegedAllowlist(context: Context): String {
        allowlistCache?.let { return it }
        val text = context.applicationContext.resources
            .openRawResource(R.raw.privileged_apps_allowlist)
            .bufferedReader()
            .use { it.readText() }
        allowlistCache = text
        return text
    }

    /** Host from a privileged browser origin, if the caller is allowlisted. */
    fun webHostOrNull(context: Context, callingAppInfo: CallingAppInfo): String? {
        if (!callingAppInfo.isOriginPopulated()) return null
        return try {
            callingAppInfo.getOrigin(privilegedAllowlist(context))
                ?.removePrefix("https://")
                ?.removePrefix("http://")
                ?.substringBefore('/')
                ?.takeIf { it.isNotEmpty() }
        } catch (_: Exception) {
            null
        }
    }

    fun resolve(context: Context, callingAppInfo: CallingAppInfo, fallbackHost: String?): String {
        if (callingAppInfo.isOriginPopulated()) {
            try {
                val origin = callingAppInfo.getOrigin(privilegedAllowlist(context))
                if (!origin.isNullOrEmpty()) return origin
            } catch (_: Exception) {
                // Fall through to native / https fallback.
            }
        }
        return try {
            apkKeyHashOrigin(callingAppInfo)
        } catch (_: Exception) {
            val host = fallbackHost?.takeIf { it.isNotEmpty() } ?: callingAppInfo.packageName
            "https://$host"
        }
    }

    private fun apkKeyHashOrigin(info: CallingAppInfo): String {
        val cert = info.signingInfo.apkContentsSigners[0].toByteArray()
        val digest = MessageDigest.getInstance("SHA-256").digest(cert)
        val b64 = Base64.getUrlEncoder().withoutPadding().encodeToString(digest)
        return "android:apk-key-hash:$b64"
    }
}
