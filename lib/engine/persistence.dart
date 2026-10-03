/// Persistence — simpan/muat ledger event ke adapter (PRD §9 satu sumber state).
/// v1: file JSON di path app-documents. v2 sync: adapter sama, sink cloud.
library;

import 'dart:convert';
import 'dart:io';

import 'store_engine.dart';

abstract class PersistenceAdapter {
  Future<String?> read();
  Future<void> write(String contents);
}

/// In-memory (tests / fallback aman kalau IO gagal).
class InMemoryPersistence implements PersistenceAdapter {
  String? data;
  int writes = 0;

  @override
  Future<String?> read() async => data;

  @override
  Future<void> write(String contents) async {
    data = contents;
    writes++;
  }
}

/// File JSON di path eksplisit (app documents).
class FilePersistence implements PersistenceAdapter {
  FilePersistence({required this.path});
  final String path;

  @override
  Future<String?> read() async {
    final f = File(path);
    if (!f.existsSync()) return null;
    return f.readAsString();
  }

  @override
  Future<void> write(String contents) async {
    final f = File(path);
    await f.parent.create(recursive: true);
    await f.writeAsString(contents, flush: true);
  }
}

class Persistence {
  Persistence._();

  /// Snapshot seluruh ledger (bukan derived state — PRD §9).
  static Future<void> save(PersistenceAdapter adapter, StoreEngine engine) async {
    final payload = {
      'version': 1,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
      'events': engine.events.map((e) => e.toJson()).toList(),
    };
    await adapter.write(jsonEncode(payload));
  }

  /// Muat + replay events. Korup/tak dikenal → mulai kosong (jangan crash).
  static Future<StoreEngine> load(PersistenceAdapter adapter, StoreEngine Function() factory) async {
    final e = factory();
    try {
      final raw = await adapter.read();
      if (raw == null) return e;
      final parsed = jsonDecode(raw) as Map<String, Object?>;
      final events = (parsed['events'] as List?) ?? const [];
      for (final j in events.cast<Map<String, Object?>>()) {
        try {
          e.apply(StoreEvent.fromJson(j));
        } catch (_) {
          // event korup individual → skip, jangan buang seluruh ledger
        }
      }
    } catch (_) {
      // file korup total → state kosong; ledger backups di v2 namespace
    }
    return e;
  }
}
