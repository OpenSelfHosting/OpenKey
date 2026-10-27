import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openkey_app/src/src.dart';

class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({super.key, required this.breadcrumb});

  final List<VaultCollection> breadcrumb;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: s.root,
              isCurrent: breadcrumb.isEmpty,
              onTap: () {
                context
                    .read<CollectionBloc>()
                    .add(const CollectionNavigateBreadcrumb(-1));
              },
            ),
            for (var i = 0; i < breadcrumb.length; i++) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              _Chip(
                label: breadcrumb[i].name,
                isCurrent: i == breadcrumb.length - 1,
                onTap: i == breadcrumb.length - 1
                    ? null
                    : () {
                        context
                            .read<CollectionBloc>()
                            .add(CollectionNavigateBreadcrumb(i));
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isCurrent,
    this.onTap,
  });

  final String label;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isCurrent ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: isCurrent
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
