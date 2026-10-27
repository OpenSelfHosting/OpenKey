package com.openselfhosting.openkey.autofill

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.openselfhosting.openkey.MainActivity

/**
 * Autofill dataset trampoline for "Manage passwords…".
 * Opens OpenKey and dismisses the fill UI so the user lands in the vault.
 */
class AutofillManageActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startActivity(
            Intent(this, MainActivity::class.java).apply {
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP or
                        Intent.FLAG_ACTIVITY_CLEAR_TOP or
                        Intent.FLAG_ACTIVITY_REORDER_TO_FRONT,
                )
            },
        )
        setResult(RESULT_CANCELED)
        finish()
    }
}
