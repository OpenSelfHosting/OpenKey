import 'dart:math';

/// How the username (or email local-part) is assembled.
enum UsernameStyle { words, random }

/// Joiner between adjective and noun in [UsernameStyle.words].
enum UsernameSeparator { none, underscore, hyphen, dot }

/// Cryptographically random usernames and email local-parts.
///
/// Word lists are ASCII-only so generated values stay valid as usernames
/// and email local-parts without extra encoding.
class IdentityGenerator {
  IdentityGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static const adjectives = [
    'able',
    'amber',
    'arctic',
    'autumn',
    'azure',
    'bold',
    'brave',
    'bright',
    'brisk',
    'calm',
    'cedar',
    'clear',
    'clever',
    'coral',
    'cosmic',
    'crisp',
    'curious',
    'delta',
    'eager',
    'early',
    'ember',
    'fair',
    'fern',
    'fierce',
    'gentle',
    'giant',
    'golden',
    'grand',
    'happy',
    'hidden',
    'ivory',
    'jade',
    'jolly',
    'keen',
    'kind',
    'lunar',
    'maple',
    'marble',
    'meadow',
    'merry',
    'misty',
    'noble',
    'north',
    'olive',
    'pearl',
    'pine',
    'polar',
    'proud',
    'quiet',
    'rapid',
    'rustic',
    'sage',
    'silent',
    'silver',
    'solar',
    'south',
    'spring',
    'steel',
    'storm',
    'summer',
    'swift',
    'tidal',
    'tidy',
    'true',
    'velvet',
    'vivid',
    'warm',
    'wild',
    'winter',
    'wise',
  ];

  static const nouns = [
    'acorn',
    'atlas',
    'badge',
    'basin',
    'beacon',
    'birch',
    'bloom',
    'breeze',
    'brook',
    'canyon',
    'clover',
    'comet',
    'crane',
    'creek',
    'crown',
    'dawn',
    'dove',
    'dune',
    'eagle',
    'field',
    'fjord',
    'flame',
    'flint',
    'frost',
    'garden',
    'grove',
    'harbor',
    'haven',
    'hawk',
    'hill',
    'horizon',
    'iris',
    'island',
    'jewel',
    'lagoon',
    'lake',
    'lantern',
    'leaf',
    'lotus',
    'moon',
    'moss',
    'oak',
    'ocean',
    'orchard',
    'otter',
    'palm',
    'peak',
    'pebble',
    'petal',
    'prairie',
    'quartz',
    'raven',
    'ridge',
    'river',
    'robin',
    'sail',
    'shore',
    'sky',
    'spark',
    'spruce',
    'stone',
    'stream',
    'summit',
    'sun',
    'tide',
    'trail',
    'valley',
    'wave',
    'willow',
    'wind',
    'wolf',
    'wood',
  ];

  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits = '0123456789';

  String username({
    UsernameStyle style = UsernameStyle.words,
    bool capitalize = true,
    bool includeDigits = true,
    UsernameSeparator separator = UsernameSeparator.none,
    int length = 12,
  }) {
    final core = switch (style) {
      UsernameStyle.words => _wordUsername(
        capitalize: capitalize,
        separator: separator,
      ),
      UsernameStyle.random => _randomUsername(
        length: length.clamp(6, 32),
        capitalize: capitalize,
        includeDigits: includeDigits,
      ),
    };
    if (style == UsernameStyle.random || !includeDigits) return core;
    return '$core${_digitSuffix()}';
  }

  /// Builds `local@domain`, or a plus-address when [plusEmail] contains `@`.
  String email({
    String domain = 'example.com',
    String? plusEmail,
    UsernameStyle localStyle = UsernameStyle.words,
    bool includeDigits = true,
    int length = 12,
  }) {
    final tag = username(
      style: localStyle,
      capitalize: false,
      includeDigits: includeDigits,
      separator: UsernameSeparator.none,
      length: length,
    ).toLowerCase();

    final plus = plusEmail?.trim();
    if (plus != null && plus.contains('@')) {
      final at = plus.indexOf('@');
      final local = plus.substring(0, at).trim();
      final host = _normalizeDomain(plus.substring(at + 1));
      if (local.isNotEmpty && host.isNotEmpty) {
        final base = local.split('+').first.toLowerCase();
        return '$base+$tag@$host';
      }
    }

    return '$tag@${_normalizeDomain(domain)}';
  }

  String _wordUsername({
    required bool capitalize,
    required UsernameSeparator separator,
  }) {
    final adjective = adjectives[_random.nextInt(adjectives.length)];
    final noun = nouns[_random.nextInt(nouns.length)];
    final left = capitalize ? _cap(adjective) : adjective;
    final right = capitalize ? _cap(noun) : noun;
    final join = switch (separator) {
      UsernameSeparator.none => '',
      UsernameSeparator.underscore => '_',
      UsernameSeparator.hyphen => '-',
      UsernameSeparator.dot => '.',
    };
    return '$left$join$right';
  }

  String _randomUsername({
    required int length,
    required bool capitalize,
    required bool includeDigits,
  }) {
    final pool = StringBuffer(_lower);
    if (capitalize) pool.write(_upper);
    if (includeDigits) pool.write(_digits);
    final chars = pool.toString();
    final letters = capitalize ? '$_lower$_upper' : _lower;
    final out = StringBuffer(letters[_random.nextInt(letters.length)]);
    for (var i = 1; i < length; i++) {
      out.write(chars[_random.nextInt(chars.length)]);
    }
    return out.toString();
  }

  String _digitSuffix() {
    final count = 2 + _random.nextInt(2);
    final buf = StringBuffer();
    buf.write(1 + _random.nextInt(9));
    for (var i = 1; i < count; i++) {
      buf.write(_random.nextInt(10));
    }
    return buf.toString();
  }

  static String _cap(String word) {
    if (word.isEmpty) return word;
    return '${word[0].toUpperCase()}${word.substring(1)}';
  }

  static String _normalizeDomain(String raw) {
    var host = raw.trim().toLowerCase();
    if (host.startsWith('@')) host = host.substring(1);
    if (host.isEmpty) return 'example.com';
    return host;
  }
}
