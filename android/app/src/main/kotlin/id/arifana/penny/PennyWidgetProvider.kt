package id.arifana.penny

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File

abstract class PennyWidgetProviderBase : AppWidgetProvider() {

    abstract val layoutId: Int
    abstract val isMedium: Boolean

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)

        val totalText = prefs.getString("today_total_text", "Rp 0") ?: "Rp 0"
        val countLabel = prefs.getString("transaction_label", "dari 0 transaksi")
            ?: "dari 0 transaksi"
        val pennyMessage = prefs.getString("penny_message", "Jangan lupa catat ya! 💕")
            ?: "Jangan lupa catat ya! 💕"
        val bgImagePath = prefs.getString("bg_image_path", null)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, layoutId)
            views.setTextViewText(R.id.widget_total, totalText)
            if (isMedium) {
                views.setTextViewText(R.id.widget_count, countLabel)
                views.setTextViewText(R.id.widget_message, pennyMessage)
            }

            if (!bgImagePath.isNullOrEmpty()) {
                val file = File(bgImagePath)
                if (file.exists()) {
                    try {
                        val bmp = decodeScaled(file.absolutePath, 512)
                        if (bmp != null) {
                            views.setImageViewBitmap(R.id.widget_bg, bmp)
                        } else {
                            views.setImageViewResource(
                                R.id.widget_bg,
                                R.drawable.penny_widget_default_bg
                            )
                        }
                    } catch (_: Throwable) {
                        views.setImageViewResource(
                            R.id.widget_bg,
                            R.drawable.penny_widget_default_bg
                        )
                    }
                }
            } else {
                views.setImageViewResource(
                    R.id.widget_bg,
                    R.drawable.penny_widget_default_bg
                )
            }

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                data = Uri.parse("penny://home")
            }
            val pi = PendingIntent.getActivity(
                context,
                widgetId,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pi)
            views.setOnClickPendingIntent(R.id.widget_total, pi)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    // Downsample to ~maxDim px so the RemoteViews bitmap stays well under the
    // 1MB Binder transaction limit (full-res camera photos overflow it and the
    // launcher shows "Can't load widget").
    private fun decodeScaled(path: String, maxDim: Int): android.graphics.Bitmap? {
        val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(path, bounds)
        val longest = maxOf(bounds.outWidth, bounds.outHeight)
        if (longest <= 0) return null
        var sample = 1
        while (longest / sample > maxDim) sample *= 2
        val opts = BitmapFactory.Options().apply { inSampleSize = sample }
        return BitmapFactory.decodeFile(path, opts)
    }

    companion object {
        fun refresh(context: Context, providerClass: Class<out AppWidgetProvider>) {
            val mgr = AppWidgetManager.getInstance(context)
            val ids = mgr.getAppWidgetIds(ComponentName(context, providerClass))
            if (ids.isNotEmpty()) {
                val intent = Intent(context, providerClass).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(intent)
            }
        }
    }
}

class PennyWidgetSmall : PennyWidgetProviderBase() {
    override val layoutId: Int = R.layout.penny_widget_small
    override val isMedium: Boolean = false
}

class PennyWidgetMedium : PennyWidgetProviderBase() {
    override val layoutId: Int = R.layout.penny_widget_medium
    override val isMedium: Boolean = true
}
