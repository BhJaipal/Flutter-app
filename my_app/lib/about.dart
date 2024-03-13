import 'package:flutter/material.dart';
import 'package:my_app/main.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  List<String> tasks = [];
  final inputControl = TextEditingController();
  void addItem() {
    setState(() {
      debugPrint(inputControl.text);
      tasks.add(inputControl.text);
      inputControl.clear();
      print(tasks);
    });
  }

  @override
  void dispose() {
    inputControl.dispose();
    super.dispose();
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
            title: const Text("About"),
            leading: const Icon(Icons.article),
            tileColor: Colors.lightBlueAccent.shade200,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ToDoList())),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text("About"),
        backgroundColor: Colors.lightBlueAccent,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      body: Form(
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Container(
                  width: 300,
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(50, 10, 0, 0),
                  child: TextField(
                    controller: inputControl,
                    decoration: const InputDecoration(
                      hintText: "Todo name",
                    ),
                  ),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                      shape: MaterialStatePropertyAll(CircleBorder())),
                  onPressed: addItem,
                  child: const Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 50, 30, 0),
              child: ListView(
                shrinkWrap: true,
                semanticChildCount: 3,
                scrollDirection: Axis.vertical,
                children: tasks.map((e) {
                  return TODO(
                    taskName: e,
                    deleteFn: () {
                      setState(() {
                        tasks.remove(e);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TODO extends StatefulWidget {
  const TODO({super.key, required this.taskName, required this.deleteFn});

  final String taskName;
  final void Function() deleteFn;

  @override
  State<TODO> createState() => _TODOState();
}

class _TODOState extends State<TODO> {
  var isDone = false;
  Color doneColor = Colors.red;
  Color taskColor = const Color.fromARGB(255, 228, 191, 194);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.taskName),
      titleTextStyle: TextStyle(
        color: doneColor,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      style: ListTileStyle.list,
      dense: true,
      tileColor: taskColor,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            children: [
              SimpleDialogOption(
                child: Checkbox(
                  activeColor: Colors.greenAccent,
                  value: isDone,
                  onChanged: (value) {
                    setState(() {
                      isDone = value!;
                      doneColor = isDone ? Colors.blue : Colors.red;
                      taskColor = isDone
                          ? const Color.fromARGB(255, 157, 208, 250)
                          : const Color.fromARGB(255, 228, 191, 194);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: widget.deleteFn,
    );
  }
}
