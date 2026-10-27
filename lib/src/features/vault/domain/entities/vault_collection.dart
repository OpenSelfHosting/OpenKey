import 'package:equatable/equatable.dart';
import 'package:openkey_app/src/features/vault/domain/entities/collection_icons.dart';

class VaultCollection extends Equatable {
  const VaultCollection({
    required this.uuid,
    required this.name,
    this.icon = CollectionIcons.defaultKey,
    this.color,
    this.parentUuid,
    this.sortOrder = 0,
    this.revision = 1,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  final String uuid;
  final String name;
  final String icon;
  final int? color;
  final String? parentUuid;
  final int sortOrder;
  final int revision;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isRoot => parentUuid == null;

  VaultCollection copyWith({
    String? uuid,
    String? name,
    String? icon,
    int? color,
    String? parentUuid,
    int? sortOrder,
    int? revision,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearParent = false,
  }) {
    return VaultCollection(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentUuid: clearParent ? null : (parentUuid ?? this.parentUuid),
      sortOrder: sortOrder ?? this.sortOrder,
      revision: revision ?? this.revision,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [uuid, name, icon, color, parentUuid, sortOrder, revision];
}
