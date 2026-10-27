package com.openselfhosting.openkey.autofill

import java.security.SecureRandom

/** Strong password used by the Autofill "Suggest password" dataset. */
object AutofillPasswordGenerator {
    private const val LOWER = "abcdefghijklmnopqrstuvwxyz"
    private const val UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private const val DIGITS = "0123456789"
    private const val SYMBOLS = "!@#\$%^&*()-_=+[]{};:,.?"
    private val random = SecureRandom()

    fun generate(length: Int = 20): String {
        val sets = listOf(LOWER, UPPER, DIGITS, SYMBOLS)
        val size = length.coerceAtLeast(sets.size)
        val pool = sets.joinToString("")
        val chars = CharArray(size)
        for (i in sets.indices) {
            chars[i] = sets[i][random.nextInt(sets[i].length)]
        }
        for (i in sets.size until size) {
            chars[i] = pool[random.nextInt(pool.length)]
        }
        // Fisher–Yates shuffle so charset positions are not predictable.
        for (i in chars.lastIndex downTo 1) {
            val j = random.nextInt(i + 1)
            val tmp = chars[i]
            chars[i] = chars[j]
            chars[j] = tmp
        }
        return String(chars)
    }
}
