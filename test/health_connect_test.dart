import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/services/health_connect.dart';

void main() {
  group('HealthConnectService — pure logic', () {
    test('step threshold: 2000+ = award, 1999 = no', () {
      expect(HealthConnectLogic.stepsAward(2000), true);
      expect(HealthConnectLogic.stepsAward(1999), false);
    });

    test('workout threshold: >=15 min = award', () {
      expect(HealthConnectLogic.workoutAward(minutes: 15), true);
      expect(HealthConnectLogic.workoutAward(minutes: 14), false);
    });

    test('sleep threshold: >=7 jam = award', () {
      expect(HealthConnectLogic.sleepAward(minutes: 420), true);
      expect(HealthConnectLogic.sleepAward(minutes: 419), false);
    });

    test('day key format YYYYMMDD (kunci anti-abuse & streak)', () {
      final dt = DateTime(2026, 1, 5);
      expect(HealthConnectLogic.dayKey(dt), 20260105);
    });

    test('permissions yang diminta dalam v1', () {
      expect(HealthConnectLogic.requiredTypes.length, 3); // steps, workout, sleep
    });
  });
}
