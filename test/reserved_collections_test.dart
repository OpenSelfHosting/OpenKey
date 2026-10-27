import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/database/reserved_collections.dart';

void main() {
  test('known reserved ids', () {
    expect(ReservedCollections.isReserved(ReservedCollections.wallets), isTrue);
    expect(ReservedCollections.isReserved(ReservedCollections.crypto), isTrue);
    expect(ReservedCollections.isReserved(ReservedCollections.secrets), isTrue);
    expect(ReservedCollections.all, {
      '__wallets__',
      '__crypto_wallets__',
      '__dev_secrets__',
    });
    expect(ReservedCollections.all.length, 3);
  });

  test('regular collection ids are not reserved', () {
    expect(ReservedCollections.isReserved('folder-1'), isFalse);
    expect(ReservedCollections.isReserved(null), isFalse);
    expect(ReservedCollections.isReserved(''), isFalse);
    expect(ReservedCollections.isReserved('wallets'), isFalse);
  });
}
