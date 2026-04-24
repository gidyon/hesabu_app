import 'package:dio/dio.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/core/network/api_exception.dart';
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
        final data = e.response?.data;
        String message = 'Failed to fetch groups';
        if (data is Map) {
          message = data['message'] ?? data['errorMessage'] ?? data['error'] ?? e.response?.statusMessage ?? message;
        } else {
          message = e.response?.statusMessage ?? message;
        }
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<GroupStatementsResponse> getGroupStatements(String groupId) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/statements',
        data: {'group_id': groupId},
      );
      return GroupStatementsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String message = 'Failed to fetch statements';
        if (data is Map) {
          message = data['message'] ?? data['errorMessage'] ?? data['error'] ?? e.response?.statusMessage ?? message;
        } else {
          message = e.response?.statusMessage ?? message;
        }
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<GroupMembersResponse> getGroupMembers(String groupId) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/members',
        data: {'group_id': groupId},
      );
      return GroupMembersResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String message = 'Failed to fetch members';
        if (data is Map) {
          message = data['message'] ?? data['errorMessage'] ?? data['error'] ?? e.response?.statusMessage ?? message;
        } else {
          message = e.response?.statusMessage ?? message;
        }
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<bool> joinGroup(String groupId, String msisdn) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/join',
        data: {'group_id': groupId, 'msisdn': msisdn},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String message = 'Failed to join group';
        if (data is Map) {
          message = data['message'] ?? data['errorMessage'] ?? data['error'] ?? e.response?.statusMessage ?? message;
        } else {
          message = e.response?.statusMessage ?? message;
        }
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<CreateGroupResponse> createGroup(
    Map<String, dynamic> groupData,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/create',
        data: groupData,
      );
      return CreateGroupResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Failed to create group';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<bool> editGroup(
    String groupId,
    Map<String, dynamic> groupData,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/edit/$groupId',
        data: groupData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Failed to edit group';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<bool> inviteMember(String groupId, String msisdn) async {
    try {
      final response = await apiClient.dio.post(
        '/groups/join',
        data: {'group_id': groupId, 'msisdn': msisdn},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Failed to invite member';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<bool> deposit(
    String groupId,
    double amount,
    String msisdn,
    String mainWalletAccount,
    String payingMsisdn,
  ) async {
    try {
      final response = await apiClient.dio.post(
        '/initiate/group/payment',
        data: {
          'msisdn': msisdn,
          'amount': amount,
          'group_id': int.tryParse(groupId) ?? 0,
          'main_wallet_account_number': mainWalletAccount,
          'paying_msisdn': payingMsisdn,
        },
      );
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          (response.data['ResponseCode'] == "0");
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['errorMessage'] != null)
            ? data['errorMessage']
            : 'Deposit failed';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }

  Future<bool> withdraw({
    required String groupId,
    required double amount,
    required String withdrawalType,
    required String destination,
    String? billerType,
    String? billerNumber,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'group_id': groupId,
        'amount': amount.toString(),
        'withdrawal_type': withdrawalType,
        'destination': destination,
      };

      if (billerType != null) {
        data['biller_type'] = billerType;
      }

      if (billerNumber != null) {
        // Based on user example, Paybill uses "BILLER_NUMBER"
        data['BILLER_NUMBER'] = billerNumber;
      }

      final response = await apiClient.dio.post(
        '/groups/withdraw',
        data: data,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message']
            : 'Failed to withdraw funds';
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }
  Future<GroupPreviewModel> previewGroup(String id) async {
    try {
      final response = await apiClient.dio.get('/groups/preview/$id');
      return GroupPreviewModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        String message = 'Failed to preview group';
        if (data is Map) {
          message = data['message'] ?? data['errorMessage'] ?? data['error'] ?? e.response?.statusMessage ?? message;
        } else {
          message = e.response?.statusMessage ?? message;
        }
        throw ApiException(
          message: message,
          statusCode: e.response?.statusCode,
        );
      }
      throw NetworkException();
    }
  }
}
