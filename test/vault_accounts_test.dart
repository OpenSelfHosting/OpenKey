import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/crypto/crypto_service.dart';
import 'package:openkey_app/src/core/services/vault_metadata_store.dart';

class _MemoryPrefs implements SharedPreferencesLike {
  final Map<String, Object> data = {};

  @override
  bool? getBool(String key) {
    final value = data[key];
    return value is bool ? value : null;
  }

  @override
  int? getInt(String key) {
    final value = data[key];
    return value is int ? value : null;
  }

  @override
  String? getString(String key) {
    final value = data[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    data[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    data.remove(key);
    return true;
  }
}

void main() {
  test('migrates a single legacy vault into the account registry', () async {
    final prefs = _MemoryPrefs();
    await prefs.setBool('ok_has_vault', true);
    await prefs.setString('ok_email', 'owner@example.com');
    await prefs.setString('ok_salt', 'c2FsdA');
    await prefs.setString('ok_wrapped_vault_key', 'd3JhcA');
    await prefs.setString('ok_kdf', '{"memory":65536}');

    var n = 0;
    final store = VaultMetadataStore(
      prefs,
      usePrefsForSecure: true,
      newAccountId: () => 'legacy-${n++}',
    );
    await store.migrateToAccountRegistry();
    await store.ensureLoaded();

    expect(store.hasVault, isTrue);
    expect(store.accounts, hasLength(1));
    expect(store.accounts.single.id, 'legacy-0');
    expect(store.accounts.single.email, 'owner@example.com');
    expect(store.activeAccountId, 'legacy-0');
    expect(store.email, 'owner@example.com');
    expect(store.saltBase64, 'c2FsdA');
    expect(store.wrappedVaultKey, 'd3JhcA');
    expect(prefs.getString('ok_email'), isNull);
    expect(prefs.getString('ok.a.legacy-0.email'), 'owner@example.com');
  });

  test(
    'createAccount keeps the previous vault and rejects duplicate email',
    () async {
      final prefs = _MemoryPrefs();
      var n = 0;
      final store = VaultMetadataStore(
        prefs,
        usePrefsForSecure: true,
        newAccountId: () => 'acc-${n++}',
      );

      final first = await store.createAccount(email: 'one@example.com');
      await store.saveVaultMetadata(
        email: 'one@example.com',
        saltBase64: 's1',
        kdfParams: const {'memory': 1},
        wrappedVaultKey: 'w1',
      );
      expect(store.emailExists('one@example.com'), isTrue);

      final second = await store.createAccount(email: 'two@example.com');
      await store.saveVaultMetadata(
        email: 'two@example.com',
        saltBase64: 's2',
        kdfParams: const {'memory': 1},
        wrappedVaultKey: 'w2',
      );

      expect(first.id, 'acc-0');
      expect(second.id, 'acc-1');
      expect(store.accounts, hasLength(2));
      expect(store.activeAccountId, 'acc-1');
      expect(store.email, 'two@example.com');
      expect(store.saltBase64, 's2');
      expect(store.emailExists('two@example.com'), isTrue);
      expect(store.emailExists('one@example.com'), isTrue);
    },
  );

  test('switchAccount reloads the other vault metadata', () async {
    final prefs = _MemoryPrefs();
    var n = 0;
    final store = VaultMetadataStore(
      prefs,
      usePrefsForSecure: true,
      newAccountId: () => 'acc-${n++}',
    );

    await store.createAccount(email: 'one@example.com');
    await store.saveVaultMetadata(
      email: 'one@example.com',
      saltBase64: 's1',
      kdfParams: const {'memory': 1},
      wrappedVaultKey: 'w1',
    );
    await store.createAccount(email: 'two@example.com');
    await store.saveVaultMetadata(
      email: 'two@example.com',
      saltBase64: 's2',
      kdfParams: const {'memory': 1},
      wrappedVaultKey: 'w2',
    );

    await store.setActiveAccount('acc-0');
    expect(store.email, 'one@example.com');
    expect(store.saltBase64, 's1');
    expect(store.wrappedVaultKey, 'w1');

    await store.setActiveAccount('acc-1');
    expect(store.email, 'two@example.com');
    expect(store.saltBase64, 's2');
  });

  test('lock and generator prefs stay isolated per account', () async {
    final prefs = _MemoryPrefs();
    var n = 0;
    final store = VaultMetadataStore(
      prefs,
      usePrefsForSecure: true,
      newAccountId: () => 'acc-${n++}',
    );

    await store.createAccount(email: 'one@example.com');
    await store.setLockMinutes(1);
    await store.setPasswordGenerator(length: 12);
    await store.setBlockScreenshot(true);

    await store.createAccount(email: 'two@example.com');
    expect(store.lockMinutes, 5);
    expect(store.passwordLength, 20);
    expect(store.blockScreenshot, isFalse);

    await store.setLockMinutes(15);
    await store.setPasswordGenerator(length: 32);

    await store.setActiveAccount('acc-0');
    expect(store.lockMinutes, 1);
    expect(store.passwordLength, 12);
    expect(store.blockScreenshot, isTrue);

    await store.setActiveAccount('acc-1');
    expect(store.lockMinutes, 15);
    expect(store.passwordLength, 32);
    expect(store.blockScreenshot, isFalse);
  });

  test('shared lock minutes copy onto every existing account once', () async {
    final prefs = _MemoryPrefs();
    var n = 0;
    final store = VaultMetadataStore(
      prefs,
      usePrefsForSecure: true,
      newAccountId: () => 'acc-${n++}',
    );

    await store.createAccount(email: 'one@example.com');
    await store.createAccount(email: 'two@example.com');
    await prefs.setInt('ok_lock_minutes', 3);
    await store.migrateSharedVaultPrefsToAccounts();

    await store.setActiveAccount('acc-0');
    expect(store.lockMinutes, 3);
    await store.setActiveAccount('acc-1');
    expect(store.lockMinutes, 3);

    await store.setLockMinutes(10);
    await store.setActiveAccount('acc-0');
    expect(store.lockMinutes, 3);
    expect(prefs.getInt('ok_lock_minutes'), isNull);
  });

  test(
    'removeAccount activates the remaining vault or clears the registry',
    () async {
      final prefs = _MemoryPrefs();
      var n = 0;
      final store = VaultMetadataStore(
        prefs,
        usePrefsForSecure: true,
        newAccountId: () => 'acc-${n++}',
      );

      await store.createAccount(email: 'one@example.com');
      await store.saveVaultMetadata(
        email: 'one@example.com',
        saltBase64: 's1',
        kdfParams: const {'memory': 1},
        wrappedVaultKey: 'w1',
      );
      await store.createAccount(email: 'two@example.com');
      await store.saveVaultMetadata(
        email: 'two@example.com',
        saltBase64: 's2',
        kdfParams: const {'memory': 1},
        wrappedVaultKey: 'w2',
      );

      await store.removeAccount('acc-1');
      expect(store.hasVault, isTrue);
      expect(store.accounts, hasLength(1));
      expect(store.activeAccountId, 'acc-0');
      expect(store.email, 'one@example.com');
      expect(store.saltBase64, 's1');

      await store.removeAccount('acc-0');
      expect(store.hasVault, isFalse);
      expect(store.accounts, isEmpty);
      expect(store.activeAccountId, isNull);
    },
  );

  test(
    'change-email rewrap unlocks with the new email and same password',
    () async {
      final crypto = CryptoService();
      const oldEmail = 'old@example.com';
      const newEmail = 'new@example.com';
      const password = 'correct-horse-battery';
      final salt = crypto.generateSalt();
      final vaultKeyBytes = crypto.generateVaultKey();
      final kdf = crypto.defaultKdfParams();

      final oldMaster = await crypto.deriveMasterKey(
        email: oldEmail,
        masterPassword: password,
        salt: salt,
        kdfParams: kdf,
      );
      final wrapped = await crypto.wrapVaultKey(
        masterKey: oldMaster,
        vaultKeyBytes: vaultKeyBytes,
      );

      final newMaster = await crypto.deriveMasterKey(
        email: newEmail,
        masterPassword: password,
        salt: salt,
        kdfParams: kdf,
      );
      final newWrapped = await crypto.wrapVaultKey(
        masterKey: newMaster,
        vaultKeyBytes: vaultKeyBytes,
      );

      final recovered = await crypto.unwrapVaultKey(
        masterKey: newMaster,
        wrappedVaultKey: newWrapped,
      );
      expect(recovered, vaultKeyBytes);

      await expectLater(
        crypto.unwrapVaultKey(
          masterKey: oldMaster,
          wrappedVaultKey: newWrapped,
        ),
        throwsA(anything),
      );
      await expectLater(
        crypto.unwrapVaultKey(masterKey: newMaster, wrappedVaultKey: wrapped),
        throwsA(anything),
      );
    },
  );
}
