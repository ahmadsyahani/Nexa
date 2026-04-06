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
      version: 1,
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
}
