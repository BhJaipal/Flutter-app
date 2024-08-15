import 'package:flutter/material.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Create"),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
           crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(600,100,600,50),
                child:
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter App name',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
                ),
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
                  if (isSpace ==1) {
                    return "Name must not be only spaces";
                  }
                  return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(600,0,600,50),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter URL',
                    hintStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder()
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    if (value.length <= 3) {
                      return "Name must be longer than 3 letters";
                    }
                    if (!(value.startsWith("http://") || value.startsWith("https://"))) {
                      return "URL must start with http:// or https://";
                    }
                    if (!((value.startsWith("http://") && value.split("http://")[1].contains(".")) || (value.startsWith("https://") && value.split("https://")[1].contains(".")))) {
                      return "URL must have a top domain like .com .net .org .app .io";
                    }
                    int isSpace = 1;
                    for (var element in value.runes) {
                      if (" " != String.fromCharCode(element)) {
                        isSpace = 0;
                      }
                    }
                    if (isSpace ==1) {
                      return "Name must not be only spaces";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
