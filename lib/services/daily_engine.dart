/// DailyEngine — loop produk penuh (PRD §3-4):
/// HC/manual data → CoinEngine (threshold + multiplier + cap) → StoreEngine
/// (ledger event) → Persistence (snapshot yang bisa direplay).
library;

import '../engine/coins.dart';
import '../engine/models.dart';
import '../engine/persistence.dart';
import '../engine/store_engine.dart';

class DailyResult {
  const DailyResult({required this.awardedCoins, this.details = const []});
  final int awardedCoins;
  final List<CoinResult> details;
}

class DailyEngine {
  DailyEngine({required this.store, required this.persistence, DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final StoreEngine store;
  final PersistenceAdapter persistence;
  final DateTime Function() _now;

  /// Sink data Health Connect hari ini → award koin per sumber yang lolos.
  /// Sekali verifikasi final per sumber per hari (§4.4) — award kedua ditolak.
  Future<DailyResult> syncHealth({
    required int steps,
    int workoutMinutes = 0,
    int sleepMinutes = 0,
  }) async {
    final day = _dayKey();
    final results = <CoinResult>[];
    var total = 0;

    Future<void> award(HabitSource s, bool passed) async {
      if (!passed) return;
      final already = store.countToday(s, dayKey: day);
      if (already >= CoinEngine.maxPerDay(s)) return; // sudah diverifikasi hari ini
      final r = CoinEngine.award(s, streakDays: store.streakDays, alreadyToday: already);
      store.apply(StoreEvent.earn(source: s, coins: r.coins, streakDays: store.streakDays, dayKey: day));
      total += r.coins;
      results.add(r);
    }

    await award(HabitSource.steps2000, HealthThresholds.steps(steps));
    await award(HabitSource.workout15m, HealthThresholds.workout(workoutMinutes));
    await award(HabitSource.sleep7h, HealthThresholds.sleep(sleepMinutes));

    if (total > 0) {
      _extendStreak();
      await Persistence.save(persistence, store);
    }
    return DailyResult(awardedCoins: total, details: results);
  }

  /// Habit manual (push-up/squat/meditasi/air) — jalur tap UI.
  Future<int> completeManual(HabitSource s) async {
    final day = _dayKey();
    final already = store.countToday(s, dayKey: day);
    final r = CoinEngine.award(s, streakDays: store.streakDays, alreadyToday: already, manual: s.hpConnectVerified);
    store.apply(StoreEvent.earn(source: s, coins: r.coins, streakDays: store.streakDays, dayKey: day));
    _extendStreak();
    await Persistence.save(persistence, store);
    return r.coins;
  }

  /// Belanja unlock: spend dari saldo + tulis event + persist.
  Future<UnlockSession?> purchaseUnlock(UnlockPackage pkg) async {
    final now = _now().millisecondsSinceEpoch;
    final session = SessionInfo(
      startedAt: now,
      expiresAt: now + pkg.minutes * 60000,
    );
    final outcome = store.apply(StoreEvent.spendUnlock(pkg: pkg, cost: pkg.price, sessionInfo: session));
    if (outcome != null) return null; // insufficient-funds
    await Persistence.save(persistence, store);
    return store.activeSession;
  }

  int? _streakExtendedOnDay;

  /// Streak: extend SEKALI per hari (award pertama); award rep berikutnya tidak
  /// menaikkan streak lagi (multiplier hari ini tetap).
  void _extendStreak() {
    final day = _dayKey();
    if (_streakExtendedOnDay == day) return;
    _streakExtendedOnDay = day;
    store.apply(StoreEvent.streakExtended(days: store.streakDays + 1));
  }

  int _dayKey() {
    final d = _now();
    return d.year * 10000 + d.month * 100 + d.day;
  }
}

/// Threshold checker — HealthConnectLogic logic dipindah ke sini agar DailyEngine
/// tidak import plugin `health` (test tanpa plugin binding).
abstract final class HealthThresholds {
  static bool steps(int steps) => steps >= 2000;
  static bool workout(int minutes) => minutes >= 15;
  static bool sleep(int minutes) => minutes >= 420; // 7 jam
}
