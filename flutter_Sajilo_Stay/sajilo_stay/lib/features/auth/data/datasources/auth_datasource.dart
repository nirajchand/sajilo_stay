import 'package:sajilo_stay/features/auth/data/models/auth_api_model.dart';
import 'package:sajilo_stay/features/auth/data/models/auth_hive_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<AuthHiveModel> registerUser(AuthHiveModel user);
  Future<AuthHiveModel?> loginUser(String email, String password);
  Future<bool> logout();
}

abstract interface class IAuthRemoteDatasource {
  Future<AuthApiModel> registerUser(AuthApiModel user);
  Future<AuthApiModel?> loginUser(String email, String password);
  Future<AuthApiModel> googleSignIn(String idToken);
  Future<bool> sendToken(String email);
  Future<bool> verifyOtp(String email, String otp);
  Future<bool> resetToken(String email, String newPassword);
}
