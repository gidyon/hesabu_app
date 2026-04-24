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

abstract class GroupsRepository {
  Future<List<Group>> getActiveGroups();
  Future<double> getTotalSavings();
  Future<List<Transaction>> getRecentTransactions(String groupId);
  Future<double> getGroupBalance(String groupId);
  Future<bool> joinGroup(String groupId);
  Future<bool> createGroup(Map<String, dynamic> groupData);
  Future<bool> editGroup(String groupId, Map<String, dynamic> groupData);
  Future<bool> inviteMember(String groupId, String msisdn);
  Future<List<Member>> getMembers(String groupId);
  Future<bool> deposit(String groupId, double amount, String method);
  Future<bool> withdraw(String groupId, double amount, String destination);
}
