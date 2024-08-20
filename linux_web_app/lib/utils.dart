import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

// ignore: non_constant_identifier_names
Future<Directory> HomeDir() async {
  Directory dir = await getApplicationDocumentsDirectory();
  return dir.parent;
}

Future<void> copyIcons() async {
  Directory iconsFolder =
      Directory("${(await HomeDir()).path}/.var/app/com.flutter.WebApps/icons");
  if (!await iconsFolder.exists()) {
    iconsFolder.create(recursive: true);
  }
  if ((await iconsFolder.list().toList()).isEmpty) {
    Directory currIconsDir =
        Directory("${Directory.current.path}/assets/icons");
    List<FileSystemEntity> folders = await currIconsDir.list().toList();
    // ignore: avoid_function_literals_in_foreach_calls
    folders.forEach((element) async {
      Directory category = Directory(element.path);
      Directory iconDirCategory =
          Directory("${iconsFolder.path}/${category.path.split('/').last}");
      if (!await iconDirCategory.exists()) {
        await iconDirCategory.create(recursive: true);
      }
      Logger().d(category);
      for (FileSystemEntity el in await category.list().toList()) {
        File icon = File("${iconDirCategory.path}/${el.path.split('/').last}");
        if (!(await icon.exists())) {
          await icon.copy(el.path);
        }
      }
    });
  }
}
