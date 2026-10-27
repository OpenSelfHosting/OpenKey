import 'package:flutter/material.dart';
import 'package:openkey_app/src/features/vault/domain/entities/custom_icons.dart';
import 'package:openkey_app/src/features/vault/domain/entities/entry_icons.dart';
import 'package:openkey_app/src/features/vault/domain/entities/material_icon_catalog.dart';

/// Collection icon keys share the [EntryIcons] catalog / suggestions.
///
/// Default is a folder glyph. Legacy `brand:*` keys render through the same
/// Simple Icons SVGs as entries ([EntryIcons.legacyBrandSvg]).
class CollectionIcons {
  CollectionIcons._();

  static const defaultKey = 'material:folder';

  static bool isBrand(String key) => EntryIcons.isBrand(key);

  static bool isCustom(String key) => CustomIcons.isCustom(key);

  static bool needsBackdrop(String key) => EntryIcons.needsBackdrop(key);

  static IconData resolveMaterial(String key) {
    if (key.isEmpty) {
      return MaterialIconCatalog.resolve(
        defaultKey,
        fallback: Icons.folder_rounded,
      );
    }
    return MaterialIconCatalog.resolve(key, fallback: Icons.folder_rounded);
  }

  static Iterable<String> get materialKeys => EntryIcons.materialKeys;

  static List<String> searchMaterial(String query) =>
      EntryIcons.searchMaterial(query);

  static Future<String> suggest({String name = ''}) =>
      EntryIcons.suggest(title: name, fetchFavicon: false);
}
