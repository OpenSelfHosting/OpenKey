import 'dart:ui';

import 'package:flutter/material.dart';

import 'floating_animation/floating_config.dart';
import 'floating_animation/floating_controller.dart';
import 'floating_animation/glare_effect_widget.dart';
import 'models/glassmorphism_config.dart';
import 'utils/constants.dart';
import 'utils/extensions.dart';

class CardBackground extends StatelessWidget {
  const CardBackground({
    required this.backgroundGradientColor,
    required this.child,
    required this.padding,
    this.backgroundImage,
    this.backgroundNetworkImage,
    this.width,
    this.height,
    this.glassmorphismConfig,
    this.border,
    this.floatingController,
    this.glarePosition,
    this.shadowConfig,
    super.key,
  }) : assert(
          backgroundImage == null || backgroundNetworkImage == null,
          'You can\'t use network image & asset image at same time as card'
          ' background',
        );

  final String? backgroundImage;
  final String? backgroundNetworkImage;
  final Widget child;
  final Gradient backgroundGradientColor;
  final Glassmorphism? glassmorphismConfig;
  final double? width;
  final double? height;
  final double padding;
  final BoxBorder? border;
  final FloatingController? floatingController;
  final double? glarePosition;
  final FloatingShadowConfig? shadowConfig;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQueryData = MediaQuery.of(context);
    final Orientation orientation = mediaQueryData.orientation;
    final Size screenSize = mediaQueryData.size;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenWidth = constraints.maxWidth.isInfinite
            ? screenSize.width
            : constraints.maxWidth;
        final double implicitHeight = orientation.isPortrait
            ? ((width ?? screenWidth) - (padding * 2)) *
                AppConstants.creditCardAspectRatio
            : screenSize.height / 2;
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(padding),
              width: width ?? screenWidth,
              height: height ?? implicitHeight,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: AppConstants.creditCardBorderRadius,
                boxShadow: shadowConfig != null && floatingController != null
                    ? <BoxShadow>[
                        BoxShadow(
                          blurRadius: shadowConfig!.blurRadius,
                          color: shadowConfig!.color,
                          offset: shadowConfig!.offset +
                              Offset(
                                floatingController!.y * 100,
                                -floatingController!.x * 100,
                              ),
                        ),
                      ]
                    : null,
                border: border,
                gradient:
                    glassmorphismConfig?.gradient ?? backgroundGradientColor,
                image: backgroundImage?.isNotEmpty ?? false
                    ? DecorationImage(
                        image: ExactAssetImage(backgroundImage!),
                        fit: BoxFit.fill,
                      )
                    : backgroundNetworkImage?.isNotEmpty ?? false
                        ? DecorationImage(
                            image: NetworkImage(backgroundNetworkImage!),
                            fit: BoxFit.fill,
                          )
                        : null,
              ),
              child: GlareEffectWidget(
                border: border,
                glarePosition: glarePosition,
                child: glassmorphismConfig == null
                    ? child
                    : BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: glassmorphismConfig!.blurX,
                          sigmaY: glassmorphismConfig!.blurY,
                        ),
                        child: child,
                      ),
              ),
            ),
            if (glassmorphismConfig != null)
              Padding(
                padding: EdgeInsets.all(padding),
                child: _GlassmorphicBorder(
                  width: width ?? screenWidth,
                  height: height ?? implicitHeight,
                  colors: glassmorphismConfig!.borderColors,
                  stops: glassmorphismConfig!.borderStops,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GlassmorphicBorder extends StatelessWidget {
  _GlassmorphicBorder({
    required this.height,
    required this.width,
    this.colors,
    this.stops,
  }) : _painter = _GradientPainter(
          strokeWidth: 1.4,
          radius: 10,
          colors: colors,
          stops: stops,
        );

  final _GradientPainter _painter;
  final double width;
  final double height;
  final List<Color>? colors;
  final List<double>? stops;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _painter,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: AppConstants.creditCardBorderRadius,
        ),
        width: width,
        height: height,
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  _GradientPainter({
    required this.strokeWidth,
    required this.radius,
    this.colors,
    this.stops,
  });

  final double radius;
  final double strokeWidth;
  final List<Color>? colors;
  final List<double>? stops;

  @override
  void paint(Canvas canvas, Size size) {
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors ??
          <Color>[
            Colors.white.withValues(alpha: 0.70),
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.10),
          ],
      stops: stops ?? const <double>[0.0, 0.55, 1.0],
    );
    final RRect innerRect2 = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        strokeWidth,
        strokeWidth,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius - strokeWidth),
    );

    final RRect outerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final Paint paintObject = Paint()
      ..shader = gradient.createShader(Offset.zero & size);

    final Path outerRectPath = Path()..addRRect(outerRect);
    final Path innerRectPath2 = Path()..addRRect(innerRect2);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        outerRectPath,
        Path.combine(
          PathOperation.intersect,
          outerRectPath,
          innerRectPath2,
        ),
      ),
      paintObject,
    );
  }

  @override
  bool shouldRepaint(covariant _GradientPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius ||
        oldDelegate.colors != colors ||
        oldDelegate.stops != stops;
  }
}
