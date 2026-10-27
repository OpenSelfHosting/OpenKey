package com.openselfhosting.openkey.autofill

object UriMatcher {
    private const val ANDROID_APP_PREFIX = "androidapp://"

    fun match(
        credentials: List<AutofillCredential>,
        packageName: String?,
        webDomain: String?,
    ): List<AutofillCredential> {
        val exact = LinkedHashSet<AutofillCredential>()
        val fuzzy = LinkedHashSet<AutofillCredential>()

        val domain = normalizeHost(webDomain)
        val pkg = packageName?.trim().orEmpty()

        for (credential in credentials) {
            if (credential.username.isEmpty() && credential.password.isEmpty()) continue
            for (raw in credential.urls) {
                val url = raw.trim()
                if (url.isEmpty()) continue

                if (pkg.isNotEmpty() && url.startsWith(ANDROID_APP_PREFIX, ignoreCase = true)) {
                    val appId = url.substring(ANDROID_APP_PREFIX.length).trim()
                    if (appId.equals(pkg, ignoreCase = true)) {
                        exact.add(credential)
                        break
                    }
                }

                if (domain != null) {
                    val host = hostFromUrl(url) ?: continue
                    if (host.equals(domain, ignoreCase = true)) {
                        exact.add(credential)
                        break
                    }
                    if (host.endsWith(".$domain", ignoreCase = true) ||
                        domain.endsWith(".$host", ignoreCase = true)
                    ) {
                        fuzzy.add(credential)
                        break
                    }
                }
            }
        }

        // Only return URI/package matches. Never dump the whole vault for an
        // unrelated app — that leaks unrelated root logins into suggestions.
        val result = LinkedHashSet<AutofillCredential>()
        result.addAll(exact)
        result.addAll(fuzzy)
        return result.toList()
    }

    private fun hostFromUrl(raw: String): String? {
        if (raw.startsWith(ANDROID_APP_PREFIX, ignoreCase = true)) return null
        return try {
            val withScheme = if (raw.contains("://")) raw else "https://$raw"
            normalizeHost(android.net.Uri.parse(withScheme).host)
        } catch (_: Exception) {
            null
        }
    }

    private fun normalizeHost(host: String?): String? {
        val h = host?.trim()?.lowercase()?.trim('.') ?: return null
        if (h.isEmpty()) return null
        return h.removePrefix("www.")
    }
}
