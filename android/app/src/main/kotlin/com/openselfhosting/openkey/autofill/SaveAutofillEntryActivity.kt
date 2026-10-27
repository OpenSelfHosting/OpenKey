package com.openselfhosting.openkey.autofill

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.openselfhosting.openkey.MainActivity

/**
 * Forwards an autofill save to [MainActivity]. The app icon is stored in
 * [AutofillPendingSave] by [OpenKeyAutofillService] before this activity runs.
 */
class SaveAutofillEntryActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val username = intent.getStringExtra(EXTRA_USERNAME).orEmpty()
        val password = intent.getStringExtra(EXTRA_PASSWORD).orEmpty()
        val uri = intent.getStringExtra(EXTRA_URI).orEmpty()
        val packageName = intent.getStringExtra(EXTRA_PACKAGE).orEmpty()

        // Fill gaps only — do not consume / overwrite a good icon from the service.
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

        startActivity(
            Intent(this, MainActivity::class.java).apply {
                action = MainActivity.ACTION_AUTOFILL_SAVE
                putExtra(MainActivity.EXTRA_SAVE_USERNAME, username)
                putExtra(MainActivity.EXTRA_SAVE_PASSWORD, password)
                putExtra(MainActivity.EXTRA_SAVE_URI, uri)
                putExtra(MainActivity.EXTRA_SAVE_PACKAGE, packageName)
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP,
                )
            },
        )
        finish()
    }

    private fun isBrowserPackage(packageName: String): Boolean {
        return BROWSER_PACKAGES.contains(packageName)
    }

    companion object {
        const val EXTRA_USERNAME = "username"
        const val EXTRA_PASSWORD = "password"
        const val EXTRA_URI = "uri"
        const val EXTRA_PACKAGE = "package"

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
