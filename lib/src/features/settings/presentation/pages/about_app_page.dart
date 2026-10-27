import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';
import 'package:vector_graphics/vector_graphics.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  Future<void> _copyVersion(BuildContext context, String? version) async {
    if (version == null || version.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: version));
    if (!context.mounted) return;
    showMEToast(
      context,
      message: context.s.copied,
      kind: METoastKind.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MESliverScaffold(
      title: s.aboutApp,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      spacer: 4,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              FutureBuilder<String>(
                future: AppContact.appVersion(context),
                builder: (context, snapshot) {
                  return ActionItem(
                    title: s.appName,
                    subtitle: Text(
                      snapshot.data ?? '',
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => _copyVersion(context, snapshot.data),
                    icon: SettingsIcon(
                      Icons.password_rounded,
                      size: 58,
                      shape: ExpressiveShape.cookie12Sided,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                    ),
                    trailing: Row(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SocialChip(
                          onTap: () => AppContact.openUrl(AppContact.telegram),
                          child: Icon(
                            Icons.telegram,
                            size: 24,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        _SocialChip(
                          onTap: () => AppContact.openUrl(AppContact.website),
                          child: Icon(
                            CupertinoIcons.globe,
                            size: 24,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        _SocialChip(
                          onTap: () => AppContact.openUrl(AppContact.github),
                          child: Icon(
                            Icons.code_rounded,
                            size: 24,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    itemPosition: ItemPosition.top,
                  );
                },
              ),
              ActionItem(
                title: s.developerName,
                maxSubtitleLines: 4,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.developer,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SocialChip(
                          horizontalPadding: 14,
                          onTap: () =>
                              AppContact.openUrl(AppContact.openSelfHostingTelegram),
                          child: Icon(
                            Icons.telegram,
                            size: 24,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        _SocialChip(
                          horizontalPadding: 14,
                          onTap: () =>
                              AppContact.openUrl(AppContact.openSelfHostingWebsite),
                          child: Icon(
                            CupertinoIcons.globe,
                            size: 24,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        _SocialChip(
                          horizontalPadding: 14,
                          onTap: () =>
                              AppContact.openUrl(AppContact.openSelfHostingGithub),
                          child: Icon(
                            Icons.code_rounded,
                            size: 24,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                icon: ExpressiveIconContainer(
                  size: 58,
                  shape: ExpressiveShape.cookie12Sided,
                  backgroundColor: scheme.primaryContainer,
                  child: VectorGraphic(
                    loader: const AssetBytesLoader(
                      'assets/icon/company_logo.svg',
                    ),
                    width: 29,
                    height: 29,
                    colorFilter: ColorFilter.mode(
                      scheme.onPrimaryContainer,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                itemPosition: ItemPosition.bottom,
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: ActionItem(
            title: s.rateUsIn(
              platformCase(
                android: () => 'Google Play',
                ios: () => 'App Store',
                windows: () => 'Microsoft Store',
                macos: () => 'Mac App Store',
                linux: () => 'GitHub',
              ),
            ),
            subtitle: Text(
              s.doYouLikeTheAppRateUs,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            padding: 22,
            icon: ExpressiveIconContainer(
              size: 44,
              shape: ExpressiveShape.cookie9Sided,
              backgroundColor: scheme.tertiaryContainer,
              child: platformCase<Widget>(
                android: () => Icon(
                  Icons.shop_rounded,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                ios: () => Icon(
                  Icons.phone_iphone_rounded,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                windows: () => Icon(
                  Icons.desktop_windows_rounded,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                macos: () => Icon(
                  Icons.laptop_mac_rounded,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
                linux: () => Icon(
                  Icons.code_rounded,
                  size: 20,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ),
            onTap: AppContact.openStoreListing,
            itemPosition: ItemPosition.alone,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Column(
            children: [
              ActionItem(
                title: s.privacyPolicy,
                subtitle: Text(
                  s.privacyPolicySubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.privacy_tip_rounded,
                  backgroundColor: scheme.primaryContainer,
                  foregroundColor: scheme.onPrimaryContainer,
                ),
                onTap: () => AppContact.openUrl(AppContact.privacyPolicyUrl),
                trailing: const Icon(Icons.chevron_right_rounded),
                itemPosition: ItemPosition.start,
              ),
              ActionItem(
                title: s.termsOfService,
                subtitle: Text(
                  s.termsOfServiceSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.description_rounded,
                  backgroundColor: scheme.secondaryContainer,
                  foregroundColor: scheme.onSecondaryContainer,
                ),
                onTap: () => AppContact.openUrl(AppContact.termsOfServiceUrl),
                trailing: const Icon(Icons.chevron_right_rounded),
                itemPosition: ItemPosition.center,
              ),
              ActionItem(
                title: s.pricing,
                subtitle: Text(
                  s.pricingSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.sell_rounded,
                  backgroundColor: scheme.tertiaryContainer,
                  foregroundColor: scheme.onTertiaryContainer,
                ),
                onTap: () => AppContact.openUrl(AppContact.pricingUrl),
                trailing: const Icon(Icons.chevron_right_rounded),
                itemPosition: ItemPosition.center,
              ),
              ActionItem(
                title: s.licenses,
                subtitle: Text(
                  s.openLicenses,
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                icon: SettingsIcon(
                  Icons.book_rounded,
                  backgroundColor: scheme.surfaceContainerHighest,
                  foregroundColor: scheme.onSurfaceVariant,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: s.appName,
                  applicationLegalese: '© OpenSelfHosting',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                itemPosition: ItemPosition.end,
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.child,
    required this.onTap,
    this.horizontalPadding = 4,
  });

  final Widget child;
  final VoidCallback onTap;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(100),
        ),
        child: child,
      ),
    );
  }
}
