import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/token_storage.dart';
import '../models/auth/token_response.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;

  Future<TokenResponse> login(String email, String password) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    final tokenResponse = TokenResponse.fromJson(
        DioClient.extractData(response));
    await TokenStorage.saveTokens(
      accessToken: tokenResponse.accessToken,
      refreshToken: tokenResponse.refreshToken,
    );
    return tokenResponse;
  }

  Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    await _dio.post(ApiConstants.signup, data: {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
    });
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  Future<bool> checkEmail(String email) async {
    final response = await _dio.get(
      ApiConstants.checkEmail,
      queryParameters: {'email': email},
    );
    return DioClient.extractData(response)['available'];
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post(
      ApiConstants.requestPasswordReset,
      data: {'email': email},
    );
  }

  Future<void> resetPasswordByPhone({
    required String name,
    required String phone,
    required String newPassword,
  }) async {
    await _dio.post(
      ApiConstants.resetPassword,
      data: {'name': name, 'phone': phone, 'newPassword': newPassword},
    );
  }
}
