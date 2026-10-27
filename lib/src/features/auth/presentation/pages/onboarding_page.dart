import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// First-run setup pager, modeled on SpatialFlow's immersive onboarding.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const pageCount = 6;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with WidgetsBindingObserver {
  final _controller = PageController();
  bool _finishing = false;
  bool _autofillGranted = false;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onScroll);
    _refreshAutofill();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAutofill();
    }
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _refreshAutofill() async {
    try {
      final granted = await sl<AutofillBridge>().isAutofillEnabled();
      if (mounted) setState(() => _autofillGranted = granted);
    } catch (_) {
      // Platform channel unavailable (tests / unsupported hosts).
    }
  }

  Future<void> _requestAutofill() async {
    HapticFeedback.selectionClick();
    try {
      await sl<AutofillBridge>().setAutofillEnabled(true);
    } catch (_) {
      // Settings sheet is opened by the bridge on failure.
    }
    await _refreshAutofill();
  }

  double _offsetFor(int page) {
    if (!_controller.hasClients) return 0;
    return (_controller.page ?? _page.toDouble()) - page;
  }

  Future<void> _goTo(int page) async {
    if (page < 0 || page >= OnboardingPage.pageCount) return;
    HapticFeedback.selectionClick();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.jumpToPage(page);
      return;
    }
    await _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _complete() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    HapticFeedback.mediumImpact();
    await sl<VaultMetadataStore>().setOnboardingCompleted(true);
    if (!mounted) return;
    context.go(AppRoutes.setup.path);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemUi.overlayFor(
        scheme,
        navigationBarColor: scheme.surfaceContainer,
      ),
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (page) => setState(() => _page = page),
          children: [
            OnboardingWelcomeStep(pageOffset: () => _offsetFor(0)),
            OnboardingVaultStep(pageOffset: () => _offsetFor(1)),
            OnboardingFeaturesStep(pageOffset: () => _offsetFor(2)),
            OnboardingThemeStep(pageOffset: () => _offsetFor(3)),
            OnboardingAutofillStep(
              pageOffset: () => _offsetFor(4),
              granted: _autofillGranted,
              onRequest: _requestAutofill,
            ),
            OnboardingFinishStep(pageOffset: () => _offsetFor(5)),
          ],
        ),
        bottomNavigationBar: OnboardingBottomBar(
          currentPage: _page,
          pageCount: OnboardingPage.pageCount,
          onNext: () => _goTo(_page + 1),
          onBack: () => _goTo(_page - 1),
          onFinish: _finishing ? () {} : _complete,
        ),
      ),
    );
  }
}
