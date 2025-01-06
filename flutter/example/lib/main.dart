// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_gstreamer/flutter_gstreamer.dart' as flutter_gstreamer;

Future<void> main() async {
  await flutter_gstreamer.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String? fromRust;
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Test Page'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  try {
                    final res = await flutter_gstreamer.helloWorld();
                    setState(() {
                      fromRust = res;
                    });
                  } catch (e, st) {
                    print(e);
                    print(st);
                  }
                },
                child: Text(fromRust == null ? 'Call Rust' : 'Rust: $fromRust'),
              ),
              // if (response != null) Text(response!.headers.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
