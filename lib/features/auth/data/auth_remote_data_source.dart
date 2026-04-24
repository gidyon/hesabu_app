import 'package:dio/dio.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/core/network/api_exception.dart';
import 'package:hesabu_app/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<bool> sendResetCode(String msisdn) async {
    try {
      await apiClient.dio.post(
        '/request-password-reset',
        data: {'msisdn': msisdn},
      );
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Failed to request password reset';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<bool> resetPassword(
    String msisdn,
    String otp,
    String newPassword,
  ) async {
    try {
      await apiClient.dio.post(
        '/reset-password',
        data: {'msisdn': msisdn, 'otp': otp, 'new_password': newPassword},
      );
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Failed to reset password';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<LoginResponse> login(String msisdn, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/login',
        data: {'msisdn': msisdn, 'password': password},
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Login failed';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<RegisterResponse> register(
    String firstName,
    String otherNames,
    String msisdn,
    String password,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/register',
        data: {
          'msisdn': msisdn,
          'password': password,
          'first_name': firstName,
          'other_names': otherNames,
          'document_type': 'ID',
          'document_number': '00000000', // Typically collected from UI
          'user_type_id': 1,
          'device_id': 'DEVICE-DEFAULT',
          'entity_type': 'Individual',
        },
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Registration failed';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }
}
