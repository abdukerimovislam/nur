package com.midas.aion

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.midas.aion/time_zone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimeZone") {
                // Нативное получение ID таймзоны (например, "Asia/Bishkek")
                val timeZoneId = TimeZone.getDefault().id
                result.success(timeZoneId)
            } else {
                result.notImplemented()
            }
        }
    }
}