package com.openselfhosting.openkey.autofill

/**
 * Process-local handoff for an autofill save (credentials + app icon).
 *
 * Avoids stuffing large Base64 icon strings into Intent extras (Binder limits)
 * and lets [OpenKeyAutofillService] capture the icon while it still has
 * visibility of the calling package.
 */
object AutofillPendingSave {
    @Volatile
    private var pending: Payload? = null

    data class Payload(
        val username: String,
        val password: String,
        val uri: String,
        val packageName: String,
        val iconBase64: String?,
    )

    @Synchronized
    fun set(
        username: String,
        password: String,
        uri: String,
        packageName: String,
        iconBase64: String?,
    ) {
        pending = Payload(
            username = username,
            password = password,
            uri = uri,
            packageName = packageName,
            iconBase64 = iconBase64,
        )
    }

    @Synchronized
    fun peekIcon(): String? = pending?.iconBase64

    @Synchronized
    fun take(): Payload? {
        val value = pending
        pending = null
        return value
    }

    @Synchronized
    fun takeAsMap(): Map<String, Any?>? {
        val value = take() ?: return null
        return mapOf(
            "username" to value.username,
            "password" to value.password,
            "uri" to value.uri,
            "package" to value.packageName,
            "iconBase64" to value.iconBase64,
        )
    }
}
