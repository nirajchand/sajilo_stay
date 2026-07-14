import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:sajilo_stay/core/error/failures.dart';
import 'package:sajilo_stay/core/services/connectivity/network_info.dart';
import 'package:sajilo_stay/features/auth/data/datasources/auth_datasource.dart';
import 'package:sajilo_stay/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:sajilo_stay/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:sajilo_stay/features/auth/data/models/auth_api_model.dart';
import 'package:sajilo_stay/features/auth/data/models/auth_hive_model.dart';
import 'package:sajilo_stay/features/auth/domain/entities/auth_entity.dart';
import 'package:sajilo_stay/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authDatasource: ref.read(authLocalDatasourceProvider),
    authRemoteDatasource: ref.read(authRemoteProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthEntity>> loginUser(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _authRemoteDatasource.loginUser(email, password);
        if (user != null) {
          return right(user.toEntity());
        }
        return left(const ServerFailure(message: "Login failed"));
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data["message"] ?? "Login failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final user = await _authDatasource.loginUser(email, password);
        if (user != null) {
          return Right(user.toEntity());
        }
        return const Left(
          LocalDatabaseFailure(message: "Email or password is incorrect"),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogle(String idToken) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure(message: 'No internet connection'));
    }
    try {
      final user = await _authRemoteDatasource.googleSignIn(idToken);
      return Right(user.toEntity());
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data['message'] ?? 'Google sign-in failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDatasource.registerUser(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ServerFailure(
            message: e.response?.data["message"] ?? "Registration Failed",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final model = AuthHiveModel.fromEntity(user);
        await _authDatasource.registerUser(model);
        return const Right(true);
      } on HiveError catch (e) {
        return Left(LocalDatabaseFailure(message: e.message));
      } catch (e) {
        return Left(
          LocalDatabaseFailure(message: "Unexpected error: ${e.toString()}"),
        );
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: "Failed to logout"));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendToken(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure(message: "No internet connection"));
    }
    try {
      final result = await _authRemoteDatasource.sendToken(email);
      if (result) {
        return const Right(true);
      }
      return const Left(ServerFailure(message: "Failed to send reset code"));
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data["message"] ?? "Failed to send reset code",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(String email, String otp) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure(message: "No internet connection"));
    }
    try {
      final result = await _authRemoteDatasource.verifyOtp(email, otp);
      if (result) {
        return const Right(true);
      }
      return const Left(ServerFailure(message: "Invalid or expired code"));
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data["message"] ?? "Invalid or expired code",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword(
    String email,
    String newPassword,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ServerFailure(message: "No internet connection"));
    }
    try {
      final result = await _authRemoteDatasource.resetToken(email, newPassword);
      if (result) {
        return const Right(true);
      }
      return const Left(ServerFailure(message: "Failed to reset password"));
    } on DioException catch (e) {
      return Left(
        ServerFailure(
          message: e.response?.data["message"] ?? "Failed to reset password",
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
