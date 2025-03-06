import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL
      );
    ''');
    
    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT NOT NULL,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      );
    ''');
  }

  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await instance.database;
    return await db.query('folders');
  }

  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    final db = await instance.database;
    return await db.query('cards', where: 'folder_id = ?', whereArgs: [folderId]);
  }

  Future<int> insertFolder(String folderName) async {
    final db = await instance.database;
    return await db.insert('folders', {'folder_name': folderName});
  }

  Future<int> insertCard(String name, String suit, String imageUrl, int folderId) async {
    final db = await instance.database;
    return await db.insert('cards', {
      'card_name': name,
      'suit': suit,
      'image_url': imageUrl,
      'folder_id': folderId,
    });
  }
}
