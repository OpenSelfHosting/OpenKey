import 'package:flutter/material.dart';

class Glassmorphism {
  /// A config class for glassmorphism effect.
  Glassmorphism({
    required this.blurX,
    required this.blurY,
    required this.gradient,
    this.borderColors,
    this.borderStops,
  });

  /// Default config for glassmorphism effect.
  factory Glassmorphism.defaultConfig() {
    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        Colors.white.withValues(alpha: 0.14),
        Colors.white.withValues(alpha: 0.05),
      ],
      stops: const <double>[0.0, 1.0],
    );
    return Glassmorphism(
      blurX: 10.0,
      blurY: 18.0,
      gradient: gradient,
      borderColors: <Color>[
        Colors.white.withValues(alpha: 0.45),
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.08),
      ],
    );
  }

  /// The sigmaX value for glassmorphism effect.
  final double blurX;

  /// The sigmaY value for glassmorphism effect.
  final double blurY;

  /// Gradient for the glassmorphism effect.
  final Gradient gradient;

  /// Specular edge colors (top-left highlight → bottom-right rim).
  ///
  /// When null, a subtle white rim is used.
  final List<Color>? borderColors;

  /// Stops for [borderColors]. Ignored when [borderColors] is null.
  final List<double>? borderStops;
}
