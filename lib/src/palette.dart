/// The components of HSV Color Picker
///
/// Try to create a Color Picker with other layout on your own :)
library;

import 'package:flutter/material.dart';

/// Track types for slider picker.
enum TrackType {
  hue,
  alpha,
}

class _SliderLayout extends MultiChildLayoutDelegate {
  static const String track = 'track';
  static const String thumb = 'thumb';
  static const String gestureContainer = 'gesturecontainer';

  @override
  void performLayout(Size size) {
    layoutChild(
      track,
      BoxConstraints.tightFor(
        width: size.width - 30.0,
        height: size.height / 5,
      ),
    );
    positionChild(track, Offset(15.0, size.height * 0.4));
    layoutChild(
      thumb,
      BoxConstraints.tightFor(width: 5.0, height: size.height / 4),
    );
    positionChild(thumb, Offset(0.0, size.height * 0.4));
    layoutChild(
      gestureContainer,
      BoxConstraints.tightFor(width: size.width, height: size.height),
    );
    positionChild(gestureContainer, Offset.zero);
  }

  @override
  bool shouldRelayout(_SliderLayout oldDelegate) => false;
}

/// Painter for all kinds of track types.
class TrackPainter extends CustomPainter {
  const TrackPainter(this.trackType, this.hsvColor);

  final TrackType trackType;
  final HSVColor hsvColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    if (trackType == TrackType.alpha) {
      final Size chessSize = Size(size.height / 2, size.height / 2);
      Paint chessPaintB = Paint()..color = const Color(0xffcccccc);
      Paint chessPaintW = Paint()..color = Colors.white;
      List.generate((size.height / chessSize.height).round(), (int y) {
        List.generate((size.width / chessSize.width).round(), (int x) {
          canvas.drawRect(
            Offset(chessSize.width * x, chessSize.width * y) & chessSize,
            (x + y) % 2 != 0 ? chessPaintW : chessPaintB,
          );
        });
      });
    }

    switch (trackType) {
      case TrackType.hue:
        final List<Color> colors = [
          const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 60.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 120.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 180.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 240.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 300.0, 1.0, 1.0).toColor(),
          const HSVColor.fromAHSV(1.0, 360.0, 1.0, 1.0).toColor(),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;

      case TrackType.alpha:
        final List<Color> colors = [
          hsvColor.toColor().withOpacity(0.0),
          hsvColor.toColor().withOpacity(1.0),
        ];
        Gradient gradient = LinearGradient(colors: colors);
        canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Painter for thumb of slider.
class ThumbPainter extends CustomPainter {
  const ThumbPainter({this.thumbColor, this.fullThumbColor = false});

  final Color? thumbColor;
  final bool fullThumbColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
      Path()
        ..addOval(
          Rect.fromCircle(
            center: const Offset(0.5, 2.0),
            radius: size.width * 1.1,
          ),
        ),
      Colors.grey,
      5.0,
      true,
    );
    // canvas.drawCircle(
    //   Offset(0.0, size.height * 0.4),
    //   size.height,
    //   Paint()
    //     ..strokeWidth = 3
    //     ..color = Colors.white
    //     ..style = PaintingStyle.stroke,
    // );

    if (thumbColor != null) {
      canvas.drawCircle(
        Offset(0.0, size.height * 0.4),
        size.height * 1.0,
        Paint()
          ..color = thumbColor!
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Painter for chess type alpha background in color indicator widget.
class IndicatorPainter extends CustomPainter {
  const IndicatorPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Size chessSize = Size(size.width / 10, size.height / 10);
    final Paint chessPaintB = Paint()..color = const Color(0xFFCCCCCC);
    final Paint chessPaintW = Paint()..color = Colors.white;
    List.generate((size.height / chessSize.height).round(), (int y) {
      List.generate((size.width / chessSize.width).round(), (int x) {
        canvas.drawRect(
          Offset(chessSize.width * x, chessSize.height * y) & chessSize,
          (x + y) % 2 != 0 ? chessPaintW : chessPaintB,
        );
      });
    });

    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.height / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// Painter for chess type alpha background in slider track widget.
class CheckerPainter extends CustomPainter {
  const CheckerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Size chessSize = Size(size.height / 6, size.height / 6);
    Paint chessPaintB = Paint()..color = const Color(0xffcccccc);
    Paint chessPaintW = Paint()..color = Colors.white;
    List.generate((size.height / chessSize.height).round(), (int y) {
      List.generate((size.width / chessSize.width).round(), (int x) {
        canvas.drawRect(
          Offset(chessSize.width * x, chessSize.width * y) & chessSize,
          (x + y) % 2 != 0 ? chessPaintW : chessPaintB,
        );
      });
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 9 track types for slider picker widget.
class ColorPickerSlider extends StatelessWidget {
  const ColorPickerSlider(
    this.trackType,
    this.hsvColor,
    this.onColorChanged, {
    super.key,
    required this.size,
    this.fullThumbColor = false,
  });

  final TrackType trackType;
  final HSVColor hsvColor;
  final Size size;
  final ValueChanged<HSVColor> onColorChanged;
  final bool fullThumbColor;

  void slideEvent(Offset pos) {
    double localDx = pos.dx - 15.0;
    double width = size.width;
    // double height = size.height;
    double progress = localDx.clamp(0.0, width - 30.0) / (width - 30.0);
    switch (trackType) {
      case TrackType.hue:
        // 360 is the same as zero
        // if set to 360, sliding to end goes to zero
        onColorChanged(hsvColor.withHue(progress * 359));
        break;

      case TrackType.alpha:
        onColorChanged(hsvColor
            .withAlpha(localDx.clamp(0.0, width - 30.0) / (width - 30.0)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double thumbOffset = 15.0;

    switch (trackType) {
      case TrackType.hue:
        thumbOffset += (size.width - 30.0) * hsvColor.hue / 360;
        break;
      case TrackType.alpha:
        thumbOffset += (size.width - 30.0) * hsvColor.toColor().opacity;
        break;
    }
    return GestureDetector(
      onTapDown: (details) => slideEvent(details.localPosition),
      onPanStart: (details) {
        slideEvent(details.localPosition);
      },
      onPanUpdate: (details) => slideEvent(details.localPosition),
      child: Container(
        color: Colors.transparent,
        width: size.width,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(50.0)),
                child: CustomPaint(
                  size: Size(size.width, 10),
                  painter: TrackPainter(
                    trackType,
                    hsvColor,
                  ),
                ),
              ),
            ),
            Positioned(
              left: thumbOffset,
              top: 2,
              child: CustomPaint(
                size: const Size(8, 8),
                painter: ThumbPainter(
                  thumbColor: Colors.white,
                  fullThumbColor: fullThumbColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorPickerArea extends StatelessWidget {
  const ColorPickerArea(
    this.hsvColor,
    this.size,
    this.onColorChanged, {
    super.key,
  });

  final HSVColor hsvColor;
  final Size size;
  final ValueChanged<HSVColor> onColorChanged;

  void _handleColorRectChange(double horizontal, double vertical) {
    onColorChanged(hsvColor.withSaturation(horizontal).withValue(vertical));
  }

  void _handleGesture(Offset position) {
    final width = size.width;
    final height = size.height;
    double horizontal = position.dx.clamp(0.0, width);
    double vertical = position.dy.clamp(0.0, height);

    _handleColorRectChange(horizontal / width, 1 - (vertical / height));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _handleGesture(details.localPosition);
      },
      onPanUpdate: (details) {
        _handleGesture(details.localPosition);
      },
      child: CustomPaint(
        size: size,
        painter: ColorAreaPainter(hsvColor),
      ),
    );
  }
}

// Painter for SV mixture.
class ColorAreaPainter extends CustomPainter {
  const ColorAreaPainter(this.hsvColor, {this.pointerColor});

  final HSVColor hsvColor;
  final Color? pointerColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const Gradient gradientV = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.black],
    );
    final Gradient gradientH = LinearGradient(
      colors: [
        Colors.white,
        HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor(),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradientV.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.multiply
        ..shader = gradientH.createShader(rect),
    );

// paint the ring
    canvas.drawCircle(
      Offset(
        size.width * hsvColor.saturation,
        size.height * (1 - hsvColor.value),
      ),
      size.height * 0.04,
      Paint()
        ..color = pointerColor ?? (Colors.white)
        ..strokeWidth = 3
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ColorAreaPainter oldDelegate) => true;
}
