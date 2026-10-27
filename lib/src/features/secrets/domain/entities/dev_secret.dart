import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/database/reserved_collections.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';

/// Reserved collection id for developer secret entries in the encrypted DB.
abstract final class SecretIds {
  static const collectionUuid = ReservedCollections.secrets;

  static bool isReserved(String? id) => id == collectionUuid;
}

enum SecretKind {
  sshKey,
  apiToken,
  envSnippet,
  other;

  String label(BuildContext context) {
    final s = context.s;
    return switch (this) {
      SecretKind.sshKey => s.secretKindSsh,
      SecretKind.apiToken => s.secretKindApiToken,
      SecretKind.envSnippet => s.secretKindEnv,
      SecretKind.other => s.secretKindOther,
    };
  }

  IconData get icon => switch (this) {
        SecretKind.sshKey => Icons.terminal_rounded,
        SecretKind.apiToken => Icons.vpn_key_rounded,
        SecretKind.envSnippet => Icons.data_object_rounded,
        SecretKind.other => Icons.lock_outline_rounded,
      };

  static SecretKind fromName(String? name) {
    final key = name?.toLowerCase().trim() ?? '';
    for (final kind in SecretKind.values) {
      if (kind.name.toLowerCase() == key) return kind;
    }
    return switch (key) {
      'ssh' || 'ssh_key' || 'sshkey' => SecretKind.sshKey,
      'api' || 'token' || 'api_token' || 'apitoken' => SecretKind.apiToken,
      'env' || 'dotenv' || '.env' || 'env_snippet' => SecretKind.envSnippet,
      _ => SecretKind.other,
    };
  }
}

class DevSecret extends Equatable {
  const DevSecret({
    required this.uuid,
    this.name = '',
    this.kind = SecretKind.apiToken,
    this.username = '',
    this.host = '',
    this.publicKey = '',
    this.secret = '',
    this.passphrase = '',
    this.notes = '',
    /// Device / machine label used to group secrets (e.g. hostname from CLI discover).
    this.device = '',
    this.revision = 1,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uuid;
  final String name;
  final SecretKind kind;
  final String username;
  final String host;

  /// SSH public key (optional for other kinds).
  final String publicKey;

  /// Private key, API token, or `.env` body.
  final String secret;
  final String passphrase;
  final String notes;

  /// Logical device collection inside Secrets (hostname or custom label).
  final String device;
  final int revision;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    return switch (kind) {
      SecretKind.sshKey => 'SSH key',
      SecretKind.apiToken => 'API token',
      SecretKind.envSnippet => '.env',
      SecretKind.other => 'Secret',
    };
  }

  /// Group key for UI sections — empty device sorts under a shared bucket.
  String get deviceGroup {
    final d = device.trim();
    return d.isEmpty ? '' : d;
  }

  String listSubtitle(BuildContext context) {
    final parts = <String>[kind.label(context)];
    final hostOrUser = host.trim().isNotEmpty
        ? host.trim()
        : username.trim();
    if (hostOrUser.isNotEmpty) parts.add(hostOrUser);
    return parts.join(' · ');
  }

  String get maskedSecret {
    final value = secret.trim();
    if (value.isEmpty) return '—';
    if (value.length <= 8) return '••••••••';
    return '${value.substring(0, 4)}…${value.substring(value.length - 4)}';
  }

  bool get hasSecret => secret.trim().isNotEmpty;

  DevSecret copyWith({
    String? uuid,
    String? name,
    SecretKind? kind,
    String? username,
    String? host,
    String? publicKey,
    String? secret,
    String? passphrase,
    String? notes,
    String? device,
    int? revision,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DevSecret(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      username: username ?? this.username,
      host: host ?? this.host,
      publicKey: publicKey ?? this.publicKey,
      secret: secret ?? this.secret,
      passphrase: passphrase ?? this.passphrase,
      notes: notes ?? this.notes,
      device: device ?? this.device,
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toPayload() => {
        'type': 'secret',
        'name': name,
        'kind': kind.name,
        'username': username,
        'host': host,
        'publicKey': publicKey,
        'secret': secret,
        'passphrase': passphrase,
        'notes': notes,
        if (device.trim().isNotEmpty) 'device': device.trim(),
      };

  factory DevSecret.fromPayload({
    required String uuid,
    required Map<String, dynamic> payload,
    int revision = 1,
    bool isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DevSecret(
      uuid: uuid,
      name: payload['name']?.toString() ?? '',
      kind: SecretKind.fromName(payload['kind']?.toString()),
      username: payload['username']?.toString() ?? '',
      host: payload['host']?.toString() ?? '',
      publicKey: payload['publicKey']?.toString() ?? '',
      secret: payload['secret']?.toString() ??
          payload['privateKey']?.toString() ??
          payload['token']?.toString() ??
          '',
      passphrase: payload['passphrase']?.toString() ?? '',
      notes: payload['notes']?.toString() ?? '',
      device: payload['device']?.toString() ?? '',
      revision: revision,
      isSynced: isSynced,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uuid,
        name,
        kind,
        username,
        host,
        publicKey,
        secret,
        passphrase,
        notes,
        device,
        revision,
      ];
}
