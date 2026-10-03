package com.criss10x.health_leveling

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "health_leveling/engine"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    val on = isServiceEnabled()
                    result.success(on)
                }
                "openAccessibilitySettings" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                "saveRegistry" -> {
                    // args: locked: List<String>, unlockUntil: Long, detox: Boolean, detoxTargets: List<String>
                    val locked = (call.argument<List<Any?>>("locked") ?: emptyList()).map { it.toString() }
                    val unlockUntil = (call.argument<Number>("unlockUntil") ?: 0).toLong()
                    val detox = call.argument<Boolean>("detox") ?: false
                    val detoxTargets = (call.argument<List<Any?>>("detoxTargets") ?: emptyList()).map { it.toString() }
                    StateBridge.save(this, locked, unlockUntil, detox, detoxTargets)
                    result.success(true)
                }
                "lockedPkg" -> result.success(intent?.getStringExtra("locked_pkg"))
                "clearLockedPkg" -> {
                    intent?.removeExtra("locked_pkg")
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isServiceEnabled(): Boolean {
        val enabled = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        return enabled.split(':').any {
            it.contains("$packageName/.LockoutAccessibilityService") || it.contains("LockoutAccessibilityService")
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
