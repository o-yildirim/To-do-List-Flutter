import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "To do-List",
      home: TaskView(),
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
        accentColor: Colors.deepOrangeAccent,
      ),
    );
  }
}
