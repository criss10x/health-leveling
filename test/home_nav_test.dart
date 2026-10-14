import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:health_leveling/features/home/home_screen.dart';

void main() {
  Future<void> pump(WidgetTester tester) async {
    // viewport = canvas design (576x1024) -> hit test koordinat 1:1
    tester.view.physicalSize = const Size(576, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
  }

  group('HomeScreen — navigation wiring', () {
    testWidgets('bottom nav has tappable targets (star/lock icons)', (tester) async {
      await pump(tester);
      final tappable = tester.widgetList(find.byWidgetPredicate(
        (w) => w is IconButton || w is GestureDetector,
      )).length;
      expect(tappable, greaterThanOrEqualTo(3), reason: 'nav items tappable');
    });

    testWidgets('tapping nav challenges pushes ChallengesScreen', (tester) async {
      await pump(tester);
      // cari tombol challenge nav (icon star di nav bar)
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Your challenges'), findsOneWidget, reason: 'navigasi ke Challenges');
    });

    testWidgets('tapping nav lock pushes UnlockScreen', (tester) async {
      await pump(tester);
      await tester.tap(find.byIcon(Icons.lock_outline_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Unlock screen time'), findsOneWidget, reason: 'navigasi ke Unlock');
    });
  });
}
