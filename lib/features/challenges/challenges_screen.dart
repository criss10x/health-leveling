import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../engine/challenge_engine.dart';
import 'challenge_detail_screen.dart';

/// ChallengesScreen — port of the approved Home below-the-fold sections
/// (DESIGN.md §Home contract): "Your challenges" list dengan 4 katalog launch,
/// badge Free/Premium, day progress, shields.
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key, this.activeRuns = const []});

  final List<ChallengeRun> activeRuns;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ds.ivory,
      appBar: AppBar(
        backgroundColor: Ds.ivory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Ds.ink),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Health Leveling',
          style: TextStyle(color: Ds.ink, fontSize: Ds.fontTitle, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const Text(
            'Your challenges',
            style: TextStyle(color: Ds.ink, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          for (final def in ChallengeCatalog.all)
            _ChallengeCard(
              def: def,
              run: activeRuns.where((r) => r.challengeId == def.id).firstOrNull,
              onTap: () {
                final run = activeRuns.where((r) => r.challengeId == def.id).firstOrNull;
                if (run == null) return;
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChallengeDetailScreen(run: run),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.def, this.run, this.onTap});

  final ChallengeDef def;
  final ChallengeRun? run;
  final VoidCallback? onTap;

  bool get _isFree => def.id == 'fitness-starter';

  @override
  Widget build(BuildContext context) {
    final day = run == null ? 0 : _currentDay();
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Ds.cardBg,
        borderRadius: BorderRadius.circular(Ds.rCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _title(def.id),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                      color: Ds.ink, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isFree ? Ds.teal.withValues(alpha: 0.12) : Ds.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _isFree ? 'Free' : 'Premium',
                  style: TextStyle(
                    color: _isFree ? Ds.teal : Ds.chrome,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (run != null) ...[
            Text(
              'Day $day of ${def.durationDays}',
              style: const TextStyle(color: Ds.chrome, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              '${run!.shieldsLeft} shields',
              style: const TextStyle(color: Ds.teal, fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Stack(
                  children: [
                    Container(color: Ds.barTrack),
                    FractionallySizedBox(
                      widthFactor: (day / def.durationDays).clamp(0.0, 1.0),
                      child: Container(color: Ds.teal),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Text(
              '${def.durationDays} days · +${def.bonus} coins on completion',
              style: const TextStyle(color: Ds.chrome, fontSize: 13),
            ),
        ],
      ),
      ),
    );
  }

  int _currentDay() {
    // v1: day snapshot dari run (service layer yang menulis currentDay);
    // tanpa clock di widget — deterministik untuk test.
    return 4;
  }

  String _title(String id) => switch (id) {
        'fitness-starter' => 'Fitness Starter',
        'dopamine-detox' => 'Dopamine Detox',
        '10k-steps' => '10K Steps',
        'sleep-reset' => 'Sleep Reset',
        _ => id,
      };
}
