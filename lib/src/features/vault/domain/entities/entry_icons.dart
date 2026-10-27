import 'package:flutter/material.dart';
import 'package:openkey_app/src/features/vault/domain/entities/app_icon_fetcher.dart';
import 'package:openkey_app/src/features/vault/domain/entities/brand_icon_catalog.dart';
import 'package:openkey_app/src/features/vault/domain/entities/custom_icons.dart';
import 'package:openkey_app/src/features/vault/domain/entities/favicon_fetcher.dart';
import 'package:openkey_app/src/features/vault/domain/entities/material_icon_catalog.dart';

/// Catalog / key helpers for vault entry icons.
///
/// Stored on [VaultEntry.icon]:
/// - `material:<name>` — Material Icons
/// - `brands/<file.svg>` — SVG brand asset from `assets/brands/`
/// - `custom:png:<base64>` — image picked from the device
/// - `custom:favicon:png:<base64>` — website favicon fetched for the entry
/// - empty — unresolved; UI suggests from title / URL / username
class EntryIcons {
  EntryIcons._();

  static const defaultKey = 'material:key';

  /// Legacy short names that don't match Material glyph names 1:1.
  static const aliases = <String, String>{
    'games': 'sports_esports',
    'music': 'music_note',
    'health': 'health_and_safety',
    'wallet': 'account_balance_wallet',
  };

  /// Keyword → material glyph used when no brand match is found.
  static const _keywordIcons = <String, String>{
    'password': 'key',
    'passwd': 'key',
    'login': 'login',
    'signin': 'login',
    'account': 'manage_accounts',
    'user': 'person',
    'person': 'person',
    'people': 'groups',
    'group': 'groups',
    'team': 'groups',
    'email': 'email',
    'mail': 'email',
    'phone': 'phone',
    'mobile': 'smartphone',
    'sms': 'sms',
    'chat': 'chat',
    'message': 'message',
    'bank': 'account_balance',
    'finance': 'account_balance',
    'money': 'payments',
    'pay': 'payments',
    'payment': 'payments',
    'card': 'credit_card',
    'credit': 'credit_card',
    'debit': 'credit_card',
    'wallet': 'account_balance_wallet',
    'crypto': 'currency_bitcoin',
    'bitcoin': 'currency_bitcoin',
    'wifi': 'wifi',
    'router': 'router',
    'network': 'lan',
    'vpn': 'vpn_key',
    'server': 'dns',
    'cloud': 'cloud',
    'database': 'storage',
    'storage': 'storage',
    'api': 'api',
    'code': 'code',
    'dev': 'code',
    'developer': 'code',
    'terminal': 'terminal',
    'ssh': 'terminal',
    'work': 'work',
    'office': 'work',
    'job': 'work',
    'home': 'home',
    'house': 'home',
    'school': 'school',
    'university': 'school',
    'college': 'school',
    'edu': 'school',
    'game': 'sports_esports',
    'games': 'sports_esports',
    'gaming': 'sports_esports',
    'music': 'music_note',
    'movie': 'movie',
    'film': 'movie',
    'video': 'videocam',
    'photo': 'photo',
    'image': 'image',
    'camera': 'photo_camera',
    'health': 'health_and_safety',
    'medical': 'medical_services',
    'hospital': 'local_hospital',
    'flight': 'flight',
    'travel': 'flight_takeoff',
    'hotel': 'hotel',
    'car': 'directions_car',
    'drive': 'drive_eta',
    'shop': 'shopping_bag',
    'shopping': 'shopping_bag',
    'store': 'store',
    'cart': 'shopping_cart',
    'lock': 'lock',
    'secure': 'lock',
    'security': 'security',
    'key': 'key',
    'id': 'badge',
    'badge': 'badge',
    'identity': 'badge',
    'passport': 'airplane_ticket',
    'note': 'sticky_note_2',
    'notes': 'sticky_note_2',
    'document': 'description',
    'file': 'insert_drive_file',
    'folder': 'folder',
    'star': 'star',
    'favorite': 'favorite',
    'fav': 'favorite',
    'social': 'share',
    'share': 'share',
    'settings': 'settings',
    'config': 'settings',
    'admin': 'admin_panel_settings',
  };

  static bool isBrand(String key) =>
      key.startsWith('brands/') || key.startsWith('brand:');

  static bool isMaterial(String key) => MaterialIconCatalog.isMaterialKey(key);

  static bool isCustom(String key) => CustomIcons.isCustom(key);

  /// Default key glyph — not a user-chosen brand, photo, or Material icon.
  /// Matches the extension `isGenericMaterialIcon` so list/detail can fetch
  /// a site favicon the same way the browser popup does.
  static const _genericMaterialNames = {'key', 'vpn_key', 'login', 'password'};

  static bool isUnresolved(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return true;
    if (isCustom(trimmed) || isBrand(trimmed)) return false;
    var name = MaterialIconCatalog.nameOf(trimmed);
    if (name.endsWith('_rounded')) {
      name = name.substring(0, name.length - '_rounded'.length);
    }
    name = aliases[name] ?? name;
    return _genericMaterialNames.contains(name);
  }

  /// Material / default icons get a tinted surface; brand & custom do not.
  static bool needsBackdrop(String key) {
    if (key.isEmpty) return true;
    if (isCustom(key) || isBrand(key)) return false;
    return true;
  }

  static String brandKey(String fileName) {
    final name = fileName.contains('/') ? fileName.split('/').last : fileName;
    return 'brands/$name';
  }

  /// Old Font Awesome `brand:*` keys → Simple Icons SVGs already in assets.
  static const legacyBrandSvg = <String, String>{
    'brand:google': 'brands/google.svg',
    'brand:github': 'brands/github.svg',
    'brand:apple': 'brands/apple.svg',
    'brand:microsoft': 'brands/microsoft.svg',
    'brand:amazon': 'brands/amazon.svg',
    'brand:facebook': 'brands/facebook.svg',
    'brand:xTwitter': 'brands/x.svg',
    'brand:instagram': 'brands/instagram.svg',
    'brand:linkedin': 'brands/linkedin.svg',
    'brand:discord': 'brands/discord.svg',
    'brand:slack': 'brands/slack.svg',
    'brand:spotify': 'brands/spotify.svg',
    'brand:paypal': 'brands/paypal.svg',
    'brand:stripe': 'brands/stripe.svg',
    'brand:aws': 'brands/aws.svg',
    'brand:docker': 'brands/docker.svg',
    'brand:reddit': 'brands/reddit.svg',
    'brand:telegram': 'brands/telegram.svg',
    'brand:youtube': 'brands/youtube.svg',
    'brand:dropbox': 'brands/dropbox.svg',
  };

  static String? brandAssetPath(String key) {
    if (key.startsWith('brands/')) {
      return 'assets/$key';
    }
    final legacy = legacyBrandSvg[key];
    if (legacy != null) return 'assets/$legacy';
    return null;
  }

  static String brandFileName(String key) {
    if (key.startsWith('brands/')) return key.substring('brands/'.length);
    return key;
  }

  static IconData resolveMaterial(String key) {
    if (key.isEmpty) {
      return MaterialIconCatalog.resolve(defaultKey, fallback: Icons.key_rounded);
    }
    var name = MaterialIconCatalog.nameOf(key);
    name = aliases[name] ?? name;
    return MaterialIconCatalog.resolve(
      MaterialIconCatalog.keyFor(name),
      fallback: Icons.key_rounded,
    );
  }

  static Iterable<String> get materialKeys => MaterialIconCatalog.keys;

  static List<String> searchMaterial(String query) =>
      MaterialIconCatalog.search(query);

  /// Suggest an icon for an entry.
  ///
  /// Priority:
  /// 1. Website domain brand → website favicon
  /// 2. Android app package brand → installed app icon
  /// 3. Title-as-domain brand → favicon
  /// 4. Brand from title / username / extras
  /// 5. Material / [defaultKey]
  static Future<String> suggest({
    String title = '',
    String url = '',
    String username = '',
    Iterable<String> extras = const [],
    bool fetchFavicon = true,
  }) async {
    final urlTrimmed = url.trim();
    final titleTrimmed = title.trim();
    final titleIsDomain = FaviconFetcher.looksLikeDomain(titleTrimmed);
    String? androidPackage = AppIconFetcher.packageOf(urlTrimmed);
    if (androidPackage == null) {
      for (final extra in extras) {
        androidPackage = AppIconFetcher.packageOf(extra);
        if (androidPackage != null) break;
      }
    }

    // Native Android app: prefer the installed icon over a brand guess.
    if (androidPackage != null) {
      final appIcon = await AppIconFetcher.iconKeyFor(androidPackage);
      if (appIcon != null) return appIcon;

      final appBrand = await BrandIconCatalog.matchBrand(
        extras: [androidPackage],
      );
      if (appBrand != null) return appBrand;
    }

    // Website domain: brand first, then favicon (skip androidapp:// URLs).
    if (urlTrimmed.isNotEmpty && !urlTrimmed.startsWith('androidapp://')) {
      final urlBrand = await BrandIconCatalog.matchBrand(url: urlTrimmed);
      if (urlBrand != null) return urlBrand;

      if (fetchFavicon) {
        final favicon = await FaviconFetcher.fetchFor(urlTrimmed);
        if (favicon != null) return favicon;
      }
    }

    // Title that is itself a domain (e.g. "github.com").
    if (titleIsDomain) {
      final titleBrand = await BrandIconCatalog.matchBrand(title: titleTrimmed);
      if (titleBrand != null) return titleBrand;

      if (fetchFavicon) {
        final favicon = await FaviconFetcher.fetchFor(titleTrimmed);
        if (favicon != null) return favicon;
      }
    }

    // Remaining fields (non-domain title, username, extras).
    final brand = await BrandIconCatalog.matchBrand(
      title: titleIsDomain ? '' : titleTrimmed,
      username: username,
      extras: extras,
    );
    if (brand != null) return brand;

    final material = suggestMaterial(
      title: titleIsDomain ? '' : titleTrimmed,
      url: urlTrimmed.startsWith('androidapp://') ? '' : urlTrimmed,
      username: username,
      extras: extras,
    );
    return material ?? defaultKey;
  }

  /// Suggest a Material icon from entry fields (no brand matching).
  static String? suggestMaterial({
    String title = '',
    String url = '',
    String username = '',
    Iterable<String> extras = const [],
  }) {
    for (final tokens in BrandIconCatalog.tokenTiers(
      title: title,
      url: url,
      username: username,
      extras: extras,
    )) {
      final match = _bestMaterial(tokens);
      if (match != null) return match;
    }
    return null;
  }

  static String? _bestMaterial(Iterable<String> tokens) {
    final unique = tokens.toSet();
    if (unique.isEmpty) return null;

    String? bestName;
    var bestScore = 0;

    // Prefer curated keywords first (cheap + intentional).
    for (final token in unique) {
      final keyword = _keywordIcons[token];
      if (keyword == null || !MaterialIconCatalog.icons.containsKey(keyword)) {
        continue;
      }
      final score = 90 + token.length.clamp(0, 10);
      if (score > bestScore) {
        bestScore = score;
        bestName = keyword;
      }
    }
    if (bestName != null && bestScore >= 90) {
      return MaterialIconCatalog.keyFor(bestName);
    }

    // Fall back to matching Material glyph names.
    for (final token in unique) {
      final catalogScore = _scoreMaterialName(token);
      if (catalogScore.$2 > bestScore) {
        bestScore = catalogScore.$2;
        bestName = catalogScore.$1;
      }
    }

    if (bestName == null || bestScore < 70) return null;
    return MaterialIconCatalog.keyFor(bestName);
  }

  static (String?, int) _scoreMaterialName(String token) {
    if (token.length < 3) return (null, 0);
    final icons = MaterialIconCatalog.icons;
    if (icons.containsKey(token)) return (token, 95);

    String? best;
    var bestScore = 0;
    for (final name in icons.keys) {
      if (name == token) return (name, 95);
      if (name.startsWith('${token}_') || name.endsWith('_$token')) {
        if (88 > bestScore) {
          bestScore = 88;
          best = name;
        }
      } else if (name.contains(token) && token.length >= 4) {
        if (78 > bestScore) {
          bestScore = 78;
          best = name;
        }
      } else if (token.contains(name) && name.length >= 4) {
        if (72 > bestScore) {
          bestScore = 72;
          best = name;
        }
      }
    }
    return (best, bestScore);
  }
}
