import 'package:hesabu_app/core/api/api_response.dart';
import 'package:hesabu_app/core/network/api_exception.dart';
import 'package:hesabu_app/core/network/auth_local_data_source.dart';
import 'package:hesabu_app/features/groups/data/groups_remote_data_source.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  GroupsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  String _formatMsisdn(String input) {
    String formatted = input.trim().replaceAll(' ', '');
    if (formatted.startsWith('+')) {
      formatted = formatted.substring(1);
    }
    if (formatted.startsWith('07')) {
      formatted = '2547${formatted.substring(2)}';
    } else if (formatted.startsWith('01')) {
      formatted = '2541${formatted.substring(2)}';
    }
    return formatted;
  }

  @override
  Future<ApiResponse<List<Group>>> getActiveGroups() async {
    try {
      final response = await remoteDataSource.getMyGroups();
      final groups = response.groups.map((model) {
        return Group(
          id: model.groupId.toString(),
          name: model.name,
          membersCount: 'Members',
          frequency: 'Monthly',
          imageUrl: '',
          balance: model.availableBalance,
          goal: 0.0,
          progressPercentage: 0.0,
          status: model.status,
          role: model.role,
          accountNo: model.accountNo,
          location: model.location,
          description: model.configs,
        );
      }).toList();
      return ApiResponse.success(groups);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<double>> getTotalSavings() async {
    try {
      final response = await getActiveGroups();
      if (response.hasError) return ApiResponse.error(response.errorMessage!);
      double total = 0;
      for (var group in response.data!) {
        total += group.balance;
      }
      return ApiResponse.success(total);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<ApiResponse<double>> getGroupBalance(String groupId) async {
    try {
      final statements = await remoteDataSource.getGroupStatements(groupId);
      if (statements.statements.isNotEmpty) {
        return ApiResponse.success(statements.statements.first.balAfter);
      }
      return ApiResponse.success(0.0);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Transaction>>> getRecentTransactions(String groupId) async {
    try {
      final statementsResponse = await remoteDataSource.getGroupStatements(
        groupId,
      );
      final txs = statementsResponse.statements.map((model) {
        return Transaction(
          id: model.transactionId,
          title: '${model.operation} - ${model.memberName}',
          date: model.dateCreated,
          type: model.operation.toLowerCase() == 'deposit'
              ? 'Inflow'
              : 'Outflow',
          amount: model.amount,
          method: 'Wallet',
        );
      }).toList();
      return ApiResponse.success(txs);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> joinGroup(String groupId) async {
    try {
      final user = await localDataSource.getUser();
      final msisdn = user?['msisdn']?.toString() ?? '';
      if (msisdn.isEmpty) throw Exception('No logged in user');
      final success = await remoteDataSource.joinGroup(groupId, msisdn);
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> createGroup(Map<String, dynamic> groupData) async {
    try {
      await remoteDataSource.createGroup(groupData);
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> editGroup(String groupId, Map<String, dynamic> groupData) async {
    try {
      final success = await remoteDataSource.editGroup(groupId, groupData);
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> inviteMember(String groupId, String msisdn) async {
    try {
      final success = await remoteDataSource.inviteMember(groupId, _formatMsisdn(msisdn));
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<List<Member>>> getMembers(String groupId) async {
    try {
      final response = await remoteDataSource.getGroupMembers(groupId);
      final members = response.members.map((model) {
        return Member(
          id: model.memberId.toString(),
          name: '${model.firstName} ${model.otherNames}',
          msisdn: model.msisdn,
          role: model.role,
          status: model.status,
          dateJoined: model.dateJoined,
        );
      }).toList();
      return ApiResponse.success(members);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> deposit(String groupId, double amount, String method) async {
    try {
      final user = await localDataSource.getUser();
      final msisdn = user?['msisdn']?.toString() ?? '';
      if (msisdn.isEmpty) throw Exception('No logged in user');

      final groupsResponse = await getActiveGroups();
      if (groupsResponse.hasError) return ApiResponse.error(groupsResponse.errorMessage!);
      
      final group = groupsResponse.data!.firstWhere(
        (g) => g.id == groupId,
        orElse: () => throw Exception('Group not found'),
      );

      await remoteDataSource.deposit(
        groupId,
        amount,
        msisdn,
        group.name,
        msisdn,
      );
      return ApiResponse.success(true);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }

  @override
  Future<ApiResponse<bool>> withdraw(
    String groupId,
    double amount,
    String destination,
  ) async {
    try {
      final success = await remoteDataSource.withdraw(
        groupId,
        amount,
        _formatMsisdn(destination),
      );
      return ApiResponse.success(success);
    } catch (e) {
      return ApiResponse.error(e is ApiException ? e.message : e.toString());
    }
  }
}
