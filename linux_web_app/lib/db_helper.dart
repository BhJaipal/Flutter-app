import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbHelper {
  String dbName = '../../../data/apps.db';
  String tableName = 'apps';
  String colName = 'name';
  String colUrl = 'url';
  String colLogo = 'logo';
  Database? db;
  DbHelper() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  Future<void> init() async {
    db = await openDatabase(join(await getDatabasesPath(), dbName), version: 1,
        onCreate: (Database db2, int version) {
      db2.execute(
          "CREATE TABLE IF NOT EXISTS apps(name VARCHAR(30), url VARCHAR(100), logo VARCHAR(50))");
    });
    return Future.value();
  }

  Future<Map<String, bool>> insertApp(App app) async {
    await init();
    try {
      if (db == null) return {"status": false};
      int res = await db!.insert(
        'apps',
        app.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      print("Res: $res");
      if (res != 0) {
        return {"status": true};
      } else {
        return {"status": false};
      }
    } catch (e) {
      return {"status": false};
    }
  }

  Future<List<App>> getApps() async {
    init();
    db = await openDatabase(join(await getDatabasesPath(), dbName), version: 1,
        onCreate: (Database db2, int version) {
      db2.execute(
          "CREATE TABLE IF NOT EXISTS apps(name VARCHAR(30), url VARCHAR(100), logo VARCHAR(50))");
    });
    if (db == null) {
      throw Exception("Db is null");
    }
    final List<Map<String, dynamic>> maps = await db!.query('apps');
    return [
      for (final {
            'app': app as String,
            'url': url as String,
            'logo': logo as String
          } in maps)
        App(name: app, url: url, logo: logo)
    ];
  }

  Future<void> editApp(App app, String name) async {
    init();
    db = await openDatabase(join(await getDatabasesPath(), dbName), version: 1,
        onCreate: (Database db2, int version) {
      db2.execute(
          "CREATE TABLE IF NOT EXISTS apps(name VARCHAR(30), url VARCHAR(100), logo VARCHAR(50))");
    });
    if (db == null) {
      throw Exception("Db is null");
    }
    int res = await db!.update("app", app.toMap(),
        where: 'app=?',
        whereArgs: [name],
        conflictAlgorithm: ConflictAlgorithm.fail);

    return Future.value();
  }
}

class App {
  String name;
  String url;
  String logo;
  App({required this.name, required this.url, required this.logo});
  Map<String, dynamic> toMap() {
    return {"app": name, "url": url, "logo": logo};
  }

  @override
  String toString() {
    return 'App{name: $name, url: $url, logo: $logo}';
  }
}
