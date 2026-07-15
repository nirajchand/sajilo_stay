import 'package:dartz/dartz.dart';
import 'package:sajilo_stay/core/error/failures.dart';
import 'package:sajilo_stay/features/auth/domain/entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password);
  Future<Either<Failure, AuthEntity>> loginWithGoogle(String idToken);
  Future<Either<Failure, bool>> registerUser(AuthEntity user);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> sendToken(String email);
  Future<Either<Failure, bool>> verifyOtp(String email, String otp);
  Future<Either<Failure, bool>> resetPassword(String email, String newPassword);
}
