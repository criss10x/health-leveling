import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:health_leveling/features/onboarding/onboarding_screen.dart';

void main() {
  group('OnboardingScreen — 8 layar (PRD §7 ringkas v1)', () {
    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
      await tester.pumpAndSettle();
    }

    void jumpTo(WidgetTester tester, int page) {
      tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(page);
    }

    testWidgets('page 1: hero Ember + tagline', (tester) async {
      await pump(tester);
      expect(find.textContaining('Earn your screen'), findsOneWidget);
    });

    testWidgets('pages carry expected titles across the flow', (tester) async {
      await pump(tester);
      const titles = [
        'Earn your screen',
        'Your apps are free.',
        'How it works',
        'Pick your first',
        'Daily criteria',
        'Gentle nudges',
        'App blocking',
        "You're ready",
      ];
      for (var i = 0; i < titles.length; i++) {
        jumpTo(tester, i);
        await tester.pumpAndSettle();
        expect(find.textContaining(titles[i]), findsOneWidget, reason: 'page ${i + 1}');
      }
    });

    testWidgets('CTA on last page completes onboarding', (tester) async {
      String? completed;
      await tester.pumpWidget(MaterialApp(
        home: OnboardingScreen(onComplete: () => completed = 'yes'),
      ));
      await tester.pumpAndSettle();
      jumpTo(tester, 7);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      expect(completed, 'yes');
    });

    testWidgets('progress advances on Next', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Your apps are free'), findsOneWidget);
    });
  });
}
