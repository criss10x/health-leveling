import 'package:flutter_test/flutter_test.dart';
import 'package:health_leveling/engine/store_engine.dart';
import 'package:health_leveling/engine/persistence.dart';
import 'package:health_leveling/engine/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Persistence — persist & reload roundtrip', () {
    test('events survive save/load via in-memory adapter', () async {
      final a = StoreEngine();
      a.apply(StoreEvent.earn(source: HabitSource.steps2000, coins: 10, streakDays: 0));
      a.apply(StoreEvent.earn(source: HabitSource.pushup5x, coins: 2, streakDays: 0));
      a.apply(StoreEvent.streakExtended(days: 3));
      a.apply(StoreEvent.spendUnlock(
        pkg: UnlockPackage.m10,
        cost: 20,
        sessionInfo: SessionInfo(startedAt: 1000, expiresAt: 700000),
      ));

      final adapter = InMemoryPersistence();
      await Persistence.save(adapter, a);
      expect(adapter.writes, 1);

      final b = await Persistence.load(adapter, () => StoreEngine());
      expect(b.events.length, 3, reason: 'spend gagal tidak masuk ledger (earn, earn, streak)');
      expect(b.balance, 12);
      expect(b.streakDays, 3);
    });

    test('spend yang sukses masuk ledger dan balance turun', () async {
      final a = StoreEngine();
      a.apply(StoreEvent.earn(source: HabitSource.workout15m, coins: 15, streakDays: 7));
      a.apply(StoreEvent.earn(source: HabitSource.steps2000, coins: 10, streakDays: 7));
      a.apply(StoreEvent.earn(source: HabitSource.meditation5m, coins: 5, streakDays: 7));
      a.apply(StoreEvent.earn(source: HabitSource.squat5x, coins: 2, streakDays: 7));
      a.apply(StoreEvent.earn(source: HabitSource.pushup5x, coins: 2, streakDays: 7));
      // saldo 34 → spend 20 OK
      a.apply(StoreEvent.spendUnlock(
        pkg: UnlockPackage.m10,
        cost: 20,
        sessionInfo: SessionInfo(startedAt: 0, expiresAt: 600000),
      ));
      expect(a.balance, 14);
      final adapter = InMemoryPersistence();
      await Persistence.save(adapter, a);
      final b = await Persistence.load(adapter, () => StoreEngine());
      expect(b.balance, 14);
      expect(b.events.length, 6);
    });
  });

  group('Persistence — file adapter (integration, salah satu lokasi disk)' , () {
    test('writes and reads from a real temp file', () async {
      final tmp = '/tmp/hl_test_persistence.json';
      final a = StoreEngine();
      a.apply(StoreEvent.earn(source: HabitSource.sleep7h, coins: 10, streakDays: 14));
      final f = FilePersistence(path: tmp);
      await Persistence.save(f, a);
      final loaded = await Persistence.load(f, () => StoreEngine());
      expect(loaded.balance, 10);
      // verify file contents JSON snapshot
      // format: {'version':1,'events':[...]}
    });
  });
}
