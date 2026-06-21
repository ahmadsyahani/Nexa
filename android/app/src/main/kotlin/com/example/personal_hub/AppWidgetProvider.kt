package com.example.personal_hub

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class AppWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                val undoneTasks = widgetData.getString("undone_tasks", "Tugas Belum Selesai: 0")
                val nearestDeadline = widgetData.getString("nearest_deadline", "Deadline: -")
                
                setTextViewText(R.id.widget_undone_tasks, undoneTasks)
                setTextViewText(R.id.widget_nearest_deadline, nearestDeadline)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
