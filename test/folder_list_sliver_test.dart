import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/widgets/responsive/responsive.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_collection.dart';
import 'package:openkey_app/src/features/vault/presentation/widgets/collection_item.dart';
import 'package:openkey_app/src/features/vault/presentation/widgets/folder_list_sliver.dart';

import 'screenshots/screenshot_pump.dart';

void main() {
  Widget app({required int count}) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            FolderListSliver(
              itemCount: count,
              itemBuilder: (context, index, position) {
                return ColoredBox(
                  color: Colors.grey,
                  child: Text('$index-${position.name}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> setSize(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(size);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('keeps a grouped list on compact widths', (tester) async {
    await setSize(tester, const Size(400, 800));
    await tester.pumpWidget(app(count: 3));

    expect(find.byType(SliverList), findsOneWidget);
    expect(find.byType(SliverGrid), findsNothing);
    expect(find.text('0-start'), findsOneWidget);
    expect(find.text('1-center'), findsOneWidget);
    expect(find.text('2-end'), findsOneWidget);
  });

  testWidgets('keeps a grouped list on large widths', (tester) async {
    await setSize(tester, const Size(1000, 800));
    await tester.pumpWidget(app(count: 4));

    expect(find.byType(SliverList), findsOneWidget);
    expect(find.byType(SliverGrid), findsNothing);
    expect(find.text('0-start'), findsOneWidget);
    expect(find.text('1-center'), findsOneWidget);
    expect(find.text('3-end'), findsOneWidget);
  });

  testWidgets('centers a capped column when maxWidth is set', (tester) async {
    await setSize(tester, const Size(1400, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              FolderListSliver(
                maxWidth: 960,
                itemCount: 2,
                itemBuilder: (context, index, position) {
                  return ColoredBox(
                    color: Colors.grey,
                    child: Text('$index-${position.name}'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AdaptiveContentWidth), findsNWidgets(2));
    final constrained = tester.widget<ConstrainedBox>(
      find.descendant(
        of: find.byType(AdaptiveContentWidth).first,
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(constrained.constraints.maxWidth, 960);
  });

  testWidgets('folder tiles do not overflow in a wide list', (tester) async {
    await setSize(tester, const Size(1000, 800));
    await tester.pumpWidget(
      screenshotMaterialApp(
        brightness: Brightness.dark,
        surfaceSize: const Size(1000, 800),
        child: CustomScrollView(
          slivers: [
            FolderListSliver(
              itemCount: 5,
              itemBuilder: (context, index, position) {
                return CollectionItem(
                  collection: VaultCollection(
                    uuid: 'f$index',
                    name: 'Folder $index',
                    icon: 'material:folder',
                  ),
                  count: index + 1,
                  position: position,
                );
              },
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Folder 0'), findsOneWidget);
  });
}
