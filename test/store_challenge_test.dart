import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/engine/models.dart';
import 'package:health_leveling/engine/store_engine.dart';
import 'package:health_leveling/engine/challenge_engine.dart';

void main() {
  group('StoreEngine — event replay (PRD §9: satu sumber state)', () {
    test('earn+spend events project balance & sessions', () {
      final e = StoreEngine();
      e.apply(StoreEvent.earn(source: HabitSource.steps2000, coins: 10, streakDays: 0));
      e.apply(StoreEvent.earn(source: HabitSource.pushup5x, coins: 2, streakDays: 0));
      expect(e.balance, 12);
      final exp = e.apply(
        StoreEvent.spendUnlock(pkg: UnlockPackage.m10, cost: 20),
      );
      expect(exp, 'insufficient-funds');
      e.apply(StoreEvent.earn(source: HabitSource.workout15m, coins: 15, streakDays: 0));
      expect(e.balance, 27);
      final ok = e.apply(StoreEvent.spendUnlock(pkg: UnlockPackage.m10, cost: 20, sessionInfo: SessionInfo(startedAt: 1000, expiresAt: 700000)));
      expect(ok, null);
      expect(e.balance, 7);
      expect(e.activeSession!.isActive(1000), true);
      expect(e.activeSession!.isActive(700000), false);
      expect(e.activeSession!.minutesLeft(1000), 12);
    });

    test('events are serialized and replay to identical state', () {
      final a = StoreEngine();
      a.apply(StoreEvent.earn(source: HabitSource.meditation5m, coins: 5, streakDays: 0));
      a.apply(StoreEvent.spendUnlock(pkg: UnlockPackage.m30, cost: 50, sessionInfo: SessionInfo(startedAt: 1, expiresAt: 1800001)));
      a.apply(StoreEvent.streakExtended(days: 7));
      final events = a.events.map((x) => x.toJson()).toList();

      final b = StoreEngine();
      for (final j in events) {
        b.apply(StoreEvent.fromJson(j));
      }
      expect(b.balance, a.balance);
      expect(b.streakDays, a.streakDays);
      expect(b.activeSession?.expiresAt, a.activeSession?.expiresAt);
    });

    test('activity counting for anti-abuse (alreadyToday)', () {
      final e = StoreEngine();
      for (var i = 0; i < 8; i++) {
        e.apply(StoreEvent.activityDone(source: HabitSource.water1glass, dayKey: _refDay));
      }
      expect(e.countToday(HabitSource.water1glass, dayKey: _refDay), 8);
    });
  });

  group('ChallengeEngine — tiers & shields (PRD §5)', () {
    test('tier from daily criteria', () {
      // Fitness Starter: bronze 15+15, silver 30+30, gold 50+50
      expect(ChallengeEngine.tier(pushups: 5, squats: 5), DailyTier.none);
      expect(ChallengeEngine.tier(pushups: 15, squats: 15), DailyTier.bronze);
      expect(ChallengeEngine.tier(pushups: 30, squats: 29), DailyTier.bronze); // dua-duanya harus lolos
      expect(ChallengeEngine.tier(pushups: 30, squats: 30), DailyTier.silver);
      expect(ChallengeEngine.tier(pushups: 50, squats: 50), DailyTier.gold);
      expect(ChallengeEngine.tier(pushups: 50, squats: 49), DailyTier.silver);
    });

    test('miss day uses shield first (2 shields per challenge)', () {
      final run = ChallengeRun(id: 'fs', challengeId: 'fitness-starter', startedDayKey: 0, shieldsLeft: 2);
      final r1 = ChallengeEngine.recordMiss(run);
      expect(r1.shieldsLeft, 1);
      expect(r1.missedDays, 0); // hari dihitung ✅-dengan-shield
      expect(ChallengeEngine.usedShield(run: r1, dayKey: 1), true);
      final r2 = ChallengeEngine.recordMiss(r1);
      expect(r2.shieldsLeft, 0);
      final r3 = ChallengeEngine.recordMiss(r2);
      expect(r3.shieldsLeft, 0);
      expect(r3.missedDays, 1); // habis shield → hari gagal
      expect(r3.brokenPerfect, true);
    });

    test('completion bonus per challenge (§5 tabel koin bonus)', () {
      expect(ChallengeEngine.completionBonus('fitness-starter'), 100);
      expect(ChallengeEngine.completionBonus('dopamine-detox'), 150);
      expect(ChallengeEngine.completionBonus('10k-steps'), 200);
      expect(ChallengeEngine.completionBonus('sleep-reset'), 100);
    });

    test('challenge durations', () {
      expect(ChallengeEngine.durationDays('fitness-starter'), 21);
      expect(ChallengeEngine.durationDays('dopamine-detox'), 7);
      expect(ChallengeEngine.durationDays('10k-steps'), 30);
      expect(ChallengeEngine.durationDays('sleep-reset'), 14);
    });
  });
}

const int _refDay = 20260101;
