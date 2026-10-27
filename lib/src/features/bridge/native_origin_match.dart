/// Pure URL / origin matching for autofill and native-messaging fill.
///
/// Port-aware: `https://example.com:8443` never matches `:443`.
/// Hostname relatedness allows `app.example.com` ↔ `example.com`.
library;

/// Returns true when [pageHost] is the same as [entryHost] or a subdomain of it.
bool hostnamesRelated(String pageHost, String entryHost) {
  final page = pageHost.toLowerCase();
  final entry = entryHost.toLowerCase();
  if (page == entry) return true;
  return page.endsWith('.$entry');
}

/// Default port when the URI omits it (Dart [Uri.host] never includes port).
int effectiveUriPort(Uri uri) {
  if (uri.hasPort) return uri.port;
  if (uri.scheme == 'http') return 80;
  if (uri.scheme == 'https') return 443;
  return 0;
}

Uri? tryParseUri(String raw) {
  try {
    final value = raw.startsWith('http') ? raw : 'https://$raw';
    return Uri.parse(value);
  } catch (_) {
    return null;
  }
}

/// 0 = no match. Higher is better. Different ports never match.
int scoreUrlMatch(String candidate, Uri page) {
  final entry = tryParseUri(candidate);
  if (entry == null || entry.host.isEmpty || page.host.isEmpty) return 0;

  if (effectiveUriPort(page) != effectiveUriPort(entry)) return 0;

  final pageHost = page.host.toLowerCase();
  final entryHost = entry.host.toLowerCase();
  if (pageHost.isEmpty || entryHost.isEmpty) return 0;
  if (!hostnamesRelated(pageHost, entryHost)) return 0;

  final pageOrigin =
      '${page.scheme}://${page.host}:${effectiveUriPort(page)}';
  final entryOrigin =
      '${entry.scheme}://${entry.host}:${effectiveUriPort(entry)}';

  if (pageOrigin == entryOrigin) {
    if (page.path == entry.path ||
        page.path.startsWith(entry.path) ||
        entry.path == '/' ||
        entry.path.isEmpty) {
      return page.path == entry.path ? 4 : 3;
    }
    return 3;
  }

  if (pageHost == entryHost) return 2;
  if (pageHost.endsWith('.$entryHost')) return 1;
  return 0;
}

/// Rank [candidates] by URL match quality against [origin]; drop non-matches.
///
/// [urlsOf] extracts the URL list for each candidate. Results are unique by
/// [idOf] and sorted best-first.
List<T> matchByOrigin<T>({
  required List<T> candidates,
  required String origin,
  required List<String> Function(T item) urlsOf,
  required String Function(T item) idOf,
}) {
  final page = tryParseUri(origin);
  if (page == null || page.host.isEmpty) return const [];

  final scored = <({T item, int score})>[];
  for (final item in candidates) {
    var best = 0;
    for (final u in urlsOf(item)) {
      final score = scoreUrlMatch(u, page);
      if (score > best) best = score;
    }
    if (best > 0) scored.add((item: item, score: best));
  }
  scored.sort((a, b) => b.score.compareTo(a.score));
  final seen = <String>{};
  return [
    for (final s in scored)
      if (seen.add(idOf(s.item))) s.item,
  ];
}
