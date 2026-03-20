import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../models/log_entry.dart';


class DatabaseService {
  
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  Database? _db;

  static const String _tableName    = 'logs';
  static const String _colId        = 'id';
  static const String _colLotNumber = 'lot_number';
  static const String _colMaterial  = 'material_type';
  static const String _colQuantity  = 'quantity';
  static const String _colIssuedTo  = 'issued_to';
  static const String _colCountedBy = 'counted_by';
  static const String _colIssueDate = 'issue_date';   // stored as ISO string
  static const String _colSite      = 'site';
  static const String _colIsSynced  = 'is_synced';    // stored as 0 or 1

  Future<Database> get _database async {
    // Already open — return it immediately
    if (_db != null) return _db!;

    // First time — open (or create) the file
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // getDatabasesPath() → the OS-given folder
    // for this app's private storage
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, 'solar_counter.db');

    return await openDatabase(
      fullPath,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade  ← add here in future if schema changes
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $_colId        TEXT PRIMARY KEY,
        $_colLotNumber TEXT NOT NULL,
        $_colMaterial  TEXT NOT NULL,
        $_colQuantity  INTEGER NOT NULL,
        $_colIssuedTo  TEXT NOT NULL,
        $_colCountedBy TEXT NOT NULL,
        $_colIssueDate TEXT NOT NULL,
        $_colSite      TEXT NOT NULL,
        $_colIsSynced  INTEGER NOT NULL DEFAULT 0
      )
    ''');

  }

  Future<void> insertLog(LogEntry entry) async {
    final db = await _database;
    await db.insert(
      _tableName,
      _toMap(entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LogEntry>> getAllLogs() async {
    final db   = await _database;
    final rows = await db.query(
      _tableName,
      orderBy: '$_colIssueDate DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<List<LogEntry>> getRecentLogs({int limit = 5}) async {
    final db   = await _database;
    final rows = await db.query(
      _tableName,
      orderBy: '$_colIssueDate DESC',
      limit: limit,
    );
    return rows.map(_fromMap).toList();
  }

  Future<LogStats> getStats() async {
    final db = await _database;

    // Today's date as ISO prefix (e.g. "2024-03-15")
    final todayPrefix = DateTime.now()
        .toIso8601String()
        .substring(0, 10); // "YYYY-MM-DD"

    // 7 days ago as ISO string for comparison
    final weekAgo = DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String();

    final todayResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName '
      'WHERE $_colIssueDate LIKE ?',
      ['$todayPrefix%'],
    );
    final logsToday = Sqflite.firstIntValue(todayResult) ?? 0;

    // Total items counted in last 7 days
    final weekResult = await db.rawQuery(
      'SELECT SUM($_colQuantity) as total FROM $_tableName '
      'WHERE $_colIssueDate >= ?',
      [weekAgo],
    );
    final itemsThisWeek = Sqflite.firstIntValue(weekResult) ?? 0;

    // All-time total log entries
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName',
    );
    final totalLogs = Sqflite.firstIntValue(totalResult) ?? 0;

    // Pending sync count
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName '
      'WHERE $_colIsSynced = 0',
    );
    final pendingSync = Sqflite.firstIntValue(pendingResult) ?? 0;

    return LogStats(
      logsToday:    logsToday,
      itemsThisWeek: itemsThisWeek,
      totalLogs:    totalLogs,
      pendingSync:  pendingSync,
    );
  }

  Future<void> deleteLog(String id) async {
    final db = await _database;
    await db.delete(
      _tableName,
      where: '$_colId = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsSynced(String id) async {
    final db = await _database;
    await db.update(
      _tableName,
      {_colIsSynced: 1},
      where: '$_colId = ?',
      whereArgs: [id],
    );
  }
  Future<List<LogEntry>> getUnsyncedLogs() async {
    final db   = await _database;
    final rows = await db.query(
      _tableName,
      where: '$_colIsSynced = ?',
      whereArgs: [0],
      orderBy: '$_colIssueDate ASC', // oldest unsynced first
    );
    return rows.map(_fromMap).toList();
  }

  Map<String, dynamic> _toMap(LogEntry e) {
    return {
      _colId:        e.id,
      _colLotNumber: e.lotNumber,
      _colMaterial:  e.materialType,
      _colQuantity:  e.quantity,
      _colIssuedTo:  e.issuedTo,
      _colCountedBy: e.countedBy,
      _colIssueDate: e.issueDate.toIso8601String(),
      _colSite:      e.site,
      _colIsSynced:  e.isSynced ? 1 : 0,
    };
  }

  // Map<String, dynamic> from DB → LogEntry
  LogEntry _fromMap(Map<String, dynamic> row) {
    return LogEntry(
      id:           row[_colId] as String,
      lotNumber:    row[_colLotNumber] as String,
      materialType: row[_colMaterial] as String,
      quantity:     row[_colQuantity] as int,
      issuedTo:     row[_colIssuedTo] as String,
      countedBy:    row[_colCountedBy] as String,
      issueDate:    DateTime.parse(row[_colIssueDate] as String),
      site:         row[_colSite] as String,
      isSynced:     (row[_colIsSynced] as int) == 1,
    );
  }
}

class LogStats {
  final int logsToday;
  final int itemsThisWeek;
  final int totalLogs;
  final int pendingSync;

  const LogStats({
    required this.logsToday,
    required this.itemsThisWeek,
    required this.totalLogs,
    required this.pendingSync,
  });

  // Convenience — a zero state for before data loads
  factory LogStats.empty() => const LogStats(
        logsToday:    0,
        itemsThisWeek: 0,
        totalLogs:    0,
        pendingSync:  0,
      );
}