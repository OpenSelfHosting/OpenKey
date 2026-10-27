import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/features/vault/domain/entities/entry_icons.dart';

void main() {
  group('EntryIcons.isUnresolved', () {
    test('empty and default key glyphs are unresolved', () {
      expect(EntryIcons.isUnresolved(''), isTrue);
      expect(EntryIcons.isUnresolved('   '), isTrue);
      expect(EntryIcons.isUnresolved(EntryIcons.defaultKey), isTrue);
      expect(EntryIcons.isUnresolved('key'), isTrue);
      expect(EntryIcons.isUnresolved('material:vpn_key'), isTrue);
      expect(EntryIcons.isUnresolved('material:login'), isTrue);
      expect(EntryIcons.isUnresolved('password'), isTrue);
    });

    test('chosen brands, photos, and other Material icons stay resolved', () {
      expect(EntryIcons.isUnresolved('brands/linux.svg'), isFalse);
      expect(EntryIcons.isUnresolved('brand:github'), isFalse);
      expect(EntryIcons.isUnresolved('custom:favicon:png:AAAA'), isFalse);
      expect(EntryIcons.isUnresolved('custom:png:AAAA'), isFalse);
      expect(EntryIcons.isUnresolved('material:lock'), isFalse);
      expect(EntryIcons.isUnresolved('material:folder'), isFalse);
    });
  });
}
