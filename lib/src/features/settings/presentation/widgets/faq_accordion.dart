import 'package:flutter/material.dart';
import 'package:openkey_app/src/src.dart';

/// Shared FAQ catalogue — used by the settings FAQ page.
class FaqEntry {
  const FaqEntry({
    required this.icon,
    required this.question,
    required this.answer,
  });

  final IconData icon;
  final String Function(AppLocalizations s) question;
  final String Function(AppLocalizations s) answer;
}

/// Canonical FAQ list. Keep order intentional: trust → risk → daily use.
const List<FaqEntry> kFaqEntries = [
  FaqEntry(
    icon: Icons.lock_outline_rounded,
    question: _encryptionQ,
    answer: _encryptionA,
  ),
  FaqEntry(icon: Icons.key_off_outlined, question: _forgotQ, answer: _forgotA),
  FaqEntry(
    icon: Icons.cloud_off_outlined,
    question: _offlineQ,
    answer: _offlineA,
  ),
  FaqEntry(
    icon: Icons.timer_outlined,
    question: _autoLockQ,
    answer: _autoLockA,
  ),
  FaqEntry(
    icon: Icons.fingerprint_rounded,
    question: _biometricQ,
    answer: _biometricA,
  ),
  FaqEntry(icon: Icons.dns_outlined, question: _syncQ, answer: _syncA),
  FaqEntry(icon: Icons.backup_rounded, question: _backupQ, answer: _backupA),
];

String _encryptionQ(AppLocalizations s) => s.faqEncryptionQ;
String _encryptionA(AppLocalizations s) => s.faqEncryptionA;
String _forgotQ(AppLocalizations s) => s.faqForgotPasswordQ;
String _forgotA(AppLocalizations s) => s.faqForgotPasswordA;
String _offlineQ(AppLocalizations s) => s.faqOfflineQ;
String _offlineA(AppLocalizations s) => s.faqOfflineA;
String _autoLockQ(AppLocalizations s) => s.faqAutoLockQ;
String _autoLockA(AppLocalizations s) => s.faqAutoLockA;
String _biometricQ(AppLocalizations s) => s.faqBiometricQ;
String _biometricA(AppLocalizations s) => s.faqBiometricA;
String _syncQ(AppLocalizations s) => s.faqSyncQ;
String _syncA(AppLocalizations s) => s.faqSyncA;
String _backupQ(AppLocalizations s) => s.faqBackupQ;
String _backupA(AppLocalizations s) => s.faqBackupA;

List<MEAccordionItem> faqAccordionItems(AppLocalizations s) {
  return [
    for (final entry in kFaqEntries)
      MEAccordionItem(
        icon: entry.icon,
        header: Text(entry.question(s)),
        body: Text(entry.answer(s)),
      ),
  ];
}

/// Expressive FAQ accordion used by [FaqPage].
class FaqAccordion extends StatelessWidget {
  const FaqAccordion({super.key, this.initiallyExpanded = const <int>{}});

  final Set<int> initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return MEAccordion(
      items: faqAccordionItems(context.s),
      initiallyExpanded: initiallyExpanded,
    );
  }
}
