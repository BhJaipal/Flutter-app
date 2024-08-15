import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linux_web_app/create.dart';
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
                    return const CircularProgressIndicator(); // Show a loading indicator while fetching data
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error loading apps: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    );
                  } else if (!snapshot.hasData) {
                    return const Text(
                      'No apps found.',
                      style: TextStyle(color: Colors.redAccent),
                    );
                  } else {
                    final apps = snapshot.data!;
                    return ListView.builder(
                      itemCount: apps.length,
                      itemBuilder: (context, index) {
                        final app = apps[index];
                        return ListTile(
                          tileColor: Colors.lightBlueAccent,
                          leading: Image.asset('assets/${app.logo}'),
                          title: Text(app.name),
                          subtitle: Text(app.url),
                        );
                      },
                    );
                  }
                },
              )
            ]),
      ),
    );
  }
}

Future<List<App>> getApps() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query('apps');
  debugPrint(maps.toString());
  return [
    for (final {
          'name': name as String,
          'url': url as String,
          'logo': logo as String
        } in maps)
      App(name: name, url: url, logo: logo)
  ];
}
