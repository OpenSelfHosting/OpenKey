/// Estimates password strength on a normalized 0.0–1.0 scale.
///
/// This preserves the heuristic already used by OpenKey: up to 0.5 points for
/// length (capped at 12 characters), plus 0.125 for each character class.
double passwordStrengthScore(String password) {
  if (password.isEmpty) return 0;

  var score = (password.length / 12).clamp(0.0, 0.5);
  if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.125;
  if (RegExp(r'[a-z]').hasMatch(password)) score += 0.125;
  if (RegExp(r'\d').hasMatch(password)) score += 0.125;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score += 0.125;

  return score.clamp(0.0, 1.0);
}

/// Returns whether [password] is weak under the OpenKey vault heuristic.
bool isWeakPassword(String password) {
  if (password.isEmpty) return false;
  if (password.length < 8) return true;
  return passwordStrengthScore(password) < 0.35;
}
