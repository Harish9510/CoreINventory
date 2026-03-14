class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final String subscriptionPlan;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? organizationId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.subscriptionPlan,
    required this.createdAt,
    this.lastLogin,
    this.organizationId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      status: json['status'] ?? 'active',
      subscriptionPlan: json['subscription_plan'] ?? 'free',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      organizationId: json['organization_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'subscription_plan': subscriptionPlan,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'organization_id': organizationId,
    };
  }

  bool get isAdmin => role == 'admin' || role == 'owner';
  bool get isSuperAdmin => role == 'super_admin';
  bool get isActive => status == 'active';
}
