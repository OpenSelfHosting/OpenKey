import 'package:flutter/services.dart';
import 'package:openkey_app/src/core/l10n/l10n.dart';
import 'package:openkey_app/src/features/vault/presentation/models/entry_editor_field.dart';

/// Type-aware validation and input filtering for entry editor fields.
class EntryFieldValidators {
  EntryFieldValidators._();

  static String? validate(
    EntryEditorField field,
    String value,
    AppLocalizations s,
  ) {
    final v = value.trim();
    if (v.isEmpty) return null;

    return switch (field) {
      EntryEditorField.email =>
        isValidEmail(v) ? null : s.invalidEmailFormat,
      EntryEditorField.website =>
        isValidUrl(v) ? null : s.invalidUrlFormat,
      EntryEditorField.phone =>
        isValidPhone(v) ? null : s.invalidPhoneFormat,
      EntryEditorField.pin => isValidPin(v) ? null : s.invalidPinFormat,
      EntryEditorField.number =>
        isValidNumber(v) ? null : s.invalidNumberFormat,
      EntryEditorField.card =>
        isValidCardNumber(v) ? null : s.invalidCardFormat,
      EntryEditorField.ipAddress =>
        isValidIpAddress(v) ? null : s.invalidIpFormat,
      EntryEditorField.walletAddress =>
        isValidWalletAddress(v) ? null : s.invalidWalletFormat,
      EntryEditorField.recoveryCodes =>
        isValidRecoveryCodes(v) ? null : s.invalidRecoveryCodesFormat,
      _ => null,
    };
  }

  static List<TextInputFormatter> formatters(EntryEditorField field) {
    return switch (field) {
      EntryEditorField.pin || EntryEditorField.number => [
          FilteringTextInputFormatter.digitsOnly,
        ],
      EntryEditorField.card => [
          FilteringTextInputFormatter.digitsOnly,
          const CardNumberInputFormatter(),
        ],
      EntryEditorField.phone => [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]')),
        ],
      EntryEditorField.ipAddress => [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F:.]')),
        ],
      EntryEditorField.walletAddress => [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z]')),
        ],
      EntryEditorField.recoveryCodes => [
          const RecoveryCodesInputFormatter(),
        ],
      _ => const [],
    };
  }

  static bool isValidEmail(String value) {
    return RegExp(
      r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$',
    ).hasMatch(value.trim());
  }

  static bool isValidUrl(String value) {
    final v = value.trim();
    if (v.isEmpty || v.contains(RegExp(r'\s'))) return false;

    final withScheme =
        RegExp(r'^[a-zA-Z][a-zA-Z0-9+.\-]*://').hasMatch(v) ? v : 'https://$v';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) return false;
    if (uri.hasPort && (uri.port < 1 || uri.port > 65535)) return false;

    final host = uri.host;
    if (host.toLowerCase() == 'localhost') return true;
    if (isValidIpAddress(host)) return true;

    // Domain: one or more labels + alphabetic TLD (unicode-aware).
    return RegExp(
      r'^(?:[\p{L}0-9-]{1,63}\.)+[a-zA-Z]{2,63}$',
      unicode: true,
      caseSensitive: false,
    ).hasMatch(host);
  }

  static bool isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15;
  }

  static bool isValidPin(String value) {
    return RegExp(r'^\d{4,12}$').hasMatch(value.trim());
  }

  static bool isValidNumber(String value) {
    return RegExp(r'^\d+$').hasMatch(value.trim());
  }

  static bool isValidCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 13 && digits.length <= 19;
  }

  static bool isValidIpAddress(String value) {
    final pattern = r'^('
        r'((25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.){3}'
        r'(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)'
        r'|'
        r'(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|'
        r'([0-9a-fA-F]{1,4}:){1,7}:|'
        r'([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|'
        r'([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|'
        r'([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|'
        r'([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|'
        r'([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|'
        r'[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|'
        r':((:[0-9a-fA-F]{1,4}){1,7}|:)|'
        r'::(ffff(:0{1,4}){0,1}:){0,1}'
        r'((25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.){3}'
        r'(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)|'
        r'([0-9a-fA-F]{1,4}:){1,4}:'
        r'((25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?)\.){3}'
        r'(25[0-5]|2[0-4][0-9]|[0-1]?[0-9][0-9]?))'
        r')$';
    return RegExp(pattern, caseSensitive: false).hasMatch(value.trim());
  }

  static bool isValidWalletAddress(String value) {
    final v = value.trim();
    if (RegExp(r'^0x[a-fA-F0-9]{40}$').hasMatch(v)) return true;
    if (RegExp(r'^[13][a-km-zA-HJ-NP-Z1-9]{25,34}$').hasMatch(v)) return true;
    if (RegExp(r'^bc1[a-z0-9]{25,90}$').hasMatch(v)) return true;
    if (RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$').hasMatch(v)) return true;
    return v.length >= 26 &&
        v.length <= 90 &&
        RegExp(r'^[0-9a-zA-Z]+$').hasMatch(v);
  }

  static bool isValidRecoveryCodes(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return false;
    final parts = normalized.split(' ');
    if (parts.length % 2 != 0) return false;
    for (var i = 0; i < parts.length; i += 2) {
      if (!RegExp(r'^\d{4}$').hasMatch(parts[i]) ||
          !RegExp(r'^\d{4}$').hasMatch(parts[i + 1])) {
        return false;
      }
    }
    return true;
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  const CardNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class RecoveryCodesInputFormatter extends TextInputFormatter {
  const RecoveryCodesInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 8 == 0) {
        buffer.write('\n');
      } else if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
