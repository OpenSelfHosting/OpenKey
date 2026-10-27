import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'screenshots/screenshot_pump.dart';
import 'screenshots/vault_showcase.dart';

void main() {
  testWidgets('welcome onboarding shows headline and next chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      screenshotMaterialApp(
        brightness: Brightness.light,
        surfaceSize: const Size(390, 844),
        child: const OnboardingShowcase(),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Welcome'), findsOneWidget);
    expect(find.text("Let's Go!"), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
  });
}
