/// Simple password strength score used across OpenKey (0.0–1.0).
///
/// Matches the heuristic used when setting a master password: length plus
/// character-class mix.
double passwordStrengthScore(String password) {
  if (password.isEmpty) return 0;
  var score = (password.length / 12).clamp(0.0, 0.5);
  if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
  if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
  if (RegExp(r'\d').hasMatch(password)) score += 0.125;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;
  return score.clamp(0.0, 1.0);
}

/// True when the password is considered weak for vault health checks.
bool isWeakPassword(String password) {
  if (password.isEmpty) return false;
  if (password.length < 8) return true;
  return passwordStrengthScore(password) < 0.35;
}
