import 'package:flutter/material.dart';

import 'color_picker.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColorPicker(
        pickerColor: color,
        pickerAreaSize: const Size(300, 200),
        onColorChanged: (c) {
          setState(() {
            color = c;
          });
        },
      ),
    );
  }
}
