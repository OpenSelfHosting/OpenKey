/// JSON for the browser native-messaging bridge.
///
/// [list] omits attachment ciphertext so Chrome's 1MB native-message cap
/// is not blown. Favicon keys stay (they are already ~64px); only huge
/// user-picked `custom:png:` photos are dropped.
library;

import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';

String nativeListIcon(String icon) {
  if (icon.isEmpty) return icon;
  if (icon.startsWith('custom:favicon:')) return icon;
  if (icon.startsWith('custom:') && icon.length > 12 * 1024) return '';
  return icon;
}

Map<String, dynamic> nativeEntryJson(VaultEntry e, {bool list = false}) {
  final icon = list ? nativeListIcon(e.icon) : e.icon;
  return {
    'uuid': e.uuid,
    'collectionUuid': e.collectionUuid,
    'revision': e.revision,
    'title': e.title,
    'username': e.username,
    'password': e.password,
    'urls': e.urls,
    'notes': e.notes,
    if (e.tags.isNotEmpty) 'tags': e.tags,
    if (e.fields.isNotEmpty)
      'fields': e.fields.map((f) => f.toJson()).toList(),
    if (e.fieldOrder.isNotEmpty) 'fieldOrder': e.fieldOrder,
    if (icon.isNotEmpty) 'icon': icon,
    'totp': e.totp?.toJson(),
    'attachments': e.attachments
        .map(
          (a) => list
              ? {'id': a.id, 'name': a.name, 'size': a.size}
              : a.toJson(),
        )
        .toList(),
    'passkey': e.passkey?.toJson(),
  };
}
