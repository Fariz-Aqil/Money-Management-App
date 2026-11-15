package com.example.money_management

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONArray
import org.json.JSONObject

// Menangkap notifikasi yang memuat nominal "Rp" lalu menyimpannya.
// Aplikasi Flutter membaca dan memprosesnya saat dibuka.
class NotifService : NotificationListenerService() {
    private val ignored = setOf("com.whatsapp", "org.telegram.messenger", "com.google.android.apps.messaging")

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName || sbn.packageName in ignored) return
        val e = sbn.notification.extras
        val title = e.getCharSequence("android.title")?.toString() ?: ""
        val text = (e.getCharSequence("android.bigText") ?: e.getCharSequence("android.text"))?.toString() ?: ""
        if (!"$title $text".contains("Rp", ignoreCase = true)) return
        val sp = getSharedPreferences("mm_pending", MODE_PRIVATE)
        val arr = JSONArray(sp.getString("items", "[]"))
        arr.put(
            JSONObject()
                .put("id", "${sbn.packageName}-${sbn.postTime}")
                .put("pkg", sbn.packageName)
                .put("title", title)
                .put("text", text)
                .put("time", sbn.postTime)
        )
        sp.edit().putString("items", arr.toString()).apply()
    }
}
