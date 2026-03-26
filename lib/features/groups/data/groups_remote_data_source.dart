import 'package:dio/dio.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/features/groups/data/models/group_models.dart';

class GroupsRemoteDataSource {
  final ApiClient apiClient;

  GroupsRemoteDataSource({required this.apiClient});

  Future<MyGroupsResponse> getMyGroups() async {
    try {
      final response = await apiClient.dio.get('/groups/my-groups');
      return MyGroupsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch groups');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<GroupStatementsResponse> getGroupStatements(String groupId) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/statements',
        data: {
          'group_id': groupId,
        },
      );
      return GroupStatementsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to fetch statements');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/join',
        data: {
          'group_id': groupId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to join group');
      }
      throw Exception('Network error occurred');
    }
  }

  Future<bool> createGroup(Map<String, dynamic> groupData) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/create',
        data: groupData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to create group');
      }
      throw Exception('Network error occurred');
    }
  }
}
