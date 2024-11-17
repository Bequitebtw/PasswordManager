import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pass_meneger/models/password_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('passwords.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path = join(await getDatabasesPath(), filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS passwords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        password_group TEXT,
        name TEXT,
        login TEXT,
        password TEXT
      );
    ''');
  }

  Future<void> insertPassword(Password password) async {
    final db = await database;
    await db.insert(
      'passwords',
      {
        'password_group': password.group,
        'name': password.name,
        'login': password.login,
        'password': password.password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Password>> getPasswords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('passwords');
    return List.generate(maps.length, (i) {
      return Password.fromMap({
        'id': maps[i]['id'],
        'group': maps[i]['password_group'],
        'name': maps[i]['name'],
        'login': maps[i]['login'],
        'password': maps[i]['password'],
      });
    });
  }

  Future<int> updatePassword({
    required int id,
    required String group,
    required String name,
    required String login,
    required String password,
  }) async {
    final db = await database;
    return await db.update(
      'passwords',
      {
        'password_group': group,
        'name': name,
        'login': login,
        'password': password,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePassword(int id) async {
    final db = await database;
    var result = await db.query('passwords', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      print("No password found with id: $id");
    } else {
      await db.delete(
        'passwords',
        where: 'id = ?',
        whereArgs: [id],
      );
      print("Password deleted successfully");
    }
  }

  Future<bool> deleteAllPasswords() async {
    try {
      final db = await database;

      await db.transaction((txn) async {
        final int count = Sqflite.firstIntValue(
                await txn.rawQuery('SELECT COUNT(*) FROM passwords')) ??
            0;

        await txn.delete('passwords');

        print("Удалено записей: $count");
        await txn.execute(
            'DELETE FROM sqlite_sequence WHERE name = ?', ['passwords']);
      });

      return true;
    } catch (e) {
      print('Ошибка при удалении паролей: $e');
      return false;
    }
  }
}
