import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/engine/models.dart';
import 'package:health_leveling/engine/persistence.dart';
import 'package:health_leveling/engine/store_engine.dart';
import 'package:health_leveling/services/daily_engine.dart';

void main() {
  group('DailyEngine — menutup loop HC → koin → ledger (PRD §3-4)', () {
    test('HC steps 2500 → award 10 koin, ledger bertambah', () async {
      final store = StoreEngine();
      final adapter = InMemoryPersistence();
      final engine = DailyEngine(store: store, persistence: adapter, clock: () => DateTime(2026, 10, 14, 8));

      final result = await engine.syncHealth(
        steps: 2500, workoutMinutes: 0, sleepMinutes: 0,
      );
      expect(result.awardedCoins, 10);
      expect(store.balance, 10);
      expect(store.events.length, 2, reason: 'earn + streak-extend');
      expect(store.countToday(HabitSource.steps2000, dayKey: 20261014), 1);
    });

    test('HC dua kali sehari → koin kedua ditolak (anti-abuse §4.4)', () async {
      final store = StoreEngine();
      final adapter = InMemoryPersistence();
      final engine = DailyEngine(store: store, persistence: adapter, clock: () => DateTime(2026, 10, 14, 8));

      await engine.syncHealth(steps: 2500);
      final second = await engine.syncHealth(steps: 9000);
      expect(second.awardedCoins, 0, reason: 'sudah diverifikasi hari ini');
      expect(store.balance, 10);
    });

    test('syncHealth lengkap: steps+workout+sleep semuanya lolos threshold', () async {
      final store = StoreEngine();
      final engine = DailyEngine(
        store: store, persistence: InMemoryPersistence(),
        clock: () => DateTime(2026, 10, 14, 8),
      );
      final r = await engine.syncHealth(steps: 6000, workoutMinutes: 30, sleepMinutes: 450);
      expect(r.awardedCoins, 10 + 15 + 10);
      expect(store.balance, 35);
    });

    test('di bawah threshold → tidak ada koin', () async {
      final store = StoreEngine();
      final engine = DailyEngine(
        store: store, persistence: InMemoryPersistence(),
        clock: () => DateTime(2026, 10, 14, 8),
      );
      final r = await engine.syncHealth(steps: 1500, workoutMinutes: 10, sleepMinutes: 300);
      expect(r.awardedCoins, 0);
      expect(store.balance, 0);
    });

    test('manual habit (push-up) lewat jalur terpisah dengan cap', () async {
      final store = StoreEngine();
      final engine = DailyEngine(
        store: store, persistence: InMemoryPersistence(),
        clock: () => DateTime(2026, 10, 14, 8),
      );
      // 20 awards = 100 rep / 5 — cap tercapai
      for (var i = 0; i < 20; i++) {
        await engine.completeManual(HabitSource.pushup5x);
      }
      expect(store.balance, 40);
      expect(() => engine.completeManual(HabitSource.pushup5x), throwsStateError);
    });

    test('streak diperbarui saat pertama award hari itu', () async {
      final store = StoreEngine();
      final engine = DailyEngine(
        store: store, persistence: InMemoryPersistence(),
        clock: () => DateTime(2026, 10, 15, 8), // besoknya
      );
      // simulasi: streak kemarin 6 → hari ini award → 7 → ×1.5
      store.apply(StoreEvent.streakExtended(days: 6));
      final r = await engine.syncHealth(steps: 2500);
      // award pertama pakai multiplier LAMA (6 → ×1.2), lalu streak naik
      expect(r.awardedCoins, 12); // 10 × 1.2
      expect(store.streakDays, 7);
    });

    test('persist dipanggil tiap award', () async {
      final adapter = InMemoryPersistence();
      final store = StoreEngine();
      final engine = DailyEngine(store: store, persistence: adapter, clock: () => DateTime(2026, 10, 14, 8));
      await engine.syncHealth(steps: 2500);
      final writesAfterOne = adapter.writes;
      expect(writesAfterOne, 1);
    });
  });
}
