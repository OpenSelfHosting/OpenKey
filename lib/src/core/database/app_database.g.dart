// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountTableTable extends AccountTable
    with TableInfo<$AccountTableTable, AccountTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
    'salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kdfParamsMeta = const VerificationMeta(
    'kdfParams',
  );
  @override
  late final GeneratedColumn<String> kdfParams = GeneratedColumn<String>(
    'kdf_params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrappedVaultKeyMeta = const VerificationMeta(
    'wrappedVaultKey',
  );
  @override
  late final GeneratedColumn<String> wrappedVaultKey = GeneratedColumn<String>(
    'wrapped_vault_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverUserIdMeta = const VerificationMeta(
    'serverUserId',
  );
  @override
  late final GeneratedColumn<String> serverUserId = GeneratedColumn<String>(
    'server_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta(
    'accessToken',
  );
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    salt,
    kdfParams,
    wrappedVaultKey,
    serverUserId,
    accessToken,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    } else if (isInserting) {
      context.missing(_saltMeta);
    }
    if (data.containsKey('kdf_params')) {
      context.handle(
        _kdfParamsMeta,
        kdfParams.isAcceptableOrUnknown(data['kdf_params']!, _kdfParamsMeta),
      );
    } else if (isInserting) {
      context.missing(_kdfParamsMeta);
    }
    if (data.containsKey('wrapped_vault_key')) {
      context.handle(
        _wrappedVaultKeyMeta,
        wrappedVaultKey.isAcceptableOrUnknown(
          data['wrapped_vault_key']!,
          _wrappedVaultKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wrappedVaultKeyMeta);
    }
    if (data.containsKey('server_user_id')) {
      context.handle(
        _serverUserIdMeta,
        serverUserId.isAcceptableOrUnknown(
          data['server_user_id']!,
          _serverUserIdMeta,
        ),
      );
    }
    if (data.containsKey('access_token')) {
      context.handle(
        _accessTokenMeta,
        accessToken.isAcceptableOrUnknown(
          data['access_token']!,
          _accessTokenMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salt'],
      )!,
      kdfParams: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kdf_params'],
      )!,
      wrappedVaultKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wrapped_vault_key'],
      )!,
      serverUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_user_id'],
      ),
      accessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AccountTableTable createAlias(String alias) {
    return $AccountTableTable(attachedDatabase, alias);
  }
}

class AccountTableData extends DataClass
    implements Insertable<AccountTableData> {
  final int id;
  final String email;
  final String salt;
  final String kdfParams;
  final String wrappedVaultKey;
  final String? serverUserId;
  final String? accessToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AccountTableData({
    required this.id,
    required this.email,
    required this.salt,
    required this.kdfParams,
    required this.wrappedVaultKey,
    this.serverUserId,
    this.accessToken,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['email'] = Variable<String>(email);
    map['salt'] = Variable<String>(salt);
    map['kdf_params'] = Variable<String>(kdfParams);
    map['wrapped_vault_key'] = Variable<String>(wrappedVaultKey);
    if (!nullToAbsent || serverUserId != null) {
      map['server_user_id'] = Variable<String>(serverUserId);
    }
    if (!nullToAbsent || accessToken != null) {
      map['access_token'] = Variable<String>(accessToken);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AccountTableCompanion toCompanion(bool nullToAbsent) {
    return AccountTableCompanion(
      id: Value(id),
      email: Value(email),
      salt: Value(salt),
      kdfParams: Value(kdfParams),
      wrappedVaultKey: Value(wrappedVaultKey),
      serverUserId: serverUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUserId),
      accessToken: accessToken == null && nullToAbsent
          ? const Value.absent()
          : Value(accessToken),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AccountTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountTableData(
      id: serializer.fromJson<int>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      salt: serializer.fromJson<String>(json['salt']),
      kdfParams: serializer.fromJson<String>(json['kdfParams']),
      wrappedVaultKey: serializer.fromJson<String>(json['wrappedVaultKey']),
      serverUserId: serializer.fromJson<String?>(json['serverUserId']),
      accessToken: serializer.fromJson<String?>(json['accessToken']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'email': serializer.toJson<String>(email),
      'salt': serializer.toJson<String>(salt),
      'kdfParams': serializer.toJson<String>(kdfParams),
      'wrappedVaultKey': serializer.toJson<String>(wrappedVaultKey),
      'serverUserId': serializer.toJson<String?>(serverUserId),
      'accessToken': serializer.toJson<String?>(accessToken),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AccountTableData copyWith({
    int? id,
    String? email,
    String? salt,
    String? kdfParams,
    String? wrappedVaultKey,
    Value<String?> serverUserId = const Value.absent(),
    Value<String?> accessToken = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AccountTableData(
    id: id ?? this.id,
    email: email ?? this.email,
    salt: salt ?? this.salt,
    kdfParams: kdfParams ?? this.kdfParams,
    wrappedVaultKey: wrappedVaultKey ?? this.wrappedVaultKey,
    serverUserId: serverUserId.present ? serverUserId.value : this.serverUserId,
    accessToken: accessToken.present ? accessToken.value : this.accessToken,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AccountTableData copyWithCompanion(AccountTableCompanion data) {
    return AccountTableData(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      salt: data.salt.present ? data.salt.value : this.salt,
      kdfParams: data.kdfParams.present ? data.kdfParams.value : this.kdfParams,
      wrappedVaultKey: data.wrappedVaultKey.present
          ? data.wrappedVaultKey.value
          : this.wrappedVaultKey,
      serverUserId: data.serverUserId.present
          ? data.serverUserId.value
          : this.serverUserId,
      accessToken: data.accessToken.present
          ? data.accessToken.value
          : this.accessToken,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountTableData(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('salt: $salt, ')
          ..write('kdfParams: $kdfParams, ')
          ..write('wrappedVaultKey: $wrappedVaultKey, ')
          ..write('serverUserId: $serverUserId, ')
          ..write('accessToken: $accessToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    salt,
    kdfParams,
    wrappedVaultKey,
    serverUserId,
    accessToken,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountTableData &&
          other.id == this.id &&
          other.email == this.email &&
          other.salt == this.salt &&
          other.kdfParams == this.kdfParams &&
          other.wrappedVaultKey == this.wrappedVaultKey &&
          other.serverUserId == this.serverUserId &&
          other.accessToken == this.accessToken &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AccountTableCompanion extends UpdateCompanion<AccountTableData> {
  final Value<int> id;
  final Value<String> email;
  final Value<String> salt;
  final Value<String> kdfParams;
  final Value<String> wrappedVaultKey;
  final Value<String?> serverUserId;
  final Value<String?> accessToken;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AccountTableCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.salt = const Value.absent(),
    this.kdfParams = const Value.absent(),
    this.wrappedVaultKey = const Value.absent(),
    this.serverUserId = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AccountTableCompanion.insert({
    this.id = const Value.absent(),
    required String email,
    required String salt,
    required String kdfParams,
    required String wrappedVaultKey,
    this.serverUserId = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : email = Value(email),
       salt = Value(salt),
       kdfParams = Value(kdfParams),
       wrappedVaultKey = Value(wrappedVaultKey);
  static Insertable<AccountTableData> custom({
    Expression<int>? id,
    Expression<String>? email,
    Expression<String>? salt,
    Expression<String>? kdfParams,
    Expression<String>? wrappedVaultKey,
    Expression<String>? serverUserId,
    Expression<String>? accessToken,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (salt != null) 'salt': salt,
      if (kdfParams != null) 'kdf_params': kdfParams,
      if (wrappedVaultKey != null) 'wrapped_vault_key': wrappedVaultKey,
      if (serverUserId != null) 'server_user_id': serverUserId,
      if (accessToken != null) 'access_token': accessToken,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AccountTableCompanion copyWith({
    Value<int>? id,
    Value<String>? email,
    Value<String>? salt,
    Value<String>? kdfParams,
    Value<String>? wrappedVaultKey,
    Value<String?>? serverUserId,
    Value<String?>? accessToken,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AccountTableCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      salt: salt ?? this.salt,
      kdfParams: kdfParams ?? this.kdfParams,
      wrappedVaultKey: wrappedVaultKey ?? this.wrappedVaultKey,
      serverUserId: serverUserId ?? this.serverUserId,
      accessToken: accessToken ?? this.accessToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (kdfParams.present) {
      map['kdf_params'] = Variable<String>(kdfParams.value);
    }
    if (wrappedVaultKey.present) {
      map['wrapped_vault_key'] = Variable<String>(wrappedVaultKey.value);
    }
    if (serverUserId.present) {
      map['server_user_id'] = Variable<String>(serverUserId.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountTableCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('salt: $salt, ')
          ..write('kdfParams: $kdfParams, ')
          ..write('wrappedVaultKey: $wrappedVaultKey, ')
          ..write('serverUserId: $serverUserId, ')
          ..write('accessToken: $accessToken, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CollectionTableTable extends CollectionTable
    with TableInfo<$CollectionTableTable, CollectionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _encryptedNameMeta = const VerificationMeta(
    'encryptedName',
  );
  @override
  late final GeneratedColumn<String> encryptedName = GeneratedColumn<String>(
    'encrypted_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('material:folder'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentUuidMeta = const VerificationMeta(
    'parentUuid',
  );
  @override
  late final GeneratedColumn<String> parentUuid = GeneratedColumn<String>(
    'parent_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    encryptedName,
    icon,
    color,
    parentUuid,
    sortOrder,
    revision,
    isSynced,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('encrypted_name')) {
      context.handle(
        _encryptedNameMeta,
        encryptedName.isAcceptableOrUnknown(
          data['encrypted_name']!,
          _encryptedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedNameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('parent_uuid')) {
      context.handle(
        _parentUuidMeta,
        parentUuid.isAcceptableOrUnknown(data['parent_uuid']!, _parentUuidMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CollectionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      encryptedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      ),
      parentUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_uuid'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CollectionTableTable createAlias(String alias) {
    return $CollectionTableTable(attachedDatabase, alias);
  }
}

class CollectionTableData extends DataClass
    implements Insertable<CollectionTableData> {
  final int id;
  final String uuid;
  final String encryptedName;
  final String icon;
  final int? color;

  /// Parent folder uuid; null means top-level (root).
  final String? parentUuid;
  final int sortOrder;
  final int revision;
  final bool isSynced;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CollectionTableData({
    required this.id,
    required this.uuid,
    required this.encryptedName,
    required this.icon,
    this.color,
    this.parentUuid,
    required this.sortOrder,
    required this.revision,
    required this.isSynced,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['encrypted_name'] = Variable<String>(encryptedName);
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || parentUuid != null) {
      map['parent_uuid'] = Variable<String>(parentUuid);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['revision'] = Variable<int>(revision);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CollectionTableCompanion toCompanion(bool nullToAbsent) {
    return CollectionTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      encryptedName: Value(encryptedName),
      icon: Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      parentUuid: parentUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(parentUuid),
      sortOrder: Value(sortOrder),
      revision: Value(revision),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CollectionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      encryptedName: serializer.fromJson<String>(json['encryptedName']),
      icon: serializer.fromJson<String>(json['icon']),
      color: serializer.fromJson<int?>(json['color']),
      parentUuid: serializer.fromJson<String?>(json['parentUuid']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      revision: serializer.fromJson<int>(json['revision']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'encryptedName': serializer.toJson<String>(encryptedName),
      'icon': serializer.toJson<String>(icon),
      'color': serializer.toJson<int?>(color),
      'parentUuid': serializer.toJson<String?>(parentUuid),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'revision': serializer.toJson<int>(revision),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CollectionTableData copyWith({
    int? id,
    String? uuid,
    String? encryptedName,
    String? icon,
    Value<int?> color = const Value.absent(),
    Value<String?> parentUuid = const Value.absent(),
    int? sortOrder,
    int? revision,
    bool? isSynced,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CollectionTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    encryptedName: encryptedName ?? this.encryptedName,
    icon: icon ?? this.icon,
    color: color.present ? color.value : this.color,
    parentUuid: parentUuid.present ? parentUuid.value : this.parentUuid,
    sortOrder: sortOrder ?? this.sortOrder,
    revision: revision ?? this.revision,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CollectionTableData copyWithCompanion(CollectionTableCompanion data) {
    return CollectionTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      encryptedName: data.encryptedName.present
          ? data.encryptedName.value
          : this.encryptedName,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      parentUuid: data.parentUuid.present
          ? data.parentUuid.value
          : this.parentUuid,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      revision: data.revision.present ? data.revision.value : this.revision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('encryptedName: $encryptedName, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentUuid: $parentUuid, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('revision: $revision, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    encryptedName,
    icon,
    color,
    parentUuid,
    sortOrder,
    revision,
    isSynced,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.encryptedName == this.encryptedName &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.parentUuid == this.parentUuid &&
          other.sortOrder == this.sortOrder &&
          other.revision == this.revision &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CollectionTableCompanion extends UpdateCompanion<CollectionTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> encryptedName;
  final Value<String> icon;
  final Value<int?> color;
  final Value<String?> parentUuid;
  final Value<int> sortOrder;
  final Value<int> revision;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CollectionTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.encryptedName = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentUuid = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CollectionTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String encryptedName,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.parentUuid = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.revision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       encryptedName = Value(encryptedName);
  static Insertable<CollectionTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? encryptedName,
    Expression<String>? icon,
    Expression<int>? color,
    Expression<String>? parentUuid,
    Expression<int>? sortOrder,
    Expression<int>? revision,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (encryptedName != null) 'encrypted_name': encryptedName,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentUuid != null) 'parent_uuid': parentUuid,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (revision != null) 'revision': revision,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CollectionTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? encryptedName,
    Value<String>? icon,
    Value<int?>? color,
    Value<String?>? parentUuid,
    Value<int>? sortOrder,
    Value<int>? revision,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CollectionTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      encryptedName: encryptedName ?? this.encryptedName,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentUuid: parentUuid ?? this.parentUuid,
      sortOrder: sortOrder ?? this.sortOrder,
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (encryptedName.present) {
      map['encrypted_name'] = Variable<String>(encryptedName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (parentUuid.present) {
      map['parent_uuid'] = Variable<String>(parentUuid.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('encryptedName: $encryptedName, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('parentUuid: $parentUuid, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('revision: $revision, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EntryTableTable extends EntryTable
    with TableInfo<$EntryTableTable, EntryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _collectionUuidMeta = const VerificationMeta(
    'collectionUuid',
  );
  @override
  late final GeneratedColumn<String> collectionUuid = GeneratedColumn<String>(
    'collection_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _encryptedPayloadMeta = const VerificationMeta(
    'encryptedPayload',
  );
  @override
  late final GeneratedColumn<String> encryptedPayload = GeneratedColumn<String>(
    'encrypted_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    collectionUuid,
    encryptedPayload,
    revision,
    isSynced,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('collection_uuid')) {
      context.handle(
        _collectionUuidMeta,
        collectionUuid.isAcceptableOrUnknown(
          data['collection_uuid']!,
          _collectionUuidMeta,
        ),
      );
    }
    if (data.containsKey('encrypted_payload')) {
      context.handle(
        _encryptedPayloadMeta,
        encryptedPayload.isAcceptableOrUnknown(
          data['encrypted_payload']!,
          _encryptedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPayloadMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      collectionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_uuid'],
      ),
      encryptedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_payload'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EntryTableTable createAlias(String alias) {
    return $EntryTableTable(attachedDatabase, alias);
  }
}

class EntryTableData extends DataClass implements Insertable<EntryTableData> {
  final int id;
  final String uuid;
  final String? collectionUuid;

  /// AES-GCM ciphertext of JSON payload (title, username, password, urls, notes).
  final String encryptedPayload;
  final int revision;
  final bool isSynced;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EntryTableData({
    required this.id,
    required this.uuid,
    this.collectionUuid,
    required this.encryptedPayload,
    required this.revision,
    required this.isSynced,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || collectionUuid != null) {
      map['collection_uuid'] = Variable<String>(collectionUuid);
    }
    map['encrypted_payload'] = Variable<String>(encryptedPayload);
    map['revision'] = Variable<int>(revision);
    map['is_synced'] = Variable<bool>(isSynced);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntryTableCompanion toCompanion(bool nullToAbsent) {
    return EntryTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      collectionUuid: collectionUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionUuid),
      encryptedPayload: Value(encryptedPayload),
      revision: Value(revision),
      isSynced: Value(isSynced),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      collectionUuid: serializer.fromJson<String?>(json['collectionUuid']),
      encryptedPayload: serializer.fromJson<String>(json['encryptedPayload']),
      revision: serializer.fromJson<int>(json['revision']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'collectionUuid': serializer.toJson<String?>(collectionUuid),
      'encryptedPayload': serializer.toJson<String>(encryptedPayload),
      'revision': serializer.toJson<int>(revision),
      'isSynced': serializer.toJson<bool>(isSynced),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntryTableData copyWith({
    int? id,
    String? uuid,
    Value<String?> collectionUuid = const Value.absent(),
    String? encryptedPayload,
    int? revision,
    bool? isSynced,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EntryTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    collectionUuid: collectionUuid.present
        ? collectionUuid.value
        : this.collectionUuid,
    encryptedPayload: encryptedPayload ?? this.encryptedPayload,
    revision: revision ?? this.revision,
    isSynced: isSynced ?? this.isSynced,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EntryTableData copyWithCompanion(EntryTableCompanion data) {
    return EntryTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      collectionUuid: data.collectionUuid.present
          ? data.collectionUuid.value
          : this.collectionUuid,
      encryptedPayload: data.encryptedPayload.present
          ? data.encryptedPayload.value
          : this.encryptedPayload,
      revision: data.revision.present ? data.revision.value : this.revision,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('collectionUuid: $collectionUuid, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('revision: $revision, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    collectionUuid,
    encryptedPayload,
    revision,
    isSynced,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.collectionUuid == this.collectionUuid &&
          other.encryptedPayload == this.encryptedPayload &&
          other.revision == this.revision &&
          other.isSynced == this.isSynced &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntryTableCompanion extends UpdateCompanion<EntryTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String?> collectionUuid;
  final Value<String> encryptedPayload;
  final Value<int> revision;
  final Value<bool> isSynced;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const EntryTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.collectionUuid = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.revision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EntryTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.collectionUuid = const Value.absent(),
    required String encryptedPayload,
    this.revision = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       encryptedPayload = Value(encryptedPayload);
  static Insertable<EntryTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? collectionUuid,
    Expression<String>? encryptedPayload,
    Expression<int>? revision,
    Expression<bool>? isSynced,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (collectionUuid != null) 'collection_uuid': collectionUuid,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (revision != null) 'revision': revision,
      if (isSynced != null) 'is_synced': isSynced,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EntryTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String?>? collectionUuid,
    Value<String>? encryptedPayload,
    Value<int>? revision,
    Value<bool>? isSynced,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return EntryTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      collectionUuid: collectionUuid ?? this.collectionUuid,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (collectionUuid.present) {
      map['collection_uuid'] = Variable<String>(collectionUuid.value);
    }
    if (encryptedPayload.present) {
      map['encrypted_payload'] = Variable<String>(encryptedPayload.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('collectionUuid: $collectionUuid, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('revision: $revision, ')
          ..write('isSynced: $isSynced, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PendingSyncTableTable extends PendingSyncTable
    with TableInfo<$PendingSyncTableTable, PendingSyncTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSyncTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityUuidMeta = const VerificationMeta(
    'entityUuid',
  );
  @override
  late final GeneratedColumn<String> entityUuid = GeneratedColumn<String>(
    'entity_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    operationType,
    entityUuid,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_sync_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingSyncTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('entity_uuid')) {
      context.handle(
        _entityUuidMeta,
        entityUuid.isAcceptableOrUnknown(data['entity_uuid']!, _entityUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_entityUuidMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSyncTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSyncTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      entityUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_uuid'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingSyncTableTable createAlias(String alias) {
    return $PendingSyncTableTable(attachedDatabase, alias);
  }
}

class PendingSyncTableData extends DataClass
    implements Insertable<PendingSyncTableData> {
  final int id;
  final String entityType;
  final String operationType;
  final String entityUuid;
  final String payload;
  final DateTime createdAt;
  const PendingSyncTableData({
    required this.id,
    required this.entityType,
    required this.operationType,
    required this.entityUuid,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['operation_type'] = Variable<String>(operationType);
    map['entity_uuid'] = Variable<String>(entityUuid);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingSyncTableCompanion toCompanion(bool nullToAbsent) {
    return PendingSyncTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      operationType: Value(operationType),
      entityUuid: Value(entityUuid),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory PendingSyncTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSyncTableData(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      operationType: serializer.fromJson<String>(json['operationType']),
      entityUuid: serializer.fromJson<String>(json['entityUuid']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'operationType': serializer.toJson<String>(operationType),
      'entityUuid': serializer.toJson<String>(entityUuid),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingSyncTableData copyWith({
    int? id,
    String? entityType,
    String? operationType,
    String? entityUuid,
    String? payload,
    DateTime? createdAt,
  }) => PendingSyncTableData(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    operationType: operationType ?? this.operationType,
    entityUuid: entityUuid ?? this.entityUuid,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingSyncTableData copyWithCompanion(PendingSyncTableCompanion data) {
    return PendingSyncTableData(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      entityUuid: data.entityUuid.present
          ? data.entityUuid.value
          : this.entityUuid,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncTableData(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operationType: $operationType, ')
          ..write('entityUuid: $entityUuid, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    operationType,
    entityUuid,
    payload,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSyncTableData &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.operationType == this.operationType &&
          other.entityUuid == this.entityUuid &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class PendingSyncTableCompanion extends UpdateCompanion<PendingSyncTableData> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> operationType;
  final Value<String> entityUuid;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  const PendingSyncTableCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.operationType = const Value.absent(),
    this.entityUuid = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PendingSyncTableCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String operationType,
    required String entityUuid,
    required String payload,
    this.createdAt = const Value.absent(),
  }) : entityType = Value(entityType),
       operationType = Value(operationType),
       entityUuid = Value(entityUuid),
       payload = Value(payload);
  static Insertable<PendingSyncTableData> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? operationType,
    Expression<String>? entityUuid,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (operationType != null) 'operation_type': operationType,
      if (entityUuid != null) 'entity_uuid': entityUuid,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PendingSyncTableCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? operationType,
    Value<String>? entityUuid,
    Value<String>? payload,
    Value<DateTime>? createdAt,
  }) {
    return PendingSyncTableCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      operationType: operationType ?? this.operationType,
      entityUuid: entityUuid ?? this.entityUuid,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (entityUuid.present) {
      map['entity_uuid'] = Variable<String>(entityUuid.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSyncTableCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('operationType: $operationType, ')
          ..write('entityUuid: $entityUuid, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountTableTable accountTable = $AccountTableTable(this);
  late final $CollectionTableTable collectionTable = $CollectionTableTable(
    this,
  );
  late final $EntryTableTable entryTable = $EntryTableTable(this);
  late final $PendingSyncTableTable pendingSyncTable = $PendingSyncTableTable(
    this,
  );
  late final AccountDao accountDao = AccountDao(this as AppDatabase);
  late final CollectionDao collectionDao = CollectionDao(this as AppDatabase);
  late final EntryDao entryDao = EntryDao(this as AppDatabase);
  late final PendingSyncDao pendingSyncDao = PendingSyncDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accountTable,
    collectionTable,
    entryTable,
    pendingSyncTable,
  ];
}

typedef $$AccountTableTableCreateCompanionBuilder =
    AccountTableCompanion Function({
      Value<int> id,
      required String email,
      required String salt,
      required String kdfParams,
      required String wrappedVaultKey,
      Value<String?> serverUserId,
      Value<String?> accessToken,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AccountTableTableUpdateCompanionBuilder =
    AccountTableCompanion Function({
      Value<int> id,
      Value<String> email,
      Value<String> salt,
      Value<String> kdfParams,
      Value<String> wrappedVaultKey,
      Value<String?> serverUserId,
      Value<String?> accessToken,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AccountTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountTableTable> {
  $$AccountTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kdfParams => $composableBuilder(
    column: $table.kdfParams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wrappedVaultKey => $composableBuilder(
    column: $table.wrappedVaultKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverUserId => $composableBuilder(
    column: $table.serverUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AccountTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountTableTable> {
  $$AccountTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kdfParams => $composableBuilder(
    column: $table.kdfParams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wrappedVaultKey => $composableBuilder(
    column: $table.wrappedVaultKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUserId => $composableBuilder(
    column: $table.serverUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountTableTable> {
  $$AccountTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<String> get kdfParams =>
      $composableBuilder(column: $table.kdfParams, builder: (column) => column);

  GeneratedColumn<String> get wrappedVaultKey => $composableBuilder(
    column: $table.wrappedVaultKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverUserId => $composableBuilder(
    column: $table.serverUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accessToken => $composableBuilder(
    column: $table.accessToken,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AccountTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountTableTable,
          AccountTableData,
          $$AccountTableTableFilterComposer,
          $$AccountTableTableOrderingComposer,
          $$AccountTableTableAnnotationComposer,
          $$AccountTableTableCreateCompanionBuilder,
          $$AccountTableTableUpdateCompanionBuilder,
          (
            AccountTableData,
            BaseReferences<_$AppDatabase, $AccountTableTable, AccountTableData>,
          ),
          AccountTableData,
          PrefetchHooks Function()
        > {
  $$AccountTableTableTableManager(_$AppDatabase db, $AccountTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> salt = const Value.absent(),
                Value<String> kdfParams = const Value.absent(),
                Value<String> wrappedVaultKey = const Value.absent(),
                Value<String?> serverUserId = const Value.absent(),
                Value<String?> accessToken = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AccountTableCompanion(
                id: id,
                email: email,
                salt: salt,
                kdfParams: kdfParams,
                wrappedVaultKey: wrappedVaultKey,
                serverUserId: serverUserId,
                accessToken: accessToken,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String email,
                required String salt,
                required String kdfParams,
                required String wrappedVaultKey,
                Value<String?> serverUserId = const Value.absent(),
                Value<String?> accessToken = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AccountTableCompanion.insert(
                id: id,
                email: email,
                salt: salt,
                kdfParams: kdfParams,
                wrappedVaultKey: wrappedVaultKey,
                serverUserId: serverUserId,
                accessToken: accessToken,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AccountTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountTableTable,
      AccountTableData,
      $$AccountTableTableFilterComposer,
      $$AccountTableTableOrderingComposer,
      $$AccountTableTableAnnotationComposer,
      $$AccountTableTableCreateCompanionBuilder,
      $$AccountTableTableUpdateCompanionBuilder,
      (
        AccountTableData,
        BaseReferences<_$AppDatabase, $AccountTableTable, AccountTableData>,
      ),
      AccountTableData,
      PrefetchHooks Function()
    >;
typedef $$CollectionTableTableCreateCompanionBuilder =
    CollectionTableCompanion Function({
      Value<int> id,
      required String uuid,
      required String encryptedName,
      Value<String> icon,
      Value<int?> color,
      Value<String?> parentUuid,
      Value<int> sortOrder,
      Value<int> revision,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$CollectionTableTableUpdateCompanionBuilder =
    CollectionTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> encryptedName,
      Value<String> icon,
      Value<int?> color,
      Value<String?> parentUuid,
      Value<int> sortOrder,
      Value<int> revision,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CollectionTableTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionTableTable> {
  $$CollectionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedName => $composableBuilder(
    column: $table.encryptedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentUuid => $composableBuilder(
    column: $table.parentUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionTableTable> {
  $$CollectionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedName => $composableBuilder(
    column: $table.encryptedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentUuid => $composableBuilder(
    column: $table.parentUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionTableTable> {
  $$CollectionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get encryptedName => $composableBuilder(
    column: $table.encryptedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get parentUuid => $composableBuilder(
    column: $table.parentUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CollectionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionTableTable,
          CollectionTableData,
          $$CollectionTableTableFilterComposer,
          $$CollectionTableTableOrderingComposer,
          $$CollectionTableTableAnnotationComposer,
          $$CollectionTableTableCreateCompanionBuilder,
          $$CollectionTableTableUpdateCompanionBuilder,
          (
            CollectionTableData,
            BaseReferences<
              _$AppDatabase,
              $CollectionTableTable,
              CollectionTableData
            >,
          ),
          CollectionTableData,
          PrefetchHooks Function()
        > {
  $$CollectionTableTableTableManager(
    _$AppDatabase db,
    $CollectionTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> encryptedName = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> parentUuid = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CollectionTableCompanion(
                id: id,
                uuid: uuid,
                encryptedName: encryptedName,
                icon: icon,
                color: color,
                parentUuid: parentUuid,
                sortOrder: sortOrder,
                revision: revision,
                isSynced: isSynced,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String encryptedName,
                Value<String> icon = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<String?> parentUuid = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CollectionTableCompanion.insert(
                id: id,
                uuid: uuid,
                encryptedName: encryptedName,
                icon: icon,
                color: color,
                parentUuid: parentUuid,
                sortOrder: sortOrder,
                revision: revision,
                isSynced: isSynced,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionTableTable,
      CollectionTableData,
      $$CollectionTableTableFilterComposer,
      $$CollectionTableTableOrderingComposer,
      $$CollectionTableTableAnnotationComposer,
      $$CollectionTableTableCreateCompanionBuilder,
      $$CollectionTableTableUpdateCompanionBuilder,
      (
        CollectionTableData,
        BaseReferences<
          _$AppDatabase,
          $CollectionTableTable,
          CollectionTableData
        >,
      ),
      CollectionTableData,
      PrefetchHooks Function()
    >;
typedef $$EntryTableTableCreateCompanionBuilder =
    EntryTableCompanion Function({
      Value<int> id,
      required String uuid,
      Value<String?> collectionUuid,
      required String encryptedPayload,
      Value<int> revision,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$EntryTableTableUpdateCompanionBuilder =
    EntryTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String?> collectionUuid,
      Value<String> encryptedPayload,
      Value<int> revision,
      Value<bool> isSynced,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$EntryTableTableFilterComposer
    extends Composer<_$AppDatabase, $EntryTableTable> {
  $$EntryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionUuid => $composableBuilder(
    column: $table.collectionUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryTableTable> {
  $$EntryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionUuid => $composableBuilder(
    column: $table.collectionUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryTableTable> {
  $$EntryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get collectionUuid => $composableBuilder(
    column: $table.collectionUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EntryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntryTableTable,
          EntryTableData,
          $$EntryTableTableFilterComposer,
          $$EntryTableTableOrderingComposer,
          $$EntryTableTableAnnotationComposer,
          $$EntryTableTableCreateCompanionBuilder,
          $$EntryTableTableUpdateCompanionBuilder,
          (
            EntryTableData,
            BaseReferences<_$AppDatabase, $EntryTableTable, EntryTableData>,
          ),
          EntryTableData,
          PrefetchHooks Function()
        > {
  $$EntryTableTableTableManager(_$AppDatabase db, $EntryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String?> collectionUuid = const Value.absent(),
                Value<String> encryptedPayload = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntryTableCompanion(
                id: id,
                uuid: uuid,
                collectionUuid: collectionUuid,
                encryptedPayload: encryptedPayload,
                revision: revision,
                isSynced: isSynced,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<String?> collectionUuid = const Value.absent(),
                required String encryptedPayload,
                Value<int> revision = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EntryTableCompanion.insert(
                id: id,
                uuid: uuid,
                collectionUuid: collectionUuid,
                encryptedPayload: encryptedPayload,
                revision: revision,
                isSynced: isSynced,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntryTableTable,
      EntryTableData,
      $$EntryTableTableFilterComposer,
      $$EntryTableTableOrderingComposer,
      $$EntryTableTableAnnotationComposer,
      $$EntryTableTableCreateCompanionBuilder,
      $$EntryTableTableUpdateCompanionBuilder,
      (
        EntryTableData,
        BaseReferences<_$AppDatabase, $EntryTableTable, EntryTableData>,
      ),
      EntryTableData,
      PrefetchHooks Function()
    >;
typedef $$PendingSyncTableTableCreateCompanionBuilder =
    PendingSyncTableCompanion Function({
      Value<int> id,
      required String entityType,
      required String operationType,
      required String entityUuid,
      required String payload,
      Value<DateTime> createdAt,
    });
typedef $$PendingSyncTableTableUpdateCompanionBuilder =
    PendingSyncTableCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> operationType,
      Value<String> entityUuid,
      Value<String> payload,
      Value<DateTime> createdAt,
    });

class $$PendingSyncTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingSyncTableTable> {
  $$PendingSyncTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityUuid => $composableBuilder(
    column: $table.entityUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingSyncTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingSyncTableTable> {
  $$PendingSyncTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityUuid => $composableBuilder(
    column: $table.entityUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingSyncTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingSyncTableTable> {
  $$PendingSyncTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityUuid => $composableBuilder(
    column: $table.entityUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingSyncTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingSyncTableTable,
          PendingSyncTableData,
          $$PendingSyncTableTableFilterComposer,
          $$PendingSyncTableTableOrderingComposer,
          $$PendingSyncTableTableAnnotationComposer,
          $$PendingSyncTableTableCreateCompanionBuilder,
          $$PendingSyncTableTableUpdateCompanionBuilder,
          (
            PendingSyncTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingSyncTableTable,
              PendingSyncTableData
            >,
          ),
          PendingSyncTableData,
          PrefetchHooks Function()
        > {
  $$PendingSyncTableTableTableManager(
    _$AppDatabase db,
    $PendingSyncTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSyncTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSyncTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSyncTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> entityUuid = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingSyncTableCompanion(
                id: id,
                entityType: entityType,
                operationType: operationType,
                entityUuid: entityUuid,
                payload: payload,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String operationType,
                required String entityUuid,
                required String payload,
                Value<DateTime> createdAt = const Value.absent(),
              }) => PendingSyncTableCompanion.insert(
                id: id,
                entityType: entityType,
                operationType: operationType,
                entityUuid: entityUuid,
                payload: payload,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingSyncTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingSyncTableTable,
      PendingSyncTableData,
      $$PendingSyncTableTableFilterComposer,
      $$PendingSyncTableTableOrderingComposer,
      $$PendingSyncTableTableAnnotationComposer,
      $$PendingSyncTableTableCreateCompanionBuilder,
      $$PendingSyncTableTableUpdateCompanionBuilder,
      (
        PendingSyncTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingSyncTableTable,
          PendingSyncTableData
        >,
      ),
      PendingSyncTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountTableTableTableManager get accountTable =>
      $$AccountTableTableTableManager(_db, _db.accountTable);
  $$CollectionTableTableTableManager get collectionTable =>
      $$CollectionTableTableTableManager(_db, _db.collectionTable);
  $$EntryTableTableTableManager get entryTable =>
      $$EntryTableTableTableManager(_db, _db.entryTable);
  $$PendingSyncTableTableTableManager get pendingSyncTable =>
      $$PendingSyncTableTableTableManager(_db, _db.pendingSyncTable);
}
