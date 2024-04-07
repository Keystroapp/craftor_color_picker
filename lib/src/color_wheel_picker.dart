import 'package:craftor_color_picker/color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Set the bool flag to true to show debug prints. Even if it is forgotten
// to set it to false, debug prints will not show in release builds.
// The handy part is that if it gets in the way in debugging, it is an easy
// toggle to turn it off there too. Often I just leave them true if it is one
// I want to see in dev mode, unless it is too chatty.
const bool _debug = !kReleaseMode && false;

/// A HSV color wheel based color picker for Flutter, used by FlexColorPicker.
///
/// The color wheel picker uses a custom painter to draw the HSV color wheel
/// and rectangle. It can also be used on its own in other color picker
/// implementations.
@immutable
class ColorWheelPicker extends StatefulWidget {
  /// Default constructor for the color wheel picker.
  const ColorWheelPicker({
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

  /// The starting color value for the wheel color picker.
  final Color color;

  /// Callback that returns the currently selected color in the color wheel as
  /// a [Color].
  ///
  /// The color value is changed continuously as the wheel thumb or the surface
  /// thumb is operated.
  final ValueChanged<Color> onChanged;

  /// Optional [ValueChanged] callback, called when user starts color selection
  /// operation with the current color value.
  final ValueChanged<Color>? onChangeStart;

  /// Optional [ValueChanged] callback, called when user ends color selection
  /// with the new color value.
  final ValueChanged<Color>? onChangeEnd;

  /// Required [ValueChanged] callback, called with true when the wheel is
  /// operated and false otherwise.
  // final ValueChanged<bool> onWheel;

  /// Set to true to draw a border around the color controls.
  ///
  /// Defaults to false.
  final bool hasBorder;

  /// Color of the border around around the circle and rectangle control.
  ///
  /// Defaults to theme of context for the divider color.
  final Color? borderColor;

  /// If the widget color update should also update the wheel, set to true.
  /// This should be set to true by parent every time [color] has been updated
  /// by parent and not internally by operating the wheel.
  ///
  /// Defaults to false.
  final bool shouldUpdate;

  /// Set to true when the ColorWheelPicker should request focus.
  ///
  /// Defaults to false.
  final bool shouldRequestsFocus;

  @override
  State<ColorWheelPicker> createState() => _ColorWheelPickerState();
}

class _ColorWheelPickerState extends State<ColorWheelPicker> {
  // A global key used to find our render object
  final GlobalKey renderBoxKey = GlobalKey();

  // True, when we are dragging on the square color saturation and value box.
  bool get isSquare => true;

  // We store the HSV color components as internal state for the
  // Hue wheel, and Saturation and Value for the square.
  late double colorHue;
  late double colorSaturation;
  late double colorValue;
  late double colorAlpha;

  // Previous widget color value, stored to avoid double call in onEnd.
  late Color previousColor;

  // Used to set focus to the Focus() we wrap around our custom paint.
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
  void didUpdateWidget(ColorWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Request focus to wheel.
    if (widget.shouldRequestsFocus &&
        (widget.shouldRequestsFocus != oldWidget.shouldRequestsFocus)) {
      _focusNode.requestFocus();
    }
    // Only if widget.shouldUpdate is true will we change color. It is set to
    // true by parent when it has updated the widget.color value and it needs
    // to update the custom painted color wheel.
    if (widget.shouldUpdate) {
      // Change color wheel hue value
      if (color.hue != colorHue) {
        colorHue = color.hue;
      }
      // The color saturation is the X-axis on the shade square
      if (color.saturation != colorSaturation) {
        colorSaturation = color.saturation;
      }
      // The color value is the Y-axis on the shade square
      if (color.value != colorValue) {
        colorValue = color.value;
      }
      // Change color alpha value
      if (color.alpha != colorAlpha) {
        colorAlpha = color.alpha;
      }
    }
    if (oldWidget.color != widget.color) {
      previousColor = widget.color;
    }
  }

  // Get the widget color, but convert to HSV color that we need internally
  HSVColor get color => HSVColor.fromColor(widget.color);

  Offset getOffset(Offset ratio) {
    // This is bang and cast is not pretty, but SDK does it this way too.
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;

    final Offset startPosition = renderBox.localToGlobal(Offset.zero);
    return ratio - startPosition;
  }

  // Called when we start dragging any of the thumbs on the wheel or square
  void onStart(Offset offset) {
    // This is bang and cast is not pretty, but SDK does it this was too.
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;

    final Size size = renderBox.size;
    final Offset startPosition = renderBox.localToGlobal(Offset.zero);

    // Calculate the color saturation
    colorSaturation = ((offset.dx - startPosition.dx) / size.width).clamp(0, 1);
    // Calculate the color value
    colorValue =
        (1 - (offset.dy - startPosition.dy) / size.height).clamp(0.0, 1.0);

    // If a start callback was given, call it with the start color.
    widget.onChangeStart?.call(widget.color);
    // Make a HSV color from its component values and convert to RGB and
    // return this color in the callback.
    widget.onChanged(HSVColor.fromAHSV(
      colorAlpha,
      colorHue,
      colorSaturation,
      colorValue,
    ).toColor());
  }

  // Called when we drag the thumb on the wheel or square.
  void onUpdate(Offset offset) {
    // This is bang and cast is not pretty, but SDK does it this was too.
    final RenderBox renderBox =
        renderBoxKey.currentContext!.findRenderObject()! as RenderBox;

    final Size size = renderBox.size;
    final Offset startPosition = renderBox.localToGlobal(Offset.zero);

    // Calculate the color saturation
    colorSaturation = ((offset.dx - startPosition.dx) / size.width).clamp(0, 1);
    // Calculate the color value
    colorValue =
        (1 - (offset.dy - startPosition.dy) / size.height).clamp(0.0, 1.0);
    // Make a HSV color from its component values and convert to RGB and
    // return this color in the callback.
    widget.onChanged(HSVColor.fromAHSV(
      colorAlpha,
      colorHue,
      colorSaturation,
      colorValue,
    ).toColor());
  }

  // Called when we end dragging the thumb on the wheel or square.
  void onEnd() {
    // We stopped operating the wheel, so onWheel is false.
    // We can use this signal to know how to handle the drag cancel event
    // when we were operating the wheel.
    // widget.onWheel(false);
    // isSquare = false;

    // We are ending the dragging operation, call the onChangeEnd callback
    // with the color we ended up with.
    widget.onChangeEnd?.call(widget.color);
    // We have to call onChanged once more with final value as well,
    // but only if it has changed internally since last call, otherwise
    // we have already called it once before with that value.
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
            // If we just tap on the wheel control, we need to end as well.
            // Grabbing just the onTapUp allows to catch a drag that was too short
            // to start a drag event, while not interfering with the onTap event
            // handler we need to use elsewhere in the ColorPicker.
            onTapUp: (TapUpDetails details) => onEnd(),

            // NOTE: It would have been simpler to be able to call onEnd() on events
            // onVerticalDragCancel and onHorizontalDragCancel here as well.
            // However, they get triggered when the longPress menu is activated,
            // if we were 'dragging' but had not moved, in that case we need to
            // issue an `onColorChangeEnd` when a cancellation happens due to that.
            // Mostly it worked, but not entirely, for some reason the drag cancel
            // events get triggered while dragging, for no apparent reason, since
            // there has been no known cancellation, weird, might be a Flutter bug?!
            //
            // Due to this, the cancel events could not be used here, since they led
            // to random onEnd() calls which made the onEnd unreliable. The workaround
            // was to make the long press menu issue an "onOpen" event and handle the
            // issuing of that particular end dragging scenario in the parent
            // (color picker). Messy, but the workaround works.

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

  final double colorHue; // Color wheel coordinate 0...360 degrees
  final double colorSaturation; // The X coordinate 0...1
  final double colorValue; // The Y coordinate 0...1

  final bool hasBorder;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the color shade palette.
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

    // Draw a border around the outer edge of the square shade picker.
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

  final double colorSaturation; // The X coordinate 0...1
  final double colorValue; // The Y coordinate 0...1

  @override
  void paint(Canvas canvas, Size size) {
    // Define paint style for the selection thumbs:
    // Outer black circle.
    final Paint paintBlack = Paint()
      ..color = Colors.black
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    // Inner white circle, to be placed on top of the black one.
    final Paint paintWhite = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Define the selection thumb position on the square
    final double paletteX = size.width * colorSaturation;
    final double paletteY = size.height * (1 - colorValue);
    final Offset paletteVector = Offset(paletteX, paletteY);

    // Draw the wider black circle first, then draw the smaller white circle
    // on top of it, giving the appearance of a white indicator with black
    // edges around it.
    canvas.drawCircle(paletteVector, 12, paintBlack);
    canvas.drawCircle(paletteVector, 12, paintWhite);
  }

  @override
  bool shouldRepaint(_ShadeThumbPainter oldDelegate) {
    return oldDelegate.colorSaturation != colorSaturation ||
        oldDelegate.colorValue != colorValue;
  }
}
