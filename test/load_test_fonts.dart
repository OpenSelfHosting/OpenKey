import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

bool _fontsLoaded = false;

/// Loads Roboto and Material Icons so golden / screenshot tests render text and icons.
Future<void> loadTestFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;

  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await materialIcons.load();

  final sdkFontsDir = _resolveMaterialFontsDir();
  if (sdkFontsDir == null) {
    return;
  }

  final roboto = FontLoader('Roboto');
  for (final name in [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
    'Roboto-Italic.ttf',
    'Roboto-Light.ttf',
  ]) {
    final file = File('$sdkFontsDir/$name');
    if (file.existsSync()) {
      roboto.addFont(_loadFile(file));
    }
  }
  await roboto.load();
}

Future<ByteData> _loadFile(File file) async {
  final bytes = await file.readAsBytes();
  return ByteData.sublistView(Uint8List.fromList(bytes));
}

String? _resolveMaterialFontsDir() {
  final envRoot = Platform.environment['FLUTTER_ROOT'];
  if (envRoot != null) {
    final dir = '$envRoot/bin/cache/artifacts/material_fonts';
    if (Directory(dir).existsSync()) return dir;
  }

  for (final path in [
    '/opt/flutter/bin/cache/artifacts/material_fonts',
  ]) {
    if (Directory(path).existsSync()) return path;
  }

  final exe = Platform.resolvedExecutable;
  final cacheDir = File(exe).parent.parent.parent;
  final dir = '${cacheDir.path}/artifacts/material_fonts';
  if (Directory(dir).existsSync()) return dir;

  return null;
}
