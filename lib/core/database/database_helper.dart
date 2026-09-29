import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/capture_item.dart';
import '../models/app_settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for Windows desktop
    sqfliteFfiInit();
    final factory = databaseFactoryFfi;

    final appDocDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(appDocDir.path, 'SnapNoteAI'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    final dbPath = p.join(dbDir.path, 'snap_note.db');

    return await factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createTables,
      ),
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE captures (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        image_path TEXT NOT NULL,
        category TEXT NOT NULL,
        original_category TEXT NOT NULL,
        title TEXT NOT NULL,
        summary TEXT,
        content TEXT,
        tags TEXT,
        confidence REAL,
        is_uncertain INTEGER DEFAULT 0,
        status TEXT NOT NULL,
        error_message TEXT,
        ai_json_payload TEXT,
        date TEXT,
        time TEXT,
        end_date TEXT,
        end_time TEXT,
        location TEXT,
        address TEXT,
        city TEXT,
        country TEXT,
        url TEXT,
        people TEXT,
        product_name TEXT,
        price TEXT,
        currency TEXT,
        store TEXT,
        is_purchased INTEGER DEFAULT 0,
        programming_language TEXT,
        priority TEXT,
        due_date TEXT,
        is_completed INTEGER DEFAULT 0,
        is_read INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // --- CAPTURES CRUD ---

  Future<void> insertCapture(CaptureItem item) async {
    final db = await database;
    await db.insert('captures', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCapture(CaptureItem item) async {
    final db = await database;
    await db.update(
      'captures',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteCapture(String id) async {
    final db = await database;
    await db.delete('captures', where: 'id = ?', whereArgs: [id]);
  }

  Future<CaptureItem?> getCaptureById(String id) async {
    final db = await database;
    final results = await db.query('captures', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return CaptureItem.fromMap(results.first);
    }
    return null;
  }

  Future<List<CaptureItem>> getAllCaptures() async {
    final db = await database;
    final results = await db.query('captures', orderBy: 'created_at DESC');
    return results.map((e) => CaptureItem.fromMap(e)).toList();
  }

  Future<List<CaptureItem>> getCapturesByCategory(String category) async {
    final db = await database;
    final results = await db.query(
      'captures',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return results.map((e) => CaptureItem.fromMap(e)).toList();
  }

  Future<List<CaptureItem>> getCapturesByStatus(String status) async {
    final db = await database;
    final results = await db.query(
      'captures',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    return results.map((e) => CaptureItem.fromMap(e)).toList();
  }

  Future<List<CaptureItem>> getNeedsReviewCaptures() async {
    final db = await database;
    final results = await db.query(
      'captures',
      where: 'is_uncertain = 1 OR status = ?',
      whereArgs: ['needs_review'],
      orderBy: 'created_at DESC',
    );
    return results.map((e) => CaptureItem.fromMap(e)).toList();
  }

  Future<List<CaptureItem>> searchCaptures(String query, {String? categoryFilter, String? tagFilter}) async {
    final db = await database;
    String sql = 'SELECT * FROM captures WHERE 1=1';
    List<dynamic> args = [];

    if (query.trim().isNotEmpty) {
      final term = '%${query.trim()}%';
      sql += ''' AND (
        title LIKE ? OR 
        summary LIKE ? OR 
        content LIKE ? OR 
        tags LIKE ? OR 
        url LIKE ? OR 
        location LIKE ? OR 
        product_name LIKE ? OR 
        people LIKE ?
      )''';
      args.addAll([term, term, term, term, term, term, term, term]);
    }

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'all') {
      sql += ' AND category = ?';
      args.add(categoryFilter);
    }

    if (tagFilter != null && tagFilter.isNotEmpty) {
      sql += ' AND tags LIKE ?';
      args.add('%"$tagFilter"%');
    }

    sql += ' ORDER BY created_at DESC';

    final results = await db.rawQuery(sql, args);
    return results.map((e) => CaptureItem.fromMap(e)).toList();
  }

  // --- SETTINGS CRUD ---

  Future<AppSettings> getSettings() async {
    final db = await database;
    final results = await db.query('settings');
    Map<String, String> map = {};
    for (var row in results) {
      map[row['key'] as String] = row['value'] as String;
    }
    return AppSettings.fromMap(map);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final db = await database;
    final batch = db.batch();
    final map = settings.toMap();
    for (var entry in map.entries) {
      batch.insert(
        'settings',
        {'key': entry.key, 'value': entry.value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
