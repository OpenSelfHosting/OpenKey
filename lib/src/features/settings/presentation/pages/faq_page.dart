import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return MESliverScaffold(
      title: s.faq,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: [
        const SliverToBoxAdapter(
          child: FaqAccordion(),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
