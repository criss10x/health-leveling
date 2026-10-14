import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/engine/challenge_engine.dart';
import 'package:health_leveling/features/challenges/challenges_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('ChallengesScreen — Comp A spatial contract (below-the-fold sections)', () {
    Future<void> pump(WidgetTester tester, {List<ChallengeRun>? runs}) async {
      await tester.pumpWidget(MaterialApp(home: ChallengesScreen(activeRuns: runs ?? const [])));
      await tester.pumpAndSettle();
    }

    testWidgets('renders all 4 launch challenges', (tester) async {
      await pump(tester);
      expect(find.text('Fitness Starter'), findsOneWidget);
      expect(find.text('Dopamine Detox'), findsOneWidget);
      expect(find.text('10K Steps'), findsOneWidget);
      expect(find.text('Sleep Reset'), findsOneWidget);
    });

    testWidgets('free challenge has no lock badge; others locked', (tester) async {
      await pump(tester);
      // Fitness Starter = gratis (PRD §5): badge 'Free'
      expect(find.text('Free'), findsOneWidget);
      // Premium badge untuk 3 lainnya
      expect(find.text('Premium'), findsNWidgets(3));
    });

    testWidgets('active run shows day progress', (tester) async {
      await pump(tester, runs: [
        ChallengeRun(id: 'r1', challengeId: 'fitness-starter', startedDayKey: 0),
      ]);
      expect(find.text('Day 4 of 21'), findsOneWidget);
      expect(find.text('2 shields'), findsOneWidget);
    });

    testWidgets('back arrow + appbar title present', (tester) async {
      await pump(tester);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Health Leveling'), findsOneWidget);
    });
  });
}
