import 'package:hesabu_app/features/groups/data/groups_remote_data_source.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Group>> getActiveGroups() async {
    try {
      final response = await remoteDataSource.getMyGroups();
      return response.groups.map((model) {
        return Group(
          id: model.groupId.toString(),
          name: model.name,
          membersCount: 'Members', // Endpoint doesn't return count directly here
          frequency: 'Monthly', // Default/placeholder as it's not in the response
          imageUrl: '', // Default empty image
          balance: model.availableBalance,
          goal: 0.0, // Not in API response
          progressPercentage: 0.0,
          status: model.status,
        );
      }).toList();
    } catch (e) {
      // In case of error, return empty list or throw
      // For now, logging and returning empty list to avoid crashes
      return [];
    }
  }

  @override
  Future<double> getTotalSavings() async {
    try {
      final groups = await getActiveGroups();
      double total = 0;
      for (var group in groups) {
        total += group.balance;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<double> getGroupBalance(String groupId) async {
    try {
      final statements = await remoteDataSource.getGroupStatements(groupId);
      // The statement response contains bal_after for latest transaction or simply calculate from statements
      if (statements.statements.isNotEmpty) {
        return statements.statements.first.balAfter; // Assuming sorted desc
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<List<Transaction>> getRecentTransactions(String groupId) async {
    try {
      final statementsResponse = await remoteDataSource.getGroupStatements(groupId);
      return statementsResponse.statements.map((model) {
        return Transaction(
          id: model.transactionId,
          title: '${model.operation} - ${model.memberName}',
          date: model.dateCreated,
          type: model.operation.toLowerCase() == 'deposit' ? 'Inflow' : 'Outflow',
          amount: model.amount,
          method: 'Wallet', // Default
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
