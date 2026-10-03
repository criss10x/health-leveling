package com.criss10x.health_leveling

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * LockoutAccessibilityService — mesin blokir app (PRD §6).
 *
 * Mendeteksi app foreground via TYPE_WINDOW_STATE_CHANGED; bila package ada di
 * daftar terkunci dan tidak ada unlock session aktif → buka overlay "App locked"
 * (MainActivity yang menghandle route /locked/:pkg).
 *
 * Shared state: MainActivity (MethodChannel host) dan service ini membaca/menulis
 * partner object di companion (runtime) + SharedPreferences (persist).
 */
class LockoutAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        serviceInfo = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS
            notificationTimeout = EVENT_TIMEOUT_MS
        }
        instance = this
        Log.d(TAG, "connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val pkg = event?.packageName?.toString() ?: return
        if (pkg == BuildConfig.APPLICATION_ID) return
        val state = StateBridge.snapshot(applicationContext)
        if (!state.isBlocked(pkg, nowMs = System.currentTimeMillis())) return
        // buka layar lock (overlay di Flutter agar konsisten tema & mascot Ember)
        val i = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("locked_pkg", pkg)
        }
        startActivity(i)
    }

    override fun onInterrupt() = Unit

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    companion object {
        private const val TAG = "HL_Lockout"
        private const val EVENT_TIMEOUT_MS = 100L
        @Volatile var instance: LockoutAccessibilityService? = null
    }
}
