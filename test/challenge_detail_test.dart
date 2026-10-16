import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:health_leveling/engine/challenge_engine.dart';
import 'package:health_leveling/features/challenges/challenge_detail_screen.dart';

void main() {
  group('ChallengeDetailScreen — kalender + tier (PRD §5)', () {
    Future<void> pump(WidgetTester tester, {required ChallengeRun run}) async {
      await tester.pumpWidget(MaterialApp(home: ChallengeDetailScreen(run: run)));
      await tester.pumpAndSettle();
    }

    testWidgets('shows title, duration and bonus', (tester) async {
      await pump(tester, run: ChallengeRun(id: 'r1', challengeId: 'fitness-starter', startedDayKey: 0));
      expect(find.text('Fitness Starter'), findsOneWidget);
      expect(find.text('21 days · 2 shields'), findsOneWidget);
      expect(find.textContaining('+100'), findsOneWidget);
    });

    testWidgets('calendar renders one cell per day of duration', (tester) async {
      await pump(tester, run: ChallengeRun(id: 'r1', challengeId: 'dopamine-detox', startedDayKey: 0));
      // 7 hari → 7 kalender cells (label angka 1..7)
      final cells = tester.widgetList(find.byWidgetPredicate(
        (w) => w.key is ValueKey && (w.key as ValueKey).value.toString().startsWith('cal-cell'),
      )).length;
      expect(cells, 7);
    });

    testWidgets('completed + shielded + missed days render distinct states', (tester) async {
      final run = ChallengeRun(
        id: 'r1',
        challengeId: '10k-steps',
        startedDayKey: 0,
        shieldsLeft: 1,
        missedDays: 1,
        brokenPerfect: true,
      );
      await pump(tester, run: run);
      expect(find.text('30 days · 1 shield'), findsOneWidget);
      expect(find.textContaining('Perfect lost'), findsOneWidget);
    });

    testWidgets('shield count singular', (tester) async {
      await pump(tester, run: ChallengeRun(
        id: 'r1', challengeId: 'sleep-reset', startedDayKey: 0, shieldsLeft: 1,
      ));
      expect(find.text('14 days · 1 shield'), findsOneWidget);
    });
  });
}
