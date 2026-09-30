package com.focuspulse

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.*
import android.widget.RemoteViews

class CalendarWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_calendar_heatmap)

        // Generate the circular calendar grid bitmap
        val calendarBitmap = renderCalendarBitmap(context)
        views.setImageViewBitmap(R.id.widget_calendar_image, calendarBitmap)

        // Launch app on widget tap
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun renderCalendarBitmap(context: Context): Bitmap {
        val width = 480
        val height = 360
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 4f
            color = Color.parseColor("#4CAF50")
        }

        val textPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.WHITE
            textSize = 22f
            textAlign = Paint.Align.CENTER
            typeface = Typeface.DEFAULT_BOLD
        }

        val cols = 7
        val cellWidth = width / cols
        val cellHeight = height / 5
        val radius = 22f

        var day = 1
        val startCol = 2 // September 2026 starts on Tuesday (col 2)
        val totalDays = 30

        for (row in 0 until 5) {
            for (col in 0 until cols) {
                if (row == 0 && col < startCol) continue
                if (day > totalDays) break

                val cx = (col * cellWidth + cellWidth / 2).toFloat()
                val cy = (row * cellHeight + cellHeight / 2).toFloat()

                // Draw circular ring matching screenshot 15145.jpg
                canvas.drawCircle(cx, cy, radius, circlePaint)

                // Draw date text
                val textBounds = Rect()
                val dayStr = day.toString()
                textPaint.getTextBounds(dayStr, 0, dayStr.length, textBounds)
                canvas.drawText(dayStr, cx, cy + textBounds.height() / 2f, textPaint)

                day++
            }
        }

        return bitmap
    }
}
