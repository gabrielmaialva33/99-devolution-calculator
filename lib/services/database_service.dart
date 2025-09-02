import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../features/scanner/domain/models/barcode_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'devolution_calculator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE barcode_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        value REAL NOT NULL,
        scanned_at INTEGER NOT NULL,
        scan_method INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertBarcodeItem(BarcodeItem item) async {
    final db = await database;
    return await db.insert(
      'barcode_items',
      {
        'code': item.code,
        'value': item.value,
        'scanned_at': item.scannedAt.millisecondsSinceEpoch,
        'scan_method': item.scanMethod.index,
      },
    );
  }

  Future<List<BarcodeItem>> getAllBarcodeItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'barcode_items',
      orderBy: 'scanned_at ASC',
    );

    return List.generate(maps.length, (i) {
      return BarcodeItem(
        code: maps[i]['code'],
        value: maps[i]['value'],
        scannedAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['scanned_at']),
        scanMethod: ScanMethod.values[maps[i]['scan_method']],
      );
    });
  }

  Future<void> deleteBarcodeItem(String code, DateTime scannedAt) async {
    final db = await database;
    await db.delete(
      'barcode_items',
      where: 'code = ? AND scanned_at = ?',
      whereArgs: [code, scannedAt.millisecondsSinceEpoch],
    );
  }

  Future<void> clearAllBarcodeItems() async {
    final db = await database;
    await db.delete('barcode_items');
  }

  Future<int> getBarcodeItemsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM barcode_items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalValue() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(value) FROM barcode_items');
    return (result.first['SUM(value)'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}