import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String userType;

  const AuthEntity({
    this.userId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    required this.userType,
  });

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        password,
        confirmPassword,
        userType,
      ];
}
