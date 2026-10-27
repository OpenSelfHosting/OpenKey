import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// SpatialFlow-style setup chrome: progress, step label, morphing FAB.
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.currentPage,
    required this.pageCount,
    required this.onNext,
    required this.onBack,
    required this.onFinish,
    this.isNextEnabled = true,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final bool isNextEnabled;

  bool get _isLast => currentPage >= pageCount - 1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = context.s;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
    );
    final progress = (currentPage + 1) / pageCount;
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 500);

    return Material(
      color: scheme.surfaceContainer,
      elevation: 8,
      shadowColor: scheme.shadow.withValues(alpha: 0.18),
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: duration,
              curve: Curves.fastOutSlowIn,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 3,
                  color: scheme.primary,
                  backgroundColor: scheme.surfaceContainerHighest,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: AnimatedSwitcher(
                        duration: reduceMotion
                            ? Duration.zero
                            : const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: Offset(0, currentPage > 0 ? 0.35 : -0.35),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: currentPage == 0
                            ? Align(
                                key: const ValueKey('lets-go'),
                                alignment: AlignmentDirectional.centerStart,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 12,
                                  ),
                                  child: Text(
                                    s.onboardingLetsGo,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: scheme.primary,
                                        ),
                                  ),
                                ),
                              )
                            : Row(
                                key: ValueKey('step-$currentPage'),
                                children: [
                                  IconButton(
                                    onPressed: onBack,
                                    tooltip: MaterialLocalizations.of(
                                      context,
                                    ).backButtonTooltip,
                                    icon: const Icon(Icons.arrow_back_rounded),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      s.onboardingStepOf(
                                        currentPage,
                                        pageCount - 1,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    child: _isLast
                        ? MEFab.extended(
                            key: const ValueKey('finish'),
                            variant: MEFabVariant.primary,
                            size: MEFabSize.small,
                            onPressed: onFinish,
                            icon: const Icon(Icons.check_rounded),
                            label: Text(s.onboardingCreateVault),
                          )
                        : _MorphingNextFab(
                            key: const ValueKey('next'),
                            page: currentPage,
                            enabled: isNextEnabled,
                            onPressed: onNext,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MorphingNextFab extends StatelessWidget {
  const _MorphingNextFab({
    super.key,
    required this.page,
    required this.enabled,
    required this.onPressed,
  });

  final int page;
  final bool enabled;
  final VoidCallback onPressed;

  static const _size = 56.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final morphDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 600);
    final rotateDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 900);

    final corners = switch (page % 3) {
      0 => (50.0, 50.0, 50.0, 50.0),
      1 => (26.0, 26.0, 26.0, 26.0),
      _ => (18.0, 50.0, 18.0, 50.0),
    };

    return TweenAnimationBuilder<double>(
      tween: Tween(end: page * 360.0),
      duration: rotateDuration,
      curve: Curves.fastOutSlowIn,
      builder: (context, degrees, child) {
        return Transform.rotate(
          angle: degrees * (3.1415926535 / 180),
          child: child,
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.4,
        child: TweenAnimationBuilder<(double, double, double, double)>(
          tween: _CornerTween(corners),
          duration: morphDuration,
          curve: Curves.fastOutSlowIn,
          builder: (context, value, _) {
            final radius = BorderRadius.only(
              topLeft: Radius.circular(_size * value.$1 / 100),
              topRight: Radius.circular(_size * value.$2 / 100),
              bottomLeft: Radius.circular(_size * value.$3 / 100),
              bottomRight: Radius.circular(_size * value.$4 / 100),
            );
            return Material(
              color: scheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                child: SizedBox(
                  width: _size,
                  height: _size,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: page * 360.0),
                    duration: rotateDuration,
                    curve: Curves.fastOutSlowIn,
                    builder: (context, degrees, child) {
                      return Transform.rotate(
                        angle: -degrees * (3.1415926535 / 180),
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CornerTween extends Tween<(double, double, double, double)> {
  _CornerTween((double, double, double, double) end) : super(end: end);

  @override
  (double, double, double, double) lerp(double t) {
    final a = begin ?? end!;
    final b = end!;
    return (
      a.$1 + (b.$1 - a.$1) * t,
      a.$2 + (b.$2 - a.$2) * t,
      a.$3 + (b.$3 - a.$3) * t,
      a.$4 + (b.$4 - a.$4) * t,
    );
  }
}
