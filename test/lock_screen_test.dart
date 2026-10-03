import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_leveling/design/tokens.dart';
import 'package:health_leveling/features/lock/lock_screen.dart';

void main() {
  testWidgets('LockScreen shows locked message and CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LockScreen(lockedPkg: 'com.zhiliaoapp.musculus')));
    expect(find.text('App locked'), findsOneWidget);
    expect(find.text('Earn coins in Health Leveling'), findsOneWidget);
    expect(find.textContaining('musculus'), findsOneWidget);
    expect(find.textContaining('Unlock active'), findsNothing); // unlockUntilMs 0
  });

  testWidgets('LockScreen shows countdown when unlock active', (tester) async {
    final future = DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;
    await tester.pumpWidget(MaterialApp(home: LockScreen(lockedPkg: 'com.instagram.android', unlockUntilMs: future)));
    expect(find.textContaining('Unlock active'), findsOneWidget);
  });

  testWidgets('LockScreen uses brand ink background + ember CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LockScreen(lockedPkg: 'x')));
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Ds.ink);
    final btn = tester.widget<TextButton>(find.byType(TextButton));
    expect(btn.style?.backgroundColor?.resolve({}), Ds.ember);
  });
}
