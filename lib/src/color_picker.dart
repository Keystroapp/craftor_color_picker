import 'package:flutter/material.dart';

import 'palette.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.pickerAreaSize,
    required this.onColorChanged,
  });

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
    if (oldWidget.pickerColor != widget.pickerColor) {
      currentHsvColor = HSVColor.fromColor(widget.pickerColor);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget colorPickerSlider(TrackType trackType) {
    return ColorPickerSlider(
      trackType: trackType,
      hsvColor: currentHsvColor,
      onColorChanged: (HSVColor color) {
        setState(() => currentHsvColor = color);
        widget.onColorChanged(currentHsvColor.toColor());
      },
      size: widget.pickerAreaSize,
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
              borderRadius: BorderRadius.circular(0),
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
              const SizedBox(height: 20),
              colorPickerSlider(TrackType.hue),
              const SizedBox(height: 20),
              colorPickerSlider(TrackType.alpha),
            ],
          ),
        ),
      ],
    );
  }
}
