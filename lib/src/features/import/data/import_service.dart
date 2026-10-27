import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:kpasslib/kpasslib.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

class ImportPreviewItem {
  ImportPreviewItem({
    required this.title,
    required this.username,
    required this.password,
    required this.urls,
    this.notes = '',
    this.folder,
    this.collectionUuid,
    this.totp,
    this.tags = const [],
    this.fields = const [],
    this.fieldOrder = const [],
    this.icon = '',
    this.passkey,
  });

  final String title;
  final String username;
  final String password;
  final List<String> urls;
  final String notes;
  final String? folder;
  /// OpenKey backup: source collection uuid (remapped on commit).
  final String? collectionUuid;
  final TotpConfig? totp;
  final List<String> tags;
  final List<EntryExtraField> fields;
  final List<String> fieldOrder;
  final String icon;
  final PasskeyPayload? passkey;
}

class ImportCollectionItem {
  const ImportCollectionItem({
    required this.uuid,
    required this.name,
    this.icon = CollectionIcons.defaultKey,
    this.color,
    this.parentUuid,
    this.sortOrder = 0,
  });

  final String uuid;
  final String name;
  final String icon;
  final int? color;
  final String? parentUuid;
  final int sortOrder;
}

class OpenKeyImportData {
  const OpenKeyImportData({
    required this.collections,
    required this.entries,
  });

  final List<ImportCollectionItem> collections;
  final List<ImportPreviewItem> entries;
}

class ImportService {
  ImportService(this._collections, this._entries, this._totp);

  final CollectionRepository _collections;
  final EntryRepository _entries;
  final TotpService _totp;
  final _uuid = const Uuid();

  OpenKeyImportData parseOpenKeyJson(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final format = data['format']?.toString();
    if (format != ExportService.openKeyFormat) {
      throw FormatException(
        'Not an OpenKey backup (format=${format ?? 'missing'})',
      );
    }

    final collections = <ImportCollectionItem>[];
    for (final item in (data['collections'] as List?) ?? const []) {
      final m = item as Map<String, dynamic>;
      final uuid = m['uuid']?.toString() ?? '';
      if (uuid.isEmpty) continue;
      collections.add(
        ImportCollectionItem(
          uuid: uuid,
          name: m['name']?.toString() ?? '',
          icon: m['icon']?.toString().isNotEmpty == true
              ? m['icon'].toString()
              : CollectionIcons.defaultKey,
          color: m['color'] is int
              ? m['color'] as int
              : int.tryParse(m['color']?.toString() ?? ''),
          parentUuid: m['parentUuid']?.toString(),
          sortOrder: m['sortOrder'] is int
              ? m['sortOrder'] as int
              : int.tryParse(m['sortOrder']?.toString() ?? '') ?? 0,
        ),
      );
    }

    final entries = <ImportPreviewItem>[];
    for (final item in (data['entries'] as List?) ?? const []) {
      final m = Map<String, dynamic>.from(item as Map);
      final totpJson = m['totp'];
      final passkeyJson = m['passkey'];
      final tagsJson = m['tags'] as List?;
      final fieldsJson = m['fields'] as List?;
      final fieldOrderJson = m['fieldOrder'] as List?;
      TotpConfig? totp;
      if (totpJson is Map) {
        totp = TotpConfig.fromJson(Map<String, dynamic>.from(totpJson));
        if (totp.isEmpty) totp = null;
      }
      entries.add(
        ImportPreviewItem(
          title: m['title']?.toString() ?? 'Untitled',
          username: m['username']?.toString() ?? '',
          password: m['password']?.toString() ?? '',
          urls: (m['urls'] as List?)?.map((e) => e.toString()).toList() ??
              const [],
          notes: m['notes']?.toString() ?? '',
          collectionUuid: m['collectionUuid']?.toString(),
          totp: totp,
          tags: tagsJson?.map((e) => e.toString()).toList() ?? const [],
          fields: fieldsJson
                  ?.whereType<Map>()
                  .map(
                    (e) =>
                        EntryExtraField.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .where((f) => f.type.isNotEmpty)
                  .toList() ??
              const [],
          fieldOrder:
              fieldOrderJson?.map((e) => e.toString()).toList() ?? const [],
          icon: m['icon']?.toString() ?? '',
          passkey: passkeyJson is Map
              ? PasskeyPayload.fromJson(Map<String, dynamic>.from(passkeyJson))
              : null,
        ),
      );
    }

    return OpenKeyImportData(collections: collections, entries: entries);
  }

  List<ImportPreviewItem> parseBitwardenJson(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final folders = <String, String>{};
    for (final f in (data['folders'] as List?) ?? const []) {
      final m = f as Map<String, dynamic>;
      folders[m['id']?.toString() ?? ''] = m['name']?.toString() ?? '';
    }
    final items = <ImportPreviewItem>[];
    for (final item in (data['items'] as List?) ?? const []) {
      final m = item as Map<String, dynamic>;
      if (m['type'] != 1) continue; // login
      final login = (m['login'] as Map<String, dynamic>?) ?? {};
      final uris = (login['uris'] as List?)
              ?.map((u) => (u as Map)['uri']?.toString() ?? '')
              .where((u) => u.isNotEmpty)
              .toList() ??
          <String>[];
      TotpConfig? totp;
      final totpRaw = login['totp']?.toString();
      if (totpRaw != null && totpRaw.isNotEmpty) {
        totp = _totp.parseOtpAuth(totpRaw) ??
            TotpConfig(secret: totpRaw.replaceAll(' ', ''));
      }
      items.add(
        ImportPreviewItem(
          title: m['name']?.toString() ?? 'Untitled',
          username: login['username']?.toString() ?? '',
          password: login['password']?.toString() ?? '',
          urls: uris,
          notes: m['notes']?.toString() ?? '',
          folder: folders[m['folderId']?.toString() ?? ''],
          totp: totp,
        ),
      );
    }
    return items;
  }

  List<ImportPreviewItem> parseChromeCsv(String raw) {
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    if (rows.isEmpty) return [];
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    final nameIdx = header.indexOf('name');
    final urlIdx = header.indexOf('url');
    final userIdx = header.indexOf('username');
    final passIdx = header.indexOf('password');
    final noteIdx = header.indexOf('note');
    final items = <ImportPreviewItem>[];
    for (final row in rows.skip(1)) {
      String cell(int i) =>
          (i >= 0 && i < row.length) ? row[i].toString() : '';
      final url = cell(urlIdx);
      items.add(
        ImportPreviewItem(
          title: cell(nameIdx).isEmpty ? url : cell(nameIdx),
          username: cell(userIdx),
          password: cell(passIdx),
          urls: url.isEmpty ? const [] : [url],
          notes: cell(noteIdx),
        ),
      );
    }
    return items;
  }

  /// 1Password CSV export (common columns).
  List<ImportPreviewItem> parseOnePasswordCsv(String raw) {
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    if (rows.isEmpty) return [];
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    int idx(List<String> names) {
      for (final n in names) {
        final i = header.indexOf(n);
        if (i >= 0) return i;
      }
      return -1;
    }

    final titleIdx = idx(['title', 'name']);
    final userIdx = idx(['username', 'user']);
    final passIdx = idx(['password']);
    final urlIdx = idx(['url', 'website']);
    final notesIdx = idx(['notes', 'notesplain']);
    final otpIdx = idx(['otpauth', 'totp']);
    final items = <ImportPreviewItem>[];
    for (final row in rows.skip(1)) {
      String cell(int i) =>
          (i >= 0 && i < row.length) ? row[i].toString() : '';
      final otp = cell(otpIdx);
      items.add(
        ImportPreviewItem(
          title: cell(titleIdx),
          username: cell(userIdx),
          password: cell(passIdx),
          urls: cell(urlIdx).isEmpty ? const [] : [cell(urlIdx)],
          notes: cell(notesIdx),
          totp: otp.isEmpty
              ? null
              : (_totp.parseOtpAuth(otp) ?? TotpConfig(secret: otp)),
        ),
      );
    }
    return items;
  }

  /// LastPass CSV export (`url,username,password,totp,extra,name,grouping,fav`).
  List<ImportPreviewItem> parseLastPassCsv(String raw) {
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    if (rows.isEmpty) return [];
    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    int idx(List<String> names) {
      for (final n in names) {
        final i = header.indexOf(n);
        if (i >= 0) return i;
      }
      return -1;
    }

    final urlIdx = idx(['url', 'website']);
    final userIdx = idx(['username', 'user']);
    final passIdx = idx(['password']);
    final totpIdx = idx(['totp', 'otpauth']);
    final notesIdx = idx(['extra', 'notes', 'notesplain']);
    final nameIdx = idx(['name', 'title']);
    final folderIdx = idx(['grouping', 'folder']);
    final items = <ImportPreviewItem>[];
    for (final row in rows.skip(1)) {
      String cell(int i) =>
          (i >= 0 && i < row.length) ? row[i].toString() : '';
      final url = cell(urlIdx);
      final username = cell(userIdx);
      final password = cell(passIdx);
      final notes = cell(notesIdx);
      final name = cell(nameIdx);
      final folder = cell(folderIdx).trim();
      final otp = cell(totpIdx);
      if (url.isEmpty &&
          username.isEmpty &&
          password.isEmpty &&
          notes.isEmpty &&
          name.isEmpty &&
          otp.isEmpty) {
        continue;
      }
      items.add(
        ImportPreviewItem(
          title: name.isEmpty ? (url.isEmpty ? 'Untitled' : url) : name,
          username: username,
          password: password,
          urls: url.isEmpty ? const [] : [url],
          notes: notes,
          folder: folder.isEmpty ? null : folder,
          totp: otp.isEmpty
              ? null
              : (_totp.parseOtpAuth(otp) ??
                  TotpConfig(secret: otp.replaceAll(' ', ''))),
        ),
      );
    }
    return items;
  }

  /// KeePass / KeePassXC `.kdbx` (v3/v4) — password plus optional key file.
  Future<List<ImportPreviewItem>> parseKeePassKdbx({
    required Uint8List data,
    required String password,
    Uint8List? keyFile,
  }) async {
    final credentials = KdbxCredentials(
      password: ProtectedData.fromString(password),
      keyData: keyFile,
    );
    final db = await KdbxDatabase.fromBytes(
      data: data,
      credentials: credentials,
    );
    final recycleUuid = db.recycleBin?.uuid;
    final items = <ImportPreviewItem>[];
    for (final entry in db.root.allEntries) {
      if (_keePassInRecycleBin(entry, recycleUuid)) continue;
      final title = _keePassField(entry, 'Title');
      final username = _keePassField(entry, 'UserName');
      final passwordValue = _keePassField(entry, 'Password');
      final url = _keePassField(entry, 'URL');
      final notes = _keePassField(entry, 'Notes');
      final otpRaw = _keePassTotpRaw(entry);
      final folder = _keePassFolderPath(entry, db.root);
      items.add(
        ImportPreviewItem(
          title: title.isEmpty
              ? (url.isEmpty ? 'Untitled' : url)
              : title,
          username: username,
          password: passwordValue,
          urls: url.isEmpty ? const [] : [url],
          notes: notes,
          folder: folder,
          totp: otpRaw == null || otpRaw.isEmpty
              ? null
              : (_totp.parseOtpAuth(otpRaw) ??
                  TotpConfig(secret: otpRaw.replaceAll(' ', ''))),
        ),
      );
    }
    return items;
  }

  static String _keePassField(KdbxEntry entry, String name) =>
      entry.fields[name]?.text ?? '';

  static String? _keePassTotpRaw(KdbxEntry entry) {
    const candidates = {
      'otp',
      'otpauth',
      'totp',
      'totp seed',
      'totpseed',
      'time otp',
      'timeotp',
    };
    for (final MapEntry(:key, :value) in entry.fields.entries) {
      if (candidates.contains(key.toLowerCase().trim())) {
        final text = value.text.trim();
        if (text.isNotEmpty) return text;
      }
    }
    return null;
  }

  static bool _keePassInRecycleBin(KdbxEntry entry, KdbxUuid? recycleUuid) {
    if (recycleUuid == null) return false;
    KdbxGroup? g = entry.parent;
    while (g != null) {
      if (g.uuid == recycleUuid) return true;
      g = g.parent;
    }
    return false;
  }

  /// Path under root, e.g. `Work/Servers`. Null when entry is directly in root.
  static String? _keePassFolderPath(KdbxEntry entry, KdbxGroup root) {
    final parts = <String>[];
    KdbxGroup? g = entry.parent;
    while (g != null && g.uuid != root.uuid) {
      final name = g.name.trim();
      if (name.isNotEmpty) parts.add(name);
      g = g.parent;
    }
    if (parts.isEmpty) return null;
    return parts.reversed.join('/');
  }

  FutureFailureOr<int> commitOpenKey(
    OpenKeyImportData data, {
    void Function(int done, int total)? onProgress,
  }) async {
    try {
      final uuidMap = await _ensureOpenKeyCollections(data.collections);
      final items = [
        for (final item in data.entries)
          ImportPreviewItem(
            title: item.title,
            username: item.username,
            password: item.password,
            urls: item.urls,
            notes: item.notes,
            collectionUuid: item.collectionUuid == null
                ? null
                : uuidMap[item.collectionUuid],
            totp: item.totp,
            tags: item.tags,
            fields: item.fields,
            fieldOrder: item.fieldOrder,
            icon: item.icon,
            passkey: item.passkey,
          ),
      ];
      return await _commitEntries(items, onProgress: onProgress);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  FutureFailureOr<int> commit(
    List<ImportPreviewItem> items, {
    void Function(int done, int total)? onProgress,
  }) async {
    try {
      final folderToUuid = <String, String>{};
      final existing = await _collections.getCollections();
      existing.fold((_) {}, (cols) {
        for (final c in cols) {
          folderToUuid[c.name] = c.uuid;
        }
      });

      final prepared = <ImportPreviewItem>[];
      for (final item in items) {
        String? collectionUuid = item.collectionUuid;
        final folder = item.folder?.trim();
        if (folder != null && folder.isNotEmpty) {
          if (!folderToUuid.containsKey(folder)) {
            final created = await _collections.createCollection(
              CreateCollectionParams(name: folder),
            );
            created.fold((_) {}, (c) => folderToUuid[folder] = c.uuid);
          }
          collectionUuid = folderToUuid[folder];
        }
        prepared.add(
          ImportPreviewItem(
            title: item.title,
            username: item.username,
            password: item.password,
            urls: item.urls,
            notes: item.notes,
            collectionUuid: collectionUuid,
            totp: item.totp,
            tags: item.tags,
            fields: item.fields,
            fieldOrder: item.fieldOrder,
            icon: item.icon,
            passkey: item.passkey,
          ),
        );
      }

      return await _commitEntries(prepared, onProgress: onProgress);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  FutureFailureOr<int> _commitEntries(
    List<ImportPreviewItem> items, {
    void Function(int done, int total)? onProgress,
  }) async {
    final total = items.length;
    final entries = <VaultEntry>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final icon = item.icon.isNotEmpty
          ? item.icon
          : await _resolveIconFast(item);
      entries.add(
        VaultEntry(
          uuid: _uuid.v4(),
          collectionUuid: item.collectionUuid,
          title: item.title,
          username: item.username,
          password: item.password,
          urls: item.urls,
          notes: item.notes,
          tags: item.tags,
          fields: item.fields,
          fieldOrder: item.fieldOrder,
          totp: item.totp,
          icon: icon,
          passkey: item.passkey,
        ),
      );
      onProgress?.call(i + 1, total);
    }

    return _entries.createEntries(entries, onProgress: onProgress);
  }

  /// Creates / reuses folders from an OpenKey backup. Returns old→new uuid map.
  Future<Map<String, String>> _ensureOpenKeyCollections(
    List<ImportCollectionItem> collections,
  ) async {
    final uuidMap = <String, String>{};
    if (collections.isEmpty) return uuidMap;

    final existing = await _collections.getCollections();
    final byParentAndName = <String, String>{};
    existing.fold((_) {}, (cols) {
      for (final c in cols) {
        byParentAndName[_folderKey(c.parentUuid, c.name)] = c.uuid;
      }
    });

    final remaining = List<ImportCollectionItem>.from(collections);
    // Parents before children; bounded loops guard against cycles.
    while (remaining.isNotEmpty) {
      final progress = <ImportCollectionItem>[];
      for (final c in remaining) {
        final parentOld = c.parentUuid;
        if (parentOld != null &&
            parentOld.isNotEmpty &&
            !uuidMap.containsKey(parentOld)) {
          // Parent not ready yet (or missing from backup).
          final parentInBackup = collections.any((x) => x.uuid == parentOld);
          if (parentInBackup) continue;
        }
        progress.add(c);
      }
      if (progress.isEmpty) {
        // Cycle / orphan parent — create remaining at root.
        progress.addAll(remaining);
      }

      for (final c in progress) {
        remaining.remove(c);
        final parentNew = c.parentUuid == null || c.parentUuid!.isEmpty
            ? null
            : uuidMap[c.parentUuid];
        final key = _folderKey(parentNew, c.name);
        final existingUuid = byParentAndName[key];
        if (existingUuid != null) {
          uuidMap[c.uuid] = existingUuid;
          continue;
        }
        final created = await _collections.createCollection(
          CreateCollectionParams(
            name: c.name.isEmpty ? 'Folder' : c.name,
            icon: c.icon,
            color: c.color,
            parentUuid: parentNew,
          ),
        );
        created.fold((_) {}, (col) {
          uuidMap[c.uuid] = col.uuid;
          byParentAndName[key] = col.uuid;
        });
      }
    }
    return uuidMap;
  }

  static String _folderKey(String? parentUuid, String name) =>
      '${parentUuid ?? ''}::${name.trim().toLowerCase()}';

  /// Local-only icon hint for bulk import (no network / no PackageManager).
  ///
  /// Returns a brand key when matched, otherwise empty so [ResolvedEntryIcon]
  /// can fetch a favicon later without blocking the import.
  Future<String> _resolveIconFast(ImportPreviewItem item) async {
    var website = '';
    var android = '';
    for (final u in item.urls) {
      if (u.startsWith('androidapp://')) {
        if (android.isEmpty) android = u;
      } else if (website.isEmpty && u.isNotEmpty) {
        website = u;
      }
    }
    final brand = await BrandIconCatalog.matchBrand(
      title: item.title,
      url: website,
      username: item.username,
      extras: [
        if (android.isNotEmpty) android.substring('androidapp://'.length),
      ],
    );
    return brand ?? '';
  }
}
