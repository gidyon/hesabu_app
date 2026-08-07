import 'package:hesabu_app/core/api/api_response.dart';

class Group {
  final String id;
  final String name;
  final String membersCount;
  final String frequency;
  final String imageUrl;
  final double balance;
  final double goal;
  final double progressPercentage;
  final String status;
  final String role;
  final String accountNo;
  final String location;
  final String description;

  Group({
    required this.id,
    required this.name,
    required this.membersCount,
    required this.frequency,
    required this.imageUrl,
    required this.balance,
    required this.goal,
    required this.progressPercentage,
    required this.status,
    required this.role,
    required this.accountNo,
    required this.location,
    required this.description,
  });
}

class Member {
  final String id;
  final String name;
  final String msisdn;
  final String role;
  final String status;
  final String dateJoined;

  Member({
    required this.id,
    required this.name,
    required this.msisdn,
    required this.role,
    required this.status,
    required this.dateJoined,
  });
}

class Transaction {
  final String id;
  final String title;
  final String date;
  final String type; // 'Inflow' or 'Outflow'
  final double amount;
  final String method; // 'Wallet' or 'Bank'

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.amount,
    required this.method,
  });
}

class GroupStatementEntry {
  final double amount;
  final double balanceAfter;
  final double balanceBefore;
  final String dateCreated;
  final String memberName;
  final String msisdn;
  final String operation;
  final String transactionId;

  GroupStatementEntry({
    required this.amount,
    required this.balanceAfter,
    required this.balanceBefore,
    required this.dateCreated,
    required this.memberName,
    required this.msisdn,
    required this.operation,
    required this.transactionId,
  });
}

class GroupPreview {
  final String id;
  final String name;
  final double balance;
  final int membersCount;
  final String adminName;
  final String description;

  GroupPreview({
    required this.id,
    required this.name,
    required this.balance,
    required this.membersCount,
    required this.adminName,
    required this.description,
  });
}

abstract class GroupsRepository {
  Future<ApiResponse<List<Group>>> getActiveGroups();
  Future<ApiResponse<double>> getTotalSavings();
  Future<ApiResponse<List<Transaction>>> getRecentTransactions(String groupId);
  Future<ApiResponse<List<GroupStatementEntry>>> getGroupStatements(
    String groupId,
  );
  Future<ApiResponse<double>> getGroupBalance(String groupId);
  Future<ApiResponse<GroupPreview>> previewGroup(String groupId);
  Future<ApiResponse<bool>> joinGroup(String groupId);
  Future<ApiResponse<bool>> createGroup(Map<String, dynamic> groupData);

  Future<ApiResponse<bool>> editGroup(
    String groupId,
    Map<String, dynamic> groupData,
  );
  Future<ApiResponse<bool>> inviteMember(String groupId, String msisdn);
  Future<ApiResponse<List<Member>>> getMembers(String groupId);
  Future<ApiResponse<bool>> deposit(
    String groupId,
    double amount,
    String method,
  );
  Future<ApiResponse<bool>> withdraw({
    required String groupId,
    required double amount,
    required String withdrawalType,
    required String destination,
    String? billerType,
    String? billerNumber,
  });
  Future<ApiResponse<double>> getWithdrawalFee({required double amount});
}
