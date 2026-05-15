package com.example.flutter_application_1

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.res.Configuration

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.epn.taller/resources"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getNativeResources") {
                val resources = mapOf(
                    "text" to getString(R.string.app_text),
                    "textColor" to String.format("#%06X", (0xFFFFFF and getColor(R.color.text_color))),
                    "bgColor" to String.format("#%06X", (0xFFFFFF and getColor(R.color.bg_color)))
                )
                result.success(resources)
            } else {
                result.notImplemented()
            }
        }
    }
}