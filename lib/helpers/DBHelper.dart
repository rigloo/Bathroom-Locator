import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await getDatabasesPath();

    final db = await openDatabase(path.join(dbPath, 'baths.db'),
        onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE limits(id TEXT PRIMARY KEY, bathWrites INTEGER, reviewWrites INTEGER, date TEXT)');
    }, version: 1);
    return db;
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await database();
    db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, Object?>>> fetchData(String table) async {
    final db = await database();
    final data = await db.query(table);
    return data;
  }

  static Future<List<Map<String, Object?>>> fetchDataDate(
      String table, String date) async {
    final db = await database();
    final data = await db.query(table, where: 'date = ?', whereArgs: [date]);
    return data;
  }

  static Future<int> deleteBefore(String table, String date) async {
    final db = await database();
    final count = await db.delete(table, where: 'date != ?', whereArgs: [date]);
    return count;
  }

  static Future<int> updateBathroomWrites(
      String table, String date, int newNum) async {
    final db = await database();
    final count = await db.update(table, {'bathWrites': newNum},
        where: 'date = ?', whereArgs: [date]);
    return count;
  }

  static Future<int> updateReviewWrites(
      String table, String date, int newNum) async {
    final db = await database();
    final count = await db.update(table, {'reviewWrites': newNum},
        where: 'date = ?', whereArgs: [date]);
    return count;
  }
}
