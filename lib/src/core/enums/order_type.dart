import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_collection.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';
import 'package:openkey_app/src/features/crypto/domain/entities/crypto_wallet.dart';
import 'package:openkey_app/src/features/secrets/domain/entities/dev_secret.dart';
import 'package:openkey_app/src/features/wallets/domain/entities/wallet_card.dart';

enum OrderType {
  byCreationTime,
  byLastModified,
  byName,
  byCustomOrder;

  String getName(BuildContext context) {
    final s = context.s;
    return switch (this) {
      OrderType.byCreationTime => s.sortByCreationTime,
      OrderType.byLastModified => s.sortByLastModified,
      OrderType.byName => s.sortByName,
      OrderType.byCustomOrder => s.sortByCustomOrder,
    };
  }

  void sortCollections(List<VaultCollection> collections, bool reverse) {
    collections.sort((a, b) => _compareCollections(a, b, reverse));
  }

  void sortEntries(List<VaultEntry> entries, bool reverse) {
    entries.sort((a, b) => _compareEntries(a, b, reverse));
  }

  void sortWalletCards(List<WalletCard> cards, bool reverse) {
    cards.sort((a, b) => _compareWalletCards(a, b, reverse));
  }

  void sortCryptoWallets(List<CryptoWallet> wallets, bool reverse) {
    wallets.sort((a, b) => _compareCryptoWallets(a, b, reverse));
  }

  void sortDevSecrets(List<DevSecret> secrets, bool reverse) {
    secrets.sort((a, b) => _compareDevSecrets(a, b, reverse));
  }

  int _compareNullableDates(DateTime? a, DateTime? b) {
    final left = a ?? DateTime.fromMillisecondsSinceEpoch(0);
    final right = b ?? DateTime.fromMillisecondsSinceEpoch(0);
    return left.compareTo(right);
  }

  int _compareCollections(VaultCollection a, VaultCollection b, bool reverse) {
    var compare = switch (this) {
      OrderType.byCreationTime => _compareNullableDates(a.createdAt, b.createdAt),
      OrderType.byLastModified => _compareNullableDates(a.updatedAt, b.updatedAt),
      OrderType.byName => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      OrderType.byCustomOrder => a.sortOrder.compareTo(b.sortOrder),
    };
    if (compare == 0) {
      compare = a.uuid.compareTo(b.uuid);
    }
    return reverse ? -compare : compare;
  }

  int _compareEntries(VaultEntry a, VaultEntry b, bool reverse) {
    // Entries have no sortOrder column yet — custom falls back to creation time.
    var compare = switch (this) {
      OrderType.byCreationTime ||
      OrderType.byCustomOrder =>
        _compareNullableDates(a.createdAt, b.createdAt),
      OrderType.byLastModified => _compareNullableDates(a.updatedAt, b.updatedAt),
      OrderType.byName => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
    if (compare == 0) {
      compare = a.uuid.compareTo(b.uuid);
    }
    return reverse ? -compare : compare;
  }

  int _compareWalletCards(WalletCard a, WalletCard b, bool reverse) {
    var compare = switch (this) {
      OrderType.byCreationTime ||
      OrderType.byCustomOrder =>
        _compareNullableDates(a.createdAt, b.createdAt),
      OrderType.byLastModified => _compareNullableDates(a.updatedAt, b.updatedAt),
      OrderType.byName =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    };
    if (compare == 0) {
      compare = a.uuid.compareTo(b.uuid);
    }
    return reverse ? -compare : compare;
  }

  int _compareCryptoWallets(CryptoWallet a, CryptoWallet b, bool reverse) {
    var compare = switch (this) {
      OrderType.byCreationTime ||
      OrderType.byCustomOrder =>
        _compareNullableDates(a.createdAt, b.createdAt),
      OrderType.byLastModified => _compareNullableDates(a.updatedAt, b.updatedAt),
      OrderType.byName =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    };
    if (compare == 0) {
      compare = a.uuid.compareTo(b.uuid);
    }
    return reverse ? -compare : compare;
  }

  int _compareDevSecrets(DevSecret a, DevSecret b, bool reverse) {
    var compare = switch (this) {
      OrderType.byCreationTime ||
      OrderType.byCustomOrder =>
        _compareNullableDates(a.createdAt, b.createdAt),
      OrderType.byLastModified => _compareNullableDates(a.updatedAt, b.updatedAt),
      OrderType.byName =>
        a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
    };
    if (compare == 0) {
      compare = a.uuid.compareTo(b.uuid);
    }
    return reverse ? -compare : compare;
  }
}
