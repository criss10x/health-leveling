/// ChallengeEngine — katalog, tier harian, shield, completion (PRD §5).
library;

/// Tier harian challenge.
enum DailyTier { none, bronze, silver, gold }

/// Katalog launch (§5). Durasi hari, kriteria bronze/silver/gold, koin bonus.
class ChallengeCatalog {
  ChallengeCatalog._();

  static const _fitness = _Def('fitness-starter', 21, bronze: (15, 15), silver: (30, 30), gold: (50, 50), bonus: 100);
  static const _detox = _Def('dopamine-detox', 7, bronze: (2, 0), silver: (4, 0), gold: (6, 0), bonus: 150); // jam detox
  static const _steps = _Def('10k-steps', 30, bronze: (6000, 0), silver: (8000, 0), gold: (10000, 0), bonus: 200);
  static const _sleep = _Def('sleep-reset', 14, bronze: (650, 0), silver: (700, 0), gold: (750, 0), bonus: 100); // menit tidur

  static const all = [_fitness, _detox, _steps, _sleep];
}

class _Def {
  const _Def(this.id, this.durationDays, {required this.bronze, required this.silver, required this.gold, required this.bonus});
  final String id;
  final int durationDays;
  final (int, int) bronze;
  final (int, int) silver;
  final (int, int) gold;
  final int bonus;
}

class ChallengeRun {
  ChallengeRun({
    required this.id,
    required this.challengeId,
    required this.startedDayKey,
    this.shieldsLeft = 2,
    this.missedDays = 0,
    this.brokenPerfect = false,
  });

  final String id;
  final String challengeId;
  final int startedDayKey;
  int shieldsLeft;
  int missedDays; // hari GAGAL (setelah shield habis)
  bool brokenPerfect; // badge "Perfect" hangus
}

class ChallengeEngine {
  ChallengeEngine._();

  static int durationDays(String id) => _byId(id).durationDays;

  static int completionBonus(String id) => _byId(id).bonus;

  static _Def _byId(String id) =>
      ChallengeCatalog.all.firstWhere((d) => d.id == id, orElse: () => throw ArgumentError('unknown challenge: $id'));

  /// Tier dari hasil hari ini (dua criteria indikator: main value + optional second).
  /// Untuk fitness: pushups/squats. Untuk lainnya: (value, 0).
  static DailyTier tier({required int pushups, int squats = 0}) {
    final f = ChallengeCatalog._fitness;
    if (pushups >= f.gold.$1 && squats >= f.gold.$2) return DailyTier.gold;
    if (pushups >= f.silver.$1 && squats >= f.silver.$2) return DailyTier.silver;
    if (pushups >= f.bronze.$1 && squats >= f.bronze.$2) return DailyTier.bronze;
    return DailyTier.none;
  }

  /// Hari bolong: pakai shield otomatis kalau ada; kalau habis → hari gagal.
  static ChallengeRun recordMiss(ChallengeRun run) {
    if (run.shieldsLeft > 0) {
      run.shieldsLeft--;
    } else {
      run.missedDays++;
      run.brokenPerfect = true;
    }
    return run;
  }

  /// Apakah hari [dayKey] run menggunakan shield (untuk kalender ✅*-dengan-shield).
  static bool usedShield({required ChallengeRun run, required int dayKey}) {
    // shield dipakai saat recordMiss dipanggil; marker disimpan oleh service layer
    return run.shieldsLeft < 2 && run.missedDays == 0;
  }
}
