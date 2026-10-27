package com.openselfhosting.openkey

import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.view.autofill.AutofillManager
import com.openselfhosting.openkey.autofill.AppIconHelper
import com.openselfhosting.openkey.autofill.AutofillCredential
import com.openselfhosting.openkey.autofill.AutofillCredentialCache
import com.openselfhosting.openkey.autofill.AutofillPendingSave
import com.openselfhosting.openkey.autofill.PasskeyAuthenticator
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private var channel: MethodChannel? = null
    private var pendingSave: Map<String, Any?>? = null
    private var pendingUnlockForAutofill: Boolean = false
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "syncCredentials" -> {
                        @Suppress("UNCHECKED_CAST")
                        val raw = call.arguments as? List<Map<String, Any?>> ?: emptyList()
                        val credentials = raw.map { map ->
                            @Suppress("UNCHECKED_CAST")
                            val urls = (map["urls"] as? List<*>)?.map { it.toString() } ?: emptyList()
                            @Suppress("UNCHECKED_CAST")
                            val passkeyMap = map["passkey"] as? Map<String, Any?>
                            val passkey = passkeyMap?.let { pk ->
                                PasskeyAuthenticator.PasskeyPayload(
                                    rpId = pk["rpId"]?.toString().orEmpty(),
                                    credentialId = pk["credentialId"]?.toString().orEmpty(),
                                    userHandle = pk["userHandle"]?.toString(),
                                    privateKeyCipher = pk["privateKeyCipher"]?.toString(),
                                    publicKey = pk["publicKey"]?.toString(),
                                    alg = (pk["alg"] as? Number)?.toInt() ?: PasskeyAuthenticator.ES256_ALG,
                                    signCount = (pk["signCount"] as? Number)?.toInt() ?: 0,
                                    userName = pk["userName"]?.toString(),
                                    displayName = pk["displayName"]?.toString(),
                                ).takeIf { it.rpId.isNotEmpty() && it.credentialId.isNotEmpty() }
                            }
                            AutofillCredential(
                                uuid = map["uuid"]?.toString().orEmpty(),
                                title = map["title"]?.toString().orEmpty(),
                                username = map["username"]?.toString().orEmpty(),
                                password = map["password"]?.toString().orEmpty(),
                                urls = urls,
                                passkey = passkey,
                                iconPng = map["iconPng"]?.toString()?.takeIf { it.isNotBlank() },
                            )
                        }
                        AutofillCredentialCache.sync(this@MainActivity, credentials)
                        result.success(true)
                    }
                    "clearCredentials" -> {
                        AutofillCredentialCache.clear(this@MainActivity)
                        result.success(true)
                    }
                    "isAutofillEnabled" -> {
                        result.success(isAutofillServiceEnabled())
                    }
                    "openAutofillSettings" -> {
                        openAutofillSettings()
                        result.success(true)
                    }
                    "setAutofillEnabled" -> {
                        val enabled = call.arguments as? Boolean ?: false
                        setAutofillEnabled(enabled)
                        result.success(isAutofillServiceEnabled())
                    }
                    "takePendingSave" -> {
                        // Prefer process cache (icon captured by AutofillService).
                        val fromCache = AutofillPendingSave.takeAsMap()
                        val save = fromCache ?: pendingSave
                        pendingSave = null
                        val iconLen = (save?.get("iconBase64") as? String)?.length ?: 0
                        Log.i(TAG, "takePendingSave package=${save?.get("package")} iconLen=$iconLen")
                        result.success(save)
                    }
                    "takePendingUnlock" -> {
                        val unlock = pendingUnlockForAutofill
                        pendingUnlockForAutofill = false
                        result.success(unlock)
                    }
                    "takePendingPasskeySaves" -> {
                        result.success(AutofillCredentialCache.takePendingPasskeySaves(this@MainActivity))
                    }
                    "takePendingSignCountUpdates" -> {
                        result.success(AutofillCredentialCache.takePendingSignCountUpdates(this@MainActivity))
                    }
                    "setRequireBiometric" -> {
                        val enabled = call.arguments as? Boolean ?: false
                        AutofillCredentialCache.setRequireBiometric(this@MainActivity, enabled)
                        result.success(true)
                    }
                    "setAutofillPresentation" -> {
                        val args = call.arguments as? Map<*, *>
                        val inline = args?.get("inline") as? Boolean ?: true
                        val popup = args?.get("popup") as? Boolean ?: true
                        AutofillCredentialCache.setPresentation(this@MainActivity, inline, popup)
                        result.success(true)
                    }
                    "getAppIcon" -> {
                        val packageName = call.arguments?.toString().orEmpty()
                        result.success(AppIconHelper.pngBase64(this@MainActivity, packageName))
                    }
                    else -> result.notImplemented()
                }
            }
        }
        handleLaunchIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleLaunchIntent(intent)
        channel?.invokeMethod("onAutofillIntent", null)
    }

    private fun handleLaunchIntent(intent: Intent?) {
        if (intent == null) return
        when (intent.action) {
            ACTION_AUTOFILL_UNLOCK -> pendingUnlockForAutofill = true
            ACTION_AUTOFILL_SAVE -> {
                val packageName = intent.getStringExtra(EXTRA_SAVE_PACKAGE).orEmpty()
                val uri = intent.getStringExtra(EXTRA_SAVE_URI).orEmpty()
                val username = intent.getStringExtra(EXTRA_SAVE_USERNAME).orEmpty()
                val password = intent.getStringExtra(EXTRA_SAVE_PASSWORD).orEmpty()

                // Service should have filled AutofillPendingSave (with icon).
                // Only fill gaps here — never consume the cache (Flutter does that).
                if (AutofillPendingSave.peekIcon() == null) {
                    val icon = if (packageName.isNotBlank() && !isBrowserPackage(packageName)) {
                        AppIconHelper.pngBase64(this, packageName)
                    } else {
                        null
                    }
                    AutofillPendingSave.set(
                        username = username,
                        password = password,
                        uri = uri,
                        packageName = packageName,
                        iconBase64 = icon,
                    )
                }

                pendingSave = mapOf(
                    "username" to username,
                    "password" to password,
                    "uri" to uri,
                    "package" to packageName,
                    "iconBase64" to AutofillPendingSave.peekIcon(),
                )
                Log.i(
                    TAG,
                    "AUTOFILL_SAVE package=$packageName iconLen=${(pendingSave?.get("iconBase64") as? String)?.length ?: 0}",
                )
            }
            ACTION_AUTOFILL_PASSKEY -> {
                // Passkey create/assert queued work — Flutter drains pending saves/sign counts.
            }
        }
    }

    private fun isBrowserPackage(packageName: String): Boolean {
        return BROWSER_PACKAGES.contains(packageName)
    }

    private fun isAutofillServiceEnabled(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val afm = getSystemService(AutofillManager::class.java) ?: return false
        return afm.hasEnabledAutofillServices() && afm.isAutofillSupported
            && isOurServiceSelected()
    }

    private fun isOurServiceSelected(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return try {
            val flat = Settings.Secure.getString(contentResolver, "autofill_service")
            flat != null && flat.startsWith("$packageName/")
        } catch (_: Exception) {
            false
        }
    }

    private fun setAutofillEnabled(enabled: Boolean) {
        if (enabled) {
            openAutofillSettings()
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val afm = getSystemService(AutofillManager::class.java)
                if (afm != null &&
                    (afm.hasEnabledAutofillServices() || isOurServiceSelected())
                ) {
                    afm.disableAutofillServices()
                }
            } catch (e: Exception) {
                Log.w(TAG, "disableAutofillServices failed", e)
            }
        }
        if (isAutofillServiceEnabled()) {
            openAutofillSettingsPage()
        }
    }

    private fun openAutofillSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intent = Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE).apply {
                data = android.net.Uri.parse("package:$packageName")
            }
            try {
                startActivity(intent)
                return
            } catch (_: Exception) {
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            try {
                startActivity(Intent("android.settings.CREDENTIAL_PROVIDER"))
                return
            } catch (_: Exception) {
            }
        }
        openAutofillSettingsPage()
    }

    private fun openAutofillSettingsPage() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                startActivity(Intent("android.settings.AUTOFILL_SETTINGS"))
                return
            } catch (_: Exception) {
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            try {
                startActivity(Intent("android.settings.CREDENTIAL_PROVIDER"))
                return
            } catch (_: Exception) {
            }
        }
        try {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        } catch (_: Exception) {
        }
    }

    companion object {
        private const val TAG = "OpenKeyAutofill"
        const val CHANNEL = "openkey/autofill"
        const val ACTION_AUTOFILL_UNLOCK = "com.openselfhosting.openkey.AUTOFILL_UNLOCK"
        const val ACTION_AUTOFILL_SAVE = "com.openselfhosting.openkey.AUTOFILL_SAVE"
        const val ACTION_AUTOFILL_PASSKEY = "com.openselfhosting.openkey.AUTOFILL_PASSKEY"
        const val EXTRA_SAVE_USERNAME = "save_username"
        const val EXTRA_SAVE_PASSWORD = "save_password"
        const val EXTRA_SAVE_URI = "save_uri"
        const val EXTRA_SAVE_PACKAGE = "save_package"

        private val BROWSER_PACKAGES = setOf(
            "com.android.chrome",
            "com.chrome.beta",
            "com.chrome.dev",
            "com.chrome.canary",
            "org.mozilla.firefox",
            "org.mozilla.firefox_beta",
            "org.mozilla.focus",
            "com.microsoft.emmx",
            "com.brave.browser",
            "com.opera.browser",
            "com.opera.mini.native",
            "com.sec.android.app.sbrowser",
            "com.duckduckgo.mobile.android",
            "com.vivaldi.browser",
            "com.kiwibrowser.browser",
        )
    }
}
