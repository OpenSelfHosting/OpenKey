import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class TagFilterSheet extends StatefulWidget {
  const TagFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showMEBottomSheet<void>(
      context: context,
      builder: (_) => const TagFilterSheet(),
    );
  }

  @override
  State<TagFilterSheet> createState() => _TagFilterSheetState();
}

class _TagFilterSheetState extends State<TagFilterSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.of(context.read<EntryBloc>().state.filterTags);
  }

  void _toggle(String tag) {
    setState(() {
      if (_selected.contains(tag)) {
        _selected.remove(tag);
      } else {
        _selected.add(tag);
      }
    });
    context.read<EntryBloc>().add(EntryTagFilterChanged(List.of(_selected)));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16,
      ),
      child: BlocBuilder<EntryBloc, EntryState>(
        buildWhen: (p, c) => p.entries != c.entries,
        builder: (context, state) {
          final tags = state.availableTags;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(s.tags, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (tags.isEmpty)
                MEEmptyState(
                  icon: Icons.tag,
                  title: Text(s.noTags),
                  message: Text(s.noTagsMessage),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final tag = tags[index];
                      final selected = _selected.contains(tag);
                      return ActionItem(
                        title: tag,
                        selected: selected,
                        icon: ExpressiveIconContainer(
                          size: 40,
                          backgroundColor: scheme.primary
                              .withValues(alpha: selected ? 0.2 : 0.1),
                          child: Icon(
                            Icons.tag,
                            size: 18,
                            color: scheme.primary,
                          ),
                        ),
                        trailing: Checkbox(
                          value: selected,
                          shape: const CircleBorder(),
                          onChanged: (_) => _toggle(tag),
                        ),
                        onTap: () => _toggle(tag),
                        itemPosition:
                            ItemPosition.fromIndex(index, tags.length),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
