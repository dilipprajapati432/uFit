package com.fittrack.ufit

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class WaterWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.water_widget).apply {
                val total = widgetData.getInt("water_total", 0)
                val goal = widgetData.getInt("water_goal", 2500)
                
                setTextViewText(R.id.widget_title, "💧 Water Goal")
                setTextViewText(R.id.widget_value, "$total / $goal ml")
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
