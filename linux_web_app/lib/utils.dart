import 'dart:io';
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
}
