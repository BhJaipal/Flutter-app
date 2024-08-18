import 'dart:io';

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

  Future<void> insertApp() async {
    App app = App(
        name: nameController.text,
        url: urlController.text,
        logo: logoController.value.text);
    status = await DbHelper().insertApp(app);
  }

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
                      if (status != null)
                        (status!["status"] == false)
                            ? const Padding(
                                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                child: Text(
                                  "Error, Could not add the app",
                                  style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                child: Text(
                                  "App Added",
                                  style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
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
                          shape: MaterialStatePropertyAll(
                              BeveledRectangleBorder()),
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.lightBlueAccent),
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
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all(
                                const RoundedRectangleBorder(),
                              ),
                            ),
                            child: SvgPicture.asset(
                              "assets/icons/places/folder-Arch.svg",
                              width: 150,
                              clipBehavior: Clip.hardEdge,
                              height: 150,
                              matchTextDirection: true,
                              colorFilter: const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.color,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor:
                                          const Color.fromRGBO(9, 45, 99, 1),
                                      actions: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.lightBlueAccent,
                                            ),
                                          ),
                                          onPressed: () {
                                            Logger().d("Selected");
                                          },
                                          child: const Text("Select"),
                                        ),
                                      ],
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
                                                  "app",
                                                  "applets",
                                                  "places",
                                                  "preferences",
                                                  "devices",
                                                  "categories"
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
