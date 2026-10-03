import 'package:flutter_test/flutter_test.dart';

import 'package:health_leveling/design/tokens.dart';

void main() {
  test('design tokens guard: brand colors', () {
    expect(Ds.ember.toARGB32(), 0xFFF0671E);
    expect(Ds.teal.toARGB32(), 0xFF0AB199);
    expect(Ds.ink.toARGB32(), 0xFF0A0D15);
    expect(Ds.ivory.toARGB32(), 0xFFF8F8EF);
  });

  test('design tokens guard: coin economy (PRD §4)', () {
    expect(Ds.coinsPer2000Steps, 10);
    expect(Ds.coinsPushups5x, 2);
    expect(Ds.coinsSquats5x, 2);
    expect(Ds.coinsWorkout15Min, 15);
    expect(Ds.coinsPer10MinUnlock, 20);
  });
}
