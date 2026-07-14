import 'package:sajilo_stay/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String role;
  final String? profileImage;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    this.role = 'USER',
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'role': role,
    };
  }

  // Parses the user object returned inside backend responses.
  // Backend sends: { id, email, fullName, role?, profile_image? }
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: (json['id'] ?? json['_id'])?.toString(),
      fullName: (json['fullName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? 'USER',
      profileImage: json['profile_image'] as String?,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
      role: entity.userType,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      userType: role,
    );
  }

  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
