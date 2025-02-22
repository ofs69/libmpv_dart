import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mpv_dart/libmpv.dart' as mpv_dart;
import 'package:mpv_dart/library.dart';

void main() {
  Library.init();
  var placholder=new Map<String,String>();
  final player=mpv_dart.Player(placholder);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int sumResult;
  late Future<int> sumAsyncResult;



  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                Text(
                  "",
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
