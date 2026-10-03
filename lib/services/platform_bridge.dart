/// PlatformBridge — Dart side of the health_leveling/engine channel.
/// Fallback: tanpa Android (test/desk), semua call no-op aman.
library;

import 'package:flutter/services.dart';
import '../models/app_registry.dart';

class PlatformBridge {
  PlatformBridge._();

  static const MethodChannel _ch = MethodChannel('health_leveling/engine');

  /// Normalisasi: error channel → null (desktop/test), boolean → boolean.
  static Future<bool> isAccessibilityEnabled() async {
    try {
      return await _ch.invokeMethod<bool>('isAccessibilityEnabled') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await _ch.invokeMethod('openAccessibilitySettings');
    } on MissingPluginException {
      // desktop/test: no-op
    } on PlatformException {
      // device oddities: biarkan silent, UI punya instruksi manual
    }
  }

  static Future<void> saveRegistry(LockedAppRegistry reg) async {
    final until = reg.activeUnlockUntil;
    try {
      await _ch.invokeMethod('saveRegistry', {
        'locked': reg.lockedList,
        'unlockUntil': until,
        'detox': reg.detoxActive,
        'detoxTargets': reg.detoxTargets.toList(),
      });
    } on MissingPluginException {
      // desktop/test: no-op
    } on PlatformException {
      // no-op
    }
  }

  static Future<String?> lockedPkg() async {
    try {
      return await _ch.invokeMethod<String>('lockedPkg');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  static Future<void> clearLockedPkg() async {
    try {
      await _ch.invokeMethod('clearLockedPkg');
    } on MissingPluginException {
      // no-op
    } on PlatformException {
      // no-op
    }
  }
}
