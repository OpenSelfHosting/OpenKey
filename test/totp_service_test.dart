import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/services/totp_service.dart';
import 'package:openkey_app/src/features/vault/domain/entities/vault_entry.dart';

void main() {
  late TotpService totp;

  setUp(() {
    totp = TotpService();
  });

  test('parseOtpAuth reads secret and params', () {
    final config = totp.parseOtpAuth(
      'otpauth://totp/Example:ada@example.com?secret=JBSWY3DPEHPK3PXP&period=30&digits=6&algorithm=SHA1',
    );
    expect(config, isNotNull);
    expect(config!.secret, 'JBSWY3DPEHPK3PXP');
    expect(config.period, 30);
    expect(config.digits, 6);
    expect(config.algorithm, 'SHA1');
  });

  test('parseOtpAuth returns null for invalid uris', () {
    expect(totp.parseOtpAuth('https://example.com'), isNull);
    expect(totp.parseOtpAuth('otpauth://totp/Example'), isNull);
    expect(totp.parseOtpAuth('not-a-uri'), isNull);
  });

  test('generate produces 6-digit code for known secret', () {
    final config = const TotpConfig(secret: 'JBSWY3DPEHPK3PXP');
    final code = totp.generate(
      config,
      now: DateTime.fromMillisecondsSinceEpoch(0),
    );
    expect(code.length, 6);
    expect(RegExp(r'^\d{6}$').hasMatch(code), isTrue);
  });

  test('generate returns empty for empty secret', () {
    expect(totp.generate(const TotpConfig(secret: '')), '');
  });

  test('secondsRemaining is within period', () {
    final config = const TotpConfig(secret: 'JBSWY3DPEHPK3PXP', period: 30);
    final remaining = totp.secondsRemaining(
      config,
      now: DateTime.fromMillisecondsSinceEpoch(15 * 1000),
    );
    expect(remaining, 15);
  });

  test('TotpConfig json round trip', () {
    const original = TotpConfig(
      secret: 'SECRET',
      period: 45,
      digits: 8,
      algorithm: 'SHA256',
    );
    final restored = TotpConfig.fromJson(original.toJson());
    expect(restored, original);
  });
}
