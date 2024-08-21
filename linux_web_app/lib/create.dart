import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linux_web_app/db_helper.dart';
import 'package:logger/logger.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController? logoCategoryController = TextEditingController();
  TextEditingController logoController = TextEditingController();
  late String browserController;
  late String? selectedFile;
  bool uploaded = false;

  final Map<String, String> browsers = {
    "Default": "xdg-open",
    "Google Chrome": "flatpak run com.google.Chrome",
    "Edge": "flatpak run com.microsoft.Edge",
  };

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

  Map<String, bool>? status;
  bool? statusBool;

  Future<void> insertApp() async {
    late App app;
    if (uploaded) {
      app = App(
        name: nameController.text,
        url: urlController.text,
        logo: selectedFile!,
        browser: browserController,
      );
    } else {
      app = App(
        name: nameController.text,
        url: urlController.text,
        browser: browserController,
        logo:
            "assets/icons/${logoCategoryController!.value.text.toLowerCase()}/${logoController.value.text}.svg",
      );
    }

    Map<String, bool> res = await DbHelper().insertApp(app, uploaded: uploaded);
    setState(() {
      status = res;
      statusBool = status!["status"];
    });
  }

  Future<void> fileUpload() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowedExtensions: ["jpg", "png"]);
    selectedFile = result!.files[0].path;
    uploaded = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(243, 15, 15, 15),
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
                    children: (statusBool != null)
                        ? ([
                            (!(statusBool!))
                                ? const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 150, 0, 0),
                                    child: Text(
                                      "Error, Could not add the app",
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
                                      "App Added",
                                      style: TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 40,
                                      ),
                                    ),
                                  )
                          ])
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
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 50, 50),
                              child: DropdownMenu(
                                textStyle: const TextStyle(color: Colors.white),
                                label: const Text(
                                  "Browsers",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    browserController = value!;
                                  });
                                },
                                dropdownMenuEntries: browsers.entries
                                    .map<DropdownMenuEntry<String>>(
                                        (entry) => DropdownMenuEntry(
                                              value: entry.value,
                                              label: entry.key,
                                            ))
                                    .toList(),
                              ),
                            ),
                            ElevatedButton(
                              style: const ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                    BeveledRectangleBorder()),
                                backgroundColor: MaterialStatePropertyAll(
                                    Colors.lightBlueAccent),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  insertApp();
                                }
                              },
                              child: const Text('Submit'),
                            )
                          ],
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 110, 0, 0),
                        child: ButtonTheme(
                          minWidth: 150,
                          height: 150,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(0, 30, 7, 7)),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.blueAccent),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(),
                              ),
                            ),
                            child: const Icon(Icons.add, size: 150),
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
                                                85, 25, 85, 0),
                                            child: ElevatedButton(
                                              onPressed: fileUpload,
                                              style: const ButtonStyle(
                                                backgroundColor:
                                                    MaterialStatePropertyAll(
                                                  Colors.blueAccent,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.upload,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    "Upload",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 25, 0, 50),
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
                                                  "preferences",
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
                                                        onSelected: (value) {
                                                          uploaded = false;
                                                        },
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
