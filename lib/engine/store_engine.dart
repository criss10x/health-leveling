/// StoreEngine — event-sourced store (PRD §9): append-only events, replay ke state.
/// Local v1 (in-memory + persist di service layer); sync v2 = antar/mengirim event.
library;

import 'dart:collection';

import 'models.dart';

class SessionInfo {
  const SessionInfo({required this.startedAt, required this.expiresAt});
  final int startedAt;
  final int expiresAt;
}

class StoreEvent {
  StoreEvent._({
    required this.type,
    this.source,
    this.coins = 0,
    this.streakDays = 0,
    this.pkg,
    this.cost = 0,
    this.sessionInfo,
    this.dayKey,
    this.shieldUsed = false,
  });

  factory StoreEvent.earn({required HabitSource source, required int coins, required int streakDays}) =>
      StoreEvent._(type: 'earn', source: source, coins: coins, streakDays: streakDays);

  factory StoreEvent.spendUnlock({
    required UnlockPackage pkg,
    required int cost,
    SessionInfo? sessionInfo,
  }) =>
      StoreEvent._(type: 'spend', pkg: pkg, cost: cost, sessionInfo: sessionInfo);

  factory StoreEvent.streakExtended({required int days}) =>
      StoreEvent._(type: 'streak', streakDays: days);

  factory StoreEvent.activityDone({required HabitSource source, required int dayKey, bool shieldUsed = false}) =>
      StoreEvent._(type: 'activity', source: source, dayKey: dayKey, shieldUsed: shieldUsed);

  final String type;
  final HabitSource? source;
  final int coins;
  final int streakDays;
  final UnlockPackage? pkg;
  final int cost;
  final SessionInfo? sessionInfo;
  final int? dayKey;
  final bool shieldUsed;

  Map<String, Object?> toJson() => {
        'type': type,
        if (source != null) 'source': source!.name,
        if (coins != 0) 'coins': coins,
        if (streakDays != 0) 'streakDays': streakDays,
        if (pkg != null) 'pkg': pkg!.name,
        if (cost != 0) 'cost': cost,
        if (sessionInfo != null) ...{
          'startedAt': sessionInfo!.startedAt,
          'expiresAt': sessionInfo!.expiresAt,
        },
        if (dayKey != null) 'dayKey': dayKey,
        if (shieldUsed) 'shieldUsed': true,
      };

  static StoreEvent fromJson(Map<String, Object?> j) {
    final t = j['type'] as String;
    switch (t) {
      case 'earn':
        return StoreEvent.earn(
          source: HabitSource.values.byName(j['source'] as String),
          coins: (j['coins'] as num).toInt(),
          streakDays: (j['streakDays'] as num?)?.toInt() ?? 0,
        );
      case 'spend':
        return StoreEvent.spendUnlock(
          pkg: UnlockPackage.values.byName(j['pkg'] as String),
          cost: (j['cost'] as num).toInt(),
          sessionInfo: SessionInfo(
            startedAt: (j['startedAt'] as num).toInt(),
            expiresAt: (j['expiresAt'] as num).toInt(),
          ),
        );
      case 'streak':
        return StoreEvent.streakExtended(days: (j['streakDays'] as num).toInt());
      case 'activity':
        return StoreEvent.activityDone(
          source: HabitSource.values.byName(j['source'] as String),
          dayKey: (j['dayKey'] as num).toInt(),
          shieldUsed: (j['shieldUsed'] as bool?) ?? false,
        );
      default:
        throw ArgumentError('Unknown event type: $t');
    }
  }
}

/// Hasil apply: null = sukses; string = kode penolakan.
class StoreEngine {
  final List<StoreEvent> _events = [];
  late final UnmodifiableListView<StoreEvent> events = UnmodifiableListView(_events);

  int _balance = 0;
  int _streakDays = 0;
  UnlockSession? _activeSession;
  final Map<String, int> _countBySourceDay = {}; // 'src:dayKey' → count

  int get balance => _balance;
  int get streakDays => _streakDays;
  UnlockSession? get activeSession => _isActive(_activeSession) ? _activeSession : null;

  bool _isActive(UnlockSession? s) {
    if (s == null) return false;
    return true; // dipanggil tanpa clock di level event; service layer memeriksa expire
  }

  String? apply(StoreEvent e) {
    switch (e.type) {
      case 'earn':
        _balance += e.coins;
        _events.add(e);
        if (e.source != null && e.dayKey != null) {
          _bump(e.source!, e.dayKey!);
        }
        return null;
      case 'spend':
        if (_balance < e.cost) return 'insufficient-funds';
        _balance -= e.cost;
        if (e.sessionInfo != null) {
          _activeSession = UnlockSession(
            id: '${e.sessionInfo!.startedAt}',
            startedAt: e.sessionInfo!.startedAt,
            expiresAt: e.sessionInfo!.expiresAt,
            cost: e.cost,
          );
        }
        _events.add(e);
        return null;
      case 'streak':
        _streakDays = e.streakDays;
        _events.add(e);
        return null;
      case 'activity':
        _events.add(e);
        if (e.source != null && e.dayKey != null) _bump(e.source!, e.dayKey!);
        return null;
      default:
        throw ArgumentError('unknown ${e.type}');
    }
  }

  void _bump(HabitSource s, int dayKey) {
    final k = '${s.name}:$dayKey';
    _countBySourceDay[k] = (_countBySourceDay[k] ?? 0) + 1;
  }

  int countToday(HabitSource s, {required int dayKey}) => _countBySourceDay['${s.name}:$dayKey'] ?? 0;
}

