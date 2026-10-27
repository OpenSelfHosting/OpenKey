import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Page-relative offset used for SpatialFlow-style parallax.
///
/// `0` is the settled page. Negative while arriving from the right,
/// positive while leaving to the left (flipped in RTL).
typedef OnboardingOffset = double Function();

/// Immersive canvas + bottom copy, matching SpatialFlow's onboarding layout.
class ImmersiveOnboardingLayout extends StatelessWidget {
  const ImmersiveOnboardingLayout({
    super.key,
    required this.pageOffset,
    required this.hero,
    required this.child,
    this.imageScale = 1,
  });

  final OnboardingOffset pageOffset;
  final Widget hero;
  final Widget child;
  final double imageScale;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final short = size.height < 720;
    final horizontal = width < 360 ? 20.0 : (width > 480 ? 32.0 : 28.0);
    final vertical = short
        ? 12.0
        : (width < 360 ? 16.0 : (width > 480 ? 24.0 : 20.0));
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: short ? 16 : 32,
            ),
            child: Builder(
              builder: (context) {
                final offset = reduceMotion ? 0.0 : pageOffset();
                final direction = rtl ? -1.0 : 1.0;
                return Transform.translate(
                  offset: Offset(offset * 15 * direction, 0),
                  child: Transform.rotate(
                    angle: offset * 0.035 * direction,
                    child: Transform.scale(
                      scale: (imageScale + offset.abs() * 0.08).clamp(0.7, 1.3),
                      child: Center(child: hero),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, vertical),
          child: child,
        ),
      ],
    );
  }
}

/// Fades and slides copy with the pager offset.
class OnboardingParallax extends StatelessWidget {
  const OnboardingParallax({
    super.key,
    required this.pageOffset,
    required this.child,
    this.translationY = 30,
  });

  final OnboardingOffset pageOffset;
  final Widget child;
  final double translationY;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final offset = pageOffset();
    return Opacity(
      opacity: (1 - offset.abs() * 1.5).clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, offset * translationY),
        child: child,
      ),
    );
  }
}

/// Cropped morphing mark used on every onboarding step.
class OnboardingHeroIcon extends StatelessWidget {
  const OnboardingHeroIcon({super.key, required this.icon});

  static const double viewportSize = 240;
  static const double morphSize = 550;
  static const double glyphSize = 90;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final iconWidget = Icon(
      icon,
      size: glyphSize,
      color: scheme.onPrimaryContainer,
    );

    if (reduceMotion) {
      return SizedBox(
        width: viewportSize,
        height: viewportSize,
        child: Center(
          child: ExpressiveIconContainer(
            size: viewportSize,
            backgroundColor: scheme.primaryContainer,
            shape: ExpressiveShape.cookie9Sided,
            child: iconWidget,
          ),
        ),
      );
    }

    return SizedBox(
      width: viewportSize,
      height: viewportSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          MEMorphingShape(
            size: morphSize,
            color: scheme.primaryContainer,
            child: iconWidget,
          ),
        ],
      ),
    );
  }
}

/// Display title used on every onboarding step.
class OnboardingHeadline extends StatelessWidget {
  const OnboardingHeadline(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    return Text(
      text,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: width < 360 ? 34 : 42,
        height: 1.14,
        letterSpacing: -0.5,
        color: color ?? scheme.onSurface,
      ),
    );
  }
}

/// Supporting copy under a headline.
class OnboardingLead extends StatelessWidget {
  const OnboardingLead(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        height: 1.55,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
