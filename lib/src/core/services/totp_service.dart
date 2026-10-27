import 'package:otp/otp.dart';
import 'package:openkey_app/src/src.dart';

class TotpService {
  String generate(TotpConfig config, {DateTime? now}) {
    if (config.secret.isEmpty) return '';
    final algorithm = switch (config.algorithm.toUpperCase()) {
      'SHA256' => Algorithm.SHA256,
      'SHA512' => Algorithm.SHA512,
      _ => Algorithm.SHA1,
    };
    return OTP.generateTOTPCodeString(
      config.secret.replaceAll(' ', '').toUpperCase(),
      (now ?? DateTime.now()).millisecondsSinceEpoch,
      interval: config.period,
      length: config.digits,
      algorithm: algorithm,
      isGoogle: true,
    );
  }

  TotpConfig? parseOtpAuth(String uri) {
    try {
      final url = Uri.parse(uri);
      if (url.scheme != 'otpauth') return null;
      final secret = url.queryParameters['secret'];
      if (secret == null || secret.isEmpty) return null;
      return TotpConfig(
        secret: secret,
        period: int.tryParse(url.queryParameters['period'] ?? '') ?? 30,
        digits: int.tryParse(url.queryParameters['digits'] ?? '') ?? 6,
        algorithm: (url.queryParameters['algorithm'] ?? 'SHA1').toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  int secondsRemaining(TotpConfig config, {DateTime? now}) {
    final ts = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    return config.period - (ts % config.period);
  }
}
