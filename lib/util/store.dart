import 'package:datura/util/mode.dart';
import 'package:datura/util/rand.dart';
import 'package:datura/util/types.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// const String databasePath = "store.db";

bool dbLogging = false;

String databasePath(Mode mode) => mode == Mode.production ? "prod.db" : "dev.db";

Future<Database> openStoreDatabase(String databasePath) async {
  if(dbLogging) debugPrint("[store.dart] Opening Database ...");
  return openDatabase(
    join(await getDatabasesPath(), databasePath),
    onCreate: (db, version) {
      db.execute("CREATE TABLE entries(id TEXT PRIMARY KEY, weight REAL, date INTEGER, weightUnit TEXT, review TEXT)");
    },
    version: 1
  );
}
Future<void> wipeStoreDatabase(String databasePath) async {  
  final String databasesPath = await getDatabasesPath();
  final String path = join(databasesPath, databasePath);
  await deleteDatabase(path);
}

Future<void> insertWeightEntry(Database db, IndexedWeightEntry weightEntry) async {
  if(!db.isOpen) debugPrint("[store.dart] Database is not open!");

  await db.insert("entries", weightEntry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}
Future<IndexedWeightEntry> insertUnindexedWeightEntry(Database db, WeightEntry weightEntry) async {
  if(!db.isOpen) debugPrint("[store.dart] Database is not open!");

  final String id = Rand.randomId();
  final IndexedWeightEntry indexedWeightEntry = IndexedWeightEntry(id: id, weight: weightEntry.weight, date: weightEntry.date, weightUnit: weightEntry.weightUnit);

  await db.insert("entries", indexedWeightEntry.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  return indexedWeightEntry;
}
Future<List<IndexedWeightEntry>> retrieveWeightEntries(Database db, [ DateTimeRange? timeRange ]) async {
  if(!db.isOpen) debugPrint("[store.dart] Database is not open!");

  if(timeRange != null) {
    final List<Map<String, dynamic>> maps = await db.query('entries', where: "date > ? AND date < ?", whereArgs: [timeRange.start.microsecondsSinceEpoch, timeRange.end.microsecondsSinceEpoch]);
    return maps.map((e) => IndexedWeightEntry.fromMap(e)).toList();
  }

  final List<Map<String, dynamic>> maps = await db.query('entries');
  return maps.map((e) => IndexedWeightEntry.fromMap(e)).toList();

}
Future<void> removeWeightEntry(Database db, IndexedWeightEntry weightEntry) async {
  if(!db.isOpen) debugPrint("[store.dart] Database is not open!");

  /* int affected = */await db.delete('entries', where: "id = ?", whereArgs: [weightEntry.id]);
}
Future<void> updateWeightEntry(Database db, String weightEntryId, IndexedWeightEntry updatedWeightEntry) async {

  await db.update(
    "entries",
    updatedWeightEntry.toMap(),
    where: "id = ?",
    whereArgs: [weightEntryId]
  );

}