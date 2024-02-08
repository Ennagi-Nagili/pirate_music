import 'package:pirate_music/PlaylistModel.dart';
import 'package:pirate_music/Store.dart';
import 'package:sqflite/sqflite.dart';

class PlayService {
  String tableName = "Playlists";
  String columnId = "id";
  String columnName = "name";
  String path;

  PlayService({required this.path});

  Future open(String path) async {
    Database db = await openDatabase(path, version: 1,
      onCreate: (database, version) async {
        await database.execute(
            "CREATE TABLE $tableName($columnId INTEGER PRIMARY KEY AUTOINCREMENT, "
                "$columnName TEXT NOT NULL)",
        );
      },
    );

    return db;
  }

  Future<PlayListModel> insert(PlayListModel playListModel) async {
    Database db = await open(path);
    playListModel.id = await db.insert(tableName, playListModel.toMap());
    // await openDatabase(path, version: 1, onCreate: (database, version) async {
    //   await database.execute("DROP TABLE $tableName");
    // });
    return playListModel;
  }

  Future<PlayListModel?> getById(int id) async {
    Database db = await open(path);

    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return PlayListModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<PlayListModel>?> getAll() async {
    Database db = await open(path);

    List<Map> maps = await db.query(tableName,
        columns: [columnId, columnName]);

    if (maps.isNotEmpty) {
      List<PlayListModel> list = [];

      for (int i = 0; i < maps.length; i++) {
        list.add(PlayListModel.fromMap(maps[i]));
      }

      return list;
    }
    return null;
  }

  Future<int> delete(int id) async {
    Database db = await open(path);

    return await db.delete(tableName, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(PlayListModel playlistModel) async {
    Database db = await open(path);

    return await db.update(tableName, playlistModel.toMap(),
        where: '$columnId = ?', whereArgs: [playlistModel.id]);
  }

  Future close() async {
    Database db = await open(path);
    db.close();
  }
}