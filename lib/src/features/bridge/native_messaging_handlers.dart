part of 'native_messaging_host.dart';

mixin _NativeMessagingHandlers on _NativeMessagingHostBase {
  @override
  Future<Map<String, dynamic>> handleMessage(Map<String, dynamic> msg) async {
    if (!_authTokenValid(msg)) {
      return {'ok': false, 'error': 'Unauthorized'};
    }
    final type = msg['type']?.toString();
    switch (type) {
      case 'ping':
        return {'ok': true, 'unlocked': _session.isUnlocked};
      case 'listForOrigin':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        final origin = msg['origin']?.toString() ?? '';
        // Include every vault login (root + nested folders), same as AutofillBridge.
        final result = await _entries.getEntries(collectionUuid: '__all__');
        return result.fold(
          (_) => {'ok': false, 'error': 'Failed to load entries'},
          (entries) => {
            'ok': true,
            'entries': _matchOrigin(entries, origin)
                .where((e) => e.isAutofillFillable)
                .map(_entryJson)
                .toList(),
          },
        );
      case 'listEntries':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        final origin = msg['origin']?.toString() ?? '';
        final all = await _entries.getEntries(collectionUuid: '__all__');
        return all.fold(
          (_) => {'ok': false, 'error': 'Failed to load entries'},
          (entries) {
            final scoped = origin.isEmpty
                ? entries
                : _matchOrigin(entries, origin)
                    .where((e) => e.isAutofillFillable)
                    .toList();
            return {
              'ok': true,
              'entries': scoped
                  .map((e) => _entryJson(e, list: true))
                  .toList(),
            };
          },
        );
      case 'getEntry':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        final uuid = msg['uuid']?.toString() ?? '';
        final result = await _entries.getEntry(uuid);
        return result.fold(
          (_) => {'ok': false, 'error': 'Not found'},
          (entry) => {
            'ok': true,
            'entry': entry == null ? null : _entryJson(entry),
          },
        );
      case 'createEntry':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _createEntryFromMessage(msg);
      case 'updateEntry':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _updateEntryFromMessage(msg);
      case 'deleteEntry':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _deleteEntryFromMessage(msg);
      case 'updatePasskeySignCount':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _updatePasskeySignCount(msg);
      case 'listCards':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _listCards();
      case 'listCrypto':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _listCrypto();
      case 'listSecrets':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _listSecrets();
      case 'listCollections':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _listCollections();
      case 'listVault':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _listVault();
      case 'createSecret':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _createSecretFromMessage(msg);
      case 'updateSecret':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _updateSecretFromMessage(msg);
      case 'deleteSecret':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _deleteSecretFromMessage(msg);
      case 'createCard':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _createCardFromMessage(msg);
      case 'updateCard':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _updateCardFromMessage(msg);
      case 'deleteCard':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _deleteCardFromMessage(msg);
      case 'createCrypto':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _createCryptoFromMessage(msg);
      case 'updateCrypto':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _updateCryptoFromMessage(msg);
      case 'deleteCrypto':
        if (!_session.isUnlocked) {
          return {'ok': false, 'error': 'Vault locked'};
        }
        return _deleteCryptoFromMessage(msg);
      default:
        return {'ok': false, 'error': 'Unknown type'};
    }
  }

  Future<Map<String, dynamic>> _listCards() async {
    final wallets = _wallets;
    if (wallets == null) {
      return {'ok': true, 'cards': <Map<String, dynamic>>[]};
    }
    final result = await wallets.getCards();
    return result.fold(
      (_) => {'ok': false, 'error': 'Failed to load cards'},
      (cards) => {
        'ok': true,
        'cards': cards.map(_cardJson).toList(),
      },
    );
  }

  Future<Map<String, dynamic>> _listCrypto() async {
    final crypto = _crypto;
    if (crypto == null) {
      return {'ok': true, 'wallets': <Map<String, dynamic>>[]};
    }
    final result = await crypto.getWallets();
    return result.fold(
      (_) => {'ok': false, 'error': 'Failed to load crypto wallets'},
      (wallets) => {
        'ok': true,
        'wallets': wallets.map(_cryptoJson).toList(),
      },
    );
  }

  Map<String, dynamic> _cardJson(WalletCard c) => {
        'kind': 'card',
        'type': 'card',
        'uuid': c.uuid,
        'collectionUuid': WalletIds.collectionUuid,
        'revision': c.revision,
        'name': c.name,
        'holder': c.holder,
        'number': c.number,
        'expiry': c.expiry,
        'cvc': c.cvc,
        'brand': c.brand.name,
        'notes': c.notes,
        if (c.bank.trim().isNotEmpty) 'bank': c.bank,
      };

  Map<String, dynamic> _cryptoJson(CryptoWallet w) => {
        'kind': 'crypto',
        'type': 'crypto',
        'uuid': w.uuid,
        'collectionUuid': CryptoIds.collectionUuid,
        'revision': w.revision,
        'name': w.name,
        'network': w.network.name,
        'address': w.address,
        'privateKey': w.privateKey,
        'seedPhrase': w.seedPhrase,
        'notes': w.notes,
        if (w.folder.trim().isNotEmpty) 'folder': w.folder,
      };

  Future<Map<String, dynamic>> _listSecrets() async {
    final secrets = _secrets;
    if (secrets == null) {
      return {'ok': true, 'secrets': <Map<String, dynamic>>[]};
    }
    final result = await secrets.getSecrets();
    return result.fold(
      (_) => {'ok': false, 'error': 'Failed to load secrets'},
      (items) => {
        'ok': true,
        'secrets': items.map(_secretJson).toList(),
      },
    );
  }

  Map<String, dynamic> _secretJson(DevSecret s) => {
        'kind': 'secret',
        'type': 'secret',
        'uuid': s.uuid,
        'collectionUuid': SecretIds.collectionUuid,
        'revision': s.revision,
        'name': s.name,
        'secretKind': s.kind.name,
        'username': s.username,
        'host': s.host,
        'publicKey': s.publicKey,
        'secret': s.secret,
        'passphrase': s.passphrase,
        'notes': s.notes,
        'device': s.device,
      };

  Future<Map<String, dynamic>> _listCollections() async {
    final collections = _collections;
    if (collections == null) {
      return {'ok': true, 'collections': <Map<String, dynamic>>[]};
    }
    final result = await collections.getCollections();
    return result.fold(
      (_) => {'ok': false, 'error': 'Failed to load folders'},
      (items) => {
        'ok': true,
        'collections': items.map(_collectionJson).toList(),
      },
    );
  }

  Map<String, dynamic> _collectionJson(VaultCollection c) => {
        'uuid': c.uuid,
        'name': c.name,
        'icon': c.icon,
        'color': c.color,
        'parentUuid': c.parentUuid,
        'sortOrder': c.sortOrder,
      };

  /// One round-trip for the extension popup: folders + every vault item.
  Future<Map<String, dynamic>> _listVault() async {
    final all = await _entries.getEntries(collectionUuid: '__all__');
    return await all.fold(
      (_) async => {'ok': false, 'error': 'Failed to load entries'},
      (entries) async {
        final collections = await _listCollections();
        final cards = await _listCards();
        final crypto = await _listCrypto();
        final secrets = await _listSecrets();
        return {
          'ok': true,
          'entries': entries.map((e) => _entryJson(e, list: true)).toList(),
          'collections': collections['ok'] == true
              ? collections['collections']
              : <Map<String, dynamic>>[],
          'cards': cards['ok'] == true
              ? cards['cards']
              : <Map<String, dynamic>>[],
          'wallets': crypto['ok'] == true
              ? crypto['wallets']
              : <Map<String, dynamic>>[],
          'secrets': secrets['ok'] == true
              ? secrets['secrets']
              : <Map<String, dynamic>>[],
        };
      },
    );
  }

  Map<String, dynamic> _secretFields(Map<String, dynamic> msg) {
    final raw = msg['secret'];
    final map = <String, dynamic>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        map[key.toString()] = value;
      });
    }
    // Also accept flat fields on the message root for convenience.
    for (final key in [
      'name',
      'kind',
      'secretKind',
      'username',
      'host',
      'publicKey',
      'secret',
      'passphrase',
      'notes',
      'device',
    ]) {
      if (map.containsKey(key) || msg[key] == null) continue;
      // Root `secret` may be the nested fields map — never treat that as the value.
      if (key == 'secret' && msg[key] is Map) continue;
      map[key] = msg[key];
    }
    return map;
  }

  Future<Map<String, dynamic>> _createSecretFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final secrets = _secrets;
    if (secrets == null) {
      return {'ok': false, 'error': 'Secrets not available'};
    }
    try {
      final fields = _secretFields(msg);
      final value = fields['secret']?.toString() ?? '';
      final name = fields['name']?.toString().trim() ?? '';
      if (value.isEmpty) {
        return {'ok': false, 'error': 'Secret value required'};
      }
      if (name.isEmpty) {
        return {'ok': false, 'error': 'Name required'};
      }
      final kind = SecretKind.fromName(
        fields['kind']?.toString() ?? fields['secretKind']?.toString(),
      );
      final secret = DevSecret(
        uuid: const Uuid().v4(),
        name: name,
        kind: kind,
        username: fields['username']?.toString() ?? '',
        host: fields['host']?.toString() ?? '',
        publicKey: fields['publicKey']?.toString() ?? '',
        secret: value,
        passphrase: fields['passphrase']?.toString() ?? '',
        notes: fields['notes']?.toString() ?? '',
        device: fields['device']?.toString() ?? '',
      );
      final result = await secrets.createSecret(secret);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to create secret'},
        (created) async => {'ok': true, 'secret': _secretJson(created)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost createSecret failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _updateSecretFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final secrets = _secrets;
    if (secrets == null) {
      return {'ok': false, 'error': 'Secrets not available'};
    }
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final existingResult = await secrets.getSecret(uuid);
      final existing = existingResult.fold((_) => null, (s) => s);
      if (existing == null) {
        return {'ok': false, 'error': 'Not found'};
      }
      final fields = _secretFields(msg);
      final name = fields.containsKey('name')
          ? (fields['name']?.toString().trim() ?? '')
          : existing.name;
      if (name.isEmpty) {
        return {'ok': false, 'error': 'Name required'};
      }
      final kind = fields.containsKey('kind') || fields.containsKey('secretKind')
          ? SecretKind.fromName(
              fields['kind']?.toString() ?? fields['secretKind']?.toString(),
            )
          : existing.kind;
      final value = fields.containsKey('secret')
          ? (fields['secret']?.toString() ?? '')
          : existing.secret;
      if (value.isEmpty) {
        return {'ok': false, 'error': 'Secret value required'};
      }
      final updated = existing.copyWith(
        name: name,
        kind: kind,
        username: fields.containsKey('username')
            ? (fields['username']?.toString() ?? '')
            : existing.username,
        host: fields.containsKey('host')
            ? (fields['host']?.toString() ?? '')
            : existing.host,
        publicKey: fields.containsKey('publicKey')
            ? (fields['publicKey']?.toString() ?? '')
            : existing.publicKey,
        secret: value,
        passphrase: fields.containsKey('passphrase')
            ? (fields['passphrase']?.toString() ?? '')
            : existing.passphrase,
        notes: fields.containsKey('notes')
            ? (fields['notes']?.toString() ?? '')
            : existing.notes,
        device: fields.containsKey('device')
            ? (fields['device']?.toString() ?? '')
            : existing.device,
      );
      final result = await secrets.updateSecret(updated);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to update secret'},
        (saved) async => {'ok': true, 'secret': _secretJson(saved)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost updateSecret failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _deleteSecretFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final secrets = _secrets;
    if (secrets == null) {
      return {'ok': false, 'error': 'Secrets not available'};
    }
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final result = await secrets.deleteSecret(uuid);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to delete secret'},
        (_) async => {'ok': true},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost deleteSecret failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Map<String, dynamic> _nestedFields(
    Map<String, dynamic> msg,
    String nestedKey,
    List<String> keys,
  ) {
    final raw = msg[nestedKey];
    final map = <String, dynamic>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        map[key.toString()] = value;
      });
    }
    for (final key in keys) {
      if (map.containsKey(key) || msg[key] == null) continue;
      if (key == nestedKey && msg[key] is Map) continue;
      map[key] = msg[key];
    }
    return map;
  }

  Future<Map<String, dynamic>> _createCardFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final wallets = _wallets;
    if (wallets == null) {
      return {'ok': false, 'error': 'Cards not available'};
    }
    try {
      final fields = _nestedFields(msg, 'card', [
        'name',
        'holder',
        'number',
        'expiry',
        'cvc',
        'brand',
        'notes',
        'bank',
      ]);
      final name = fields['name']?.toString().trim() ?? '';
      final number = fields['number']?.toString() ?? '';
      if (name.isEmpty && number.trim().isEmpty) {
        return {'ok': false, 'error': 'Name or number required'};
      }
      final card = WalletCard(
        uuid: const Uuid().v4(),
        name: name.isEmpty ? 'Card' : name,
        holder: fields['holder']?.toString() ?? '',
        number: number,
        expiry: fields['expiry']?.toString() ?? '',
        cvc: fields['cvc']?.toString() ?? '',
        brand: (fields['brand']?.toString().trim().isNotEmpty ?? false)
            ? CardBrand.fromName(fields['brand']?.toString())
            : CardBrand.detect(number),
        notes: fields['notes']?.toString() ?? '',
        bank: fields['bank']?.toString() ?? '',
      );
      final result = await wallets.createCard(card);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to create card'},
        (created) async => {'ok': true, 'card': _cardJson(created)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost createCard failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _updateCardFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final wallets = _wallets;
    if (wallets == null) {
      return {'ok': false, 'error': 'Cards not available'};
    }
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final existingResult = await wallets.getCard(uuid);
      final existing = existingResult.fold((_) => null, (c) => c);
      if (existing == null) {
        return {'ok': false, 'error': 'Not found'};
      }
      final fields = _nestedFields(msg, 'card', [
        'name',
        'holder',
        'number',
        'expiry',
        'cvc',
        'brand',
        'notes',
        'bank',
      ]);
      final number = fields.containsKey('number')
          ? (fields['number']?.toString() ?? '')
          : existing.number;
      final brandName = fields['brand']?.toString();
      final updated = existing.copyWith(
        name: fields.containsKey('name')
            ? (fields['name']?.toString().trim() ?? existing.name)
            : existing.name,
        holder: fields.containsKey('holder')
            ? (fields['holder']?.toString() ?? '')
            : existing.holder,
        number: number,
        expiry: fields.containsKey('expiry')
            ? (fields['expiry']?.toString() ?? '')
            : existing.expiry,
        cvc: fields.containsKey('cvc')
            ? (fields['cvc']?.toString() ?? '')
            : existing.cvc,
        brand: brandName != null && brandName.trim().isNotEmpty
            ? CardBrand.fromName(brandName)
            : CardBrand.detect(number),
        notes: fields.containsKey('notes')
            ? (fields['notes']?.toString() ?? '')
            : existing.notes,
        bank: fields.containsKey('bank')
            ? (fields['bank']?.toString() ?? '')
            : existing.bank,
      );
      final result = await wallets.updateCard(updated);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to update card'},
        (saved) async => {'ok': true, 'card': _cardJson(saved)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost updateCard failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _deleteCardFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final wallets = _wallets;
    if (wallets == null) {
      return {'ok': false, 'error': 'Cards not available'};
    }
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final result = await wallets.deleteCard(uuid);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to delete card'},
        (_) async => {'ok': true},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost deleteCard failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _createCryptoFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final crypto = _crypto;
    if (crypto == null) {
      return {'ok': false, 'error': 'Crypto wallets not available'};
    }
    try {
      final fields = _nestedFields(msg, 'wallet', [
        'name',
        'network',
        'address',
        'privateKey',
        'seedPhrase',
        'notes',
        'folder',
      ]);
      final name = fields['name']?.toString().trim() ?? '';
      final address = fields['address']?.toString() ?? '';
      if (name.isEmpty && address.trim().isEmpty) {
        return {'ok': false, 'error': 'Name or address required'};
      }
      final wallet = CryptoWallet(
        uuid: const Uuid().v4(),
        name: name.isEmpty ? 'Wallet' : name,
        network: CryptoNetwork.fromName(fields['network']?.toString()),
        address: address,
        privateKey: fields['privateKey']?.toString() ?? '',
        seedPhrase: fields['seedPhrase']?.toString() ?? '',
        notes: fields['notes']?.toString() ?? '',
        folder: fields['folder']?.toString() ?? '',
      );
      final result = await crypto.createWallet(wallet);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to create wallet'},
        (created) async => {'ok': true, 'wallet': _cryptoJson(created)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost createCrypto failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _updateCryptoFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final crypto = _crypto;
    if (crypto == null) {
      return {'ok': false, 'error': 'Crypto wallets not available'};
    }
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final existingResult = await crypto.getWallet(uuid);
      final existing = existingResult.fold((_) => null, (w) => w);
      if (existing == null) {
        return {'ok': false, 'error': 'Not found'};
      }
      final fields = _nestedFields(msg, 'wallet', [
        'name',
        'network',
        'address',
        'privateKey',
        'seedPhrase',
        'notes',
        'folder',
      ]);
      final updated = existing.copyWith(
        name: fields.containsKey('name')
            ? (fields['name']?.toString().trim() ?? existing.name)
            : existing.name,
        network: fields.containsKey('network')
            ? CryptoNetwork.fromName(fields['network']?.toString())
            : existing.network,
        address: fields.containsKey('address')
            ? (fields['address']?.toString() ?? '')
            : existing.address,
        privateKey: fields.containsKey('privateKey')
            ? (fields['privateKey']?.toString() ?? '')
            : existing.privateKey,
        seedPhrase: fields.containsKey('seedPhrase')
            ? (fields['seedPhrase']?.toString() ?? '')
            : existing.seedPhrase,
        notes: fields.containsKey('notes')
            ? (fields['notes']?.toString() ?? '')
            : existing.notes,
        folder: fields.containsKey('folder')
            ? (fields['folder']?.toString() ?? '')
            : existing.folder,
      );
      final result = await crypto.updateWallet(updated);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to update wallet'},
        (saved) async => {'ok': true, 'wallet': _cryptoJson(saved)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost updateCrypto failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _deleteCryptoFromMessage(
    Map<String, dynamic> msg,
  ) async {
    final crypto = _crypto;
    if (crypto == null) {
      return {'ok': false, 'error': 'Crypto wallets not available'};
    }
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final result = await crypto.deleteWallet(uuid);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to delete wallet'},
        (_) async => {'ok': true},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost deleteCrypto failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Map<String, dynamic> _loginFields(Map<String, dynamic> msg) {
    final raw = msg['entry'];
    final map = <String, dynamic>{};
    if (raw is Map) {
      raw.forEach((key, value) {
        map[key.toString()] = value;
      });
    }
    final urlsRaw = map['urls'];
    final urls = urlsRaw is List
        ? urlsRaw.map((e) => e.toString()).where((u) => u.isNotEmpty).toList()
        : <String>[];
    PasskeyPayload? passkey;
    final passkeyRaw = map['passkey'];
    if (passkeyRaw is Map) {
      passkey = PasskeyPayload.fromJson(
        Map<String, dynamic>.from(
          passkeyRaw.map((k, v) => MapEntry(k.toString(), v)),
        ),
      );
    }
    return {
      'title': map['title']?.toString() ?? '',
      'username': map['username']?.toString() ?? '',
      'password': map['password']?.toString() ?? '',
      'urls': urls,
      'notes': map['notes']?.toString() ?? '',
      'passkey': passkey,
      'icon': map['icon']?.toString() ?? '',
    };
  }

  Future<Map<String, dynamic>> _createEntryFromMessage(
    Map<String, dynamic> msg,
  ) async {
    try {
      final fields = _loginFields(msg);
      final password = fields['password'] as String;
      final passkey = fields['passkey'] as PasskeyPayload?;
      if (password.isEmpty && passkey == null) {
        return {'ok': false, 'error': 'Password or passkey required'};
      }
      final title = (fields['title'] as String).trim();
      final icon = (fields['icon'] as String).trim();
      final entry = VaultEntry(
        uuid: const Uuid().v4(),
        title: title.isEmpty ? (passkey?.rpId ?? 'Login') : title,
        username: (fields['username'] as String).trim().isNotEmpty
            ? (fields['username'] as String).trim()
            : (passkey?.userName ?? ''),
        password: password,
        urls: List<String>.from(fields['urls'] as List),
        notes: fields['notes'] as String,
        passkey: passkey,
        icon: icon,
      );
      final result = await _entries.createEntry(entry);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to create entry'},
        (created) async => {'ok': true, 'entry': _entryJson(created)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost createEntry failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _updateEntryFromMessage(
    Map<String, dynamic> msg,
  ) async {
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final fields = _loginFields(msg);
      final password = fields['password'] as String;
      final passkey = fields['passkey'] as PasskeyPayload?;
      final existingResult = await _entries.getEntry(uuid);
      final existing = existingResult.fold((_) => null, (e) => e);
      if (existing == null) {
        return {'ok': false, 'error': 'Not found'};
      }
      final title = (fields['title'] as String).trim();
      final urls = List<String>.from(fields['urls'] as List);
      final username = (fields['username'] as String).trim();
      final icon = (fields['icon'] as String).trim();
      final updated = existing.copyWith(
        title: title.isEmpty ? existing.title : title,
        username: username.isEmpty ? existing.username : username,
        password: password.isEmpty ? existing.password : password,
        urls: urls.isEmpty ? existing.urls : urls,
        passkey: passkey ?? existing.passkey,
        icon: icon.isEmpty ? existing.icon : icon,
      );
      final result = await _entries.updateEntry(updated);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to update entry'},
        (saved) async => {'ok': true, 'entry': _entryJson(saved)},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost updateEntry failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _deleteEntryFromMessage(
    Map<String, dynamic> msg,
  ) async {
    try {
      final uuid = msg['uuid']?.toString() ?? '';
      if (uuid.isEmpty) {
        return {'ok': false, 'error': 'Missing uuid'};
      }
      final result = await _entries.deleteEntry(uuid);
      return await result.fold(
        (_) async => {'ok': false, 'error': 'Failed to delete entry'},
        (_) async => {'ok': true},
      );
    } catch (e, st) {
      okDebugLog('NativeMessagingHost deleteEntry failed: $e\n$st');
      return {'ok': false, 'error': 'Request failed'};
    }
  }

  Future<Map<String, dynamic>> _updatePasskeySignCount(
    Map<String, dynamic> msg,
  ) async {
    final uuid = msg['uuid']?.toString() ?? '';
    final signCount = msg['signCount'];
    final count = signCount is int
        ? signCount
        : int.tryParse(signCount?.toString() ?? '');
    if (uuid.isEmpty || count == null) {
      return {'ok': false, 'error': 'Missing uuid or signCount'};
    }
    final saved = await bumpPasskeySignCount(
      _entries,
      uuid: uuid,
      signCount: count,
    );
    if (saved == null) {
      return {'ok': false, 'error': 'Not found'};
    }
    return {'ok': true, 'entry': _entryJson(saved)};
  }

  List<VaultEntry> _matchOrigin(List<VaultEntry> entries, String origin) {
    return matchByOrigin(
      candidates: entries,
      origin: origin,
      urlsOf: (e) => e.urls,
      idOf: (e) => e.uuid,
    );
  }

  Map<String, dynamic> _entryJson(VaultEntry e, {bool list = false}) =>
      nativeEntryJson(e, list: list);
}
