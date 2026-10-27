package com.openselfhosting.openkey.autofill

import android.app.Activity
import java.lang.ref.WeakReference

/**
 * Bridges Autofill authentication PendingIntent with Flutter unlock + credential sync.
 */
object AutofillAuthCoordinator {
    @Volatile
    private var pending: WeakReference<Activity>? = null

    fun begin(activity: Activity) {
        pending = WeakReference(activity)
    }

    fun cancel() {
        val activity = pending?.get()
        pending = null
        activity?.let {
            if (!it.isFinishing) {
                it.setResult(Activity.RESULT_CANCELED)
                it.finish()
            }
        }
    }

    fun notifyUnlocked() {
        val activity = pending?.get()
        pending = null
        activity?.let {
            if (!it.isFinishing) {
                it.setResult(Activity.RESULT_OK)
                it.finish()
            }
        }
    }
}
