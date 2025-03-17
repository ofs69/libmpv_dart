import 'package:flutter/material.dart';
import 'package:libmpv_dart/libmpv.dart';
import 'package:libmpv_dart_example/player_page.dart';

void main() {
  Library.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: PlayerPage(),
      ),
    );
  }
}
