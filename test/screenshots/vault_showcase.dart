import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Static first-page onboarding composition used by screenshot-oriented tests.
class OnboardingShowcase extends StatelessWidget {
  const OnboardingShowcase({super.key});

  static double _settledPage() => 0;

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingWelcomeStep(pageOffset: _settledPage),
      bottomNavigationBar: OnboardingBottomBar(
        currentPage: 0,
        pageCount: OnboardingPage.pageCount,
        onNext: _noop,
        onBack: _noop,
        onFinish: _noop,
      ),
    );
  }
}
