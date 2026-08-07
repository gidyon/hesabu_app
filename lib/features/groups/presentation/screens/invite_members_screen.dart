import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Group;
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/utils/phone_utils.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/groups/application/group_invitation_service.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:provider/provider.dart';

class InviteMembersScreen extends StatefulWidget {
  const InviteMembersScreen({
    super.key,
    required this.group,
    this.invitationService,
  });

  final Group group;
  final GroupInvitationService? invitationService;

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  final _memberController = TextEditingController();
  final Map<String, _InviteRecipient> _selectedRecipients = {};

  late final GroupInvitationService _invitationService;
  bool _isAddingMember = false;
  bool _isLoadingContacts = false;
  bool _isLaunchingShare = false;
  String? _senderName;

  @override
  void initState() {
    super.initState();
    _invitationService = widget.invitationService ?? GroupInvitationService();
    Future<void>.microtask(_loadSenderName);
  }

  @override
  void dispose() {
    _memberController.dispose();
    super.dispose();
  }

  Future<void> _loadSenderName() async {
    final user = await context.read<AuthRepository>().getUser();
    if (!mounted || user == null) return;

    final firstName = user['first_name']?.toString().trim() ?? '';
    final otherNames = user['other_names']?.toString().trim() ?? '';
    final fullName = [
      firstName,
      otherNames,
    ].where((part) => part.isNotEmpty).join(' ');
    if (fullName.isNotEmpty) setState(() => _senderName = fullName);
  }

  String get _inviteMessage => _invitationService.buildInviteMessage(
    group: widget.group,
    senderName: _senderName,
  );

  Future<void> _addRegisteredMember() async {
    final phone = _memberController.text.trim();
    if (!PhoneUtils.isValidMsisdn(phone)) {
      _showMessage('Enter a valid Kenyan phone number.');
      return;
    }

    setState(() => _isAddingMember = true);
    try {
      final response = await context.read<GroupsRepository>().inviteMember(
        widget.group.id,
        phone,
      );
      if (!mounted) return;

      if (!response.hasError && response.data == true) {
        await context.read<ActivityProvider>().record(
          type: AccountActivityType.memberInvited,
          title: 'Member added',
          description: 'A registered member was added to ${widget.group.name}.',
          groupId: widget.group.id,
          groupName: widget.group.name,
          metadata: {'recipient': PhoneUtils.formatMsisdn(phone)},
        );
        if (!mounted) return;
        _memberController.clear();
        _showMessage(
          'Member added successfully.',
          backgroundColor: const Color(0xFF2ecc71),
        );
      } else {
        _showMessage(
          response.errorMessage ?? 'Failed to add the member.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'An unexpected error occurred. Please try again.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingMember = false);
    }
  }

  Future<void> _shareViaWhatsApp() async {
    setState(() => _isLaunchingShare = true);
    final result = await _invitationService.shareViaWhatsApp(_inviteMessage);
    if (!mounted) return;

    setState(() => _isLaunchingShare = false);
    if (result.succeeded) {
      await context.read<ActivityProvider>().record(
        type: AccountActivityType.memberInvited,
        title: 'WhatsApp invitation opened',
        description: 'The ${widget.group.name} invitation is ready to share.',
        status: AccountActivityStatus.pending,
        groupId: widget.group.id,
        groupName: widget.group.name,
        metadata: {'channel': 'whatsapp'},
      );
    } else {
      _showMessage(
        result.errorMessage!,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _composeBulkSms() async {
    setState(() => _isLaunchingShare = true);
    final result = await _invitationService.composeBulkSms(
      message: _inviteMessage,
      recipients: _selectedRecipients.keys.toList(growable: false),
    );
    if (!mounted) return;

    setState(() => _isLaunchingShare = false);
    if (result.succeeded) {
      await context.read<ActivityProvider>().record(
        type: AccountActivityType.memberInvited,
        title: 'SMS invitations prepared',
        description:
            '${_selectedRecipients.length} group invitation${_selectedRecipients.length == 1 ? '' : 's'} opened in your SMS app.',
        status: AccountActivityStatus.pending,
        groupId: widget.group.id,
        groupName: widget.group.name,
        metadata: {
          'channel': 'sms',
          'recipient_count': '${_selectedRecipients.length}',
        },
      );
    } else {
      _showMessage(
        result.errorMessage!,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _selectContacts() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _showMessage('Contact selection is only available on Android and iOS.');
      return;
    }

    setState(() => _isLoadingContacts = true);
    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        if (!mounted) return;
        final permanentlyDenied =
            permission == PermissionStatus.permanentlyDenied ||
            permission == PermissionStatus.restricted;
        _showMessage(
          permanentlyDenied
              ? 'Contacts access is disabled. Enable it in Settings.'
              : 'Contacts permission is required to select recipients.',
          action: permanentlyDenied
              ? SnackBarAction(
                  label: 'Settings',
                  onPressed: FlutterContacts.permissions.openSettings,
                )
              : null,
        );
        return;
      }

      final contacts = await FlutterContacts.getAll(
        properties: const {ContactProperty.phone},
      );
      final recipientsByPhone = <String, _InviteRecipient>{};
      for (final contact in contacts) {
        final name = contact.displayName?.trim();
        for (final phone in contact.phones) {
          final normalized = PhoneUtils.formatMsisdn(
            phone.normalizedNumber ?? phone.number,
          );
          if (!PhoneUtils.isValidMsisdn(normalized)) continue;
          recipientsByPhone.putIfAbsent(
            normalized,
            () => _InviteRecipient(
              name: name == null || name.isEmpty ? normalized : name,
              phone: normalized,
            ),
          );
        }
      }

      if (!mounted) return;
      if (recipientsByPhone.isEmpty) {
        _showMessage('No valid Kenyan phone numbers were found.');
        return;
      }

      final candidates = recipientsByPhone.values.toList(growable: false)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final selection = await _showContactSelectionSheet(candidates);
      if (!mounted || selection == null) return;

      setState(() {
        _selectedRecipients
          ..clear()
          ..addEntries(
            candidates
                .where((recipient) => selection.contains(recipient.phone))
                .map((recipient) => MapEntry(recipient.phone, recipient)),
          );
      });
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Contacts could not be loaded. Please try again.',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingContacts = false);
    }
  }

  Future<Set<String>?> _showContactSelectionSheet(
    List<_InviteRecipient> candidates,
  ) async {
    final searchController = TextEditingController();
    final draftSelection = _selectedRecipients.keys.toSet();
    String query = '';

    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = candidates
                .where((recipient) {
                  final searchTerm = query.toLowerCase();
                  return recipient.name.toLowerCase().contains(searchTerm) ||
                      recipient.phone.contains(searchTerm);
                })
                .toList(growable: false);

            return FractionallySizedBox(
              heightFactor: 0.82,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select contacts (${draftSelection.length}/${GroupInvitationService.maximumSmsRecipients})',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setSheetState(draftSelection.clear),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: searchController,
                      onChanged: (value) =>
                          setSheetState(() => query = value.trim()),
                      decoration: const InputDecoration(
                        hintText: 'Search contacts',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final recipient = filtered[index];
                          final selected = draftSelection.contains(
                            recipient.phone,
                          );
                          return CheckboxListTile(
                            value: selected,
                            title: Text(recipient.name),
                            subtitle: Text(recipient.phone),
                            onChanged: (checked) {
                              setSheetState(() {
                                if (checked == true) {
                                  if (draftSelection.length >=
                                      GroupInvitationService
                                          .maximumSmsRecipients) {
                                    ScaffoldMessenger.of(sheetContext)
                                      ..hideCurrentSnackBar()
                                      ..showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Maximum 50 contacts per SMS batch.',
                                          ),
                                        ),
                                      );
                                    return;
                                  }
                                  draftSelection.add(recipient.phone);
                                } else {
                                  draftSelection.remove(recipient.phone);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(
                          sheetContext,
                        ).pop(Set<String>.from(draftSelection)),
                        child: Text(
                          'Use ${draftSelection.length} contact${draftSelection.length == 1 ? '' : 's'}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    searchController.dispose();
    return result;
  }

  void _showMessage(
    String message, {
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          action: action,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = InheritedThemeController.of(context);
    final isDark = themeController.isDark;
    final accent = themeController.accentColor.primary;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = AppColors.secondaryText(context);
    final cardColor = isDark ? Theme.of(context).cardColor : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Invite Members',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.group.name,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Group account: ${widget.group.accountNo}',
                  style: TextStyle(color: secondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'INVITATION MESSAGE',
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              _inviteMessage,
              style: TextStyle(color: titleColor, height: 1.45),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLaunchingShare ? null : _shareViaWhatsApp,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Share via WhatsApp'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _isLoadingContacts ? null : _selectContacts,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            icon: _isLoadingContacts
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.contacts_outlined),
            label: Text(
              _selectedRecipients.isEmpty
                  ? 'Select contacts for SMS'
                  : 'Change selected contacts (${_selectedRecipients.length})',
            ),
          ),
          if (_selectedRecipients.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _selectedRecipients.values
                  .map(
                    (recipient) => InputChip(
                      label: Text(recipient.name),
                      onDeleted: () => setState(
                        () => _selectedRecipients.remove(recipient.phone),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _isLaunchingShare ? null : _composeBulkSms,
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              icon: const Icon(Icons.sms_outlined),
              label: Text(
                'Open SMS for ${_selectedRecipients.length} contact${_selectedRecipients.length == 1 ? '' : 's'}',
              ),
            ),
          ],
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            'ADD A REGISTERED MEMBER',
            style: TextStyle(
              color: accent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the phone number of someone who already has a Hesabu Online account.',
            style: TextStyle(color: secondaryTextColor),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'e.g. 0712 345 678',
              prefixIcon: Icon(Icons.phone_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isAddingMember ? null : _addRegisteredMember,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isAddingMember
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('Add Member'),
          ),
          const SizedBox(height: 14),
          Text(
            'Only contact people who have agreed to receive group invitations. SMS charges from your mobile provider may apply.',
            style: TextStyle(color: secondaryTextColor, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InviteRecipient {
  const _InviteRecipient({required this.name, required this.phone});

  final String name;
  final String phone;
}
