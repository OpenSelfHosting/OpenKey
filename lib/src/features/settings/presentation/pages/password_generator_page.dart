import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/src/src.dart';

class PasswordGeneratorPage extends StatelessWidget {
  const PasswordGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return MESliverScaffold(
      title: s.generatorTitle,
      leadingAppBar: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      slivers: const [
        SliverToBoxAdapter(
          child: AdaptiveContentWidth(
            maxWidth: 560,
            child: PasswordGeneratorPanel(),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
