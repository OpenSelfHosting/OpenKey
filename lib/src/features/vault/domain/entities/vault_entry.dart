import 'package:equatable/equatable.dart';

class TotpConfig extends Equatable {
  const TotpConfig({
    required this.secret,
    this.period = 30,
    this.digits = 6,
    this.algorithm = 'SHA1',
  });

  final String secret;
  final int period;
  final int digits;
  final String algorithm;

  Map<String, dynamic> toJson() => {
        'secret': secret,
        'period': period,
        'digits': digits,
        'algorithm': algorithm,
      };

  factory TotpConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TotpConfig(secret: '');
    }
    return TotpConfig(
      secret: json['secret']?.toString() ?? '',
      period: json['period'] as int? ?? 30,
      digits: json['digits'] as int? ?? 6,
      algorithm: json['algorithm']?.toString() ?? 'SHA1',
    );
  }

  bool get isEmpty => secret.isEmpty;

  @override
  List<Object?> get props => [secret, period, digits, algorithm];
}

class AttachmentMeta extends Equatable {
  const AttachmentMeta({
    required this.id,
    required this.name,
    required this.size,
    this.cipher,
  });

  final String id;
  final String name;
  final int size;
  final String? cipher;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'size': size,
        if (cipher != null) 'cipher': cipher,
      };

  factory AttachmentMeta.fromJson(Map<String, dynamic> json) {
    return AttachmentMeta(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      size: json['size'] as int? ?? 0,
      cipher: json['cipher']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, name, size, cipher];
}

class PasskeyPayload extends Equatable {
  const PasskeyPayload({
    required this.rpId,
    required this.credentialId,
    this.userHandle,
    this.privateKeyCipher,
    this.publicKey,
    this.alg,
    this.signCount,
    this.userName,
    this.displayName,
  });

  final String rpId;
  final String credentialId;
  final String? userHandle;

  /// PKCS8 private key (base64url), protected by outer vault encryption.
  final String? privateKeyCipher;

  /// COSE_Key public key (base64url CBOR).
  final String? publicKey;

  /// COSE algorithm identifier; default -7 (ES256).
  final int? alg;

  /// Signature counter.
  final int? signCount;
  final String? userName;
  final String? displayName;

  Map<String, dynamic> toJson() => {
        'rpId': rpId,
        'credentialId': credentialId,
        if (userHandle != null) 'userHandle': userHandle,
        if (privateKeyCipher != null) 'privateKeyCipher': privateKeyCipher,
        if (publicKey != null) 'publicKey': publicKey,
        if (alg != null) 'alg': alg,
        if (signCount != null) 'signCount': signCount,
        if (userName != null) 'userName': userName,
        if (displayName != null) 'displayName': displayName,
      };

  factory PasskeyPayload.fromJson(Map<String, dynamic> json) {
    return PasskeyPayload(
      rpId: json['rpId']?.toString() ?? '',
      credentialId: json['credentialId']?.toString() ?? '',
      userHandle: json['userHandle']?.toString(),
      privateKeyCipher: json['privateKeyCipher']?.toString(),
      publicKey: json['publicKey']?.toString(),
      alg: json['alg'] is int
          ? json['alg'] as int
          : int.tryParse(json['alg']?.toString() ?? ''),
      signCount: json['signCount'] is int
          ? json['signCount'] as int
          : int.tryParse(json['signCount']?.toString() ?? ''),
      userName: json['userName']?.toString(),
      displayName: json['displayName']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        rpId,
        credentialId,
        userHandle,
        privateKeyCipher,
        publicKey,
        alg,
        signCount,
        userName,
        displayName,
      ];
}

/// Extra typed field on a login entry (email, phone, PIN, …).
class EntryExtraField extends Equatable {
  const EntryExtraField({
    required this.type,
    required this.value,
  });

  /// Stable type key, e.g. `email`, `phone`, `pin`.
  final String type;
  final String value;

  bool get isEmpty => value.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
      };

  factory EntryExtraField.fromJson(Map<String, dynamic> json) {
    return EntryExtraField(
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  EntryExtraField copyWith({String? type, String? value}) {
    return EntryExtraField(
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [type, value];
}

class VaultEntry extends Equatable {
  const VaultEntry({
    required this.uuid,
    required this.title,
    this.collectionUuid,
    this.username = '',
    this.password = '',
    this.urls = const [],
    this.notes = '',
    this.tags = const [],
    this.fields = const [],
    this.fieldOrder = const [],
    this.icon = '',
    this.totp,
    this.attachments = const [],
    this.passkey,
    this.revision = 1,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uuid;
  final String? collectionUuid;
  final String title;
  final String username;
  final String password;
  final List<String> urls;
  final String notes;
  final List<String> tags;
  final List<EntryExtraField> fields;
  /// Ordered optional field keys (`username`, `email`, …) for the editor UI.
  final List<String> fieldOrder;
  /// Icon key: `material:*`, `brands/*.svg`, or empty (auto-suggest).
  final String icon;
  final TotpConfig? totp;
  final List<AttachmentMeta> attachments;
  final PasskeyPayload? passkey;
  final int revision;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// True when OS autofill / origin fill should offer this login.
  bool get isAutofillFillable =>
      username.isNotEmpty ||
      password.isNotEmpty ||
      (passkey?.privateKeyCipher?.isNotEmpty ?? false);

  String? fieldValue(String type) {
    for (final field in fields) {
      if (field.type == type) return field.value;
    }
    return null;
  }

  VaultEntry copyWith({
    String? uuid,
    String? collectionUuid,
    String? title,
    String? username,
    String? password,
    List<String>? urls,
    String? notes,
    List<String>? tags,
    List<EntryExtraField>? fields,
    List<String>? fieldOrder,
    String? icon,
    TotpConfig? totp,
    List<AttachmentMeta>? attachments,
    PasskeyPayload? passkey,
    int? revision,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCollection = false,
    bool clearTotp = false,
    bool clearPasskey = false,
  }) {
    return VaultEntry(
      uuid: uuid ?? this.uuid,
      collectionUuid:
          clearCollection ? null : (collectionUuid ?? this.collectionUuid),
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      urls: urls ?? this.urls,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      fields: fields ?? this.fields,
      fieldOrder: fieldOrder ?? this.fieldOrder,
      icon: icon ?? this.icon,
      totp: clearTotp ? null : (totp ?? this.totp),
      attachments: attachments ?? this.attachments,
      passkey: clearPasskey ? null : (passkey ?? this.passkey),
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toPayload() => {
        'title': title,
        'username': username,
        'password': password,
        'urls': urls,
        'notes': notes,
        if (tags.isNotEmpty) 'tags': tags,
        if (fields.isNotEmpty)
          'fields': fields.map((f) => f.toJson()).toList(),
        if (fieldOrder.isNotEmpty) 'fieldOrder': fieldOrder,
        if (icon.isNotEmpty) 'icon': icon,
        if (totp != null && !totp!.isEmpty) 'totp': totp!.toJson(),
        if (attachments.isNotEmpty)
          'attachments': attachments.map((a) => a.toJson()).toList(),
        if (passkey != null) 'passkey': passkey!.toJson(),
      };

  factory VaultEntry.fromPayload({
    required String uuid,
    String? collectionUuid,
    required Map<String, dynamic> payload,
    int revision = 1,
    bool isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final totpJson = payload['totp'];
    final passkeyJson = payload['passkey'];
    final attachmentsJson = payload['attachments'] as List?;
    final tagsJson = payload['tags'] as List?;
    final fieldsJson = payload['fields'] as List?;
    final fieldOrderJson = payload['fieldOrder'] as List?;
    return VaultEntry(
      uuid: uuid,
      collectionUuid: collectionUuid,
      title: payload['title']?.toString() ?? '',
      username: payload['username']?.toString() ?? '',
      password: payload['password']?.toString() ?? '',
      urls: (payload['urls'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      notes: payload['notes']?.toString() ?? '',
      tags: tagsJson?.map((e) => e.toString()).toList() ?? const [],
      fields: fieldsJson
              ?.whereType<Map>()
              .map((e) => EntryExtraField.fromJson(Map<String, dynamic>.from(e)))
              .where((f) => f.type.isNotEmpty)
              .toList() ??
          const [],
      fieldOrder:
          fieldOrderJson?.map((e) => e.toString()).toList() ?? const [],
      icon: payload['icon']?.toString() ?? '',
      totp: totpJson is Map<String, dynamic>
          ? TotpConfig.fromJson(totpJson)
          : null,
      attachments: attachmentsJson
              ?.whereType<Map>()
              .map((e) => AttachmentMeta.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
      passkey: passkeyJson is Map<String, dynamic>
          ? PasskeyPayload.fromJson(passkeyJson)
          : null,
      revision: revision,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uuid,
        collectionUuid,
        title,
        username,
        password,
        urls,
        notes,
        tags,
        fields,
        fieldOrder,
        icon,
        totp,
        attachments,
        passkey,
        revision,
      ];
}
