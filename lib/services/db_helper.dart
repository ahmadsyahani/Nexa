import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;
  static const String tableName = 'notes';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'nexa_notes.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            date TEXT,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE attendance(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject_name TEXT,
            attended INTEGER,
            skipped INTEGER,
            total_meetings INTEGER,
            target_percentage REAL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE attendance(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              subject_name TEXT,
              attended INTEGER,
              skipped INTEGER,
              total_meetings INTEGER,
              target_percentage REAL
            )
          ''');
        }
      },
    );
  }

  // --- CRUD OPERATIONS ---
  Future<int> insertNote(Map<String, dynamic> note) async {
    var dbClient = await db;
    return await dbClient.insert(tableName, note);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    var dbClient = await db;
    // Order by id DESC (Catatan terbaru di atas)
    return await dbClient.query(tableName, orderBy: 'id DESC');
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    var dbClient = await db;
    return await dbClient.update(
      tableName,
      note,
      where: 'id = ?',
      whereArgs: [note['id']],
    );
  }

  Future<int> deleteNote(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  // --- ATTENDANCE CRUD OPERATIONS ---
  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    var dbClient = await db;
    return await dbClient.insert('attendance', attendance);
  }

  Future<List<Map<String, dynamic>>> getAttendanceList() async {
    var dbClient = await db;
    return await dbClient.query('attendance', orderBy: 'id DESC');
  }

  Future<int> updateAttendance(Map<String, dynamic> attendance) async {
    var dbClient = await db;
    return await dbClient.update(
      'attendance',
      attendance,
      where: 'id = ?',
      whereArgs: [attendance['id']],
    );
  }

  Future<int> deleteAttendance(int id) async {
    var dbClient = await db;
    return await dbClient.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}
