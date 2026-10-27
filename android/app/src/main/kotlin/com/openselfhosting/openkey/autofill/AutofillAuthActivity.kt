package com.openselfhosting.openkey.autofill

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.openselfhosting.openkey.MainActivity

/**
 * Shown when Autofill needs the vault unlocked. Launches [MainActivity] for unlock;
 * finishes with RESULT_OK after [AutofillCredentialCache.sync].
 */
class AutofillAuthActivity : Activity() {
    private var launchedUnlock = false
    private var ignoreNextResume = true

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (AutofillCredentialCache.isUnlocked(this)) {
            setResult(RESULT_OK)
            finish()
            return
        }
        AutofillAuthCoordinator.begin(this)
        startActivity(
            Intent(this, MainActivity::class.java).apply {
                action = MainActivity.ACTION_AUTOFILL_UNLOCK
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            },
        )
        launchedUnlock = true
    }

    override fun onResume() {
        super.onResume()
        if (!launchedUnlock) return
        if (ignoreNextResume) {
            ignoreNextResume = false
            return
        }
        if (AutofillCredentialCache.isUnlocked(this)) {
            AutofillAuthCoordinator.notifyUnlocked()
        } else {
            AutofillAuthCoordinator.cancel()
        }
    }
}
