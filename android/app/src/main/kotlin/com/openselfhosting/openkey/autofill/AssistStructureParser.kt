package com.openselfhosting.openkey.autofill

import android.app.assist.AssistStructure
import android.os.Build
import android.text.InputType
import android.view.View
import android.view.autofill.AutofillId
import androidx.annotation.RequiresApi

/**
 * Walks an [AssistStructure] and identifies username/password fields plus a
 * likely login/submit control for [android.service.autofill.SaveInfo] triggers.
 */
@RequiresApi(Build.VERSION_CODES.O)
class AssistStructureParser(structure: AssistStructure) {
    data class ParsedField(
        val id: AutofillId,
        val hints: Set<String>,
        val isPassword: Boolean,
        val isUsername: Boolean,
        val htmlInfo: String?,
    )

    data class Result(
        val packageName: String?,
        val webDomain: String?,
        val fields: List<ParsedField>,
        val usernameIds: List<AutofillId>,
        val passwordIds: List<AutofillId>,
        /** True when the form looks like signup / change-password (`new-password`). */
        val hasNewPassword: Boolean,
        /** Best-effort login/submit control; used with [SaveInfo.Builder.setTriggerId]. */
        val triggerId: AutofillId?,
    )

    val result: Result

    init {
        val fields = mutableListOf<ParsedField>()
        val triggerCandidates = mutableListOf<Pair<AutofillId, Int>>()
        var packageName: String? = null
        var webDomain: String? = null

        for (i in 0 until structure.windowNodeCount) {
            val window = structure.getWindowNodeAt(i)
            val root = window.rootViewNode
            if (packageName == null) {
                packageName = root.idPackage ?: structure.activityComponent?.packageName
            }
            walk(root, fields, triggerCandidates)
        }

        for (i in 0 until structure.windowNodeCount) {
            webDomain = findWebDomain(structure.getWindowNodeAt(i).rootViewNode) ?: webDomain
        }

        var usernameIds = fields.filter { it.isUsername }.map { it.id }.distinct()
        val passwordIds = fields.filter { it.isPassword }.map { it.id }.distinct()

        // Heuristic: password present but no username hints → treat adjacent text/email fields
        // as usernames (common in banking apps that omit autofillHints).
        if (passwordIds.isNotEmpty() && usernameIds.isEmpty()) {
            usernameIds = fields
                .asSequence()
                .filter { !it.isPassword && isLikelyUsernameFallback(it) }
                .map { it.id }
                .distinct()
                .take(2)
                .toList()
        }

        val triggerId = triggerCandidates
            .maxByOrNull { it.second }
            ?.first

        val hasNewPassword = fields.any { it.isPassword && isNewPasswordHint(it.hints) }

        result = Result(
            packageName = packageName,
            webDomain = webDomain,
            fields = fields,
            usernameIds = usernameIds,
            passwordIds = passwordIds,
            hasNewPassword = hasNewPassword,
            triggerId = triggerId,
        )
    }

    private fun walk(
        node: AssistStructure.ViewNode,
        out: MutableList<ParsedField>,
        triggers: MutableList<Pair<AutofillId, Int>>,
    ) {
        val id = node.autofillId
        if (id != null) {
            maybeCollectTrigger(node, id, triggers)

            if (node.autofillType != View.AUTOFILL_TYPE_NONE) {
                val hints = collectHints(node)
                val inputType = node.inputType
                val isPasswordType = isPasswordField(inputType, hints)
                val isOtp = isOtpField(inputType, hints)
                val isUsername = !isPasswordType && !isOtp && isUsernameField(hints)

                // Keep password/username fields, and generic autofillable text that may become
                // a username fallback when a password field exists on the same screen.
                val keep =
                    isPasswordType ||
                        isUsername ||
                        (!isOtp && hints.isNotEmpty()) ||
                        (!isPasswordType && !isOtp && isEditableText(inputType, node))

                if (keep) {
                    out.add(
                        ParsedField(
                            id = id,
                            hints = hints,
                            isPassword = isPasswordType,
                            isUsername = isUsername,
                            htmlInfo = node.webDomain,
                        ),
                    )
                }
            }
        }

        for (i in 0 until node.childCount) {
            walk(node.getChildAt(i), out, triggers)
        }
    }

    private fun collectHints(node: AssistStructure.ViewNode): Set<String> {
        val hints = linkedSetOf<String>()
        node.autofillHints?.forEach { hints.add(it.lowercase()) }
        node.htmlInfo?.attributes?.forEach { pair ->
            if (pair.first.equals("autocomplete", ignoreCase = true) ||
                pair.first.equals("name", ignoreCase = true) ||
                pair.first.equals("type", ignoreCase = true) ||
                pair.first.equals("id", ignoreCase = true)
            ) {
                hints.add(pair.second.lowercase())
            }
        }
        node.idEntry?.lowercase()?.takeIf { it.isNotBlank() }?.let { hints.add(it) }
        node.hint?.lowercase()?.takeIf { it.isNotBlank() }?.let { hints.add(it) }
        node.text?.toString()?.lowercase()?.takeIf { it.isNotBlank() && it.length < 48 }
            ?.let { hints.add(it) }
        return hints
    }

    private fun isPasswordField(inputType: Int, hints: Set<String>): Boolean {
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        return variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
            variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD ||
            variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
            variation == InputType.TYPE_NUMBER_VARIATION_PASSWORD ||
            hints.any {
                it.contains("password") ||
                    it == "current-password" ||
                    it == "new-password" ||
                    it == View.AUTOFILL_HINT_PASSWORD
            }
    }

    private fun isNewPasswordHint(hints: Set<String>): Boolean {
        return hints.any {
            it == "new-password" ||
                it.contains("new-password") ||
                it.contains("new_password") ||
                it.contains("newpassword")
        }
    }

    private fun isOtpField(inputType: Int, hints: Set<String>): Boolean {
        if (hints.any {
                it.contains("otp") ||
                    it.contains("one-time") ||
                    it.contains("onetime") ||
                    it.contains("verification") ||
                    it.contains("authcode") ||
                    it.contains("2fa") ||
                    it.contains("mfa") ||
                    it == "sms-otp" ||
                    it == "one-time-code"
            }
        ) {
            return true
        }
        val classType = inputType and InputType.TYPE_MASK_CLASS
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        return classType == InputType.TYPE_CLASS_NUMBER &&
            variation != InputType.TYPE_NUMBER_VARIATION_PASSWORD &&
            hints.any { it.contains("code") || it.contains("pin") }
    }

    private fun isUsernameField(hints: Set<String>): Boolean {
        return hints.any {
            it.contains("username") ||
                it.contains("email") ||
                it.contains("e-mail") ||
                it == "webauthn" ||
                it.contains("login") ||
                it.contains("user") ||
                it.contains("account") ||
                it.contains("phone") ||
                it.contains("mobile") ||
                it == View.AUTOFILL_HINT_USERNAME ||
                it == View.AUTOFILL_HINT_EMAIL_ADDRESS ||
                it == View.AUTOFILL_HINT_PHONE
        }
    }

    private fun isEditableText(inputType: Int, node: AssistStructure.ViewNode): Boolean {
        if (node.className?.contains("EditText", ignoreCase = true) == true) return true
        val classType = inputType and InputType.TYPE_MASK_CLASS
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        return classType == InputType.TYPE_CLASS_TEXT ||
            classType == InputType.TYPE_CLASS_PHONE ||
            variation == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS ||
            variation == InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS
    }

    private fun isLikelyUsernameFallback(field: ParsedField): Boolean {
        if (field.isPassword) return false
        if (isUsernameField(field.hints)) return true
        // Prefer email-ish / text fields; skip obvious search boxes.
        return field.hints.none {
            it.contains("search") ||
                it.contains("query") ||
                it.contains("filter") ||
                it.contains("message") ||
                it.contains("comment")
        }
    }

    private fun maybeCollectTrigger(
        node: AssistStructure.ViewNode,
        id: AutofillId,
        triggers: MutableList<Pair<AutofillId, Int>>,
    ) {
        if (!node.isClickable && node.htmlInfo?.tag?.equals("button", true) != true) return
        val label = buildString {
            node.text?.toString()?.let { append(it) }
            append(' ')
            node.idEntry?.let { append(it) }
            append(' ')
            node.hint?.let { append(it) }
            node.autofillHints?.forEach {
                append(' ')
                append(it)
            }
        }.lowercase()

        val score = when {
            label.contains("sign in") ||
                label.contains("signin") ||
                label.contains("log in") ||
                label.contains("login") ||
                label.contains("logon") ||
                label.contains("submit") ||
                label.contains("continue") ||
                label.contains("next") ||
                label.contains("register") ||
                label.contains("sign up") ||
                label.contains("signup") ||
                label.contains("create account") ||
                label.contains("تسجيل") ||
                label.contains("دخول") ||
                label.contains("متابعة") ||
                label.contains("التالي") -> 3
            label.contains("ok") || label.contains("done") || label.contains("save") -> 1
            else -> 0
        }
        if (score > 0) {
            triggers.add(id to score)
        }
    }

    private fun findWebDomain(node: AssistStructure.ViewNode): String? {
        val domain = node.webDomain
        if (!domain.isNullOrBlank()) return domain
        for (i in 0 until node.childCount) {
            val child = findWebDomain(node.getChildAt(i))
            if (child != null) return child
        }
        return null
    }
}
