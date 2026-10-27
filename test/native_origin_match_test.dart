import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/features/bridge/native_origin_match.dart';

void main() {
  group('hostnamesRelated', () {
    test('exact and subdomain', () {
      expect(hostnamesRelated('example.com', 'example.com'), isTrue);
      expect(hostnamesRelated('app.example.com', 'example.com'), isTrue);
      expect(hostnamesRelated('example.com', 'app.example.com'), isFalse);
      expect(hostnamesRelated('evil.com', 'example.com'), isFalse);
      expect(hostnamesRelated('notexample.com', 'example.com'), isFalse);
    });
  });

  group('scoreUrlMatch', () {
    final page = Uri.parse('https://app.example.com/login');

    test('exact origin+path scores highest', () {
      expect(scoreUrlMatch('https://app.example.com/login', page), 4);
    });

    test('same origin different path still matches', () {
      expect(scoreUrlMatch('https://app.example.com/', page), 3);
      expect(scoreUrlMatch('https://app.example.com/other', page), 3);
    });

    test('parent hostname is weaker but non-zero', () {
      expect(scoreUrlMatch('https://example.com/', page), 1);
    });

    test('different ports never match', () {
      expect(scoreUrlMatch('https://app.example.com:8443/login', page), 0);
      final custom = Uri.parse('https://app.example.com:8443/login');
      expect(scoreUrlMatch('https://app.example.com:8443/login', custom), 4);
      expect(scoreUrlMatch('https://app.example.com/login', custom), 0);
    });

    test('http vs https default ports differ', () {
      final httpPage = Uri.parse('http://app.example.com/login');
      expect(scoreUrlMatch('https://app.example.com/login', httpPage), 0);
      expect(scoreUrlMatch('http://app.example.com/login', httpPage), 4);
    });
  });

  group('matchByOrigin', () {
    test('ranks and dedupes by id', () {
      final items = [
        (id: 'a', urls: ['https://example.com/']),
        (id: 'b', urls: ['https://app.example.com/login']),
        (id: 'c', urls: ['https://other.com/']),
        (id: 'a', urls: ['https://example.com/again']),
      ];
      final matched = matchByOrigin(
        candidates: items,
        origin: 'https://app.example.com/login',
        urlsOf: (e) => e.urls,
        idOf: (e) => e.id,
      );
      expect(matched.map((e) => e.id).toList(), ['b', 'a']);
    });

    test('empty origin yields empty', () {
      expect(
        matchByOrigin(
          candidates: [(id: 'a', urls: ['https://x.com'])],
          origin: '',
          urlsOf: (e) => e.urls,
          idOf: (e) => e.id,
        ),
        isEmpty,
      );
    });
  });

  group('extension parity (url_match.ts)', () {
    const page8444 = 'https://main-worker-01.tail319662.ts.net:8444/#/lock';
    const entry5678 = 'https://main-worker-01.tail319662.ts.net:5678/';
    const entry8444 = 'https://main-worker-01.tail319662.ts.net:8444/';

    test('different ports are different sites', () {
      final page = Uri.parse(page8444);
      expect(scoreUrlMatch(entry5678, page), 0);
      expect(scoreUrlMatch(entry8444, page), greaterThan(0));
    });

    test('ranks correct port ahead of wrong port', () {
      final items = [
        (id: 'wrong', urls: [entry5678]),
        (id: 'right', urls: [entry8444]),
      ];
      final ranked = matchByOrigin(
        candidates: items,
        origin: page8444,
        urlsOf: (e) => e.urls,
        idOf: (e) => e.id,
      );
      expect(ranked.map((e) => e.id).toList(), ['right']);
    });

    test('default https port equals :443', () {
      final page = Uri.parse('https://example.com:443/login');
      expect(scoreUrlMatch('https://example.com/', page), greaterThan(0));
    });

    test('subdomain match only on same port', () {
      expect(
        scoreUrlMatch(
          'https://example.com:8444/',
          Uri.parse('https://app.example.com:8444/login'),
        ),
        1,
      );
      expect(
        scoreUrlMatch(
          'https://example.com:5678/',
          Uri.parse('https://app.example.com:8444/login'),
        ),
        0,
      );
    });
  });
}
