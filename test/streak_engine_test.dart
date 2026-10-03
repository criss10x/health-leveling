import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/engine/streak_engine.dart';

void main() {
  group('StreakEngine', () {
    test('first activity day → streak 1, multiplier ×1.0', () {
      final s = StreakEngine.evaluate(previousStreak: 0, activityToday: true);
      expect(s.streakDays, 1);
      expect(s.multiplier, 1.0);
    });

    test('consecutive day extends streak', () {
      final s = StreakEngine.evaluate(previousStreak: 4, activityToday: true, daysSinceLast: 1);
      expect(s.streakDays, 5);
      expect(s.multiplier, 1.2);
    });

    test('miss 1 day without shield → reset to 0 (§4.3)', () {
      final s = StreakEngine.evaluate(previousStreak: 12, activityToday: false, daysSinceLast: 2);
      expect(s.streakDays, 0);
    });

    test('miss 1 day WITH shield → streak continues (§5)', () {
      final s = StreakEngine.evaluate(
        previousStreak: 12,
        activityToday: false,
        daysSinceLast: 2,
        shieldUsed: true,
      );
      expect(s.streakDays, 13);
    });

    test('multiplier boundaries: 12→13 hari ×1.5, 14 hari ×2.0, 30 hari ×2.5', () {
      expect(StreakEngine.evaluate(previousStreak: 12, activityToday: true, daysSinceLast: 1).multiplier, 1.5);
      expect(StreakEngine.evaluate(previousStreak: 13, activityToday: true, daysSinceLast: 1).multiplier, 2.0);
      expect(StreakEngine.evaluate(previousStreak: 28, activityToday: true, daysSinceLast: 1).multiplier, 2.0);
      expect(StreakEngine.evaluate(previousStreak: 30, activityToday: true, daysSinceLast: 1).multiplier, 2.5);
    });

    test('shield melindungi hari tapi multiplier tetap mengikuti tabel (§4.3)', () {
      // streak 6 + hari ini (dengan shield kemarin) → 7 hari → ×1.5 (bukan ekstra)
      final s = StreakEngine.evaluate(previousStreak: 6, activityToday: true, daysSinceLast: 1, shieldUsed: true);
      expect(s.streakDays, 7);
      expect(s.multiplier, 1.5);
    });
  });
}
