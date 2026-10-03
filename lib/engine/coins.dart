/// CoinEngine — aturan ekonomi koin (PRD §4). Pure logic, no I/O.
library;

import 'models.dart';

class CoinEngine {
  CoinEngine._();

  /// Batas per hari per sumber (§4.4): air max 8, rep max 100 (÷5 per award = 20),
  /// sumber Health Connect sekali verifikasi final per hari.
  static int maxPerDay(HabitSource s) {
    switch (s) {
      case HabitSource.water1glass:
        return 8;
      case HabitSource.pushup5x:
      case HabitSource.squat5x:
        return 20;
      case HabitSource.steps2000:
      case HabitSource.workout15m:
      case HabitSource.meditation5m:
      case HabitSource.sleep7h:
        return 1;
    }
  }

  static double multiplier(int streakDays) => multiplierFor(streakDays).value;

  /// Koin yang diberikan untuk satu award (base × multiplier, floor).
  static CoinResult award(
    HabitSource source, {
    int streakDays = 0,
    int alreadyToday = 0,
    int shieldsUsed = 0,
    bool manual = false,
  }) {
    if (manual && source.hpConnectVerified) {
      throw ArgumentError('Manual input not allowed for ${source.name} (Health Connect only)');
    }
    if (alreadyToday >= maxPerDay(source)) {
      throw StateError('Daily cap reached for ${source.name} ($alreadyToday/${maxPerDay(source)})');
    }
    final mult = multiplier(streakDays); // shields tidak memengaruhi multiplier
    final coins = (source.baseCoins * mult).floor();
    return CoinResult(source: source, coins: coins, multiplier: mult);
  }

  /// Belanja unlock — cukup saldo? (tidak mutasi state; caller menulis ledger).
  static SpendResult spend({required int balance, required UnlockPackage pkg}) {
    if (balance < pkg.price) {
      throw ArgumentError('Not enough coins: $balance < ${pkg.price}');
    }
    return SpendResult(pkg: pkg, cost: pkg.price, minutes: pkg.minutes);
  }
}

class CoinResult {
  const CoinResult({required this.source, required this.coins, required this.multiplier});
  final HabitSource source;
  final int coins;
  final double multiplier;

  String get explain => '${source.name}: $source.coins ×$multiplier = $coins';
}

class SpendResult {
  const SpendResult({required this.pkg, required this.cost, required this.minutes});
  final UnlockPackage pkg;
  final int cost;
  final int minutes;
}
