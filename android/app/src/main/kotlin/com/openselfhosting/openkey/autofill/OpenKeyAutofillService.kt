package com.openselfhosting.openkey.autofill

import android.app.PendingIntent
import android.app.assist.AssistStructure
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.Icon
import android.os.Build
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveInfo
import android.service.autofill.SaveRequest
import android.view.autofill.AutofillId
import android.widget.inline.InlinePresentationSpec
import androidx.annotation.RequiresApi
import com.openselfhosting.openkey.R

/**
 * System Autofill provider. Dataset UI mirrors Google Password Manager:
 * icon + username + masked password, a tap fills username and password
 * together, "Manage passwords…" opens OpenKey, and "Suggest password"
 * appears when the site/app has no saved login (or the field is new-password).
 *
 * Save prompts are configured like Bitwarden:
 * [SaveInfo.FLAG_SAVE_ON_ALL_VIEWS_INVISIBLE] so the system chip appears as soon as
 * login fields disappear after a successful sign-in — not only when the app is closed.
 */
@RequiresApi(Build.VERSION_CODES.O)
class OpenKeyAutofillService : AutofillService() {
    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback,
    ) {
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) {
            callback.onSuccess(null)
            return
        }

        val parsed = AssistStructureParser(structure).result
        if (shouldSkipPackage(parsed.packageName)) {
            callback.onSuccess(null)
            return
        }
        if (parsed.usernameIds.isEmpty() && parsed.passwordIds.isEmpty()) {
            callback.onSuccess(null)
            return
        }

        val fillIds = (parsed.usernameIds + parsed.passwordIds).distinct()
        val response = FillResponse.Builder()
        val session = FillSession(request, parsed, fillIds)

        if (!AutofillCredentialCache.isUnlocked(this)) {
            session.addResponseUnlock(response)
            attachSaveInfo(response, parsed, request)
            callback.onSuccess(response.build())
            return
        }

        val matches = UriMatcher.match(
            credentials = AutofillCredentialCache.credentials(this),
            packageName = parsed.packageName,
            webDomain = parsed.webDomain,
        )

        for (credential in matches.take(MAX_CREDENTIALS)) {
            session.addCredentialDataset(response, credential)
        }
        val suggestPassword = parsed.passwordIds.isNotEmpty() &&
            (matches.isEmpty() || parsed.hasNewPassword)
        if (suggestPassword) {
            session.addSuggestDataset(response)
        }
        session.addManageDataset(response)

        attachSaveInfo(response, parsed, request)
        session.applyFillDialog(response)
        callback.onSuccess(response.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) {
            callback.onSuccess()
            return
        }
        val parsed = AssistStructureParser(structure).result
        if (shouldSkipPackage(parsed.packageName)) {
            callback.onSuccess()
            return
        }

        var username = ""
        var password = ""

        fun readValue(id: AutofillId): String {
            // Walk contexts newest → oldest so the value after typing wins.
            for (ctx in request.fillContexts.asReversed()) {
                val node = findNode(ctx.structure, id) ?: continue
                val text = node.text?.toString()
                if (!text.isNullOrEmpty()) return text
                val autofill = node.autofillValue
                if (autofill != null && autofill.isText) {
                    val value = autofill.textValue?.toString().orEmpty()
                    if (value.isNotEmpty()) return value
                }
            }
            return ""
        }

        for (id in parsed.usernameIds) {
            val v = readValue(id)
            if (v.isNotEmpty()) {
                username = v
                break
            }
        }
        for (id in parsed.passwordIds) {
            val v = readValue(id)
            if (v.isNotEmpty()) {
                password = v
                break
            }
        }

        // Fallback: scan all password-looking nodes if AutofillIds changed across screens.
        if (password.isEmpty()) {
            password = findAnyPasswordValue(request) ?: ""
        }
        if (username.isEmpty()) {
            username = findAnyUsernameValue(request) ?: ""
        }

        if (username.isEmpty() && password.isEmpty()) {
            callback.onSuccess()
            return
        }

        val uri = parsed.webDomain?.let { "https://$it" }.orEmpty()
        val packageName = parsed.packageName.orEmpty()
        // Capture the icon here: AutofillService can see the calling package
        // under Android 11+ package visibility; MainActivity often cannot.
        val iconBase64 = if (packageName.isNotBlank() && !isKnownBrowser(packageName)) {
            AppIconHelper.pngBase64(this, packageName)
        } else {
            null
        }
        AutofillPendingSave.set(
            username = username,
            password = password,
            uri = uri,
            packageName = packageName,
            iconBase64 = iconBase64,
        )
        startActivity(
            Intent(this, SaveAutofillEntryActivity::class.java).apply {
                putExtra(SaveAutofillEntryActivity.EXTRA_USERNAME, username)
                putExtra(SaveAutofillEntryActivity.EXTRA_PASSWORD, password)
                putExtra(SaveAutofillEntryActivity.EXTRA_URI, uri)
                putExtra(SaveAutofillEntryActivity.EXTRA_PACKAGE, packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
        callback.onSuccess()
    }

    /**
     * Mirrors Bitwarden's SaveInfo strategy:
     * - Request save when login views become invisible (single-Activity apps / SPAs).
     * - Delay on username-only screens (multi-step login).
     * - Prefer a login/submit control as an explicit trigger when available.
     * - Skip unreliable password-only saves in browser compat mode (masked fields).
     */
    private fun attachSaveInfo(
        builder: FillResponse.Builder,
        parsed: AssistStructureParser.Result,
        request: FillRequest,
    ) {
        val compatBrowser = isCompatBrowser(request, parsed.packageName)

        // Password-only forms in compat browsers yield masked values — skip.
        if (compatBrowser &&
            parsed.passwordIds.isNotEmpty() &&
            parsed.usernameIds.isEmpty()
        ) {
            return
        }

        when {
            parsed.passwordIds.isNotEmpty() -> {
                val type = if (parsed.usernameIds.isNotEmpty()) {
                    SaveInfo.SAVE_DATA_TYPE_USERNAME or SaveInfo.SAVE_DATA_TYPE_PASSWORD
                } else {
                    SaveInfo.SAVE_DATA_TYPE_PASSWORD
                }
                val saveBuilder = SaveInfo.Builder(type, parsed.passwordIds.toTypedArray())
                if (parsed.usernameIds.isNotEmpty()) {
                    saveBuilder.setOptionalIds(parsed.usernameIds.toTypedArray())
                }
                // Critical: show the system save chip when fields disappear after login,
                // without waiting for the host Activity to finish / the user to leave the app.
                saveBuilder.setFlags(SaveInfo.FLAG_SAVE_ON_ALL_VIEWS_INVISIBLE)
                applyTrigger(saveBuilder, parsed.triggerId)
                builder.setSaveInfo(saveBuilder.build())
            }
            parsed.usernameIds.isNotEmpty() -> {
                // Username-only step of a multi-screen login — wait for the password page.
                val saveBuilder = SaveInfo.Builder(
                    SaveInfo.SAVE_DATA_TYPE_USERNAME,
                    parsed.usernameIds.toTypedArray(),
                )
                saveBuilder.setFlags(
                    SaveInfo.FLAG_DELAY_SAVE or SaveInfo.FLAG_SAVE_ON_ALL_VIEWS_INVISIBLE,
                )
                applyTrigger(saveBuilder, parsed.triggerId)
                builder.setSaveInfo(saveBuilder.build())
            }
        }
    }

    private fun applyTrigger(saveBuilder: SaveInfo.Builder, triggerId: AutofillId?) {
        if (triggerId == null) return
        try {
            saveBuilder.setTriggerId(triggerId)
        } catch (_: Exception) {
            // Older OEM Autofill implementations may reject unknown trigger ids.
        }
    }

    private fun isCompatBrowser(request: FillRequest, packageName: String?): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            return (request.flags and FillRequest.FLAG_COMPATIBILITY_MODE_REQUEST) != 0
        }
        return isKnownBrowser(packageName)
    }

    private fun shouldSkipPackage(packageName: String?): Boolean {
        if (packageName.isNullOrBlank()) return false
        if (packageName == this.packageName) return true
        return SKIP_PACKAGES.contains(packageName)
    }

    private fun isKnownBrowser(packageName: String?): Boolean {
        if (packageName.isNullOrBlank()) return false
        return COMPAT_BROWSERS.contains(packageName)
    }

    private inner class FillSession(
        request: FillRequest,
        private val parsed: AssistStructureParser.Result,
        private val fillIds: List<AutofillId>,
    ) {
        private val iconSizePx = (32 * resources.displayMetrics.density).toInt().coerceAtLeast(32)
        private val showInline: Boolean = AutofillCredentialCache.showInline(this@OpenKeyAutofillService)
        private val showPopup: Boolean = AutofillCredentialCache.showPopup(this@OpenKeyAutofillService)
        private val openKeyIcon: Bitmap? = AppIconHelper.bitmap(this@OpenKeyAutofillService, packageName, iconSizePx)
        private val siteIcon: Bitmap? = loadSiteIcon()
        private val inlineSpecs: List<InlinePresentationSpec> = inlineSpecsOf(request)
        private val attribution: PendingIntent = activityPending(REQUEST_ATTRIBUTION, manageIntent())
        private val startIcon: Icon = openKeyIcon?.let { AutofillPresentations.iconFromBitmap(it) }
            ?: Icon.createWithResource(this@OpenKeyAutofillService, R.drawable.ic_autofill_key)
        private var inlineIndex = 0

        private fun nextInlineSpec(): InlinePresentationSpec? {
            if (inlineIndex >= inlineSpecs.size) return null
            return inlineSpecs[inlineIndex++]
        }

        fun addCredentialDataset(response: FillResponse.Builder, credential: AutofillCredential) {
            val username = displayName(credential)
            val entryIcon = credential.decodedIcon(iconSizePx) ?: siteIcon
            val menu = AutofillPresentations.credential(this@OpenKeyAutofillService, username, entryIcon)
            val dialog = if (showPopup) menu else null
            val inlineIcon = entryIcon?.let { AutofillPresentations.iconFromBitmap(it) } ?: startIcon
            val inline = AutofillPresentations.inline(
                spec = nextInlineSpec(),
                title = username,
                subtitle = getString(R.string.autofill_password_masked),
                icon = inlineIcon,
                attribution = attribution,
            )
            val dataset = Dataset.Builder()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                dataset.setId("cred:${credential.uuid}")
            }
            if (AutofillCredentialCache.requireBiometric(this@OpenKeyAutofillService)) {
                AutofillPresentations.authenticate(dataset, fillIds, menu, dialog, inline)
                dataset.setAuthentication(biometricPending(credential).intentSender)
            } else {
                AutofillPresentations.fill(
                    dataset = dataset,
                    usernameIds = parsed.usernameIds,
                    passwordIds = parsed.passwordIds,
                    username = credential.username,
                    password = credential.password,
                    menu = menu,
                    dialog = dialog,
                    inline = inline,
                )
            }
            response.addDataset(dataset.build())
        }

        fun addSuggestDataset(response: FillResponse.Builder) {
            val generated = AutofillPasswordGenerator.generate()
            val label = getString(R.string.autofill_suggest_password)
            val menu = AutofillPresentations.action(
                context = this@OpenKeyAutofillService,
                label = label,
                icon = openKeyIcon,
            )
            val inline = AutofillPresentations.inline(
                spec = nextInlineSpec(),
                title = label,
                subtitle = getString(R.string.autofill_password_masked),
                icon = Icon.createWithResource(this@OpenKeyAutofillService, R.drawable.ic_autofill_key),
                attribution = attribution,
            )
            val dataset = Dataset.Builder()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                dataset.setId("suggest")
            }
            AutofillPresentations.fill(
                dataset = dataset,
                usernameIds = emptyList(),
                passwordIds = parsed.passwordIds,
                username = null,
                password = generated,
                menu = menu,
                dialog = if (showPopup) menu else null,
                inline = inline,
            )
            response.addDataset(dataset.build())
        }

        fun addResponseUnlock(response: FillResponse.Builder) {
            val label = getString(R.string.autofill_unlock_openkey)
            val menu = AutofillPresentations.action(
                context = this@OpenKeyAutofillService,
                label = label,
                icon = openKeyIcon,
                showTrailing = false,
            )
            val inline = AutofillPresentations.inline(
                spec = nextInlineSpec(),
                title = label,
                subtitle = null,
                icon = startIcon,
                attribution = attribution,
            )
            val sender = activityPending(
                REQUEST_UNLOCK,
                Intent(this@OpenKeyAutofillService, AutofillAuthActivity::class.java),
            ).intentSender
            val ids = fillIds.toTypedArray()
            if (inline != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                response.setAuthentication(ids, sender, menu, inline)
            } else {
                response.setAuthentication(ids, sender, menu)
            }
        }

        fun addManageDataset(response: FillResponse.Builder) {
            val label = getString(R.string.autofill_manage_passwords)
            val menu = AutofillPresentations.action(
                context = this@OpenKeyAutofillService,
                label = label,
                icon = openKeyIcon,
                showTrailing = false,
            )
            // Keep Manage in the dropdown; skip the IME chip so credentials stay visible.
            val dataset = Dataset.Builder()
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                dataset.setId("manage")
            }
            AutofillPresentations.authenticate(
                dataset,
                fillIds,
                menu,
                if (showPopup) menu else null,
                null,
            )
            dataset.setAuthentication(activityPending(REQUEST_MANAGE, manageIntent()).intentSender)
            response.addDataset(dataset.build())
        }

        fun applyFillDialog(response: FillResponse.Builder) {
            if (!showPopup) return
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return
            if (fillIds.isEmpty()) return
            if ((requestFlags and FillRequest.FLAG_SUPPORTS_FILL_DIALOG) == 0) return
            try {
                response.setFillDialogTriggerIds(*fillIds.toTypedArray())
            } catch (_: Exception) {
                // Some OEM Autofill implementations reject dialog triggers.
            }
        }

        private val requestFlags: Int = request.flags

        private fun loadSiteIcon(): Bitmap? {
            val pkg = parsed.packageName.orEmpty()
            if (pkg.isBlank() || isKnownBrowser(pkg)) return openKeyIcon
            return AppIconHelper.bitmap(this@OpenKeyAutofillService, pkg, iconSizePx) ?: openKeyIcon
        }

        private fun inlineSpecsOf(request: FillRequest): List<InlinePresentationSpec> {
            // Keyboard chips hide the dropdown above the field. If popup is on, skip inline.
            if (!showInline || showPopup) return emptyList()
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return emptyList()
            return try {
                request.inlineSuggestionsRequest?.inlinePresentationSpecs.orEmpty()
            } catch (_: Exception) {
                emptyList()
            }
        }

        private fun biometricPending(credential: AutofillCredential): PendingIntent {
            val authIntent = Intent(this@OpenKeyAutofillService, AutofillBiometricActivity::class.java).apply {
                putExtra(AutofillBiometricActivity.EXTRA_CREDENTIAL_UUID, credential.uuid)
                putParcelableArrayListExtra(
                    AutofillBiometricActivity.EXTRA_USERNAME_IDS,
                    ArrayList(parsed.usernameIds),
                )
                putParcelableArrayListExtra(
                    AutofillBiometricActivity.EXTRA_PASSWORD_IDS,
                    ArrayList(parsed.passwordIds),
                )
            }
            val requestCode = REQUEST_BIOMETRIC_BASE + (credential.uuid.hashCode() and 0xFFFF)
            return activityPending(requestCode, authIntent)
        }

        private fun manageIntent(): Intent {
            return Intent(this@OpenKeyAutofillService, AutofillManageActivity::class.java)
        }

        private fun activityPending(requestCode: Int, intent: Intent): PendingIntent {
            var flags = PendingIntent.FLAG_CANCEL_CURRENT
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                flags = flags or PendingIntent.FLAG_MUTABLE
            }
            return PendingIntent.getActivity(this@OpenKeyAutofillService, requestCode, intent, flags)
        }
    }

    private fun displayName(credential: AutofillCredential): String {
        return credential.username.ifBlank { credential.title }
            .ifBlank { getString(R.string.autofill_login) }
    }

    private fun findAnyPasswordValue(request: SaveRequest): String? {
        for (ctx in request.fillContexts.asReversed()) {
            val value = findPasswordInTree(ctx.structure)
            if (!value.isNullOrEmpty()) return value
        }
        return null
    }

    private fun findAnyUsernameValue(request: SaveRequest): String? {
        for (ctx in request.fillContexts.asReversed()) {
            val snap = AssistStructureParser(ctx.structure).result
            for (id in snap.usernameIds) {
                val node = findNode(ctx.structure, id) ?: continue
                val text = node.text?.toString()
                if (!text.isNullOrEmpty()) return text
                val autofill = node.autofillValue
                if (autofill != null && autofill.isText) {
                    val v = autofill.textValue?.toString().orEmpty()
                    if (v.isNotEmpty()) return v
                }
            }
        }
        return null
    }

    private fun findPasswordInTree(structure: AssistStructure): String? {
        for (i in 0 until structure.windowNodeCount) {
            val found = findPasswordInNode(structure.getWindowNodeAt(i).rootViewNode)
            if (!found.isNullOrEmpty()) return found
        }
        return null
    }

    private fun findPasswordInNode(node: AssistStructure.ViewNode): String? {
        val id = node.autofillId
        if (id != null && node.autofillType != android.view.View.AUTOFILL_TYPE_NONE) {
            val hints = node.autofillHints?.map { it.lowercase() }.orEmpty()
            val inputType = node.inputType
            val variation = inputType and android.text.InputType.TYPE_MASK_VARIATION
            val isPassword =
                variation == android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD ||
                    variation == android.text.InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD ||
                    variation == android.text.InputType.TYPE_NUMBER_VARIATION_PASSWORD ||
                    hints.any { it.contains("password") }
            if (isPassword) {
                val text = node.text?.toString()
                if (!text.isNullOrEmpty()) return text
                val autofill = node.autofillValue
                if (autofill != null && autofill.isText) {
                    val v = autofill.textValue?.toString().orEmpty()
                    if (v.isNotEmpty()) return v
                }
            }
        }
        for (i in 0 until node.childCount) {
            val child = findPasswordInNode(node.getChildAt(i))
            if (!child.isNullOrEmpty()) return child
        }
        return null
    }

    private fun findNode(
        structure: AssistStructure,
        id: AutofillId,
    ): AssistStructure.ViewNode? {
        for (i in 0 until structure.windowNodeCount) {
            val found = findNode(structure.getWindowNodeAt(i).rootViewNode, id)
            if (found != null) return found
        }
        return null
    }

    private fun findNode(
        node: AssistStructure.ViewNode,
        id: AutofillId,
    ): AssistStructure.ViewNode? {
        if (id == node.autofillId) return node
        for (i in 0 until node.childCount) {
            val found = findNode(node.getChildAt(i), id)
            if (found != null) return found
        }
        return null
    }

    companion object {
        private const val MAX_CREDENTIALS = 10
        private const val REQUEST_UNLOCK = 1001
        private const val REQUEST_MANAGE = 1002
        private const val REQUEST_ATTRIBUTION = 1003
        private const val REQUEST_BIOMETRIC_BASE = 2000

        private val SKIP_PACKAGES = setOf(
            "com.android.settings",
            "com.google.android.gms",
            "com.google.android.permissioncontroller",
            "com.android.systemui",
            "com.google.android.inputmethod.latin",
        )

        /** Browsers that often run Autofill in compatibility mode with masked passwords. */
        private val COMPAT_BROWSERS = setOf(
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
        )
    }
}
