package com.openselfhosting.openkey.autofill

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64

data class AutofillCredential(
    val uuid: String,
    val title: String,
    val username: String,
    val password: String,
    val urls: List<String>,
    val passkey: PasskeyAuthenticator.PasskeyPayload? = null,
    val iconPng: String? = null,
) {
    val hasPasswordLogin: Boolean
        get() = username.isNotEmpty() || password.isNotEmpty()

    val hasUsablePasskey: Boolean
        get() = !passkey?.privateKeyCipher.isNullOrEmpty()

    fun decodedIcon(sizePx: Int): Bitmap? {
        val raw = iconPng ?: return null
        if (raw.isBlank()) return null
        return try {
            val bytes = Base64.decode(raw, Base64.DEFAULT)
            val src = BitmapFactory.decodeByteArray(bytes, 0, bytes.size) ?: return null
            if (src.width <= 0 || src.height <= 0) return null
            val maxDim = maxOf(src.width, src.height)
            if (maxDim <= sizePx) return src
            val scale = sizePx.toFloat() / maxDim
            val w = (src.width * scale).toInt().coerceAtLeast(1)
            val h = (src.height * scale).toInt().coerceAtLeast(1)
            Bitmap.createScaledBitmap(src, w, h, true)
        } catch (_: Exception) {
            null
        }
    }
}
