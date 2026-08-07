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
  final String configs;

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
    required this.configs,
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
      configs: json['configs']?.toString() ?? '',
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

class GroupMembersResponse {
  final String groupId;
  final List<MemberModel> members;

  GroupMembersResponse({required this.groupId, required this.members});

  factory GroupMembersResponse.fromJson(Map<String, dynamic> json) {
    var membersJson = json['members'] as List? ?? [];
    return GroupMembersResponse(
      groupId: json['group_id']?.toString() ?? '',
      members: membersJson.map((e) => MemberModel.fromJson(e)).toList(),
    );
  }
}

class MemberModel {
  final String dateJoined;
  final String? dateLeft;
  final String documentNumber;
  final String firstName;
  final int memberId;
  final String msisdn;
  final String otherNames;
  final String role;
  final String status;

  MemberModel({
    required this.dateJoined,
    this.dateLeft,
    required this.documentNumber,
    required this.firstName,
    required this.memberId,
    required this.msisdn,
    required this.otherNames,
    required this.role,
    required this.status,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      dateJoined: json['date_joined']?.toString() ?? '',
      dateLeft: json['date_left']?.toString(),
      documentNumber: json['document_number']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      memberId: json['member_id'] as int? ?? 0,
      msisdn: json['msisdn']?.toString() ?? '',
      otherNames: json['other_names']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      status: json['status']?.toString() ?? 'active',
    );
  }
}

class GroupPreviewModel {
  final String id;
  final String name;
  final double balance;
  final int membersCount;
  final String adminName;
  final String description;

  GroupPreviewModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.membersCount,
    required this.adminName,
    required this.description,
  });

  factory GroupPreviewModel.fromJson(Map<String, dynamic> json) {
    return GroupPreviewModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      membersCount: json['members_count'] as int? ?? 0,
      adminName: json['admin_name']?.toString() ?? '',
      description:
          json['description']?.toString() ??
          json['dexcription']?.toString() ??
          '',
    );
  }
}
