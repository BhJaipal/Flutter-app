import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Create"),
      ),
      body: Center(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(100, 100, 50, 50),
                        child: TextFormField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: 'Enter App name',
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder()),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            if (value.length <= 3) {
                              return "Name must be longer than 3 letters";
                            }
                            int isSpace = 1;
                            for (var element in value.runes) {
                              if (" " != String.fromCharCode(element)) {
                                isSpace = 0;
                              }
                            }
                            if (isSpace == 1) {
                              return "Name must not be only spaces";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(100, 0, 50, 50),
                        child: TextFormField(
                          controller: urlController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                              hintText: 'Enter URL',
                              hintStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder()),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a URL';
                            }
                            if (value.length <= 3) {
                              return "Name must be longer than 3 letters";
                            }
                            if (!(value.startsWith("http://") ||
                                value.startsWith("https://"))) {
                              return "URL must start with http:// or https://";
                            }
                            if (!((value.startsWith("http://") &&
                                    value.split("http://")[1].contains(".")) ||
                                (value.startsWith("https://") &&
                                    value
                                        .split("https://")[1]
                                        .contains(".")))) {
                              return "URL must have a top domain like .com .net .org .app .io";
                            }
                            int isSpace = 1;
                            for (var element in value.runes) {
                              if (" " != String.fromCharCode(element)) {
                                isSpace = 0;
                              }
                            }
                            if (isSpace == 1) {
                              return "Name must not be only spaces";
                            }
                            return null;
                          },
                        ),
                      ),
                      ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.lightBlueAccent)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            App app = App(
                                name: nameController.text,
                                url: urlController.text,
                                logo: "logo.png");
                            debugPrint(app.toString());
                            insertApp(app);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: Image.asset(
                          "assets/unknown.jpg",
                          height: 100,
                          width: 100,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.lightBlueAccent)),
                          child: const Text(
                            "Select",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final database =
   openDatabase("./../data/apps.db", version: 1, onCreate: (db, version) {
  db.execute(
      "CREATE TABLE IF NOT EXISTS apps(name VARCHAR(30), url VARCHAR(100), logo VARCHAR(50))");
  version = 1;
});

Future<void> insertApp(App app) async {
  final db = await database;
  await db.insert(
    'apps',
    app.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

class App {
  String name;
  String url;
  String logo;
  App({required this.name, required this.url, required this.logo});
  Map<String, dynamic> toMap() {
    return {"name": name, "url": url, "logo": logo};
  }

  @override
  String toString() {
    return 'App{name: $name, url: $url, logo: $logo}';
  }
}
