package com.criss10x.health_leveling

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

/**
 * StateBridge — jembatan state Flutter ↔ Kotlin (SharedPreferences + in-memory).
 * Key versi dimulai 'hl_' agar eksplisit milik Health Leveling.
 */
object StateBridge {

    private const val PREFS = "hl_state"
    private const val K_LOCKED = "hl_locked_apps"
    private const val K_UNLOCK_UNTIL = "hl_unlock_until"
    private const val K_DETOX = "hl_detox"
    private const val K_DETOX_TARGETS = "hl_detox_targets"

    fun save(context: Context, locked: List<String>, unlockUntil: Long, detox: Boolean, detoxTargets: List<String>) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().apply {
            putString(K_LOCKED, JSONArray(locked).toString())
            putLong(K_UNLOCK_UNTIL, unlockUntil)
            putBoolean(K_DETOX, detox)
            putString(K_DETOX_TARGETS, JSONArray(detoxTargets).toString())
            apply()
        }
    }

    fun snapshot(context: Context): RegistryState {
        val p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val locked = jsonList(p.getString(K_LOCKED, "[]"))
        val detox = jsonList(p.getString(K_DETOX_TARGETS, "[]"))
        return RegistryState(
            locked = locked,
            unlockUntil = p.getLong(K_UNLOCK_UNTIL, 0L),
            detox = p.getBoolean(K_DETOX, false),
            detoxTargets = detox,
        )
    }

    private fun jsonList(raw: String?): List<String> =
        try {
            val a = JSONArray(raw)
            (0 until a.length()).map { a.getString(it) }
        } catch (_: Exception) {
            emptyList()
        }
}

/** Mirror LockedAppRegistry (Dart) untuk sisi Kotlin (pure logic, testable). */
data class RegistryState(
    val locked: List<String>,
    val unlockUntil: Long,
    val detox: Boolean,
    val detoxTargets: List<String>,
) {
    fun isBlocked(pkg: String, nowMs: Long): Boolean {
        if (nowMs < unlockUntil) return false
        return (detox && detoxTargets.contains(pkg)) || locked.contains(pkg)
    }
}
