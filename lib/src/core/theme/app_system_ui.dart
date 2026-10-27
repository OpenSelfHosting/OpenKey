import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expressive_ui_kit/expressive_ui_kit.dart';

/// System chrome (status + navigation bars) aligned with [ColorScheme].
abstract final class AppSystemUi {
  static SystemUiOverlayStyle overlayFor(
    ColorScheme scheme, {
    Color? navigationBarColor,
    Color? statusBarColor,
  }) {
    return MESystemUi.overlayFor(
      scheme,
      navigationBarColor: navigationBarColor,
      statusBarColor: statusBarColor,
    );
  }
}

/// Applies [AppSystemUi.overlayFor] to the subtree (status + nav bars on Android).
class AppSystemUiScope extends StatelessWidget {
  const AppSystemUiScope({
    super.key,
    required this.child,
    this.navigationBarColor,
    this.statusBarColor,
  });

  final Widget child;
  final Color? navigationBarColor;
  final Color? statusBarColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.overlayFor(
        scheme,
        navigationBarColor: navigationBarColor,
        statusBarColor: statusBarColor,
      ),
      child: child,
    );
  }
}
