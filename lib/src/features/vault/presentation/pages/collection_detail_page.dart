import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

/// Deep-link / legacy route: jump into the folder on the vault home.
class CollectionDetailPage extends StatefulWidget {
  const CollectionDetailPage({super.key, required this.uuid});

  final String uuid;

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final collections = context.read<CollectionBloc>().state.allCollections;
      final folder = collections.cast<VaultCollection?>().firstWhere(
            (c) => c?.uuid == widget.uuid,
            orElse: () => null,
          );
      if (folder != null) {
        // Rebuild breadcrumb from parent chain.
        final byId = {for (final c in collections) c.uuid: c};
        final crumb = <VaultCollection>[];
        var cursor = folder.parentUuid;
        while (cursor != null) {
          final parent = byId[cursor];
          if (parent == null) break;
          crumb.insert(0, parent);
          cursor = parent.parentUuid;
        }
        crumb.add(folder);
        context.read<CollectionBloc>().add(const CollectionNavigateBreadcrumb(-1));
        for (final c in crumb) {
          context.read<CollectionBloc>().add(CollectionNavigateToFolder(c));
        }
        // EntryBloc resyncs via VaultHomePage listener on folder change.
      }
      if (mounted) context.go(AppRoutes.vault.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
