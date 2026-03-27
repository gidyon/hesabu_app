class MyGroupsResponse {
  final List<GroupModel> groups;

  MyGroupsResponse({required this.groups});

  factory MyGroupsResponse.fromJson(Map<String, dynamic> json) {
    var groupsJson = json['groups'] as List? ?? [];
    return MyGroupsResponse(
      groups: groupsJson.map((e) => GroupModel.fromJson(e)).toList(),
    );
  }
}

class GroupModel {
  final String accountNo;
  final String adminMsisdn;
  final double availableBalance;
  final String dateCreated;
  final int groupId;
  final String groupType;
  final String location;
  final String name;
  final String role;
  final String status;
  final String treasurerMsisdn;

  GroupModel({
    required this.accountNo,
    required this.adminMsisdn,
    required this.availableBalance,
    required this.dateCreated,
    required this.groupId,
    required this.groupType,
    required this.location,
    required this.name,
    required this.role,
    required this.status,
    required this.treasurerMsisdn,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      accountNo: json['account_no']?.toString() ?? '',
      adminMsisdn: json['admin_msisdn']?.toString() ?? '',
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
      dateCreated: json['date_created']?.toString() ?? '',
      groupId: json['group_id'] as int? ?? 0,
      groupType: json['group_type']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      treasurerMsisdn: json['treasurer_msisdn']?.toString() ?? '',
    );
  }
}

class GroupStatementsResponse {
  final String? filterMsisdn;
  final String groupId;
  final List<StatementModel> statements;
  final double totalAmount;
  final int totalTransactions;

  GroupStatementsResponse({
    this.filterMsisdn,
    required this.groupId,
    required this.statements,
    required this.totalAmount,
    required this.totalTransactions,
  });

  factory GroupStatementsResponse.fromJson(Map<String, dynamic> json) {
    var statementsJson = json['statements'] as List? ?? [];
    return GroupStatementsResponse(
      filterMsisdn: json['filter_msisdn']?.toString(),
      groupId: json['group_id']?.toString() ?? '',
      statements: statementsJson
          .map((e) => StatementModel.fromJson(e))
          .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: json['total_transactions'] as int? ?? 0,
    );
  }
}

class StatementModel {
  final double amount;
  final double balAfter;
  final double balBefore;
  final String dateCreated;
  final int id;
  final String memberName;
  final String msisdn;
  final String operation;
  final String transactionId;

  StatementModel({
    required this.amount,
    required this.balAfter,
    required this.balBefore,
    required this.dateCreated,
    required this.id,
    required this.memberName,
    required this.msisdn,
    required this.operation,
    required this.transactionId,
  });

  factory StatementModel.fromJson(Map<String, dynamic> json) {
    return StatementModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balAfter: (json['bal_after'] as num?)?.toDouble() ?? 0.0,
      balBefore: (json['bal_before'] as num?)?.toDouble() ?? 0.0,
      dateCreated: json['date_created']?.toString() ?? '',
      id: json['id'] as int? ?? 0,
      memberName: json['member_name']?.toString() ?? '',
      msisdn: json['msisdn']?.toString() ?? '',
      operation: json['operation']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
    );
  }
}

class CreateGroupResponse {
  final String accountNo;
  final int groupId;
  final String message;

  CreateGroupResponse({
    required this.accountNo,
    required this.groupId,
    required this.message,
  });

  factory CreateGroupResponse.fromJson(Map<String, dynamic> json) {
    return CreateGroupResponse(
      accountNo: json['account_no']?.toString() ?? '',
      groupId: json['group_id'] as int? ?? 0,
      message: json['message']?.toString() ?? '',
    );
  }
}
