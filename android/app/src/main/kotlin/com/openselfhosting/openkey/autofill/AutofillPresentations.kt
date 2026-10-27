package com.openselfhosting.openkey.autofill

import android.app.PendingIntent
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BlendMode
import android.graphics.drawable.Icon
import android.os.Build
import android.service.autofill.Dataset
import android.service.autofill.Field
import android.service.autofill.InlinePresentation
import android.service.autofill.Presentations
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import android.widget.inline.InlinePresentationSpec
import androidx.annotation.DrawableRes
import androidx.autofill.inline.UiVersions
import androidx.autofill.inline.v1.InlineSuggestionUi
import com.openselfhosting.openkey.R

/**
 * Google-style Autofill row / keyboard-chip presentations.
 *
 * Menu + dialog RemoteViews show icon, username, and a masked password.
 * Inline chips (IME suggestion strip) are built when the keyboard asks for them.
 */
object AutofillPresentations {
    fun credential(
        context: Context,
        username: String,
        icon: Bitmap?,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.autofill_dataset_item)
        views.setTextViewText(R.id.autofill_dataset_username, username)
        views.setTextViewText(
            R.id.autofill_dataset_password,
            context.getString(R.string.autofill_password_masked),
        )
        if (icon != null) {
            views.setImageViewBitmap(R.id.autofill_dataset_icon, icon)
        } else {
            views.setImageViewResource(R.id.autofill_dataset_icon, R.drawable.ic_autofill_key)
        }
        return views
    }

    fun action(
        context: Context,
        label: String,
        icon: Bitmap?,
        @DrawableRes trailingRes: Int = R.drawable.ic_autofill_key,
        showTrailing: Boolean = true,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.autofill_dataset_action)
        views.setTextViewText(R.id.autofill_action_label, label)
        if (icon != null) {
            views.setImageViewBitmap(R.id.autofill_action_icon, AppIconHelper.software(icon))
        } else {
            views.setImageViewResource(R.id.autofill_action_icon, R.mipmap.ic_launcher)
        }
        if (showTrailing) {
            views.setImageViewResource(R.id.autofill_action_trailing, trailingRes)
            views.setViewVisibility(R.id.autofill_action_trailing, android.view.View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.autofill_action_trailing, android.view.View.GONE)
        }
        return views
    }

    /** Bitmap icon that keeps original colors; the IME otherwise tints it white. */
    fun iconFromBitmap(bitmap: Bitmap): Icon {
        val icon = Icon.createWithBitmap(bitmap)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            icon.setTintBlendMode(BlendMode.DST)
        }
        return icon
    }

    fun inline(
        spec: InlinePresentationSpec?,
        title: String,
        subtitle: String?,
        icon: Icon,
        attribution: PendingIntent,
    ): InlinePresentation? {
        if (spec == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.R) return null
        return try {
            val versions = UiVersions.getVersions(spec.style)
            if (!versions.contains(UiVersions.INLINE_UI_VERSION_1)) return null
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                icon.setTintBlendMode(BlendMode.DST)
            }
            val content = InlineSuggestionUi.newContentBuilder(attribution)
                .setContentDescription(title)
                .setTitle(title)
                .setStartIcon(icon)
            if (!subtitle.isNullOrBlank()) {
                content.setSubtitle(subtitle)
            }
            InlinePresentation(content.build().slice, spec, false)
        } catch (_: Exception) {
            null
        }
    }

    fun fill(
        dataset: Dataset.Builder,
        usernameIds: List<AutofillId>,
        passwordIds: List<AutofillId>,
        username: String?,
        password: String?,
        menu: RemoteViews,
        dialog: RemoteViews?,
        inline: InlinePresentation?,
    ): Dataset.Builder {
        for (id in usernameIds) {
            setFieldValue(
                dataset = dataset,
                id = id,
                value = username?.let { AutofillValue.forText(it) },
                menu = menu,
                dialog = dialog,
                inline = inline,
            )
        }
        for (id in passwordIds) {
            setFieldValue(
                dataset = dataset,
                id = id,
                value = password?.let { AutofillValue.forText(it) },
                menu = menu,
                dialog = dialog,
                inline = inline,
            )
        }
        return dataset
    }

    fun authenticate(
        dataset: Dataset.Builder,
        fillIds: List<AutofillId>,
        menu: RemoteViews,
        dialog: RemoteViews?,
        inline: InlinePresentation?,
    ): Dataset.Builder {
        for (id in fillIds) {
            setFieldValue(
                dataset = dataset,
                id = id,
                value = null,
                menu = menu,
                dialog = dialog,
                inline = inline,
            )
        }
        return dataset
    }

    @Suppress("DEPRECATION")
    private fun setFieldValue(
        dataset: Dataset.Builder,
        id: AutofillId,
        value: AutofillValue?,
        menu: RemoteViews,
        dialog: RemoteViews?,
        inline: InlinePresentation?,
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val presentations = Presentations.Builder()
                .setMenuPresentation(menu)
                .apply {
                    if (dialog != null) setDialogPresentation(dialog)
                    if (inline != null) setInlinePresentation(inline)
                }
                .build()
            val field = Field.Builder()
                .setPresentations(presentations)
                .apply { if (value != null) setValue(value) }
                .build()
            dataset.setField(id, field)
            return
        }
        if (inline != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            dataset.setValue(id, value, menu, inline)
            return
        }
        dataset.setValue(id, value, menu)
    }
}
