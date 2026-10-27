import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:openkey_app/src/features/vault/domain/entities/custom_icons.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Downloads a site favicon once, caches it on disk by host, and reuses it.
///
/// HTTP stays async on the calling isolate (non-blocking). Image decode/resize
/// runs on a background [Isolate] via [CustomIcons.fromFaviconBytes].
///
/// Returned keys are entry-local `custom:png:…` strings. The same host always
/// resolves to the same cached bytes after the first successful fetch.
class FaviconFetcher {
  FaviconFetcher._();

  static final http.Client _client = http.Client();
  static final Map<String, String?> _memory = {};
  static final Map<String, Future<String?>> _inflight = {};
  static Directory? _dir;

  static const _timeout = Duration(seconds: 6);
  static const _maxBytes = 512 * 1024;
  static const _missTtl = Duration(days: 7);

  /// Drops in-memory host → icon mappings after an account switch.
  static void clearMemory() {
    _memory.clear();
    _inflight.clear();
  }

  /// Suggest a custom icon from [url], or from [title] when it looks like a domain.
  static Future<String?> suggest({String url = '', String title = ''}) async {
    final fromUrl = await fetchFor(url);
    if (fromUrl != null) return fromUrl;

    if (looksLikeDomain(title)) {
      return fetchFor(title);
    }
    return null;
  }

  /// Whether [text] is a bare domain / URL suitable for favicon lookup.
  static bool looksLikeDomain(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains(' ') || trimmed.contains('@')) return false;
    final host = extractHost(trimmed);
    if (host == null || !host.contains('.')) return false;
    if (!trimmed.contains('://') && trimmed.contains('/')) return false;
    final labels = host.split('.');
    if (labels.length < 2) return false;
    final tld = labels.last;
    if (tld.length < 2 || !RegExp(r'^[a-z]+$').hasMatch(tld)) return false;
    return true;
  }

  static String? extractHost(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final withScheme = text.contains('://') ? text : 'https://$text';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) return null;
    var host = uri.host.toLowerCase();
    if (host.startsWith('www.')) host = host.substring(4);
    return host;
  }

  static Future<String?> fetchFor(String urlOrHost) async {
    final host = extractHost(urlOrHost);
    if (host == null) return null;
    return fetchForHost(host);
  }

  /// Store an already-owned custom icon under [urlOrHost] for reuse.
  static Future<void> remember(String urlOrHost, String customIconKey) async {
    final host = extractHost(urlOrHost);
    if (host == null || !CustomIcons.isCustom(customIconKey)) return;
    final bytes = CustomIcons.decode(customIconKey);
    if (bytes == null || bytes.isEmpty) return;
    final key = CustomIcons.isFavicon(customIconKey)
        ? customIconKey
        : CustomIcons.encodeFaviconPng(bytes);
    _memory[host] = key;
    await _writeDisk(host, bytes);
  }

  static Future<String?> fetchForHost(String host) async {
    final h = host.trim().toLowerCase();
    if (h.isEmpty) return null;

    if (_memory.containsKey(h)) return _memory[h];

    final pending = _inflight[h];
    if (pending != null) return pending;

    final future = _resolve(h);
    _inflight[h] = future;
    try {
      final key = await future;
      _memory[h] = key;
      return key;
    } finally {
      _inflight.remove(h);
    }
  }

  static Future<String?> _resolve(String host) async {
    final cached = await _readDisk(host);
    if (cached != null) return cached;
    if (await _isMissFresh(host)) return null;

    final key = await _download(host);
    if (key != null) {
      final bytes = CustomIcons.decode(key);
      if (bytes != null) await _writeDisk(host, bytes);
      return key;
    }

    await _writeMiss(host);
    return null;
  }

  static Future<String?> _download(String host) async {
    Future<String?> tryUris(Iterable<Uri> uris) async {
      final seen = <String>{};
      for (final uri in uris) {
        if (!seen.add(uri.toString())) continue;
        final bytes = await _getImageBytes(uri);
        if (bytes == null || bytes.isEmpty) continue;
        try {
          // Decode/resize on a background isolate.
          return await CustomIcons.fromFaviconBytes(bytes);
        } catch (_) {
          continue;
        }
      }
      return null;
    }

    final fromDirect = await tryUris([
      Uri.https(host, '/apple-touch-icon.png'),
      Uri.https(host, '/apple-touch-icon-precomposed.png'),
      Uri.https(host, '/favicon.png'),
    ]);
    if (fromDirect != null) return fromDirect;

    final fromHtml = await tryUris(await _htmlIconUris(host));
    if (fromHtml != null) return fromHtml;

    return tryUris([
      Uri.parse('https://www.google.com/s2/favicons?domain=$host&sz=128'),
      Uri.parse('https://icons.duckduckgo.com/ip3/$host.ico'),
      Uri.https(host, '/favicon.ico'),
    ]);
  }

  static Future<Directory> _cacheDir() async {
    if (_dir != null) return _dir!;
    final root = await getApplicationSupportDirectory();
    final dir = Directory(p.join(root.path, 'favicon_cache'));
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  static String _fileId(String host) =>
      sha1.convert(utf8.encode(host)).toString();

  static Future<File> _pngFile(String host) async {
    final dir = await _cacheDir();
    return File(p.join(dir.path, '${_fileId(host)}.png'));
  }

  static Future<File> _missFile(String host) async {
    final dir = await _cacheDir();
    return File(p.join(dir.path, '${_fileId(host)}.miss'));
  }

  static Future<String?> _readDisk(String host) async {
    try {
      final file = await _pngFile(host);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      return await Isolate.run(() => CustomIcons.encodeFaviconPng(bytes));
    } catch (_) {
      return null;
    }
  }

  static Future<void> _writeDisk(String host, Uint8List bytes) async {
    try {
      final file = await _pngFile(host);
      await file.writeAsBytes(bytes, flush: true);
      final miss = await _missFile(host);
      if (await miss.exists()) await miss.delete();
    } catch (_) {}
  }

  static Future<bool> _isMissFresh(String host) async {
    try {
      final file = await _missFile(host);
      if (!await file.exists()) return false;
      final stat = await file.stat();
      return DateTime.now().difference(stat.modified) < _missTtl;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _writeMiss(String host) async {
    try {
      final file = await _missFile(host);
      await file.writeAsString(DateTime.now().toUtc().toIso8601String());
    } catch (_) {}
  }

  static Future<List<Uri>> _htmlIconUris(String host) async {
    try {
      final response = await _client
          .get(Uri.https(host, '/'), headers: _headers)
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }
      final body = response.body;
      if (body.isEmpty) return const [];

      final base = Uri.https(host, '/');
      final found = <Uri>[];
      final re = RegExp(
        r'''<link[^>]+rel=["']([^"']*icon[^"']*)["'][^>]*>''',
        caseSensitive: false,
      );
      for (final match in re.allMatches(body)) {
        final tag = match.group(0)!;
        final hrefMatch = RegExp(
          r'''href=["']([^"']+)["']''',
          caseSensitive: false,
        ).firstMatch(tag);
        final href = hrefMatch?.group(1)?.trim();
        if (href == null || href.isEmpty) continue;
        final lower = href.toLowerCase();
        if (lower.endsWith('.svg') || lower.contains('svg+xml')) continue;
        final resolved = base.resolve(href);
        if (resolved.scheme != 'https' && resolved.scheme != 'http') continue;
        found.add(resolved);
      }

      found.sort((a, b) {
        final as = a.path.toLowerCase();
        final bs = b.path.toLowerCase();
        int score(String path) {
          if (path.contains('apple-touch')) return 0;
          if (path.endsWith('.png')) return 1;
          if (path.endsWith('.webp')) return 2;
          return 3;
        }

        return score(as).compareTo(score(bs));
      });
      return found;
    } catch (_) {
      return const [];
    }
  }

  static Future<Uint8List?> _getImageBytes(Uri uri) async {
    try {
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final bytes = response.bodyBytes;
      if (bytes.isEmpty || bytes.length > _maxBytes) return null;
      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('text/html') ||
          contentType.contains('text/plain') ||
          contentType.contains('application/json') ||
          contentType.contains('svg')) {
        return null;
      }
      if (bytes.length >= 5) {
        final head = String.fromCharCodes(bytes.take(64));
        if (head.contains('<svg') || head.contains('<?xml')) return null;
      }
      return bytes;
    } catch (_) {
      return null;
    }
  }

  static const _headers = {
    'User-Agent': 'OpenKey/1.0 (favicon)',
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
  };
}
