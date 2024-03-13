import 'package:flutter/material.dart';
import "package:my_app/about.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Home Page'),
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
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
      debugPrint(_counter.toString());
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      debugPrint(_counter.toString());
    });
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
            const Padding(
              padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
              child: Text(
                'You have pushed the button this many times:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _decrementCounter,
                  tooltip: "Decrement",
                  child: const Icon(Icons.remove),
                ),
                FloatingActionButton(
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  onPressed: () {},
                ),
                FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const ToDoList(),
          ],
        ),
      ),
    );
  }
}
