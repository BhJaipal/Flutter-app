import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linux_web_app/create.dart';
import 'package:linux_web_app/db_helper.dart';
import "package:sqflite_common_ffi/sqflite_ffi.dart";

Future<void> main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
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
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
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
                            fontSize: 40),
                      )));
                } else if (!snapshot.hasData) {
                  return const Text(
                    'No apps found.',
                    style: TextStyle(color: Colors.redAccent),
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
                              fontSize: 40, fontWeight: FontWeight.bold),
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
                          tileColor: Colors.blueAccent,
                          style: ListTileStyle.drawer,
                          shape: const RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Color(0xFF005AA8), width: 2)),
                          leading: Image.asset('assets/${app.logo}'),
                          title: Text(app.name),
                          subtitle: Text(app.url),
                        ),
                      );
                    },
                  );
                }
              },
            )
          ],
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
