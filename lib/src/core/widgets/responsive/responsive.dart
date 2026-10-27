import 'package:flutter/material.dart';

/// Shared breakpoints matching Invito / Material adaptive layout.
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet;

  static bool isMobileOf(BuildContext context) =>
      isMobile(MediaQuery.sizeOf(context).width);

  static bool isTabletOf(BuildContext context) =>
      isTablet(MediaQuery.sizeOf(context).width);

  static bool isDesktopOf(BuildContext context) =>
      isDesktop(MediaQuery.sizeOf(context).width);
}

/// Caps [child] width on large screens (forms, auth, sheets).
///
/// Defaults to centering; pass [alignment] (e.g. [AlignmentDirectional.topStart])
/// to pin content to a side instead.
///
/// Use [expandHeight] for scaffold bodies with a scroll view so the child
/// receives a bounded height. Leave it false for bars/buttons so they
/// shrink-wrap and do not stretch to the screen height.
class AdaptiveContentWidth extends StatelessWidget {
  const AdaptiveContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.padding,
    this.expandHeight = false,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  /// When true, fills parent height (scaffold body). When false, shrink-wraps.
  final bool expandHeight;

  /// Where the constrained child sits in the available width.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final content = padding == null
        ? child
        : Padding(padding: padding!, child: child);

    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: content,
    );

    if (expandHeight) {
      return SizedBox.expand(
        child: Align(
          alignment: alignment,
          child: constrained,
        ),
      );
    }

    return Align(
      alignment: alignment,
      heightFactor: 1,
      child: constrained,
    );
  }
}
