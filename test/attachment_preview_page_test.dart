import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:openkey_app/src/src.dart';

import 'screenshots/screenshot_pump.dart';

void main() {
  group('attachmentKindFor', () {
    test('classifies images, video, audio, text, and other files', () {
      expect(attachmentKindFor('photo.PNG'), AttachmentKind.image);
      expect(attachmentKindFor('clip.mp4'), AttachmentKind.video);
      expect(attachmentKindFor('voice.m4a'), AttachmentKind.audio);
      expect(attachmentKindFor('notes.txt'), AttachmentKind.text);
      expect(attachmentKindFor('secret.pdf'), AttachmentKind.other);
      expect(attachmentKindFor('noext'), AttachmentKind.other);
    });

    test('reads the extension from a path-like name', () {
      expect(attachmentExtension(r'C:\vault\scan.JPEG'), 'jpeg');
      expect(attachmentExtension('folder/inner.webp'), 'webp');
    });

    test('formats byte sizes', () {
      expect(formatAttachmentSize(512), '512 B');
      expect(formatAttachmentSize(2048), '2.0 KB');
      expect(formatAttachmentSize(2 * 1024 * 1024), '2.0 MB');
    });

    test('builds text preview snippets', () {
      final snippet = attachmentTextPreview(
        Uint8List.fromList('hello vault attachment'.codeUnits),
      );
      expect(snippet, 'hello vault attachment');
    });

    test('normalizes attachment names for playback', () {
      expect(
        ensureAttachmentFileName('gallery_video', pathHint: '/sdcard/clip.MP4'),
        'gallery_video.mp4',
      );
      expect(attachmentPlaybackFileName('clip.mp4'), 'clip.mp4');
      expect(attachmentContentType('clip.mp4'), 'video/mp4');
    });
  });

  group('AttachmentPreviewPage', () {
    Uint8List pngBytes() {
      final image = img.Image(width: 8, height: 8);
      img.fill(image, color: img.ColorRgb8(0, 128, 255));
      return Uint8List.fromList(img.encodePng(image));
    }

    Future<void> pumpPreview(
      WidgetTester tester, {
      required String name,
      required Uint8List bytes,
      Future<bool> Function(String name, Uint8List bytes)? onSave,
      Future<bool> Function(String name, Uint8List bytes)? onOpen,
    }) async {
      await tester.pumpWidget(
        screenshotMaterialApp(
          brightness: Brightness.light,
          surfaceSize: const Size(390, 844),
          child: AttachmentPreviewPage(
            name: name,
            bytes: bytes,
            onSave: onSave,
            onOpen: onOpen,
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('shows a zoomable image and download action', (tester) async {
      var saved = false;
      await pumpPreview(
        tester,
        name: 'id.png',
        bytes: pngBytes(),
        onSave: (name, bytes) async {
          saved = true;
          expect(name, 'id.png');
          expect(bytes, isNotEmpty);
          return true;
        },
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      await tester.tap(find.byTooltip('Download'));
      await tester.pump();
      expect(saved, isTrue);
      expect(find.text('id.png saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    });

    testWidgets('shows play and download for videos', (tester) async {
      var opened = false;
      var saved = false;
      await pumpPreview(
        tester,
        name: 'clip.mp4',
        bytes: Uint8List.fromList([0, 1, 2, 3, 4]),
        onOpen: (name, bytes) async {
          opened = true;
          return true;
        },
        onSave: (name, bytes) async {
          saved = true;
          return true;
        },
      );

      expect(find.text('Play video'), findsOneWidget);
      await tester.tap(find.text('Play video'));
      await tester.pump();
      expect(opened, isTrue);

      await tester.tap(find.text('Download').last);
      await tester.pump();
      expect(saved, isTrue);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
    });

    testWidgets('renders text attachments as selectable text', (tester) async {
      await pumpPreview(
        tester,
        name: 'note.txt',
        bytes: Uint8List.fromList('hello vault'.codeUnits),
      );

      expect(find.text('hello vault'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('offers open and download when preview is unavailable', (
      tester,
    ) async {
      var opened = false;
      await pumpPreview(
        tester,
        name: 'secret.pdf',
        bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
        onOpen: (name, bytes) async {
          opened = true;
          return true;
        },
      );

      expect(find.textContaining("Preview isn't available"), findsOneWidget);
      await tester.tap(find.text('Open'));
      await tester.pump();
      expect(opened, isTrue);
    });
  });
}
