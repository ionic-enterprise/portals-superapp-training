package io.ionic.superapp.ui.plugins

import android.util.Log
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import java.text.SimpleDateFormat
import java.util.Date

@CapacitorPlugin(name = "Logging")
class LoggingPlugin: Plugin() {

    @PluginMethod
    fun trackActivity(call: PluginCall) {
        try {
            val activityName = call.getString("activityName")

            val dateFormat = SimpleDateFormat("yyyy-dd-MM HH:mm:ss")
            val currentDate = Date()

            Log.d("LOGGING_PLUGIN", "Activity $activityName occurred at ${dateFormat.format(currentDate)}")

            val data = JSObject()
            data.put("success", true)

            call.resolve(data)
        } catch (e: Exception) {
            val data = JSObject()
            data.put("success", false)
            call.resolve(data)
        }
    }

    @PluginMethod
    fun logError(call: PluginCall) {
        try {
            val error = call.getString("error")
            Log.e("LOGGING_PLUGIN", "Error: $error")
            call.resolve()
        } catch(e: Exception) {
            call.reject("Please provide an error to log!")
        }
    }

}