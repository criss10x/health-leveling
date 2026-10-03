import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/engine/models.dart';
import 'package:health_leveling/engine/coins.dart';

void main() {
  group('CoinEngine — earning (PRD §4.1)', () {
    test('2000 steps = 10 coins', () {
      expect(CoinEngine.award(HabitSource.steps2000, streakDays: 0).coins, Ds.coinsPer2000Steps);
    });

    test('push-up 5x = 2, squat 5x = 2, workout 15m = 15', () {
      expect(CoinEngine.award(HabitSource.pushup5x).coins, 2);
      expect(CoinEngine.award(HabitSource.squat5x).coins, 2);
      expect(CoinEngine.award(HabitSource.workout15m).coins, 15);
    });

    test('streak multiplier table (PRD §4.3)', () {
      // 0–2 hari ×1.0, 3–6 ×1.2, 7–13 ×1.5, 14–29 ×2.0, 30+ ×2.5
      expect(CoinEngine.multiplier(0), 1.0);
      expect(CoinEngine.multiplier(2), 1.0);
      expect(CoinEngine.multiplier(3), 1.2);
      expect(CoinEngine.multiplier(6), 1.2);
      expect(CoinEngine.multiplier(7), 1.5);
      expect(CoinEngine.multiplier(13), 1.5);
      expect(CoinEngine.multiplier(14), 2.0);
      expect(CoinEngine.multiplier(29), 2.0);
      expect(CoinEngine.multiplier(30), 2.5);
    });

    test('award applies streak multiplier with floor rounding', () {
      // 10 coins × 1.5 = 15
      final a = CoinEngine.award(HabitSource.steps2000, streakDays: 7);
      expect(a.coins, 15);
      // 2 coins × 1.2 = 2.4 → floor 2 (koin bulat, floor)
      final b = CoinEngine.award(HabitSource.pushup5x, streakDays: 3);
      expect(b.coins, 2);
      // 15 × 2.0 = 30
      expect(CoinEngine.award(HabitSource.workout15m, streakDays: 14).coins, 30);
    });

    test('shield does not boost multiplier — only protects days (§4.3)', () {
      // dengan streak 7 + shield aktif, multiplier tetap ×1.5 (bukan lebih)
      final a = CoinEngine.award(HabitSource.steps2000, streakDays: 7, shieldsUsed: 1);
      expect(a.coins, 15);
    });
  });

  group('CoinEngine — spending (PRD §4.2)', () {
    test('unlock packages: 10m=20, 30m=50, 60m=90', () {
      expect(Ds.coinsPer10MinUnlock, 20);
      expect(UnlockPackage.m10.price, 20);
      expect(UnlockPackage.m30.price, 50);
      expect(UnlockPackage.m60.price, 90);
    });

    test('cannot spend more than balance', () {
      expect(() => CoinEngine.spend(balance: 19, pkg: UnlockPackage.m10), throwsArgumentError);
      // tepat 19 + earn 1? — cukup: 19 < 20 gagal, 20 tepat sukses
      final s = CoinEngine.spend(balance: 20, pkg: UnlockPackage.m10);
      expect(s.cost, 20);
    });
  });

  group('Anti-abuse v1 (PRD §4.4)', () {
    test('water tap max 8/day, reps max 100/day', () {
      expect(CoinEngine.maxPerDay(HabitSource.water1glass), 8);
      expect(CoinEngine.maxPerDay(HabitSource.pushup5x), 20); // 100 rep / 5
      expect(CoinEngine.maxPerDay(HabitSource.squat5x), 20);
      // steps/workout dari Health Connect: sekali verifikasi per hari
      expect(CoinEngine.maxPerDay(HabitSource.steps2000), 1);
      expect(CoinEngine.maxPerDay(HabitSource.workout15m), 1);
    });

    test('award rejects exceeding daily cap', () {
      expect(() => CoinEngine.award(HabitSource.water1glass, alreadyToday: 8), throwsStateError);
    });

    test('steps/workout manual input rejected (HC only)', () {
      expect(() => CoinEngine.award(HabitSource.steps2000, manual: true), throwsArgumentError);
      expect(() => CoinEngine.award(HabitSource.workout15m, manual: true), throwsArgumentError);
    });
  });

  group('CoinEngine — extra sources (§4.1 meds/air/tidur)', () {
    test('meditation 5m = +5, water glass = +1, sleep ≥7h = +10', () {
      expect(CoinEngine.award(HabitSource.meditation5m).coins, 5);
      expect(CoinEngine.award(HabitSource.water1glass).coins, 1);
      expect(CoinEngine.award(HabitSource.sleep7h).coins, 10);
    });
  });
}
