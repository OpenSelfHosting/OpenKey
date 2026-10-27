import 'package:equatable/equatable.dart';

/// A local vault identity on this device (shown before unlock).
class VaultAccount extends Equatable {
  const VaultAccount({
    required this.id,
    required this.email,
    this.avatarPath,
  });

  final String id;
  final String email;

  /// Absolute path to a local avatar PNG, if one exists.
  final String? avatarPath;

  String get initials {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return '?';
    final at = trimmed.indexOf('@');
    final local = at > 0 ? trimmed.substring(0, at) : trimmed;
    return local.substring(0, 1).toUpperCase();
  }

  VaultAccount copyWith({
    String? id,
    String? email,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    return VaultAccount(
      id: id ?? this.id,
      email: email ?? this.email,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
      };

  factory VaultAccount.fromJson(Map<String, dynamic> json) {
    return VaultAccount(
      id: json['id'] as String? ?? '',
      email: (json['email'] as String? ?? '').trim().toLowerCase(),
    );
  }

  @override
  List<Object?> get props => [id, email, avatarPath];
}
