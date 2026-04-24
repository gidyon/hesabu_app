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
  Future<ApiResponse<double>> getGroupBalance(String groupId);
  Future<ApiResponse<GroupPreview>> previewGroup(String groupId);
  Future<ApiResponse<bool>> joinGroup(String groupId);
  Future<ApiResponse<bool>> createGroup(Map<String, dynamic> groupData);

  Future<ApiResponse<bool>> editGroup(String groupId, Map<String, dynamic> groupData);
  Future<ApiResponse<bool>> inviteMember(String groupId, String msisdn);
  Future<ApiResponse<List<Member>>> getMembers(String groupId);
  Future<ApiResponse<bool>> deposit(String groupId, double amount, String method);
  Future<ApiResponse<bool>> withdraw({
    required String groupId,
    required double amount,
    required String withdrawalType,
    required String destination,
    String? billerType,
    String? billerNumber,
  });
}
