import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'todoitems.db');
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todoitems(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_name TEXT,
            description_name TEXT,
            itemsdone INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> insertToDoItem(Map<String, dynamic> todoitem) async {
    final db = await database;
    await db.insert('todoitems', todoitem);
  }

  Future<List<Map<String, dynamic>>> getToDoItems() async {
    final db = await database;
    return await db.query('todoitems');
  }

  Future<void> markToDoItem(int id) async {
    final db = await database;
    await db.update('todoitems', {'itemsdone': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteToDoItem(int id) async {
    final db = await database;
    await db.delete('todoitems', where: 'id = ?', whereArgs: [id]);
  }
}
