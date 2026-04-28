import 'package:atos_logos_mobile/core/enums/role.dart';

class RolePermission {
  final Role role;
  final Map<String, bool> permissions;
  final DateTime updatedAt;

  const RolePermission({
    required this.role,
    required this.permissions,
    required this.updatedAt,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      role: Role.values.firstWhere(
        (r) => r.name.toUpperCase() == (json['role'] as String).toUpperCase(),
      ),
      permissions: Map<String, bool>.from(json['permissions'] as Map),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name.toUpperCase(),
      'permissions': permissions,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  RolePermission copyWith({
    Role? role,
    Map<String, bool>? permissions,
    DateTime? updatedAt,
  }) {
    return RolePermission(
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool hasPermission(String permissionKey) {
    return permissions[permissionKey] == true;
  }
}
