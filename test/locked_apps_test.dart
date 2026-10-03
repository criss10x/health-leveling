import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/models/app_registry.dart';

void main() {
  group('LockedAppRegistry (PRD §6)', () {
    test('tracks locked apps and unlock exemption', () {
      final reg = LockedAppRegistry();
      reg.setLocked(['com.instagram.android', 'com.zhiliaoapp.musculus'], locked: true);
      expect(reg.isLocked('com.instagram.android'), true);
      expect(reg.isLocked('com.android.chrome'), false);

      // unlock aktif → exemption
      reg.activeUnlockUntil = 17000000;
      expect(reg.isBlocked('com.instagram.android', nowMs: 16990000), false);
      expect(reg.isBlocked('com.instagram.android', nowMs: 17000001), true);
    });

    test('detox mode locks whitelist app regardless of user list', () {
      final reg = LockedAppRegistry();
      reg.setDetoxActive(true);
      reg.setDetoxTargets(['com.instagram.android']);
      expect(reg.isBlocked('com.instagram.android', nowMs: 0), true);
      // tidak ada unlock aktif
      expect(reg.activeUnlockUntil, 0);
    });
  });
}
