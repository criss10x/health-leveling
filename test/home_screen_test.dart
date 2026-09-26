import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:health_leveling/features/home/home_screen.dart';

void main() {
  testWidgets('Home renders hero elements from Comp A contract', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('1,240 coins'), findsOneWidget);
    expect(find.text('1,240'), findsOneWidget);
    expect(find.text('Day 4 · Fitness Starter'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);
  });
}
