import 'package:pirate_music/Store.dart';
import 'package:sqflite/sqflite.dart';

class FileService {
  String path;
  String tableName = "Files";
  String columnId = "id";
  String columnName = "name";
  String columnPath = "path";
  String columnListId = "listId";

  FileService({required this.path});

  Future open(String path) async {
    Database db = await openDatabase(path, version: 1,
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY AUTOINCREMENT, "
              "$columnName TEXT NOT NULL, $columnPath TEXT NOT NULL, $columnListId INTEGER NOT NULL)",
        );
      },
    );

    return db;
  }

  Future<Store> insert(Store store) async {
    Database db = await open(path);
    store.id = await db.insert(tableName, store.toMap());
    return store;
  }

  Future<Store?> getById(int id) async {
    Database db = await open(path);

    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPath, columnListId],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Store.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Store>?> getAll() async {
    Database db = await open(path);

    List<Map> maps = await db.query(tableName,
      columns: [columnId, columnName, columnPath, columnListId]);

    if (maps.isNotEmpty) {
      List<Store> list = [];

      for (int i = 0; i < maps.length; i++) {
        list.add(Store.fromMap(maps[i]));
      }

      return list;
    }
    return null;
  }

  Future<List<Store>?> getAllByListId(int id) async {
    Database db = await open(path);

    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPath, columnListId],
        where: '$columnListId = ?',
        whereArgs: [id]
    );

    if (maps.isNotEmpty) {
      List<Store> list = [];

      for (int i = 0; i < maps.length; i++) {
        list.add(Store.fromMap(maps[i]));
      }

      return list;
    }
    return null;
  }

  Future<List<Store>?> getAllByName(String name) async {
    Database db = await open(path);

    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName, columnPath, columnListId],
        where: '$columnName = ?',
        whereArgs: [name]
    );

    if (maps.isNotEmpty) {
      List<Store> list = [];

      for (int i = 0; i < maps.length; i++) {
        list.add(Store.fromMap(maps[i]));
      }

      return list;
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await open(path);
    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteByListId(int id) async {
    Database db = await open(path);
    return await db.delete(tableName, where: '$columnListId = ?', whereArgs: [id]);
  }

  Future<int> update(Store store) async {
    Database db = await open(path);
    return await db.update(tableName, store.toMap(),
        where: '$columnId = ?', whereArgs: [store.id]);
  }

  Future close() async {
    Database db = await open(path);
    db.close();
  }
}