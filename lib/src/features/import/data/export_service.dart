import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:kpasslib/kpasslib.dart';
import 'package:openkey_app/src/src.dart';
import 'package:uuid/uuid.dart';

enum ExportFormat {
  openKeyJson,
  bitwardenJson,
  chromeCsv,
  lastPassCsv,
  onePasswordCsv,
  keePassKdbx,
}

class ExportService {
  ExportService(this._collections, this._entries);

  final CollectionRepository _collections;
  final EntryRepository _entries;
  final _uuid = const Uuid();

  static const openKeyFormat = 'openkey';
  static const openKeyVersion = 1;

  /// Builds an export file as bytes (UTF-8 for text formats; binary for `.kdbx`).
  ///
  /// [keePassPassword] / [keePassKeyFile] are required only for
  /// [ExportFormat.keePassKdbx] (empty password is allowed).
  FutureFailureOr<Uint8List> buildExport(
    ExportFormat format, {
    String? keePassPassword,
    Uint8List? keePassKeyFile,
  }) async {
    try {
      final collectionsResult = await _collections.getCollections();
      final entriesResult = await _entries.getEntries(collectionUuid: '__all__');

      AppFailure? failure;
      List<VaultCollection>? collections;
      List<VaultEntry>? entries;
      collectionsResult.fold((f) => failure = f, (c) => collections = c);
      if (failure != null) return Left(failure!);
      entriesResult.fold((f) => failure = f, (e) => entries = e);
      if (failure != null) return Left(failure!);

      final cols = collections!;
      final ents = entries!;
      final folderByUuid = {for (final c in cols) c.uuid: c.name};

      final Uint8List bytes;
      switch (format) {
        case ExportFormat.openKeyJson:
          bytes = Uint8List.fromList(
            utf8.encode(_toOpenKeyJson(cols, ents)),
          );
        case ExportFormat.bitwardenJson:
          bytes = Uint8List.fromList(
            utf8.encode(_toBitwardenJson(ents, folderByUuid)),
          );
        case ExportFormat.chromeCsv:
          bytes = Uint8List.fromList(utf8.encode(_toChromeCsv(ents)));
        case ExportFormat.lastPassCsv:
          bytes = Uint8List.fromList(
            utf8.encode(_toLastPassCsv(ents, folderByUuid)),
          );
        case ExportFormat.onePasswordCsv:
          bytes = Uint8List.fromList(utf8.encode(_toOnePasswordCsv(ents)));
        case ExportFormat.keePassKdbx:
          bytes = await _toKeePassKdbx(
            collections: cols,
            entries: ents,
            password: keePassPassword ?? '',
            keyFile: keePassKeyFile,
          );
      }
      return Right(bytes);
    } catch (e) {
      return Left(FailureMessage(e.toString()));
    }
  }

  String fileName(ExportFormat format) {
    final stamp = DateTime.now().toIso8601String().split('T').first;
    return switch (format) {
      ExportFormat.openKeyJson => 'openkey-backup-$stamp.json',
      ExportFormat.bitwardenJson => 'openkey-export-$stamp.json',
      ExportFormat.chromeCsv => 'openkey-chrome-$stamp.csv',
      ExportFormat.lastPassCsv => 'openkey-lastpass-$stamp.csv',
      ExportFormat.onePasswordCsv => 'openkey-1password-$stamp.csv',
      ExportFormat.keePassKdbx => 'openkey-keepass-$stamp.kdbx',
    };
  }

  String extension(ExportFormat format) => switch (format) {
        ExportFormat.openKeyJson || ExportFormat.bitwardenJson => 'json',
        ExportFormat.chromeCsv ||
        ExportFormat.lastPassCsv ||
        ExportFormat.onePasswordCsv =>
          'csv',
        ExportFormat.keePassKdbx => 'kdbx',
      };

  String _toOpenKeyJson(
    List<VaultCollection> collections,
    List<VaultEntry> entries,
  ) {
    return const JsonEncoder.withIndent('  ').convert({
      'format': openKeyFormat,
      'version': openKeyVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'collections': [
        for (final c in collections)
          {
            'uuid': c.uuid,
            'name': c.name,
            'icon': c.icon,
            if (c.color != null) 'color': c.color,
            if (c.parentUuid != null) 'parentUuid': c.parentUuid,
            'sortOrder': c.sortOrder,
          },
      ],
      'entries': [
        for (final e in entries) _openKeyEntry(e),
      ],
    });
  }

  Map<String, dynamic> _openKeyEntry(VaultEntry e) {
    // Attachment blobs live outside the entry payload and are keyed to the
    // current vault key — omit them from portable backups.
    final payload = e.toPayload()..remove('attachments');
    return {
      'uuid': e.uuid,
      if (e.collectionUuid != null) 'collectionUuid': e.collectionUuid,
      ...payload,
    };
  }

  String _toBitwardenJson(
    List<VaultEntry> entries,
    Map<String, String> folderByUuid,
  ) {
    final folders = <Map<String, dynamic>>[];
    final folderIdByUuid = <String, String>{};
    for (final entry in folderByUuid.entries) {
      final id = _uuid.v4();
      folderIdByUuid[entry.key] = id;
      folders.add({'id': id, 'name': entry.value});
    }

    final items = <Map<String, dynamic>>[];
    for (final entry in entries) {
      final uris = entry.urls
          .where((u) => u.trim().isNotEmpty)
          .map((u) => {'uri': u})
          .toList();
      final totp = entry.totp;
      items.add({
        'id': entry.uuid,
        'name': entry.title,
        'notes': entry.notes,
        'type': 1,
        if (entry.collectionUuid != null &&
            folderIdByUuid.containsKey(entry.collectionUuid))
          'folderId': folderIdByUuid[entry.collectionUuid],
        'login': {
          'username': entry.username,
          'password': entry.password,
          if (uris.isNotEmpty) 'uris': uris,
          if (totp != null && !totp.isEmpty) 'totp': _otpAuthUri(entry),
        },
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'encrypted': false,
      'folders': folders,
      'items': items,
    });
  }

  String _toChromeCsv(List<VaultEntry> entries) {
    final rows = <List<dynamic>>[
      ['name', 'url', 'username', 'password', 'note'],
      for (final e in entries)
        [
          e.title,
          e.urls.isEmpty ? '' : e.urls.first,
          e.username,
          e.password,
          e.notes,
        ],
    ];
    return const ListToCsvConverter().convert(rows);
  }

  /// LastPass CSV columns match the import parser:
  /// `url,username,password,totp,extra,name,grouping,fav`.
  String _toLastPassCsv(
    List<VaultEntry> entries,
    Map<String, String> folderByUuid,
  ) {
    final rows = <List<dynamic>>[
      ['url', 'username', 'password', 'totp', 'extra', 'name', 'grouping', 'fav'],
      for (final e in entries)
        [
          e.urls.isEmpty ? '' : e.urls.first,
          e.username,
          e.password,
          (e.totp != null && !e.totp!.isEmpty) ? _otpAuthUri(e) : '',
          e.notes,
          e.title,
          e.collectionUuid == null
              ? ''
              : (folderByUuid[e.collectionUuid] ?? ''),
          '0',
        ],
    ];
    return const ListToCsvConverter().convert(rows);
  }

  String _toOnePasswordCsv(List<VaultEntry> entries) {
    final rows = <List<dynamic>>[
      ['title', 'username', 'password', 'url', 'notes', 'otpauth'],
      for (final e in entries)
        [
          e.title,
          e.username,
          e.password,
          e.urls.isEmpty ? '' : e.urls.first,
          e.notes,
          (e.totp != null && !e.totp!.isEmpty) ? _otpAuthUri(e) : '',
        ],
    ];
    return const ListToCsvConverter().convert(rows);
  }

  Future<Uint8List> _toKeePassKdbx({
    required List<VaultCollection> collections,
    required List<VaultEntry> entries,
    required String password,
    Uint8List? keyFile,
  }) async {
    final credentials = KdbxCredentials(
      password: ProtectedData.fromString(password),
      keyData: keyFile,
    );
    final db = KdbxDatabase.create(credentials: credentials, name: 'OpenKey');
    final byUuid = {for (final c in collections) c.uuid: c};
    final groups = <String, KdbxGroup>{};

    KdbxGroup groupFor(String? collectionUuid) {
      if (collectionUuid == null || !byUuid.containsKey(collectionUuid)) {
        return db.root;
      }
      final existing = groups[collectionUuid];
      if (existing != null) return existing;

      final collection = byUuid[collectionUuid]!;
      final parent = groupFor(collection.parentUuid);
      final created = db.createGroup(
        parent: parent,
        name: collection.name.isEmpty ? 'Folder' : collection.name,
      );
      groups[collectionUuid] = created;
      return created;
    }

    for (final entry in entries) {
      final parent = groupFor(entry.collectionUuid);
      final kdbxEntry = db.createEntry(parent: parent);
      kdbxEntry.fields['Title'] = KdbxTextField.fromText(text: entry.title);
      kdbxEntry.fields['UserName'] =
          KdbxTextField.fromText(text: entry.username);
      kdbxEntry.fields['Password'] = KdbxTextField.fromText(
        text: entry.password,
        protected: true,
      );
      if (entry.urls.isNotEmpty) {
        kdbxEntry.fields['URL'] =
            KdbxTextField.fromText(text: entry.urls.first);
      }
      if (entry.notes.isNotEmpty) {
        kdbxEntry.fields['Notes'] = KdbxTextField.fromText(text: entry.notes);
      }
      final totp = entry.totp;
      if (totp != null && !totp.isEmpty) {
        kdbxEntry.fields['otp'] = KdbxTextField.fromText(
          text: _otpAuthUri(entry),
          protected: true,
        );
      }
    }

    final saved = await db.save();
    return Uint8List.fromList(saved);
  }

  String _otpAuthUri(VaultEntry entry) {
    final totp = entry.totp;
    if (totp == null || totp.isEmpty) return '';
    final label = Uri.encodeComponent(
      entry.username.isNotEmpty ? entry.username : entry.title,
    );
    final params = <String, String>{
      'secret': totp.secret.replaceAll(' ', ''),
      'issuer': 'OpenKey',
      if (totp.period != 30) 'period': '${totp.period}',
      if (totp.digits != 6) 'digits': '${totp.digits}',
      if (totp.algorithm.toUpperCase() != 'SHA1')
        'algorithm': totp.algorithm.toUpperCase(),
    };
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return 'otpauth://totp/$label?$query';
  }
}
