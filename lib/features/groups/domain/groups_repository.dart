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
}
