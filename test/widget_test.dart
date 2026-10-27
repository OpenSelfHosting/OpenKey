import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/database/reserved_collections.dart';

/// Smoke sanity check that the test harness loads app libraries.
void main() {
  test('app library imports resolve', () {
    expect(ReservedCollections.wallets, isNotEmpty);
  });
}
