/// LockedAppRegistry — state app terkunci + unlock aktif + detox mode (PRD §6).
/// Dipakai oleh AccessibilityService (side) dan UI (Flutter) lewat platform channel.
library;

/// Pure logic, testable tanpa Android.
class LockedAppRegistry {
  final Set<String> _locked = {};
  int activeUnlockUntil = 0; // epoch ms; 0 = tidak ada unlock
  bool detoxActive = false;
  Set<String> detoxTargets = {};

  void setLocked(List<String> packages, {required bool locked}) {
    locked ? _locked.addAll(packages) : _locked.removeAll(packages);
  }

  void setDetoxActive(bool active) => detoxActive = active;

  void setDetoxTargets(List<String> packages) => detoxTargets = packages.toSet().cast<String>();

  bool isLocked(String pkg) => _locked.contains(pkg);

  bool isBlocked(String pkg, {required int nowMs}) {
    if (nowMs < activeUnlockUntil) return false; // unlock aktif → bebas
    return detoxActive && detoxTargets.contains(pkg) || _locked.contains(pkg);
  }

  List<String> get lockedList => _locked.toList(growable: false);
}
