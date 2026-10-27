import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openkey_app/dependency_injection.dart';
import 'package:openkey_app/src/src.dart';

/// Full-screen camera scanner that returns an `otpauth://` URI for TOTP setup.
class TotpQrScannerPage extends StatefulWidget {
  const TotpQrScannerPage({super.key});

  /// Platforms where [mobile_scanner] can open a camera preview.
  static bool get isSupported {
    return !Platform.isLinux && !Platform.isWindows;
  }

  /// Opens the scanner and returns a valid otpauth URI, or `null` if cancelled.
  static Future<String?> scan(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const TotpQrScannerPage(),
      ),
    );
  }

  @override
  State<TotpQrScannerPage> createState() => _TotpQrScannerPageState();
}

class _TotpQrScannerPageState extends State<TotpQrScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handled = false;
  DateTime? _lastInvalidToast;

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || !mounted) return;

    final raw = capture.barcodes
        .map((b) => b.rawValue?.trim())
        .whereType<String>()
        .firstWhere((v) => v.isNotEmpty, orElse: () => '');
    if (raw.isEmpty) return;

    final config = sl<TotpService>().parseOtpAuth(raw);
    if (config == null || config.isEmpty) {
      final now = DateTime.now();
      if (_lastInvalidToast == null ||
          now.difference(_lastInvalidToast!) > const Duration(seconds: 2)) {
        _lastInvalidToast = now;
        showMEToast(
          context,
          message: context.s.invalidTotpQr,
          kind: METoastKind.error,
        );
      }
      return;
    }

    _handled = true;
    unawaited(_controller.stop());
    Navigator.of(context).pop(raw);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(s.scanTotpQr),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              final message = error.errorCode ==
                      MobileScannerErrorCode.permissionDenied
                  ? s.cameraPermissionDenied
                  : (error.errorDetails?.message ?? error.errorCode.message);
              return ColoredBox(
                color: Colors.black,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videocam_off_outlined,
                          size: 48,
                          color: scheme.onInverseSurface,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onInverseSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      s.scanTotpQrHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
