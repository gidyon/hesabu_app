import 'package:dio/dio.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/features/auth/data/models/auth_models.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<LoginResponse> login(String msisdn, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/login',
        data: {
          'msisdn': msisdn,
          'password': password,
        },
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<RegisterResponse> register(String firstName, String otherNames, String msisdn, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/register',
        data: {
          'msisdn': msisdn,
          'password': password,
          'first_name': firstName,
          'other_names': otherNames,
          'document_type': 'ID',
          'document_number': '00000000', // Default or dummy
          'user_type_id': 1,
          'device_id': 'DEVICE-DEFAULT',
          'entity_type': 'Individual',
        },
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error occurred');
    }
  }
}
