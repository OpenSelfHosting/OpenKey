import 'package:equatable/equatable.dart';

/// Named folder / bank / device group with a vault icon key
/// (Material, brand SVG, or custom device image encoded in the key).
class NamedGroup extends Equatable {
  const NamedGroup({
    required this.name,
    this.icon = defaultIcon,
  });

  /// Same default as [CollectionIcons.defaultKey].
  static const defaultIcon = 'material:folder';
  static const bankDefaultIcon = 'material:account_balance';
  static const deviceDefaultIcon = 'material:computer';

  final String name;
  final String icon;

  String get iconKey {
    final key = icon.trim();
    return key.isEmpty ? defaultIcon : key;
  }

  NamedGroup copyWith({String? name, String? icon}) {
    return NamedGroup(
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': iconKey,
      };

  /// Accepts legacy bare strings or `{name, icon}` maps.
  factory NamedGroup.fromJson(
    dynamic raw, {
    String fallbackIcon = NamedGroup.defaultIcon,
  }) {
    if (raw is String) {
      return NamedGroup(name: raw.trim(), icon: fallbackIcon);
    }
    if (raw is Map) {
      final name = raw['name']?.toString().trim() ?? '';
      final icon = raw['icon']?.toString().trim() ?? '';
      return NamedGroup(
        name: name,
        icon: icon.isEmpty ? fallbackIcon : icon,
      );
    }
    return NamedGroup(name: '', icon: fallbackIcon);
  }

  @override
  List<Object?> get props => [name, icon];
}
