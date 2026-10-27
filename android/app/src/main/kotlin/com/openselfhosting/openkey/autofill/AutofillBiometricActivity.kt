package com.openselfhosting.openkey.autofill

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.autofill.Dataset
import android.view.autofill.AutofillId
import android.view.autofill.AutofillManager
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import com.openselfhosting.openkey.R

/**
 * Confirms the user with biometrics before returning Autofill values for a dataset.
 */
class AutofillBiometricActivity : FragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val uuid = intent.getStringExtra(EXTRA_CREDENTIAL_UUID).orEmpty()
        val usernameIds = parcelableAutofillIds(EXTRA_USERNAME_IDS)
        val passwordIds = parcelableAutofillIds(EXTRA_PASSWORD_IDS)
        val credential = AutofillCredentialCache.credentials(this)
            .firstOrNull { it.uuid == uuid }

        if (uuid.isEmpty() || credential == null ||
            (usernameIds.isEmpty() && passwordIds.isEmpty())
        ) {
            setResult(RESULT_CANCELED)
            finish()
            return
        }

        val authenticators =
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.BIOMETRIC_WEAK
        val canAuthenticate = BiometricManager.from(this)
            .canAuthenticate(authenticators)
        if (canAuthenticate != BiometricManager.BIOMETRIC_SUCCESS) {
            // Setting was enabled but biometrics became unavailable — fill anyway.
            deliverDataset(credential, usernameIds, passwordIds)
            return
        }

        val executor = ContextCompat.getMainExecutor(this)
        val prompt = BiometricPrompt(
            this,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    result: BiometricPrompt.AuthenticationResult,
                ) {
                    deliverDataset(credential, usernameIds, passwordIds)
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    setResult(RESULT_CANCELED)
                    finish()
                }

                override fun onAuthenticationFailed() {
                    // Keep the prompt open for another attempt.
                }
            },
        )

        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle(getString(R.string.autofill_biometric_title))
            .setSubtitle(getString(R.string.autofill_biometric_subtitle))
            .setNegativeButtonText(getString(R.string.autofill_biometric_cancel))
            .setAllowedAuthenticators(authenticators)
            .build()
        prompt.authenticate(info)
    }

    private fun deliverDataset(
        credential: AutofillCredential,
        usernameIds: List<AutofillId>,
        passwordIds: List<AutofillId>,
    ) {
        val presentation = AutofillPresentations.credential(
            this,
            credential.username.ifBlank { credential.title }
                .ifBlank { getString(R.string.autofill_login) },
            credential.decodedIcon(48) ?: AppIconHelper.bitmap(this, packageName),
        )
        val dataset = Dataset.Builder()
        AutofillPresentations.fill(
            dataset = dataset,
            usernameIds = usernameIds,
            passwordIds = passwordIds,
            username = credential.username,
            password = credential.password,
            menu = presentation,
            dialog = presentation,
            inline = null,
        )
        val reply = Intent().putExtra(
            AutofillManager.EXTRA_AUTHENTICATION_RESULT,
            dataset.build(),
        )
        setResult(RESULT_OK, reply)
        finish()
    }

    @Suppress("DEPRECATION")
    private fun parcelableAutofillIds(key: String): List<AutofillId> {
        val list = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayListExtra(key, AutofillId::class.java)
        } else {
            intent.getParcelableArrayListExtra(key)
        }
        return list?.filterNotNull().orEmpty()
    }

    companion object {
        const val EXTRA_CREDENTIAL_UUID = "credential_uuid"
        const val EXTRA_USERNAME_IDS = "username_ids"
        const val EXTRA_PASSWORD_IDS = "password_ids"
    }
}
