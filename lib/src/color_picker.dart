import 'package:flutter/material.dart';

import 'palette.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    Key? key,
    required this.pickerColor,
    required this.pickerAreaSize,
    required this.onColorChanged,
  }) : super(key: key);

  final Color pickerColor;
  final Size pickerAreaSize;
  final ValueChanged<Color> onColorChanged;

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  HSVColor currentHsvColor = const HSVColor.fromAHSV(0.0, 0.0, 0.0, 0.0);

  @override
  void initState() {
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    super.initState();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType,
      currentHsvColor,
      (HSVColor color) {
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor());
      },
    );
  }

  void onColorChanging(HSVColor color) {
    setState(() => currentHsvColor = color);
    widget.onColorChanged(currentHsvColor.toColor());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox.fromSize(
          size: widget.pickerAreaSize,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColorPickerArea(
                currentHsvColor,
                widget.pickerAreaSize,
                onColorChanging,
              ),
            ),
          ),
        ),
        SizedBox(
          width: widget.pickerAreaSize.width,
          child: Column(
            children: <Widget>[
              SizedBox(height: 40.0, child: colorPickerSlider(TrackType.hue)),
              SizedBox(
                height: 40.0,
                child: colorPickerSlider(TrackType.alpha),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
