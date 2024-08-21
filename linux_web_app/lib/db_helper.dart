import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:linux_web_app/utils.dart';
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

  Future<Map<String, bool>> insertApp(App app, {bool uploaded = false}) async {
    await init();
    try {
      if (db == null) return {"status": false};
      int res = await db!.insert(
        'apps',
        {
          "app": app.name,
          "url": app.url,
          "logo": !uploaded ? app.logo : app.logo.split("/").last
        },
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
        if (uploaded) {
          File(app.logo).copySync(
              "${(await HomeDir()).path}/.var/app/com.flutter.WebApps/${app.logo.split('/').last}");
          File(app.logo).copySync(
              "${Directory.current.path}/assets/new/${app.logo.split('/').last}");
        }
        await desktopFile.create(recursive: true);
        await desktopFile.writeAsString("""
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=$fileAppName
Exec=${app.browser} "${app.url}"
Icon=${(await HomeDir()).path}/.var/app/com.flutter.WebApps/${!uploaded ? app.logo : app.logo.split('/').last}
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

  Future<int> editApp(App updatedApp, App app, {bool uploaded = false}) async {
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
      int res = await db!.update(
          "apps",
          {
            "app": updatedApp.name,
            "url": updatedApp.url,
            "logo":
                !uploaded ? updatedApp.logo : updatedApp.logo.split("/").last
          },
          where: 'app=? AND url=? AND logo=?',
          whereArgs: [app.name, app.url, app.logo],
          conflictAlgorithm: ConflictAlgorithm.fail);

      String fileAppName = app.name
          .split(" ")
          .map((e) => e.characters.first.toUpperCase() + e.substring(1))
          .join("");

      Directory docs = await getApplicationDocumentsDirectory();
      File desktopFile = File(
          "${docs.path}/../.local/share/applications/com.WebApps.$fileAppName.desktop");
      if (uploaded) {
        File(app.logo).copySync(
            "${(await HomeDir()).path}/.var/app/com.flutter.WebApps/${updatedApp.logo.split('/').last}");
        File(app.logo).copySync(
            "${Directory.current.path}/assets/new/${updatedApp.logo.split('/').last}");
      }
      await desktopFile.delete();
      fileAppName = app.name
          .split(" ")
          .map((e) => e.characters.first.toUpperCase() + e.substring(1))
          .join("");

      String appName = updatedApp.name;
      desktopFile = File(
          "${docs.path}/../.local/share/applications/com.WebApps.${updatedApp.name.split(' ').map((el) => el.characters.first.toUpperCase() + el.substring(1)).join()}.desktop");
      desktopFile.writeAsString("""
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=$appName
Exec=${updatedApp.browser} "${updatedApp.url}"
Icon=${(await HomeDir()).path}/.var/app/com.flutter.WebApps/${!uploaded ? updatedApp.logo : updatedApp.logo.split('/').last}
        """);
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
    int res = await db!.delete(
      'apps',
      where: 'app=? AND url=? AND logo=?',
      whereArgs: [app.name, app.url, app.logo],
    );
    String appName = app.name;
    Directory docs = await getApplicationDocumentsDirectory();
    File desktopFile = File(
        "${docs.path}/../.local/share/applications/com.WebApps.$appName.desktop");
    await desktopFile.delete();
    return res;
  }
}

class App {
  String name;
  String url;
  String logo;
  String browser;
  App(
      {required this.name,
      required this.url,
      required this.logo,
      this.browser = 'xdg-open'});
  Map<String, dynamic> toMap() {
    return {"app": name, "url": url, "logo": logo};
  }

  @override
  String toString() {
    return 'App{name: $name, url: $url, logo: $logo, broswer: $browser}';
  }
}
