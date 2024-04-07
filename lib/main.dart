// import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:craftor_color_picker/color_picker.dart';
import 'package:craftor_color_picker/src/color_wheel_picker.dart';
// import 'package:craftor_color_picker/src/palette.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

// import 'color_picker.dart' as color_picker;

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
      body: Row(
        children: [
          // Expanded(
          //   child: color_picker.ColorPicker(
          //     pickerColor: color,
          //     pickerAreaSize: const Size(300, 200),
          //     onColorChanged: (c) {
          //       setState(() {
          //         color = c;
          //       });
          //       print('test2');
          //     },
          //   ),
          // ),
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 360,
                  child: ColorWheelPicker(
                    color: color,
                    // shouldUpdate: true,
                    onChanged: (c) {
                      setState(() {
                        color = c;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SelectableText('$color'),
                SelectableText('${colorToHex(color)}'),
                SelectableText('${colorToHex(color, alphaFirst: true)}'),
                TextField(onChanged: (c) {
                  setState(() {
                    color = colorFromHex(c) ?? Colors.black;
                  });
                })
              ],
            ),
          ),
        ],
      ),
    );
  }
}
