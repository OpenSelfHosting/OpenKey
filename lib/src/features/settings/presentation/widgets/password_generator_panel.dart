import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

enum GeneratorMode { password, username, email }

/// Shared generator controls built with Material 3 Expressive.
///
/// Used by [PasswordGeneratorPage]. Generates passwords, usernames, or emails
/// from the same preview + copy surface.
class PasswordGeneratorPanel extends StatefulWidget {
  const PasswordGeneratorPanel({super.key, this.onCopied});

  final VoidCallback? onCopied;

  @override
  State<PasswordGeneratorPanel> createState() => _PasswordGeneratorPanelState();
}

class _PasswordGeneratorPanelState extends State<PasswordGeneratorPanel> {
  final _identity = IdentityGenerator();
  final _domain = TextEditingController();
  final _plusEmail = TextEditingController();

  GeneratorMode _mode = GeneratorMode.password;
  UsernameStyle _usernameStyle = UsernameStyle.words;
  UsernameSeparator _separator = UsernameSeparator.none;
  bool _capitalize = true;
  bool _usernameDigits = true;
  int _usernameLength = 12;
  bool _emailPlus = false;
  String _value = '';

  static const _domainPresets = [
    'gmail.com',
    'outlook.com',
    'proton.me',
    'icloud.com',
    'duck.com',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_value.isEmpty) _value = _compute();
  }

  @override
  void dispose() {
    _domain.dispose();
    _plusEmail.dispose();
    super.dispose();
  }

  String _compute() {
    return switch (_mode) {
      GeneratorMode.password =>
        context.read<SettingsCubit>().state.generatePassword(
          sl<CryptoService>(),
        ),
      GeneratorMode.username => _identity.username(
        style: _usernameStyle,
        capitalize: _capitalize,
        includeDigits: _usernameDigits,
        separator: _separator,
        length: _usernameLength,
      ),
      GeneratorMode.email => _identity.email(
        domain: _domain.text,
        plusEmail: _emailPlus ? _plusEmail.text : null,
        localStyle: _usernameStyle,
        includeDigits: _usernameDigits,
        length: _usernameLength,
      ),
    };
  }

  void _refresh() => setState(() => _value = _compute());

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _value));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    final s = context.s;
    final message = switch (_mode) {
      GeneratorMode.password => s.passwordCopied,
      GeneratorMode.username => s.valueCopied(s.username),
      GeneratorMode.email => s.valueCopied(s.email),
    };
    showMEToast(context, message: message, kind: METoastKind.success);
    widget.onCopied?.call();
  }

  void _selectMode(GeneratorMode mode) {
    if (mode == _mode) return;
    HapticFeedback.selectionClick();
    setState(() {
      _mode = mode;
      _value = _compute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;
    final cubit = context.read<SettingsCubit>();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (p, c) =>
          p.passwordLength != c.passwordLength ||
          p.passwordUpper != c.passwordUpper ||
          p.passwordLower != c.passwordLower ||
          p.passwordDigits != c.passwordDigits ||
          p.passwordSymbols != c.passwordSymbols ||
          p.passwordAvoidAmbiguous != c.passwordAvoidAmbiguous,
      listener: (context, state) {
        if (_mode == GeneratorMode.password) _refresh();
      },
      buildWhen: (p, c) =>
          p.passwordLength != c.passwordLength ||
          p.passwordUpper != c.passwordUpper ||
          p.passwordLower != c.passwordLower ||
          p.passwordDigits != c.passwordDigits ||
          p.passwordSymbols != c.passwordSymbols ||
          p.passwordAvoidAmbiguous != c.passwordAvoidAmbiguous,
      builder: (context, settings) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              s.generatorSubtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 400;
                return MESegmentedButton<GeneratorMode>(
                  showCheckmark: false,
                  height: 44,
                  segments: [
                    MESegment(
                      value: GeneratorMode.password,
                      label: Text(s.generatorModePassword),
                      icon: compact
                          ? null
                          : const Icon(Icons.lock_outline_rounded, size: 18),
                    ),
                    MESegment(
                      value: GeneratorMode.username,
                      label: Text(s.generatorModeUsername),
                      icon: compact
                          ? null
                          : const Icon(Icons.person_outline_rounded, size: 18),
                    ),
                    MESegment(
                      value: GeneratorMode.email,
                      label: Text(s.generatorModeEmail),
                      icon: compact
                          ? null
                          : const Icon(Icons.alternate_email_rounded, size: 18),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (next) {
                    if (next.isEmpty) return;
                    _selectMode(next.first);
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _GeneratorPreview(
              mode: _mode,
              value: _value,
              reduceMotion: reduceMotion,
              onRegenerate: _refresh,
              onCopy: _copy,
            ),
            const SizedBox(height: 20),
            AnimatedSize(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: switch (_mode) {
                GeneratorMode.password => _PasswordOptions(
                  settings: settings,
                  cubit: cubit,
                ),
                GeneratorMode.username => _UsernameOptions(
                  style: _usernameStyle,
                  separator: _separator,
                  capitalize: _capitalize,
                  includeDigits: _usernameDigits,
                  length: _usernameLength,
                  onStyle: (v) {
                    setState(() => _usernameStyle = v);
                    _refresh();
                  },
                  onSeparator: (v) {
                    setState(() => _separator = v);
                    _refresh();
                  },
                  onCapitalize: (v) {
                    setState(() => _capitalize = v);
                    _refresh();
                  },
                  onDigits: (v) {
                    setState(() => _usernameDigits = v);
                    _refresh();
                  },
                  onLength: (v) {
                    setState(() => _usernameLength = v);
                    _refresh();
                  },
                ),
                GeneratorMode.email => _EmailOptions(
                  plus: _emailPlus,
                  domain: _domain,
                  plusEmail: _plusEmail,
                  style: _usernameStyle,
                  includeDigits: _usernameDigits,
                  presets: _domainPresets,
                  onPlus: (v) {
                    setState(() => _emailPlus = v);
                    _refresh();
                  },
                  onChanged: _refresh,
                  onStyle: (v) {
                    setState(() => _usernameStyle = v);
                    _refresh();
                  },
                  onDigits: (v) {
                    setState(() => _usernameDigits = v);
                    _refresh();
                  },
                  onPreset: (host) {
                    _domain.text = host;
                    _refresh();
                  },
                ),
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _GeneratorPreview extends StatelessWidget {
  const _GeneratorPreview({
    required this.mode,
    required this.value,
    required this.reduceMotion,
    required this.onRegenerate,
    required this.onCopy,
  });

  final GeneratorMode mode;
  final String value;
  final bool reduceMotion;
  final VoidCallback onRegenerate;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;
    final motion = METheme.of(context).motion;
    final strength = mode == GeneratorMode.password
        ? passwordStrengthScore(value)
        : null;
    final (label, icon) = switch (mode) {
      GeneratorMode.password => (
        s.generatedPassword,
        Icons.lock_outline_rounded,
      ),
      GeneratorMode.username => (
        s.generatedUsername,
        Icons.person_outline_rounded,
      ),
      GeneratorMode.email => (s.generatedEmail, Icons.alternate_email_rounded),
    };
    final strengthColor = strength == null
        ? null
        : strength < 0.35
        ? scheme.error
        : strength < 0.7
        ? scheme.tertiary
        : scheme.primary;
    final strengthLabel = strength == null
        ? null
        : strength < 0.35
        ? s.passwordStrengthWeak
        : strength < 0.7
        ? s.passwordStrengthFair
        : s.passwordStrengthStrong;

    return MECard(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              MEIconButton(
                tooltip: s.regenerate,
                variant: MEButtonVariant.tonal,
                size: MEButtonSize.small,
                onPressed: onRegenerate,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            child: Align(
              key: ValueKey(value),
              alignment: AlignmentDirectional.centerStart,
              child: Semantics(
                liveRegion: true,
                child: SelectableText(
                  value,
                  style: textTheme.headlineSmall?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurface,
                    letterSpacing: mode == GeneratorMode.password ? 0.8 : 0.2,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (strength != null && strengthColor != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: (strength * 4 - i).clamp(0.0, 1.0)),
                      duration: reduceMotion
                          ? Duration.zero
                          : motion.defaultEffects.approximateDuration,
                      curve: motion.defaultEffects.curve,
                      builder: (context, fill, _) => Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            scheme.surfaceContainerLow,
                            strengthColor,
                            fill,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                Text(
                  strengthLabel!,
                  style: textTheme.labelMedium?.copyWith(
                    color: strengthColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          MEButton(onPressed: onCopy, child: Text(s.copyPassword)),
        ],
      ),
    );
  }
}

class _PasswordOptions extends StatelessWidget {
  const _PasswordOptions({required this.settings, required this.cubit});

  final SettingsState settings;
  final SettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(s.passwordLength, style: textTheme.titleSmall),
            ),
            Text(
              '${settings.passwordLength}',
              style: textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        MESlider(
          value: settings.passwordLength.toDouble(),
          min: 8,
          max: 64,
          divisions: 56,
          onChanged: (v) => cubit.setPasswordLength(v.round()),
        ),
        const SizedBox(height: 8),
        Text(s.characterSets, style: textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MEChip(
              label: const Text('A–Z'),
              selected: settings.passwordUpper,
              onPressed: () => cubit.setPasswordUpper(!settings.passwordUpper),
            ),
            MEChip(
              label: const Text('a–z'),
              selected: settings.passwordLower,
              onPressed: () => cubit.setPasswordLower(!settings.passwordLower),
            ),
            MEChip(
              label: const Text('0–9'),
              selected: settings.passwordDigits,
              onPressed: () =>
                  cubit.setPasswordDigits(!settings.passwordDigits),
            ),
            MEChip(
              label: const Text(r'!@#'),
              selected: settings.passwordSymbols,
              onPressed: () =>
                  cubit.setPasswordSymbols(!settings.passwordSymbols),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ActionItem(
          title: s.avoidAmbiguous,
          subtitle: Text(
            s.avoidAmbiguousSubtitle,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          maxSubtitleLines: 2,
          icon: SettingsIcon(
            Icons.visibility_off_outlined,
            backgroundColor: scheme.surfaceContainerHighest,
            foregroundColor: scheme.onSurfaceVariant,
          ),
          trailing: MESwitch(
            value: settings.passwordAvoidAmbiguous,
            onChanged: cubit.setPasswordAvoidAmbiguous,
          ),
          itemPosition: ItemPosition.alone,
          onTap: () =>
              cubit.setPasswordAvoidAmbiguous(!settings.passwordAvoidAmbiguous),
        ),
      ],
    );
  }
}

class _UsernameOptions extends StatelessWidget {
  const _UsernameOptions({
    required this.style,
    required this.separator,
    required this.capitalize,
    required this.includeDigits,
    required this.length,
    required this.onStyle,
    required this.onSeparator,
    required this.onCapitalize,
    required this.onDigits,
    required this.onLength,
  });

  final UsernameStyle style;
  final UsernameSeparator separator;
  final bool capitalize;
  final bool includeDigits;
  final int length;
  final ValueChanged<UsernameStyle> onStyle;
  final ValueChanged<UsernameSeparator> onSeparator;
  final ValueChanged<bool> onCapitalize;
  final ValueChanged<bool> onDigits;
  final ValueChanged<int> onLength;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;
    final words = style == UsernameStyle.words;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.usernameStyle, style: textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MEChip(
              label: Text(s.usernameStyleWords),
              icon: const Icon(Icons.auto_stories_outlined),
              selected: words,
              onPressed: () => onStyle(UsernameStyle.words),
            ),
            MEChip(
              label: Text(s.usernameStyleRandom),
              icon: const Icon(Icons.shuffle_rounded),
              selected: !words,
              onPressed: () => onStyle(UsernameStyle.random),
            ),
          ],
        ),
        if (words) ...[
          const SizedBox(height: 16),
          Text(s.usernameSeparator, style: textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MEChip(
                label: Text(s.usernameSeparatorNone),
                selected: separator == UsernameSeparator.none,
                onPressed: () => onSeparator(UsernameSeparator.none),
              ),
              MEChip(
                label: const Text('_'),
                selected: separator == UsernameSeparator.underscore,
                onPressed: () => onSeparator(UsernameSeparator.underscore),
              ),
              MEChip(
                label: const Text('-'),
                selected: separator == UsernameSeparator.hyphen,
                onPressed: () => onSeparator(UsernameSeparator.hyphen),
              ),
              MEChip(
                label: const Text('.'),
                selected: separator == UsernameSeparator.dot,
                onPressed: () => onSeparator(UsernameSeparator.dot),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(s.passwordLength, style: textTheme.titleSmall),
              ),
              Text(
                '$length',
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          MESlider(
            value: length.toDouble(),
            min: 6,
            max: 24,
            divisions: 18,
            onChanged: (v) => onLength(v.round()),
          ),
        ],
        const SizedBox(height: 8),
        ActionItem(
          title: s.usernameCapitalize,
          icon: SettingsIcon(
            Icons.text_fields_rounded,
            backgroundColor: scheme.tertiaryContainer,
            foregroundColor: scheme.onTertiaryContainer,
          ),
          trailing: MESwitch(value: capitalize, onChanged: onCapitalize),
          itemPosition: ItemPosition.top,
          onTap: () => onCapitalize(!capitalize),
        ),
        ActionItem(
          title: s.usernameIncludeDigits,
          subtitle: Text(
            '0–9',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          icon: SettingsIcon(
            Icons.pin_rounded,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
          ),
          trailing: MESwitch(value: includeDigits, onChanged: onDigits),
          itemPosition: ItemPosition.bottom,
          onTap: () => onDigits(!includeDigits),
        ),
      ],
    );
  }
}

class _EmailOptions extends StatelessWidget {
  const _EmailOptions({
    required this.plus,
    required this.domain,
    required this.plusEmail,
    required this.style,
    required this.includeDigits,
    required this.presets,
    required this.onPlus,
    required this.onChanged,
    required this.onStyle,
    required this.onDigits,
    required this.onPreset,
  });

  final bool plus;
  final TextEditingController domain;
  final TextEditingController plusEmail;
  final UsernameStyle style;
  final bool includeDigits;
  final List<String> presets;
  final ValueChanged<bool> onPlus;
  final VoidCallback onChanged;
  final ValueChanged<UsernameStyle> onStyle;
  final ValueChanged<bool> onDigits;
  final ValueChanged<String> onPreset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;
    final words = style == UsernameStyle.words;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(s.emailType, style: textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MEChip(
              label: Text(s.emailTypeRandom),
              selected: !plus,
              onPressed: () => onPlus(false),
            ),
            MEChip(
              label: Text(s.emailTypePlus),
              selected: plus,
              onPressed: () => onPlus(true),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          plus ? s.emailPlusHelp : s.emailRandomHelp,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (plus)
          METextField(
            controller: plusEmail,
            label: s.emailPlusBase,
            hintText: s.emailPlusBaseHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            leadingIcon: const Icon(Icons.alternate_email_rounded),
            onChanged: (_) => onChanged(),
          )
        else ...[
          METextField(
            controller: domain,
            label: s.emailDomain,
            hintText: s.emailDomainHint,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            leadingIcon: const Icon(Icons.language_rounded),
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final host in presets)
                MEChip(
                  label: Text(host),
                  selected: domain.text.trim().toLowerCase() == host,
                  onPressed: () => onPreset(host),
                ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Text(s.usernameStyle, style: textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            MEChip(
              label: Text(s.usernameStyleWords),
              selected: words,
              onPressed: () => onStyle(UsernameStyle.words),
            ),
            MEChip(
              label: Text(s.usernameStyleRandom),
              selected: !words,
              onPressed: () => onStyle(UsernameStyle.random),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ActionItem(
          title: s.usernameIncludeDigits,
          icon: SettingsIcon(
            Icons.pin_rounded,
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
          ),
          trailing: MESwitch(value: includeDigits, onChanged: onDigits),
          itemPosition: ItemPosition.alone,
          onTap: () => onDigits(!includeDigits),
        ),
      ],
    );
  }
}
