import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:openkey_app/src/core/functions/platform_case.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public contact links and store helpers for OpenKey.
class AppContact {
  static const String email = 'security@openselfhosting.com';
  static const String telegram = 'https://t.me/OpenKeyApp';
  static const String website = 'https://openkey.openselfhosting.com';
  static const String github = 'https://github.com/OpenSelfHosting/OpenKey';

  static const String openSelfHostingTelegram = 'https://t.me/openselfhosting';
  static const String openSelfHostingWebsite = 'https://openselfhosting.com';
  static const String openSelfHostingGithub = 'https://github.com/OpenSelfHosting';

  /// Hosted on the OpenKey docs site (openselfhosting.com).
  static const String privacyPolicyUrl =
      'https://openkey.openselfhosting.com/privacy';
  static const String termsOfServiceUrl =
      'https://openkey.openselfhosting.com/terms';
  static const String pricingUrl =
      'https://openkey.openselfhosting.com/pricing';

  static const String packageName = 'com.openselfhosting.openkey';
  static const String googlePlay =
      'https://play.google.com/store/apps/details?id=$packageName';

  /// Replace when the App Store listing is live.
  static const String appStoreId = '';

  /// Replace when the Microsoft Store listing is live.
  static const String microsoftStoreId = '';

  static Future<void> openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  static Future<void> openTelegram() => openUrl(telegram);

  static Future<bool> openEmail() async {
    final version = await versionLabel();
    final query = [
      'subject=${Uri.encodeComponent('OpenKey support')}',
      'body=${Uri.encodeComponent('App version: $version\n\n')}',
    ].join('&');
    final uri = Uri.parse('mailto:$email?$query');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openGooglePlay() async {
    return launchUrl(Uri.parse(googlePlay));
  }

  static Future<bool> openAppStore() async {
    if (appStoreId.isEmpty) {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.openStoreListing();
        return true;
      }
      return false;
    }
    return launchUrl(Uri.parse('https://apps.apple.com/app/id$appStoreId'));
  }

  static Future<bool> openMicrosoftStore() async {
    if (microsoftStoreId.isEmpty) return false;
    return launchUrl(
      Uri.parse('https://www.microsoft.com/store/apps/$microsoftStoreId'),
    );
  }

  static Future<void> openStoreListing() async {
    await platformCase(
      android: openGooglePlay,
      ios: openAppStore,
      windows: openMicrosoftStore,
      macos: openAppStore,
      linux: () async {
        await openUrl(website);
        return true;
      },
    );
  }

  static Future<String> appVersion(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final storeName = platformCase(
      android: () => 'Play Store',
      ios: () => 'App Store',
      windows: () => 'Windows',
      linux: () => 'Linux',
      macos: () => 'Mac App Store',
    );
    return '$storeName (${packageInfo.buildNumber}) ${packageInfo.version}';
  }

  static Future<String> versionLabel() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version} (${packageInfo.buildNumber})';
  }
}
