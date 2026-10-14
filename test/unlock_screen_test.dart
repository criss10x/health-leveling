import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:health_leveling/features/unlock/unlock_screen.dart';

void main() {
  group('UnlockScreen — belanja koin (PRD §4.2)', () {
    Future<void> pump(WidgetTester tester, {required int balance}) async {
      await tester.pumpWidget(MaterialApp(home: UnlockScreen(balance: balance)));
      await tester.pumpAndSettle();
    }

    testWidgets('shows 3 packages with prices', (tester) async {
      await pump(tester, balance: 100);
      expect(find.text('10 minutes'), findsOneWidget);
      expect(find.text('30 minutes'), findsOneWidget);
      expect(find.text('1 hour'), findsOneWidget);
      expect(find.text('20 coins'), findsOneWidget);
      expect(find.text('50 coins'), findsOneWidget);
      expect(find.text('90 coins'), findsOneWidget);
    });

    testWidgets('balance shown', (tester) async {
      await pump(tester, balance: 47);
      expect(find.textContaining('47'), findsWidgets);
    });

    testWidgets('insufficient balance disables packages', (tester) async {
      await pump(tester, balance: 10);
      // 20 & 50 & 90 semuanya > 10 → semua disabled
      final buttons = tester.widgetList<GestureDetector>(find.byType(GestureDetector));
      expect(buttons.length, greaterThanOrEqualTo(3));
      expect(find.text('Not enough coins'), findsOneWidget);
    });

    testWidgets('affordable tap → confirm dialog shows cost & minutes', (tester) async {
      await pump(tester, balance: 100);
      await tester.tap(find.text('10 minutes'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Unlock for 10 minutes'), findsOneWidget);
      expect(find.textContaining('20 coins'), findsWidgets);
    });
  });
}
