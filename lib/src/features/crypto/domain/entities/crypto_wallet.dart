import 'package:equatable/equatable.dart';
import 'package:openkey_app/src/core/database/reserved_collections.dart';

/// Reserved collection id for crypto wallet entries in the encrypted DB.
abstract final class CryptoIds {
  static const collectionUuid = ReservedCollections.crypto;

  static bool isReserved(String? id) => id == collectionUuid;
}

enum CryptoNetwork {
  bitcoin,
  ethereum,
  solana,
  litecoin,
  monero,
  polygon,
  bnb,
  other;

  String get label => switch (this) {
        CryptoNetwork.bitcoin => 'Bitcoin',
        CryptoNetwork.ethereum => 'Ethereum',
        CryptoNetwork.solana => 'Solana',
        CryptoNetwork.litecoin => 'Litecoin',
        CryptoNetwork.monero => 'Monero',
        CryptoNetwork.polygon => 'Polygon',
        CryptoNetwork.bnb => 'BNB Chain',
        CryptoNetwork.other => 'Other',
      };

  String get symbol => switch (this) {
        CryptoNetwork.bitcoin => 'BTC',
        CryptoNetwork.ethereum => 'ETH',
        CryptoNetwork.solana => 'SOL',
        CryptoNetwork.litecoin => 'LTC',
        CryptoNetwork.monero => 'XMR',
        CryptoNetwork.polygon => 'MATIC',
        CryptoNetwork.bnb => 'BNB',
        CryptoNetwork.other => 'CRYPTO',
      };

  static CryptoNetwork fromName(String? name) {
    final key = name?.toLowerCase().trim() ?? '';
    for (final network in CryptoNetwork.values) {
      if (network.name == key ||
          network.label.toLowerCase() == key ||
          network.symbol.toLowerCase() == key) {
        return network;
      }
    }
    return CryptoNetwork.other;
  }
}

class CryptoWallet extends Equatable {
  const CryptoWallet({
    required this.uuid,
    this.name = '',
    this.network = CryptoNetwork.bitcoin,
    this.address = '',
    this.privateKey = '',
    this.seedPhrase = '',
    this.notes = '',
    /// Logical folder used to group wallets (e.g. "Cold storage").
    this.folder = '',
    this.revision = 1,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uuid;
  final String name;
  final CryptoNetwork network;
  final String address;
  final String privateKey;
  final String seedPhrase;
  final String notes;

  /// Logical folder inside Crypto.
  final String folder;
  final int revision;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName =>
      name.trim().isNotEmpty ? name.trim() : network.label;

  /// Group key for UI sections — empty folder sorts under a shared bucket.
  String get folderGroup {
    final f = folder.trim();
    return f.isEmpty ? '' : f;
  }

  String get maskedAddress {
    final value = address.trim();
    if (value.length <= 10) return value.isEmpty ? '—' : value;
    return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
  }

  bool get hasSecrets =>
      privateKey.trim().isNotEmpty || seedPhrase.trim().isNotEmpty;

  CryptoWallet copyWith({
    String? uuid,
    String? name,
    CryptoNetwork? network,
    String? address,
    String? privateKey,
    String? seedPhrase,
    String? notes,
    String? folder,
    int? revision,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CryptoWallet(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      network: network ?? this.network,
      address: address ?? this.address,
      privateKey: privateKey ?? this.privateKey,
      seedPhrase: seedPhrase ?? this.seedPhrase,
      notes: notes ?? this.notes,
      folder: folder ?? this.folder,
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toPayload() => {
        'type': 'crypto',
        'name': name,
        'network': network.name,
        'address': address,
        'privateKey': privateKey,
        'seedPhrase': seedPhrase,
        'notes': notes,
        if (folder.trim().isNotEmpty) 'folder': folder.trim(),
      };

  factory CryptoWallet.fromPayload({
    required String uuid,
    required Map<String, dynamic> payload,
    int revision = 1,
    bool isSynced = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CryptoWallet(
      uuid: uuid,
      name: payload['name']?.toString() ?? '',
      network: CryptoNetwork.fromName(payload['network']?.toString()),
      address: payload['address']?.toString() ?? '',
      privateKey: payload['privateKey']?.toString() ?? '',
      seedPhrase: payload['seedPhrase']?.toString() ?? '',
      notes: payload['notes']?.toString() ?? '',
      folder: payload['folder']?.toString() ?? '',
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
        network,
        address,
        privateKey,
        seedPhrase,
        notes,
        folder,
        revision,
      ];
}
