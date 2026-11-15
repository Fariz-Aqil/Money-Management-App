package com.example.money_management

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mm/native").setMethodCallHandler { call, result ->
            when (call.method) {
                "pending" -> {
                    val sp = getSharedPreferences("mm_pending", MODE_PRIVATE)
                    result.success(sp.getString("items", "[]"))
                    sp.edit().putString("items", "[]").apply()
                }
                "hasAccess" -> {
                    val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: ""
                    result.success(flat.contains(packageName))
                }
                "openSettings" -> {
                    startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
