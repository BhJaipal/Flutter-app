import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linux_web_app/db_helper.dart';
import 'package:logger/logger.dart';

class Edit extends StatefulWidget {
  const Edit({super.key, required this.app});

  final App app;

  @override
  // ignore: no_logic_in_create_state
  State<Edit> createState() => _EditState(app: app);
}

class _EditState extends State<Edit> {
  final App app;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController urlController;
  late TextEditingController logoController;
  TextEditingController? logoCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: app.name);
    urlController = TextEditingController(text: app.url);
    logoController = TextEditingController(text: app.logo);
  }

  _EditState({required this.app});

  Future<void> editApp() async {
    App updatedApp = App(
      name: nameController.text,
      url: urlController.text,
      logo:
          "assets/icons/${logoCategoryController!.value.text.toLowerCase()}/${logoController.value.text}.svg",
    );
    status = {"status": await DbHelper().editApp(updatedApp, app)};
    Logger().d(status);
  }

  Future<List<String>> icons(String category) async {
    Logger().d(category);
    List<String> out = [];
    category = category.toLowerCase();
    List<FileSystemEntity> list =
        await Directory("assets/icons/$category").list().toList();
    for (var e in list) {
      out.add(e.path);
    }
    return out;
  }

  Map<String, int>? status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(243, 15, 15, 15),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Edit page"),
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
                    children: (status != null)
                        ? [
                            (status!["status"] == 0)
                                ? const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                                    child: Text(
                                      "Error, Could not edit the app",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                                    child: Text(
                                      "App updated",
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                          ]
                        : [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  10, (status == null ? 100 : 10), 50, 50),
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
                              padding: const EdgeInsets.fromLTRB(10, 0, 50, 50),
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
                                          value
                                              .split("http://")[1]
                                              .contains(".")) ||
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
                                  shape: MaterialStatePropertyAll(
                                      BeveledRectangleBorder()),
                                  backgroundColor: MaterialStatePropertyAll(
                                      Colors.lightBlueAccent)),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  editApp();
                                }
                              },
                              child: const Text('Submit'),
                            )
                          ],
                  ),
                ),
                SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                        child: ButtonTheme(
                          minWidth: 150,
                          height: 150,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(),
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 150,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          const Color.fromRGBO(9, 45, 99, 1),
                                      content: SizedBox(
                                        height: 300,
                                        width: 300,
                                        child: Column(children: [
                                          const Text(
                                            "Select logo",
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 30,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 50, 0, 50),
                                            child: DropdownMenu(
                                                width: 200,
                                                menuStyle: MenuStyle(
                                                  fixedSize:
                                                      MaterialStateProperty.all(
                                                    const Size(200, 240),
                                                  ),
                                                  side:
                                                      MaterialStateProperty.all(
                                                    const BorderSide(
                                                      color: Colors.greenAccent,
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                                textStyle: const TextStyle(
                                                  color: Colors.green,
                                                ),
                                                label: const Text(
                                                  "Logo Categories",
                                                  style: TextStyle(
                                                    color: Colors.greenAccent,
                                                  ),
                                                ),
                                                controller:
                                                    logoCategoryController,
                                                dropdownMenuEntries: [
                                                  "apps",
                                                  "actions",
                                                  "applets",
                                                  "categories",
                                                  "devices",
                                                  "places",
                                                  "preferences"
                                                ]
                                                    .map<
                                                            DropdownMenuEntry<
                                                                String>>(
                                                        (String value) =>
                                                            DropdownMenuEntry(
                                                              label: value
                                                                      .characters
                                                                      .first
                                                                      .toUpperCase() +
                                                                  value
                                                                      .substring(
                                                                          1),
                                                              value: value,
                                                              style:
                                                                  ButtonStyle(
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all(Colors
                                                                            .white),
                                                                foregroundColor:
                                                                    MaterialStateProperty
                                                                        .all(Colors
                                                                            .green),
                                                              ),
                                                            ))
                                                    .toList()),
                                          ),
                                          logoCategoryController != null &&
                                                  logoCategoryController!
                                                      .value.text.isNotEmpty
                                              ? FutureBuilder(
                                                  future: icons(
                                                      logoCategoryController!
                                                          .value.text),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasData) {
                                                      List<DropdownMenuEntry>
                                                          entries = [];
                                                      for (var element
                                                          in snapshot.data
                                                              as List<String>) {
                                                        entries.add(
                                                            DropdownMenuEntry(
                                                          leadingIcon:
                                                              SvgPicture.asset(
                                                            element,
                                                            width: 50,
                                                            height: 50,
                                                            clipBehavior:
                                                                Clip.hardEdge,
                                                            matchTextDirection:
                                                                true,
                                                            colorFilter:
                                                                const ColorFilter
                                                                    .mode(
                                                              Colors
                                                                  .transparent,
                                                              BlendMode.color,
                                                            ),
                                                          ),
                                                          label: element
                                                              .split("/")
                                                              .last
                                                              .split(".svg")
                                                              .first,
                                                          value: element,
                                                          style: ButtonStyle(
                                                            textStyle:
                                                                MaterialStateProperty
                                                                    .all(
                                                              const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                            foregroundColor:
                                                                MaterialStateProperty
                                                                    .all(
                                                              Colors.black,
                                                            ),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(
                                                              Colors.white,
                                                            ),
                                                          ),
                                                        ));
                                                      }
                                                      return DropdownMenu(
                                                        controller:
                                                            logoController,
                                                        textStyle:
                                                            const TextStyle(
                                                          color: Colors.green,
                                                        ),
                                                        width: 200,
                                                        menuStyle: MenuStyle(
                                                          fixedSize:
                                                              MaterialStateProperty
                                                                  .all(
                                                            const Size(
                                                                250, 275),
                                                          ),
                                                          backgroundColor:
                                                              MaterialStateProperty
                                                                  .all(
                                                            Colors.white,
                                                          ),
                                                        ),
                                                        label: const Text(
                                                          "Select logo",
                                                          style: TextStyle(
                                                            color: Colors
                                                                .greenAccent,
                                                          ),
                                                        ),
                                                        dropdownMenuEntries:
                                                            entries,
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                        snapshot.error
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 30,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      );
                                                    }
                                                    return const Text(
                                                      "Loading",
                                                      style: TextStyle(
                                                        color:
                                                            Colors.greenAccent,
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const Text(
                                                  "Select Category",
                                                  style: TextStyle(
                                                    color: Colors.greenAccent,
                                                    fontSize: 30,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ]),
                                      ),
                                    );
                                  });
                            },
                          ),
                        ),
                      ),
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
