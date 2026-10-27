import 'package:flutter/material.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';

/// Optional fields the user can add to [EntryEditorPage].
///
/// Title is always shown and is not part of this enum.
enum EntryEditorField {
  username,
  email,
  password,
  website,
  androidApp,
  phone,
  pin,
  number,
  card,
  address,
  ipAddress,
  walletAddress,
  dateYmd,
  dateYm,
  recoveryCodes,
  text,
  notes,
  tags,
  totp,
  passkey,
  attachments;

  /// Default fields for a brand-new entry (ordered).
  static const List<EntryEditorField> defaults = [
    EntryEditorField.username,
    EntryEditorField.password,
  ];

  /// Stable catalog order used when appending newly added fields.
  static const List<EntryEditorField> displayOrder = [
    EntryEditorField.username,
    EntryEditorField.email,
    EntryEditorField.password,
    EntryEditorField.website,
    EntryEditorField.androidApp,
    EntryEditorField.phone,
    EntryEditorField.pin,
    EntryEditorField.number,
    EntryEditorField.card,
    EntryEditorField.address,
    EntryEditorField.ipAddress,
    EntryEditorField.walletAddress,
    EntryEditorField.dateYmd,
    EntryEditorField.dateYm,
    EntryEditorField.recoveryCodes,
    EntryEditorField.text,
    EntryEditorField.notes,
    EntryEditorField.tags,
    EntryEditorField.totp,
    EntryEditorField.passkey,
    EntryEditorField.attachments,
  ];

  /// Stored under `VaultEntry.fields` instead of first-class payload keys.
  bool get isExtra => switch (this) {
        EntryEditorField.email ||
        EntryEditorField.phone ||
        EntryEditorField.pin ||
        EntryEditorField.number ||
        EntryEditorField.card ||
        EntryEditorField.address ||
        EntryEditorField.ipAddress ||
        EntryEditorField.walletAddress ||
        EntryEditorField.dateYmd ||
        EntryEditorField.dateYm ||
        EntryEditorField.recoveryCodes ||
        EntryEditorField.text =>
          true,
        _ => false,
      };

  bool get isSensitive => switch (this) {
        EntryEditorField.password ||
        EntryEditorField.pin ||
        EntryEditorField.card ||
        EntryEditorField.recoveryCodes =>
          true,
        _ => false,
      };

  bool get isMultiline => switch (this) {
        EntryEditorField.address ||
        EntryEditorField.recoveryCodes ||
        EntryEditorField.text ||
        EntryEditorField.notes =>
          true,
        _ => false,
      };

  bool get isDateField =>
      this == EntryEditorField.dateYmd || this == EntryEditorField.dateYm;

  /// Payload / order key.
  String get storageKey => name;

  static EntryEditorField? byName(String key) {
    for (final field in values) {
      if (field.name == key) return field;
    }
    return null;
  }

  static EntryEditorField? fromStorageKey(String key) {
    final field = byName(key);
    if (field == null || !field.isExtra) return null;
    return field;
  }

  /// Fields that should appear when editing an existing entry (unordered).
  static Set<EntryEditorField> presentIn(VaultEntry entry) {
    final fields = <EntryEditorField>{...defaults};
    if (entry.username.isNotEmpty) fields.add(EntryEditorField.username);
    if (entry.password.isNotEmpty) fields.add(EntryEditorField.password);
    final hasWeb = entry.urls.any((u) => !u.startsWith('androidapp://'));
    final hasApp = entry.urls.any((u) => u.startsWith('androidapp://'));
    if (hasWeb) fields.add(EntryEditorField.website);
    if (hasApp) fields.add(EntryEditorField.androidApp);
    if (entry.urls.isNotEmpty && !hasWeb && !hasApp) {
      fields.add(EntryEditorField.website);
    }
    if (entry.notes.trim().isNotEmpty) fields.add(EntryEditorField.notes);
    if (entry.tags.isNotEmpty) fields.add(EntryEditorField.tags);
    if (entry.totp != null && !entry.totp!.isEmpty) {
      fields.add(EntryEditorField.totp);
    }
    if (entry.passkey != null) fields.add(EntryEditorField.passkey);
    if (entry.attachments.isNotEmpty) fields.add(EntryEditorField.attachments);
    for (final extra in entry.fields) {
      if (extra.isEmpty) continue;
      final mapped = fromStorageKey(extra.type);
      if (mapped != null) fields.add(mapped);
    }
    return fields;
  }

  /// Ordered fields for the editor, respecting [VaultEntry.fieldOrder].
  static List<EntryEditorField> inferOrderedFrom(VaultEntry entry) {
    final present = presentIn(entry);
    final ordered = <EntryEditorField>[];
    for (final key in entry.fieldOrder) {
      final field = byName(key);
      if (field == null || !present.contains(field)) continue;
      if (!ordered.contains(field)) ordered.add(field);
    }
    for (final field in displayOrder) {
      if (present.contains(field) && !ordered.contains(field)) {
        ordered.add(field);
      }
    }
    return ordered;
  }

  IconData get icon => switch (this) {
        EntryEditorField.username => Icons.person_outline_rounded,
        EntryEditorField.email => Icons.mail_outline_rounded,
        EntryEditorField.password => Icons.lock_outline_rounded,
        EntryEditorField.website => Icons.link_rounded,
        EntryEditorField.androidApp => Icons.android_rounded,
        EntryEditorField.phone => Icons.phone_outlined,
        EntryEditorField.pin => Icons.pin_outlined,
        EntryEditorField.number => Icons.numbers_rounded,
        EntryEditorField.card => Icons.credit_card_rounded,
        EntryEditorField.address => Icons.home_outlined,
        EntryEditorField.ipAddress => Icons.lan_outlined,
        EntryEditorField.walletAddress => Icons.account_balance_wallet_outlined,
        EntryEditorField.dateYmd => Icons.calendar_today_outlined,
        EntryEditorField.dateYm => Icons.calendar_month_outlined,
        EntryEditorField.recoveryCodes => Icons.vpn_key_outlined,
        EntryEditorField.text => Icons.notes_rounded,
        EntryEditorField.notes => Icons.sticky_note_2_outlined,
        EntryEditorField.tags => Icons.label_outline_rounded,
        EntryEditorField.totp => Icons.phonelink_lock_rounded,
        EntryEditorField.passkey => Icons.key_rounded,
        EntryEditorField.attachments => Icons.attach_file_rounded,
      };

  String label(AppLocalizations s) => switch (this) {
        EntryEditorField.username => s.username,
        EntryEditorField.email => s.email,
        EntryEditorField.password => s.password,
        EntryEditorField.website => s.website,
        EntryEditorField.androidApp => s.androidApp,
        EntryEditorField.phone => s.phone,
        EntryEditorField.pin => s.pin,
        EntryEditorField.number => s.number,
        EntryEditorField.card => s.cardNumber,
        EntryEditorField.address => s.address,
        EntryEditorField.ipAddress => s.ipAddress,
        EntryEditorField.walletAddress => s.walletAddress,
        EntryEditorField.dateYmd => s.dateYmd,
        EntryEditorField.dateYm => s.dateYm,
        EntryEditorField.recoveryCodes => s.recoveryCodes,
        EntryEditorField.text => s.customText,
        EntryEditorField.notes => s.notes,
        EntryEditorField.tags => s.tags,
        EntryEditorField.totp => s.authenticatorTotp,
        EntryEditorField.passkey => s.passkey,
        EntryEditorField.attachments => s.attachments,
      };

  TextInputType? get keyboardType => switch (this) {
        EntryEditorField.email => TextInputType.emailAddress,
        EntryEditorField.website => TextInputType.url,
        EntryEditorField.phone => TextInputType.phone,
        EntryEditorField.pin ||
        EntryEditorField.number ||
        EntryEditorField.card =>
          TextInputType.number,
        EntryEditorField.ipAddress => TextInputType.visiblePassword,
        _ => TextInputType.text,
      };
}
