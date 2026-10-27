package com.openselfhosting.openkey.autofill

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.LauncherApps
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.drawable.AdaptiveIconDrawable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Process
import android.util.Base64
import android.util.Log
import java.io.ByteArrayOutputStream
import kotlin.math.max
import kotlin.math.min

/**
 * Loads an installed app's launcher icon as a full-color PNG (Base64).
 *
 * Uses the **unthemed** adaptive layers (background + foreground), never the
 * Android 13+ monochrome / themed-icon layer that otherwise renders white.
 */
object AppIconHelper {
    private const val TAG = "OpenKeyAppIcon"
    private const val SIZE = 192
    private const val ALPHA_VISIBLE = 0x18

    fun bitmap(context: Context, packageName: String, sizePx: Int = SIZE): Bitmap? {
        if (packageName.isBlank()) return null
        val drawable = loadDrawable(context, packageName)
            ?: context.applicationInfo.loadIcon(context.packageManager)
            ?: return null
        return try {
            software(drawableToBitmap(drawable, sizePx.coerceAtLeast(16), keepPlate = true))
        } catch (e: Exception) {
            Log.w(TAG, "Bitmap failed for $packageName: ${e.message}")
            null
        }
    }

    fun pngBase64(context: Context, packageName: String): String? {
        if (packageName.isBlank()) return null
        val drawable = loadDrawable(context, packageName)
        if (drawable == null) {
            Log.w(TAG, "No drawable for $packageName")
            return null
        }
        return try {
            val bitmap = drawableToBitmap(drawable, SIZE, keepPlate = false)
            val out = ByteArrayOutputStream()
            if (!bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)) {
                Log.w(TAG, "PNG compress failed for $packageName")
                return null
            }
            val bytes = out.toByteArray()
            if (bytes.isEmpty()) return null
            Log.i(TAG, "Icon OK for $packageName (${bytes.size} bytes)")
            Base64.encodeToString(bytes, Base64.NO_WRAP)
        } catch (e: Exception) {
            Log.w(TAG, "Encode failed for $packageName: ${e.message}")
            null
        }
    }

    private fun loadDrawable(context: Context, packageName: String): Drawable? {
        val pm = context.packageManager

        try {
            val launch = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
            launch.setPackage(packageName)
            val resolved = pm.queryIntentActivities(launch, 0)
            if (resolved.isNotEmpty()) {
                val unthemed = loadUnthemed(pm, resolved[0])
                if (unthemed != null) return unthemed
                val activity = resolved[0].activityInfo
                val icon = activity?.loadUnbadgedIcon(pm)
                    ?: activity?.loadIcon(pm)
                    ?: resolved[0].loadIcon(pm)
                if (icon != null) return icon
            }
        } catch (e: Exception) {
            Log.w(TAG, "queryIntentActivities failed: ${e.message}")
        }

        try {
            val info = pm.getApplicationInfo(packageName, 0)
            val unthemed = loadUnthemed(pm, info)
            if (unthemed != null) return unthemed
        } catch (e: Exception) {
            Log.w(TAG, "getApplicationInfo failed: ${e.message}")
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            try {
                val launcher = context.getSystemService(LauncherApps::class.java)
                val activities = launcher?.getActivityList(packageName, Process.myUserHandle())
                val icon = activities?.firstOrNull()?.getIcon(0)
                if (icon != null) return icon
            } catch (e: Exception) {
                Log.w(TAG, "LauncherApps failed: ${e.message}")
            }
        }

        try {
            return pm.getApplicationIcon(packageName)
        } catch (e: PackageManager.NameNotFoundException) {
            Log.w(TAG, "getApplicationIcon NameNotFound: $packageName")
        } catch (e: Exception) {
            Log.w(TAG, "getApplicationIcon failed: ${e.message}")
        }

        return null
    }

    private fun loadUnthemed(pm: PackageManager, resolved: ResolveInfo): Drawable? {
        val activity = resolved.activityInfo ?: return null
        val iconRes = when {
            activity.icon != 0 -> activity.icon
            activity.applicationInfo.icon != 0 -> activity.applicationInfo.icon
            else -> return null
        }
        return loadUnthemed(pm, activity.applicationInfo, iconRes)
    }

    private fun loadUnthemed(
        pm: PackageManager,
        info: ApplicationInfo,
        iconRes: Int = info.icon,
    ): Drawable? {
        if (iconRes == 0) return null
        return try {
            val res = pm.getResourcesForApplication(info)
            @Suppress("DEPRECATION")
            res.getDrawable(iconRes, null)
        } catch (e: Exception) {
            try {
                pm.getDrawable(info.packageName, iconRes, info)
            } catch (e2: Exception) {
                Log.w(TAG, "unthemed icon failed for ${info.packageName}: ${e2.message}")
                null
            }
        }
    }

    fun software(src: Bitmap): Bitmap {
        if (src.isRecycled) return src
        if (src.config == Bitmap.Config.ARGB_8888) return src
        return src.copy(Bitmap.Config.ARGB_8888, false) ?: src
    }

    private fun drawableToBitmap(
        drawable: Drawable,
        size: Int,
        keepPlate: Boolean,
    ): Bitmap {
        if (drawable is BitmapDrawable) {
            val src = drawable.bitmap
            if (src != null && !src.isRecycled && src.width > 0 && src.height > 0) {
                return if (keepPlate) scaleToSquare(src, size)
                else scaleToFill(trimMargins(src), size)
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && drawable is AdaptiveIconDrawable) {
            return adaptiveArtworkToBitmap(drawable, size, keepPlate)
        }

        val raw = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(raw)
        drawable.setBounds(0, 0, size, size)
        drawable.draw(canvas)
        return if (keepPlate) raw else scaleToFill(trimMargins(raw), size)
    }

    /**
     * Flatten background + foreground like the launcher.
     *
     * Autofill popups are often dark; trimming the plate leaves OpenKey's
     * black foreground square which then disappears. Keep the plate there.
     */
    private fun adaptiveArtworkToBitmap(
        adaptive: AdaptiveIconDrawable,
        size: Int,
        keepPlate: Boolean,
    ): Bitmap {
        if (keepPlate) {
            val out = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(out)
            adaptive.setBounds(0, 0, size, size)
            adaptive.draw(canvas)
            return out
        }

        val fg = adaptive.foreground
        if (fg != null) {
            val fgBmp = renderLayer(fg, size)
            if (hasVisiblePixels(fgBmp) && !isMostlyAchromatic(fgBmp)) {
                return scaleToFill(trimOpaqueBounds(fgBmp), size)
            }
        }

        val canvasSize = size * 2
        val full = Bitmap.createBitmap(canvasSize, canvasSize, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(full)
        adaptive.setBounds(0, 0, canvasSize, canvasSize)
        adaptive.draw(canvas)
        return scaleToFill(trimOpaqueBounds(full), size)
    }

    private fun scaleToSquare(src: Bitmap, size: Int): Bitmap {
        if (src.width == size && src.height == size) return src
        return Bitmap.createScaledBitmap(src, size, size, true)
    }

    private fun renderLayer(drawable: Drawable, size: Int): Bitmap {
        val canvasSize = size * 2
        val tmp = Bitmap.createBitmap(canvasSize, canvasSize, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(tmp)
        val zoom = (canvasSize * 1.5f).toInt()
        val origin = (canvasSize - zoom) / 2
        drawable.setBounds(origin, origin, origin + zoom, origin + zoom)
        drawable.draw(canvas)
        return tmp
    }

    /** White / gray / black glyphs (typical adaptive + themed-icon foregrounds). */
    private fun isMostlyAchromatic(bitmap: Bitmap): Boolean {
        var colorful = 0
        var visible = 0
        val stepX = (bitmap.width / 12).coerceAtLeast(1)
        val stepY = (bitmap.height / 12).coerceAtLeast(1)
        var y = 0
        while (y < bitmap.height) {
            var x = 0
            while (x < bitmap.width) {
                val p = bitmap.getPixel(x, y)
                if (Color.alpha(p) > ALPHA_VISIBLE) {
                    visible++
                    val r = Color.red(p)
                    val g = Color.green(p)
                    val b = Color.blue(p)
                    if (max(r, max(g, b)) - min(r, min(g, b)) > 28) colorful++
                }
                x += stepX
            }
            y += stepY
        }
        if (visible == 0) return true
        return colorful < visible * 0.12f
    }

    private fun trimMargins(src: Bitmap): Bitmap {
        val byAlpha = trimOpaqueBounds(src)
        return trimUniformEdgeColor(byAlpha)
    }

    /** Crops to the bounding box of visible (non-transparent) pixels. */
    private fun trimOpaqueBounds(src: Bitmap): Bitmap {
        val w = src.width
        val h = src.height
        if (w <= 0 || h <= 0) return src

        var top = 0
        var bottom = h - 1
        var left = 0
        var right = w - 1

        fun rowHasVisible(y: Int): Boolean {
            for (x in 0 until w) {
                if (Color.alpha(src.getPixel(x, y)) > ALPHA_VISIBLE) return true
            }
            return false
        }

        fun colHasVisible(x: Int): Boolean {
            for (y in top..bottom) {
                if (Color.alpha(src.getPixel(x, y)) > ALPHA_VISIBLE) return true
            }
            return false
        }

        while (top < bottom && !rowHasVisible(top)) top++
        while (bottom > top && !rowHasVisible(bottom)) bottom--
        while (left < right && !colHasVisible(left)) left++
        while (right > left && !colHasVisible(right)) right--

        val cropW = right - left + 1
        val cropH = bottom - top + 1
        if (cropW <= 0 || cropH <= 0 || (cropW == w && cropH == h)) return src
        if (cropW * cropH < w * h * 0.05f) return src
        return Bitmap.createBitmap(src, left, top, cropW, cropH)
    }

    /**
     * If all four corners share nearly the same opaque color (adaptive plate /
     * brand backdrop), crop rows/columns that are still that plate color.
     */
    private fun trimUniformEdgeColor(src: Bitmap): Bitmap {
        val w = src.width
        val h = src.height
        if (w < 8 || h < 8) return src

        val corners = intArrayOf(
            src.getPixel(0, 0),
            src.getPixel(w - 1, 0),
            src.getPixel(0, h - 1),
            src.getPixel(w - 1, h - 1),
        )
        if (corners.any { Color.alpha(it) < 200 }) return src
        val plate = corners[0]
        if (corners.any { !colorsClose(it, plate) }) return src

        fun rowIsPlate(y: Int): Boolean {
            var plateCount = 0
            val step = (w / 32).coerceAtLeast(1)
            var samples = 0
            var x = 0
            while (x < w) {
                samples++
                val p = src.getPixel(x, y)
                if (colorsClose(p, plate) || Color.alpha(p) < ALPHA_VISIBLE) plateCount++
                x += step
            }
            return plateCount >= samples * 0.92f
        }

        fun colIsPlate(x: Int, top: Int, bottom: Int): Boolean {
            var plateCount = 0
            val step = ((bottom - top + 1) / 32).coerceAtLeast(1)
            var samples = 0
            var y = top
            while (y <= bottom) {
                samples++
                val p = src.getPixel(x, y)
                if (colorsClose(p, plate) || Color.alpha(p) < ALPHA_VISIBLE) plateCount++
                y += step
            }
            return plateCount >= samples * 0.92f
        }

        var top = 0
        var bottom = h - 1
        var left = 0
        var right = w - 1
        while (top < bottom && rowIsPlate(top)) top++
        while (bottom > top && rowIsPlate(bottom)) bottom--
        while (left < right && colIsPlate(left, top, bottom)) left++
        while (right > left && colIsPlate(right, top, bottom)) right--

        val cropW = right - left + 1
        val cropH = bottom - top + 1
        if (cropW <= 0 || cropH <= 0 || (cropW == w && cropH == h)) return src
        // Don't crop away most of the icon.
        if (cropW * cropH < w * h * 0.2f) return src
        return Bitmap.createBitmap(src, left, top, cropW, cropH)
    }

    private fun colorsClose(a: Int, b: Int, tol: Int = 18): Boolean {
        return kotlin.math.abs(Color.red(a) - Color.red(b)) <= tol &&
            kotlin.math.abs(Color.green(a) - Color.green(b)) <= tol &&
            kotlin.math.abs(Color.blue(a) - Color.blue(b)) <= tol &&
            kotlin.math.abs(Color.alpha(a) - Color.alpha(b)) <= tol
    }

    /** BoxFit.cover into a [size]×[size] square. */
    private fun scaleToFill(src: Bitmap, size: Int): Bitmap {
        if (src.width == size && src.height == size) return src
        val scale = max(size.toFloat() / src.width, size.toFloat() / src.height)
        val scaledW = max(1, (src.width * scale).toInt())
        val scaledH = max(1, (src.height * scale).toInt())
        val scaled = Bitmap.createScaledBitmap(src, scaledW, scaledH, true)
        val x = max(0, (scaledW - size) / 2)
        val y = max(0, (scaledH - size) / 2)
        val w = min(size, scaledW - x)
        val h = min(size, scaledH - y)
        if (w == size && h == size && x == 0 && y == 0 && scaledW == size && scaledH == size) {
            return scaled
        }
        return Bitmap.createBitmap(scaled, x, y, w, h)
    }

    private fun hasVisiblePixels(bitmap: Bitmap): Boolean {
        val w = bitmap.width
        val h = bitmap.height
        if (w <= 0 || h <= 0) return false
        val stepX = (w / 8).coerceAtLeast(1)
        val stepY = (h / 8).coerceAtLeast(1)
        var y = 0
        while (y < h) {
            var x = 0
            while (x < w) {
                if (Color.alpha(bitmap.getPixel(x, y)) > ALPHA_VISIBLE) return true
                x += stepX
            }
            y += stepY
        }
        return false
    }
}
