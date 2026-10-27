import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({super.key, required this.pageOffset});

  final OnboardingOffset pageOffset;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ImmersiveOnboardingLayout(
      pageOffset: pageOffset,
      hero: const OnboardingHeroIcon(icon: Icons.password_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: 30,
            child: OnboardingHeadline(s.onboardingWelcomeHeadline),
          ),
          const SizedBox(height: 16),
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: 50,
            child: OnboardingLead(s.onboardingWelcomeLead),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class OnboardingVaultStep extends StatelessWidget {
  const OnboardingVaultStep({super.key, required this.pageOffset});

  final OnboardingOffset pageOffset;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ImmersiveOnboardingLayout(
      pageOffset: pageOffset,
      hero: const OnboardingHeroIcon(icon: Icons.lock_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: -30,
            child: OnboardingHeadline(
              s.onboardingEcosystemTitle,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: -60,
            child: OnboardingLead(s.onboardingEcosystemSubtitle),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class OnboardingFeaturesStep extends StatelessWidget {
  const OnboardingFeaturesStep({super.key, required this.pageOffset});

  final OnboardingOffset pageOffset;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final phrases = [
      (s.onboardingFeaturePasswords, scheme.secondary),
      (s.onboardingFeatureAutofill, scheme.tertiary),
      (s.onboardingFeatureSelfHost, scheme.onSurface),
    ];

    return ImmersiveOnboardingLayout(
      pageOffset: pageOffset,
      hero: const OnboardingHeroIcon(icon: Icons.auto_awesome_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < phrases.length; i++)
            OnboardingParallax(
              pageOffset: pageOffset,
              translationY: 20.0 + (i * 20),
              child: Text(
                phrases[i].$1,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  height: 1.25,
                  color: phrases[i].$2,
                ),
              ),
            ),
          const SizedBox(height: 24),
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: 80,
            child: OnboardingLead(s.onboardingAllInOneSubtitle),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class OnboardingThemeStep extends StatelessWidget {
  const OnboardingThemeStep({super.key, required this.pageOffset});

  final OnboardingOffset pageOffset;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final modes = ThemeMode.values;

    return ImmersiveOnboardingLayout(
      pageOffset: pageOffset,
      hero: const OnboardingHeroIcon(icon: Icons.palette_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: -30,
            child: OnboardingHeadline(s.onboardingStyleTitle),
          ),
          const SizedBox(height: 32),
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (p, c) => p.themeMode != c.themeMode,
            builder: (context, state) {
              return Column(
                children: [
                  for (var i = 0; i < modes.length; i++)
                    OnboardingParallax(
                      pageOffset: pageOffset,
                      translationY: 50 + (i * 40),
                      child: _ThemeChoiceCard(
                        mode: modes[i],
                        selected: state.themeMode == modes[i],
                        onTap: () => context.read<SettingsCubit>().setThemeMode(
                          modes[i],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ThemeChoiceCard extends StatelessWidget {
  const _ThemeChoiceCard({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? scheme.primary : Colors.transparent,
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: scheme.onPrimary,
                          )
                        : Icon(mode.icon, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      mode.label(context.s),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingAutofillStep extends StatelessWidget {
  const OnboardingAutofillStep({
    super.key,
    required this.pageOffset,
    required this.granted,
    required this.onRequest,
  });

  final OnboardingOffset pageOffset;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return ImmersiveOnboardingLayout(
      pageOffset: pageOffset,
      hero: const OnboardingHeroIcon(icon: Icons.password_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: -30,
            child: OnboardingHeadline(s.onboardingEnableAutofillTitle),
          ),
          const SizedBox(height: 32),
          OnboardingParallax(
            pageOffset: pageOffset,
            translationY: 40,
            child: _PermissionCard(
              title: s.onboardingAutofillCardTitle,
              description: s.onboardingAutofillCardSubtitle,
              icon: Icons.login_rounded,
              granted: granted,
              onRequest: onRequest,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.granted,
    required this.onRequest,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: granted ? null : onRequest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: granted ? scheme.primary : scheme.surface,
                ),
                child: Icon(
                  granted ? Icons.check_rounded : icon,
                  size: 22,
                  color: granted ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      granted
                          ? context.s.onboardingAutofillGranted
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (!granted) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingFinishStep extends StatefulWidget {
  const OnboardingFinishStep({super.key, required this.pageOffset});

  final OnboardingOffset pageOffset;

  @override
  State<OnboardingFinishStep> createState() => _OnboardingFinishStepState();
}

class _OnboardingFinishStepState extends State<OnboardingFinishStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.value = 1;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return ImmersiveOnboardingLayout(
      pageOffset: widget.pageOffset,
      hero: const OnboardingHeroIcon(icon: Icons.password_rounded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingParallax(
            pageOffset: widget.pageOffset,
            translationY: -30,
            child: Material(
              color: scheme.primaryContainer.withValues(alpha: 0.6),
              shape: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: Tween(begin: 0.4, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _pulse,
                          curve: Curves.fastOutSlowIn,
                        ),
                      ),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s.onboardingFinishBadge,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          OnboardingParallax(
            pageOffset: widget.pageOffset,
            translationY: -20,
            child: OnboardingHeadline(s.onboardingFinishTitle),
          ),
          const SizedBox(height: 20),
          OnboardingParallax(
            pageOffset: widget.pageOffset,
            translationY: -10,
            child: OnboardingLead(s.onboardingFinishSubtitle),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
