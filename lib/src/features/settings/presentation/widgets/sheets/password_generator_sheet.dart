import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Compact expressive bottom sheet for generating passwords.
///
/// - Standalone (vault / settings): primary action copies the password.
/// - Entry editor ([forUse]): primary action returns the password via [show].
class PasswordGeneratorSheet extends StatefulWidget {
  const PasswordGeneratorSheet({
    super.key,
    this.forUse = false,
    this.seedPassword,
  });

  /// When true, the filled CTA pops with the generated password for the caller
  /// to apply (e.g. entry editor). When false, it copies and dismisses.
  final bool forUse;

  /// Optional starting password to preview (e.g. current field value).
  final String? seedPassword;

  Future<String?> show(BuildContext context) {
    return showMEBottomSheet<String>(
      context: context,
      builder: (_) => this,
    );
  }

  @override
  State<PasswordGeneratorSheet> createState() => _PasswordGeneratorSheetState();
}

class _PasswordGeneratorSheetState extends State<PasswordGeneratorSheet> {
  String _password = '';
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final seed = widget.seedPassword?.trim();
    if (seed != null && seed.isNotEmpty) {
      _password = seed;
    } else {
      _password = context.read<SettingsCubit>().state.generatePassword(
            sl<CryptoService>(),
          );
    }
  }

  String _generate(SettingsState settings) =>
      settings.generatePassword(sl<CryptoService>());

  void _regenerate(SettingsState settings) {
    setState(() => _password = _generate(settings));
  }

  double _strengthOf(String password) {
    if (password.isEmpty) return 0;
    var score = (password.length / 16).clamp(0.0, 0.5);
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
    if (RegExp(r'\d').hasMatch(password)) score += 0.125;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;
    return score.clamp(0.0, 1.0);
  }

  Future<void> _copy({bool dismiss = false}) async {
    await Clipboard.setData(ClipboardData(text: _password));
    if (!mounted) return;
    showMEToast(
      context,
      message: context.s.passwordCopied,
      kind: METoastKind.success,
    );
    if (dismiss) Navigator.of(context).pop();
  }

  void _use() => Navigator.of(context).pop(_password);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final s = context.s;
    final cubit = context.read<SettingsCubit>();
    final motion = METheme.of(context).motion;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (p, c) =>
          p.passwordLength != c.passwordLength ||
          p.passwordUpper != c.passwordUpper ||
          p.passwordLower != c.passwordLower ||
          p.passwordDigits != c.passwordDigits ||
          p.passwordSymbols != c.passwordSymbols ||
          p.passwordAvoidAmbiguous != c.passwordAvoidAmbiguous,
      listener: (context, state) => _regenerate(state),
      buildWhen: (p, c) =>
          p.passwordLength != c.passwordLength ||
          p.passwordUpper != c.passwordUpper ||
          p.passwordLower != c.passwordLower ||
          p.passwordDigits != c.passwordDigits ||
          p.passwordSymbols != c.passwordSymbols ||
          p.passwordAvoidAmbiguous != c.passwordAvoidAmbiguous,
      builder: (context, settings) {
        final strength = _strengthOf(_password);
        final strengthColor = strength < 0.35
            ? scheme.error
            : strength < 0.7
                ? scheme.tertiary
                : scheme.primary;
        final strengthLabel = strength < 0.35
            ? s.passwordStrengthWeak
            : strength < 0.7
                ? s.passwordStrengthFair
                : s.passwordStrengthStrong;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  s.passwordGenerator,
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  s.passwordGeneratorSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                // Password preview — live while options change (unlike master_key).
                MECard(
                  color: scheme.surfaceContainerHighest,
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SelectableText(
                              _password,
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'monospace',
                                letterSpacing: 0.8,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          MEIconButton(
                            tooltip: s.regenerate,
                            variant: MEButtonVariant.tonal,
                            size: MEButtonSize.small,
                            onPressed: () => _regenerate(settings),
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          for (var i = 0; i < 4; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            Expanded(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(
                                  end: (strength * 4 - i).clamp(0.0, 1.0),
                                ),
                                duration:
                                    motion.defaultEffects.approximateDuration,
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
                            strengthLabel,
                            style: textTheme.labelMedium?.copyWith(
                              color: strengthColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.passwordLength,
                        style: textTheme.titleSmall,
                      ),
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
                const SizedBox(height: 8),
                MESlider(
                  value: settings.passwordLength.toDouble(),
                  min: 8,
                  max: 64,
                  divisions: 56,
                  onChanged: (v) => cubit.setPasswordLength(v.round()),
                ),
                const SizedBox(height: 16),

                Text(s.characterSets, style: textTheme.titleSmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MEChip(
                      label: const Text('A–Z'),
                      selected: settings.passwordUpper,
                      onPressed: () =>
                          cubit.setPasswordUpper(!settings.passwordUpper),
                    ),
                    MEChip(
                      label: const Text('a–z'),
                      selected: settings.passwordLower,
                      onPressed: () =>
                          cubit.setPasswordLower(!settings.passwordLower),
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
                const SizedBox(height: 8),

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
                  onTap: () => cubit.setPasswordAvoidAmbiguous(
                    !settings.passwordAvoidAmbiguous,
                  ),
                ),
                const SizedBox(height: 16),

                if (widget.forUse) ...[
                  MEButton(
                    onPressed: _use,
                    child: Text(s.usePassword),
                  ),
                  const SizedBox(height: 10),
                  MEButton.outlined(
                    onPressed: () => _copy(),
                    child: Text(s.copyPassword),
                  ),
                ] else
                  MEButton(
                    onPressed: () => _copy(dismiss: true),
                    child: Text(s.copyPassword),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
