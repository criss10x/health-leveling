/// StreakEngine — evaluasi streak harian (PRD §4.3 + §5 shield).
library;

import 'models.dart';

class StreakState {
  const StreakState({required this.streakDays, required this.multiplier});
  final int streakDays;
  final double multiplier;
}

class StreakEngine {
  StreakEngine._();

  /// [previousStreak] streak sebelum hari ini.
  /// [activityToday] ada >=1 habit selesai hari ini?
  /// [daysSinceLast] hari sejak aktivitas terakhir (0 = hari ini, 1 = kemarin, dst).
  /// [shieldUsed] hari bolong dilindungi shield (hari dihitung ✅-dengan-shield).
  static StreakState evaluate({
    required int previousStreak,
    required bool activityToday,
    int daysSinceLast = 0,
    bool shieldUsed = false,
  }) {
    if (activityToday) {
      final streak = daysSinceLast <= 1 ? previousStreak + 1 : 0;
      return StreakState(streakDays: streak, multiplier: multiplierFor(streak).value);
    }
    // tidak ada aktivitas hari ini
    if (shieldUsed) {
      // hari shield dihitung ✅ (PRD §5) → streak bertahan dan bertambah seperti hari sukses
      final streak = previousStreak + 1;
      return StreakState(streakDays: streak, multiplier: multiplierFor(streak).value);
    }
    return const StreakState(streakDays: 0, multiplier: 1.0);
  }
}
