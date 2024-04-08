import 'package:craftor_color_picker/color_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

@immutable
class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.hasBorder = false,
    this.borderColor,
    this.shouldUpdate = false,
    this.shouldRequestsFocus = false,
  });

  final Color color;

  final ValueChanged<Color> onChanged;

  final ValueChanged<Color>? onChangeStart;

  final ValueChanged<Color>? onChangeEnd;

  final bool hasBorder;

  final Color? borderColor;

  final bool shouldUpdate;

  final bool shouldRequestsFocus;

  @override
  State<ColorPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorPicker> {
  final GlobalKey renderBoxKey = GlobalKey();

  bool get isSquare => true;

  late double colorHue;
  late double colorSaturation;
  late double colorValue;
  late double colorAlpha;

  late Color previousColor;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    colorHue = color.hue;
    previousColor = widget.color;
    colorSaturation = color.saturation;
    colorValue = color.value;
    colorAlpha = color.alpha;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldRequestsFocus &&
        (widget.shouldRequestsFocus != oldWidget.shouldRequestsFocus)) {
      _focusNode.requestFocus();
    }

    if (widget.shouldUpdate) {
      if (color.hue != colorHue) {
        colorHue = color.hue;
      }

      if (color.saturation != colorSaturation) {
        colorSaturation = color.saturation;
      }

      if (color.value != colorValue) {
        colorValue = color.value;
      }

      if (color.alpha != colorAlpha) {
        colorAlpha = color.alpha;
      }
    }
    if (oldWidget.color != widget.color) {
      previousColor = widget.color;
    }
  }

  HSVColor get color => HSVColor.fromColor(widget.color);

  Offset getOffset(Offset ratio) {
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;

    final Offset startPosition = renderBox.localToGlobal(Offset.zero);
    return ratio - startPosition;
  }

  void onStart(Offset offset) {
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;

    final Size size = renderBox.size;
    final Offset startPosition = renderBox.localToGlobal(Offset.zero);

    colorSaturation = ((offset.dx - startPosition.dx) / size.width).clamp(0, 1);

    colorValue =
        (1 - (offset.dy - startPosition.dy) / size.height).clamp(0.0, 1.0);

    widget.onChangeStart?.call(widget.color);

    widget.onChanged(HSVColor.fromAHSV(
      colorAlpha,
      colorHue,
      colorSaturation,
      colorValue,
    ).toColor());
  }

  void onUpdate(Offset offset) {
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;

    final Size size = renderBox.size;
    final Offset startPosition = renderBox.localToGlobal(Offset.zero);

    colorSaturation = ((offset.dx - startPosition.dx) / size.width).clamp(0, 1);

    colorValue =
        (1 - (offset.dy - startPosition.dy) / size.height).clamp(0.0, 1.0);

    widget.onChanged(HSVColor.fromAHSV(
      colorAlpha,
      colorHue,
      colorSaturation,
      colorValue,
    ).toColor());
  }

  void onEnd() {
    widget.onChangeEnd?.call(widget.color);

    if (widget.color != previousColor) widget.onChanged(widget.color);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          GestureDetector(
            dragStartBehavior: DragStartBehavior.down,
            onVerticalDragDown: (DragDownDetails details) =>
                onStart(details.globalPosition),
            onVerticalDragUpdate: (DragUpdateDetails details) =>
                onUpdate(details.globalPosition),
            onHorizontalDragUpdate: (DragUpdateDetails details) =>
                onUpdate(details.globalPosition),
            onVerticalDragEnd: (DragEndDetails details) => onEnd(),
            onHorizontalDragEnd: (DragEndDetails details) => onEnd(),
            onTapUp: (TapUpDetails details) => onEnd(),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight - 20 - 20 - 10 - 10,
              key: renderBoxKey,
              child: Focus(
                focusNode: _focusNode,
                child: MouseRegion(
                  cursor: MaterialStateMouseCursor.clickable,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: _ShadePainter(
                            colorHue: colorHue,
                            colorSaturation: colorSaturation,
                            colorValue: colorValue,
                            hasBorder: widget.hasBorder,
                            borderColor: widget.borderColor ??
                                Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      CustomPaint(
                        painter: _ShadeThumbPainter(
                          colorSaturation: colorSaturation,
                          colorValue: colorValue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ColorPickerSlider(
            trackType: TrackType.hue,
            hsvColor: HSVColor.fromAHSV(
              colorAlpha,
              colorHue,
              colorSaturation,
              colorValue,
            ),
            onColorChanged: (HSVColor color) {
              setState(() {
                colorHue = color.hue;
              });
              widget.onChanged(color.toColor());
            },
            size: Size(constraints.maxWidth, 10),
          ),
          const SizedBox(height: 20),
          ColorPickerSlider(
            trackType: TrackType.alpha,
            hsvColor: HSVColor.fromAHSV(
              colorAlpha,
              colorHue,
              colorSaturation,
              colorValue,
            ),
            onColorChanged: (HSVColor color) {
              setState(() {
                colorAlpha = color.alpha;
              });
              widget.onChanged(color.toColor());
            },
            size: Size(constraints.maxWidth, 10),
          ),
        ],
      );
    });
  }
}

class _ShadePainter extends CustomPainter {
  const _ShadePainter({
    required this.colorHue,
    required this.colorSaturation,
    required this.colorValue,
    this.hasBorder = false,
    required this.borderColor,
  }) : super();

  final double colorHue;
  final double colorSaturation;
  final double colorValue;

  final bool hasBorder;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rectBox = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rRect = RRect.fromRectAndRadius(rectBox, Radius.zero);

    final Shader horizontal = LinearGradient(
      colors: <Color>[
        Colors.white,
        HSVColor.fromAHSV(1, colorHue, 1, 1).toColor()
      ],
    ).createShader(rectBox);
    canvas.drawRRect(
        rRect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = horizontal);

    final Shader vertical = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[Colors.transparent, Colors.black],
    ).createShader(rectBox);
    canvas.drawRRect(
        rRect,
        Paint()
          ..style = PaintingStyle.fill
          ..shader = vertical);

    if (hasBorder) {
      canvas.drawRRect(
          rRect,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = borderColor);
    }
  }

  @override
  bool shouldRepaint(_ShadePainter oldDelegate) {
    return oldDelegate.hasBorder != hasBorder ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.colorHue != colorHue ||
        oldDelegate.colorSaturation != colorSaturation ||
        oldDelegate.colorValue != colorValue;
  }
}

class _ShadeThumbPainter extends CustomPainter {
  const _ShadeThumbPainter({
    required this.colorSaturation,
    required this.colorValue,
  }) : super();

  final double colorSaturation;
  final double colorValue;

  @override
  void paint(Canvas canvas, Size size) {
    final double paletteX = size.width * colorSaturation;
    final double paletteY = size.height * (1 - colorValue);
    final Offset paletteVector = Offset(paletteX, paletteY);

    canvas.drawCircle(
      paletteVector,
      8,
      Paint()
        ..strokeWidth = 3
        ..color = Colors.black12
        ..style = PaintingStyle.stroke,
    );

    canvas.drawCircle(
      paletteVector,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ShadeThumbPainter oldDelegate) {
    return oldDelegate.colorSaturation != colorSaturation ||
        oldDelegate.colorValue != colorValue;
  }
}
