import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:provider/provider.dart';

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  final _searchController = TextEditingController();
  List<Group> _groups = [];
  bool _isLoading = true;
  String _query = '';

  List<Group> get _visibleGroups {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _groups;
    return _groups
        .where(
          (group) =>
              group.name.toLowerCase().contains(query) ||
              group.accountNo.toLowerCase().contains(query) ||
              group.location.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    final response = await context.read<GroupsRepository>().getActiveGroups();
    if (!mounted) return;

    setState(() {
      _groups = response.data ?? [];
      _isLoading = false;
    });
    if (response.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.errorMessage ?? 'Failed to load groups.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _openCreateGroup() async {
    final result = await context.push('/groups/create');
    if (result == true) await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleGroups = _visibleGroups;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group ledgers',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '${_groups.length} active collection account${_groups.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Join a group',
            onPressed: () => context.push('/groups/join'),
            icon: const Icon(Icons.group_add_outlined),
          ),
          IconButton(
            tooltip: 'Create a group',
            onPressed: _openCreateGroup,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Search by group or account number',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_groups.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: FinancialEmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No group ledgers yet',
                  message:
                      'Create a collection group or join one using its account number.',
                  action: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton(
                        onPressed: () => context.push('/groups/join'),
                        child: const Text('Join'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _openCreateGroup,
                        child: const Text('Create group'),
                      ),
                    ],
                  ),
                ),
              )
            else if (visibleGroups.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: FinancialEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No matching groups',
                  message: 'Try a different group name or account number.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                sliver: SliverList.separated(
                  itemCount: visibleGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final group = visibleGroups[index];
                    return GroupLedgerCard(
                      group: group,
                      onOpen: () async {
                        await context.push('/groups/details', extra: group);
                        await _loadData();
                      },
                      onDeposit: () =>
                          context.push('/groups/deposit', extra: group),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
