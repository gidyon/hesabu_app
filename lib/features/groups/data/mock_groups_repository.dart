import 'package:hesabu_app/features/groups/domain/groups_repository.dart';

class MockGroupsRepository implements GroupsRepository {
  @override
  Future<List<Group>> getActiveGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Group(
        id: '1',
        name: 'Family Vacation Fund',
        membersCount: '5 Members',
        frequency: 'Monthly',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDJghQ8F6GJM4qJkqci85BzWV4262k_uFKLV6pwY1s3BpCliuOGyXo7ZdzIFszVgRah_XB-N6Uph9EjUaYo2ubNZ-OUxKi4KfhODLGlzmmgpD8xf1j7BjM06nWEcF1Twbj5BPCgHooCS74zvYAYLE0fNY7NBEE8dRY2n0JUuqIKaEWgkfO4VcMkFCL4UaHYOPJvpemMaXF8Y6hiPGapjLTz_LeqC_VS--a-ynbwXxDQmh5u4ycwoHdicUHZd2SXT3TxsEYDa8TOfgk',
        balance: 4200.00,
        goal: 5000.00,
        progressPercentage: 0.84,
        status: '84% of Goal',
      ),
      Group(
        id: '2',
        name: 'Investment Club',
        membersCount: '12 Members',
        frequency: 'Weekly',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDsRoa3uJEM8Kj-xMSD0ZLx7OZfGNUEBS0Yx0gK6Lct8Y4TE4nFT1hQc61Y7GOqrt8qOZ3H1-mj6AiI6ocw1nnuz0sooO_3KD-VFtK5a_kbmPWvDrWyIhnRSM36GPS5DjINPNnNwv1ZtXUMXS7UROVzI2-7yD4kBnhVg0Akn5mWPgh2n4tb9lmr3LoadvalgfJ00RWiQ4iFGBX27cO59_HM0pzxdmmM1PUF8YEO2x7dQfAHKnHD_r0xFu7uXxp32uL-m0ilQthw9sA',
        balance: 12400.00,
        goal: 12400.00,
        progressPercentage: 1.0,
        status: 'Goal reached!',
      ),
      Group(
        id: '3',
        name: 'New Car Circle',
        membersCount: '3 Members',
        frequency: 'Bi-Weekly',
        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB8e13NY33J2AdSOQRdqqz8XUIKY5R3zWdHsVX-vGI9pMyXvEuot2bUaTbqoYgWy3CTiHclcwE39HYLt1s31FNnJkHpIRD7GLb3Ad6-raMz_RmSOAY0CLebJ9RmCpIGfq_GOl1TN44PqClH42sttIY5flbgO9bpa4M0PTqvB-P-8rCA0Scv4kjTPY3c_1UJX6wQct_nrigXEJsOUBrsDoXwvJ69iPraToP9Edu5GnKD6dVzX1MD5eQbTxgmEb1zVjDdSmYjbySntAY',
        balance: 0.00,
        goal: 10000.00,
        progressPercentage: 0.02,
        status: 'New Start',
      ),
    ];
  }

  @override
  Future<double> getTotalSavings() async {
    return 16600.00;
  }
  
  @override
  Future<double> getGroupBalance(String groupId) async {
      return 12450.00;
  }

  @override
  Future<List<Transaction>> getRecentTransactions(String groupId) async {
    return [
      Transaction(
        id: 't1',
        title: 'Member Contribution - John Doe',
        date: 'Oct 24, 2023 • 10:45 AM',
        type: 'Inflow',
        amount: 50.00,
        method: 'Wallet',
      ),
      Transaction(
        id: 't2',
        title: 'Utility Payment - Server Hosting',
        date: 'Oct 22, 2023 • 02:15 PM',
        type: 'Outflow',
        amount: 200.00,
        method: 'Bank',
      ),
       Transaction(
        id: 't3',
        title: 'Member Contribution - Sarah M.',
        date: 'Oct 21, 2023 • 09:12 AM',
        type: 'Inflow',
        amount: 150.00,
        method: 'Wallet',
      ),
       Transaction(
        id: 't4',
        title: 'Emergency Disbursement',
        date: 'Oct 19, 2023 • 11:30 PM',
        type: 'Outflow',
        amount: 1000.00,
        method: 'Bank',
      ),
       Transaction(
        id: 't5',
        title: 'Quarterly Dividend Deposit',
        date: 'Oct 15, 2023 • 03:00 PM',
        type: 'Inflow',
        amount: 425.50,
        method: 'Wallet',
      ),
    ];
  }
}
