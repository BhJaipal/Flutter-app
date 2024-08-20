import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DbHelper {
  String dbName = 'apps.db';
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
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      String appName = app.name;
      String fileAppName = app.name
          .split(" ")
          .map((e) => e.characters.first.toUpperCase() + e.substring(1))
          .join("");
      if (res != 0) {
        Directory docs = await getApplicationDocumentsDirectory();
        File desktopFile = File(
            "${docs.path}/../.local/share/applications/com.WebApps.$appName.desktop");
        await desktopFile.create(recursive: true);
        await desktopFile.writeAsString("""
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=$fileAppName
Exec=xdg-open "${app.url}"
Icon=~/.var/app/com.flutter.WebApps/${app.logo}
        """);
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

  Future<int> editApp(App updatedApp, App app) async {
    init();
    db = await openDatabase(join(await getDatabasesPath(), dbName), version: 1,
        onCreate: (Database db2, int version) {
      db2.execute(
          "CREATE TABLE IF NOT EXISTS apps(name VARCHAR(30), url VARCHAR(100), logo VARCHAR(50))");
    });
    if (db == null) {
      throw Exception("Db is null");
    }
    try {
      int res = await db!.update("apps", updatedApp.toMap(),
          where: 'app=? AND url=? AND logo=?',
          whereArgs: [app.name, app.url, app.logo],
          conflictAlgorithm: ConflictAlgorithm.fail);
      return res;
    } catch (e) {
      Logger().d(e, error: e);
      return 0;
    }
  }

  Future<int> deleteApp(App app) async {
    init();
    db = await openDatabase(join(await getDatabasesPath(), dbName), version: 1,
        onCreate: (Database db2, int version) {
      db2.execute(
          "CREATE TABLE IF NOT EXISTS apps(name VARCHAR(30), url VARCHAR(100), logo VARCHAR(50))");
    });
    if (db == null) {
      throw Exception("Db is null");
    }
    return await db!.delete(
      'apps',
      where: 'app=? AND url=? AND logo=?',
      whereArgs: [app.name, app.url, app.logo],
    );
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
