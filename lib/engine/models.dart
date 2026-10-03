/// Health Leveling — domain models (pure data, JSON-serializable).
/// One source of state (PRD §9): store events replay into these.
library;

abstract final class Ds {
  static const int coinsPer2000Steps = 10;
  static const int coinsPushups5x = 2;
  static const int coinsSquats5x = 2;
  static const int coinsWorkout15Min = 15;
  static const int coinsMeditation5m = 5;
  static const int coinsWater1glass = 1;
  static const int coinsSleep7h = 10;
  static const int coinsPer10MinUnlock = 20;
}

/// Sumber koin (PRD §4.1 / §4.4).
enum HabitSource {
  steps2000(10), // Health Connect only
  workout15m(15), // Health Connect only
  pushup5x(2), // manual counter
  squat5x(2), // manual counter
  meditation5m(5), // timer
  water1glass(1), // tap, max 8/day
  sleep7h(10); // Health Connect

  const HabitSource(this.baseCoins);
  final int baseCoins;

  bool get hpConnectVerified => this == steps2000 || this == workout15m || this == sleep7h;
}

/// Paket unlock (PRD §4.2).
enum UnlockPackage {
  m10(20, 10),
  m30(50, 30),
  m60(90, 60);

  const UnlockPackage(this.price, this.minutes);
  final int price;
  final int minutes;
}

/// Satu event ledger koin (append-only).
class CoinEntry {
  CoinEntry({
    required this.id,
    required this.at,
    required this.kind,
    required this.amount,
    this.source,
    this.pkg,
    this.streakDaysAtEvent = 0,
  });

  final String id; // uuid-ish (epochMs + counter)
  final int at; // epoch ms
  final CoinEntryKind kind;
  final int amount; // +earn (positif) / -spend (negatif)
  final HabitSource? source; // untuk earn
  final UnlockPackage? pkg; // untuk spend
  final int streakDaysAtEvent;

  Map<String, Object?> toJson() => {
        'id': id,
        'at': at,
        'kind': kind.name,
        'amount': amount,
        if (source != null) 'source': source!.name,
        if (pkg != null) 'pkg': pkg!.name,
        'streak': streakDaysAtEvent,
      };

  static CoinEntry fromJson(Map<String, Object?> j) => CoinEntry(
        id: j['id'] as String,
        at: j['at'] as int,
        kind: CoinEntryKind.values.byName(j['kind'] as String),
        amount: j['amount'] as int,
        source: j['source'] == null ? null : HabitSource.values.byName(j['source'] as String),
        pkg: j['pkg'] == null ? null : UnlockPackage.values.byName(j['pkg'] as String),
        streakDaysAtEvent: (j['streak'] as num?)?.toInt() ?? 0,
      );
}

enum CoinEntryKind { earn, spend }

/// Sesi unlock aktif (global v1, PRD §6).
class UnlockSession {
  UnlockSession({
    required this.id,
    required this.startedAt,
    required this.expiresAt,
    required this.cost,
  });

  final String id;
  final int startedAt;
  final int expiresAt;
  final int cost;

  bool isActive(int nowMs) => nowMs < expiresAt;

  int minutesLeft(int nowMs) {
    final left = expiresAt - nowMs;
    return left <= 0 ? 0 : (left / 60000).ceil();
  }

  Map<String, Object?> toJson() => {'id': id, 'startedAt': startedAt, 'expiresAt': expiresAt, 'cost': cost};

  static UnlockSession fromJson(Map<String, Object?> j) => UnlockSession(
        id: j['id'] as String,
        startedAt: j['startedAt'] as int,
        expiresAt: j['expiresAt'] as int,
        cost: j['cost'] as int,
      );
}

StackMultiplier multiplierFor(int streakDays) {
  if (streakDays >= 30) return const StackMultiplier(2.5);
  if (streakDays >= 14) return const StackMultiplier(2.0);
  if (streakDays >= 7) return const StackMultiplier(1.5);
  if (streakDays >= 3) return const StackMultiplier(1.2);
  return const StackMultiplier(1.0);
}

class StackMultiplier {
  const StackMultiplier(this.value);
  final double value;
}
