import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key, this.group});

  final Group? group;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isSubmitting = false;
  bool _acceptedTerms = false;

  bool get _isEditMode => widget.group != null;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    if (group != null) {
      _nameController.text = group.name;
      _descriptionController.text = group.description;
      _locationController.text = group.location;
      _acceptedTerms = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isEditMode && !_acceptedTerms) {
      _showMessage('Accept the group Terms and Conditions to continue.');
      return;
    }

    setState(() => _isSubmitting = true);
    final authRepository = context.read<AuthRepository>();
    final groupsRepository = context.read<GroupsRepository>();
    final activityProvider = context.read<ActivityProvider>();

    try {
      final user = await authRepository.getUser();
      final msisdn = user?['msisdn']?.toString() ?? '';
      final name = _nameController.text.trim();
      final location = _locationController.text.trim();
      final description = _descriptionController.text.trim();

      final response = _isEditMode
          ? await groupsRepository.editGroup(widget.group!.id, {
              'name': name,
              'location': location,
              'group_type': 'normal',
              'configs': description,
            })
          : await groupsRepository.createGroup({
              'name': name,
              'treasurer_msisdn': msisdn,
              'location': location,
              'group_type': 'normal',
              'configs': description,
            });
      if (!mounted) return;

      if (response.hasError || response.data != true) {
        _showMessage(
          response.errorMessage ?? 'Unable to save the group.',
          isError: true,
        );
        return;
      }

      await activityProvider.record(
        type: _isEditMode
            ? AccountActivityType.groupUpdated
            : AccountActivityType.groupCreated,
        title: _isEditMode ? 'Group profile updated' : 'Group created',
        description: _isEditMode
            ? '$name group details were updated.'
            : '$name is ready to collect member contributions.',
        groupId: widget.group?.id,
        groupName: name,
        metadata: {'location': location},
      );
      if (!mounted) return;

      _showMessage(
        _isEditMode
            ? 'Group profile updated successfully.'
            : 'Group created successfully.',
      );
      context.pop(true);
    } catch (_) {
      if (mounted) {
        _showMessage(
          'An unexpected error occurred. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit group' : 'Create group',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            FinancialSectionHeader(
              title: _isEditMode ? 'Group profile' : 'New collection account',
              subtitle: _isEditMode
                  ? 'Keep the group identity clear for members'
                  : 'Set up a trusted ledger for contributions and payouts',
            ),
            const SizedBox(height: 12),
            FinancialSurface(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    maxLength: 80,
                    decoration: const InputDecoration(
                      labelText: 'Group name',
                      hintText: 'e.g. Kasarani Development Fund',
                      prefixIcon: Icon(Icons.groups_2_outlined),
                      counterText: '',
                    ),
                    validator: (value) {
                      final name = value?.trim() ?? '';
                      if (name.isEmpty) return 'Group name is required';
                      if (name.length < 3) return 'Use at least 3 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'e.g. Kasarani, Nairobi',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      counterText: '',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Location is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Purpose and description',
                      hintText:
                          'Explain what the group collects for and how members participate.',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 54),
                        child: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FinancialSurface(
              emphasized: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode
                              ? 'Collection account remains unchanged'
                              : 'Group account generated automatically',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _isEditMode
                              ? 'Editing the profile does not alter the group balance, ledger or account number.'
                              : 'Members and external contributors can use the generated account number when paying through the Hesabu Online Paybill.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryText(context),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!_isEditMode) ...[
              const SizedBox(height: 14),
              CheckboxListTile(
                value: _acceptedTerms,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I accept the Hesabu Online group terms'),
                subtitle: Text(
                  'I confirm the group details are accurate and members understand how collections are managed.',
                  style: TextStyle(color: AppColors.secondaryText(context)),
                ),
                onChanged: (value) =>
                    setState(() => _acceptedTerms = value ?? false),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isEditMode
                          ? Icons.save_outlined
                          : Icons.add_business_outlined,
                    ),
              label: Text(
                _isEditMode ? 'Save group profile' : 'Create collection group',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
