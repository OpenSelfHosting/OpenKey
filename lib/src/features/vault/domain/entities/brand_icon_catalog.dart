import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:openkey_app/src/features/vault/domain/entities/entry_icons.dart';

/// A brand SVG listed in `assets/brands_icons_list.json`.
class BrandIconInfo extends Equatable {
  const BrandIconInfo({required this.name, required this.path});

  final String name;
  final String path;

  String get key => EntryIcons.brandKey(path);

  String get assetPath => 'assets/brands/$path';

  String get searchText => '$name ${path.replaceAll('.svg', '')}'.toLowerCase();

  @override
  List<Object?> get props => [name, path];
}

/// Loads and matches Flowsi-style brand icons against entry fields.
class BrandIconCatalog {
  BrandIconCatalog._();

  static List<BrandIconInfo>? _cache;

  static Future<List<BrandIconInfo>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/brands_icons_list.json');
    final list = List<Map<String, dynamic>>.from(json.decode(raw) as List);
    _cache = [
      for (final item in list)
        BrandIconInfo(
          name: item['name']?.toString() ?? '',
          path: item['path']?.toString() ?? '',
        ),
    ]..removeWhere((e) => e.name.isEmpty || e.path.isEmpty);
    return _cache!;
  }

  /// Suggest an icon key from filled entry fields.
  ///
  /// Priority: title + website → username → other fields ([extras]).
  /// Falls back to Material / default via [EntryIcons.suggest].
  static Future<String> suggest({
    String title = '',
    String url = '',
    String username = '',
    Iterable<String> extras = const [],
  }) =>
      EntryIcons.suggest(
        title: title,
        url: url,
        username: username,
        extras: extras,
      );

  /// Match a brand icon only. Returns `null` when nothing is strong enough.
  ///
  /// Tries field groups in priority order and returns the first strong match,
  /// so a weaker title/website hit is never overridden by username/extras.
  static Future<String?> matchBrand({
    String title = '',
    String url = '',
    String username = '',
    Iterable<String> extras = const [],
  }) async {
    final brands = await load();

    for (final queries in tokenTiers(
      title: title,
      url: url,
      username: username,
      extras: extras,
    )) {
      final key = _bestMatch(brands, queries);
      if (key != null) return key;
    }
    return null;
  }

  /// Token groups in suggestion priority: title+website, username, extras.
  static List<List<String>> tokenTiers({
    String title = '',
    String url = '',
    String username = '',
    Iterable<String> extras = const [],
  }) =>
      [
        [..._hostTokens(url), ..._titleTokens(title)],
        [..._emailDomainTokens(username)],
        [...extraTokens(extras)],
      ];

  /// Tokens extracted from entry fields for icon matching (flat, priority order).
  static List<String> tokensFor({
    String title = '',
    String url = '',
    String username = '',
    Iterable<String> extras = const [],
  }) =>
      [
        for (final tier in tokenTiers(
          title: title,
          url: url,
          username: username,
          extras: extras,
        ))
          ...tier,
      ];

  /// Tokens from secondary fields (android app, notes, email, tags, …).
  static List<String> extraTokens(Iterable<String> extras) {
    final out = <String>{};
    for (final raw in extras) {
      final text = raw.trim();
      if (text.isEmpty) continue;
      out.addAll(_titleTokens(text));
      out.addAll(_hostTokens(text));
      out.addAll(_emailDomainTokens(text));
      out.addAll(_androidPackageTokens(text));
    }
    return out.toList();
  }

  static String? _bestMatch(List<BrandIconInfo> brands, List<String> queries) {
    if (queries.isEmpty) return null;

    BrandIconInfo? best;
    var bestScore = 0;

    for (final brand in brands) {
      for (final query in queries) {
        final score = _score(brand, query);
        if (score > bestScore) {
          bestScore = score;
          best = brand;
        }
      }
    }

    // Require a meaningful match (exact slug / strong contains).
    if (best != null && bestScore >= 80) return best.key;
    return null;
  }

  static int _score(BrandIconInfo brand, String query) {
    if (query.isEmpty) return 0;
    final slug = brand.path.replaceAll('.svg', '').toLowerCase();
    final name = brand.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final q = query.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    if (q.isEmpty) return 0;

    if (slug == q || name == q) return 100;
    if (slug.startsWith('$q-') || slug.endsWith('-$q')) return 92;
    if (slug.contains(q) && q.length >= 3) return 85;
    if (name.contains(q) && q.length >= 3) return 82;
    if (q.contains(slug) && slug.length >= 4) return 80;
    if (q.contains(name) && name.length >= 4) return 78;
    return 0;
  }

  static List<String> _hostTokens(String url) {
    final host = _extractHost(url);
    if (host == null) return const [];
    final parts = host.split('.')
      ..removeWhere((p) => p.isEmpty || _tldish.contains(p));
    // Prefer the registrable label (e.g. github from github.com).
    if (parts.isEmpty) return const [];
    final primary = parts.last;
    return {
      primary,
      if (parts.length >= 2) parts.sublist(parts.length - 2).join(''),
      host.replaceAll('.', ''),
    }.toList();
  }

  static List<String> _titleTokens(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return const [];
    final compact = trimmed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
    final words = trimmed
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.length >= 2)
        .toList();
    return {if (compact.isNotEmpty) compact, ...words}.toList();
  }

  static List<String> _emailDomainTokens(String username) {
    final at = username.indexOf('@');
    if (at < 0 || at == username.length - 1) return const [];
    return _hostTokens('https://${username.substring(at + 1)}');
  }

  static List<String> _androidPackageTokens(String package) {
    var pkg = package.trim().toLowerCase();
    if (pkg.startsWith('androidapp://')) {
      pkg = pkg.substring('androidapp://'.length);
    }
    if (pkg.isEmpty || !pkg.contains('.')) return const [];
    final parts = pkg.split('.')
      ..removeWhere((p) => p.isEmpty || _androidNoise.contains(p));
    return {
      for (final part in parts)
        if (part.length >= 3) part,
    }.toList();
  }

  static String? _extractHost(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final withScheme = text.contains('://') ? text : 'https://$text';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) return null;
    var host = uri.host.toLowerCase();
    if (host.startsWith('www.')) host = host.substring(4);
    return host;
  }

  static const _tldish = {
    'com',
    'org',
    'net',
    'io',
    'co',
    'app',
    'dev',
    'me',
    'ai',
    'gov',
    'edu',
    'uk',
    'us',
    'de',
    'fr',
    'jp',
    'cn',
    'ru',
    'br',
    'in',
    'au',
    'ca',
    'info',
    'biz',
  };

  static const _androidNoise = {
    ..._tldish,
    'android',
    'mobile',
    'client',
    'official',
  };
}
