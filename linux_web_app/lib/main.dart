import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linux_web_app/create.dart';
import 'package:linux_web_app/db_helper.dart';
import 'package:linux_web_app/edit.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import "package:sqflite_common_ffi/sqflite_ffi.dart";

Future<void> main() async {
  Directory iconsDir = Directory(
      "${(await getApplicationDocumentsDirectory()).path}../.local/share/icons/MyWebApps");
  if (!await iconsDir.exists()) {
    iconsDir.create(recursive: true);
  }

  WidgetsFlutterBinding.ensureInitialized();
  databaseFactory = databaseFactoryFfi;
  Directory dir = Directory("data");
  if (!await dir.exists()) {
    dir.create();
  }
  final file = File("data/apps.db");
  if (!await file.exists()) {
    file.create(recursive: true);
  }
  sqfliteFfiInit();
  String down = await getDatabasesPath();
  String dbFullPath = down;
  dbFullPath += "/../../../data/";
  databaseFactory.setDatabasesPath(dbFullPath);
  Logger().d(await getDatabasesPath());
  runApp(const MyApp());
  return Future.value();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 2, 163, 243),
            background: Colors.black87),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cosmic Web App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<App>> getApps() async {
    final List<App> apps = await DbHelper().getApps();
    return apps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(243, 15, 15, 15),
      drawer: NavigationDrawer(
        backgroundColor: Colors.lightBlueAccent.shade400,
        children: [
          ListTile(
            title: const Text("Home"),
            leading: const Icon(Icons.home),
            tileColor: Colors.lightBlueAccent.shade200,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MyApp())),
          ),
          ListTile(
            title: const Text("Create"),
            leading: const Icon(Icons.create),
            tileColor: Colors.lightBlueAccent.shade200,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const Create())),
          ),
        ],
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            FutureBuilder<List<App>>(
              future: getApps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ProgressIndicatorExample();
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                    child: Center(
                      child: Text(
                        'Error loading apps: ${snapshot.error}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  );
                } else if (!snapshot.hasData) {
                  return const Text(
                    'No apps found.',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else {
                  final apps = snapshot.data!;
                  if (apps.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                      child: Center(
                        child: Text(
                          "Apps List is empty",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: apps.length,
                    shrinkWrap: true,
                    physics: const PageScrollPhysics(),
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                            300, index == 0 ? 100 : 0, 300, 0),
                        child: ListTile(
                          tileColor: Colors.lightBlue,
                          style: ListTileStyle.drawer,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(
                              color: Color.fromARGB(255, 1, 90, 163),
                              width: 1,
                            ),
                          ),
                          leading: app.logo.endsWith(".jpg") ||
                                  app.logo.endsWith(".png")
                              ? Image.asset('assets/${app.logo}')
                              : SvgPicture.asset(
                                  app.logo,
                                  width: 50,
                                  clipBehavior: Clip.hardEdge,
                                  height: 50,
                                  matchTextDirection: true,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.transparent,
                                    BlendMode.color,
                                  ),
                                ),
                          title: Text(app.name),
                          subtitle: Text(app.url),
                          trailing: Wrap(
                            spacing: 10,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Edit(app: app),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  DbHelper().deleteApp(app);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const MyHomePage(
                                              title: "Cosmic Web App",
                                            )),
                                    (route) => false,
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 50, 50),
        child: FloatingActionButton(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          foregroundColor: Colors.blueAccent,
          child: const Icon(Icons.refresh),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyHomePage(
                        title: "Cosmic Web App",
                      )),
              (route) => false,
            );
          },
        ),
      ),
    );
  }
}

class ProgressIndicatorExample extends StatefulWidget {
  const ProgressIndicatorExample({super.key});

  @override
  State<ProgressIndicatorExample> createState() =>
      _ProgressIndicatorExampleState();
}

class _ProgressIndicatorExampleState extends State<ProgressIndicatorExample>
    with TickerProviderStateMixin {
  late AnimationController controller;
  bool determinate = false;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 30),
          CircularProgressIndicator(
            value: controller.value,
            semanticsLabel: 'Circular progress indicator',
          ),
        ],
      ),
    );
  }
}
