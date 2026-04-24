import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:provider/provider.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

class InviteMembersScreen extends StatefulWidget {
  final String groupId;
  const InviteMembersScreen({super.key, required this.groupId});

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  final _inviteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  void _sendInvite() async {
    if (_inviteController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await context.read<GroupsRepository>().inviteMember(
        widget.groupId,
        _inviteController.text,
      );

      if (!response.hasError && response.data == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent successfully!'),
            backgroundColor: Color(0xFF2ecc71),
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'Failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'An unexpected error occurred. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = InheritedThemeController.of(context);
    final isDark = themeController.isDark;
    final accent = themeController.accentColor.primary;
    final backgroundColor = isDark
        ? themeController.accentColor.darkBackground
        : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final inputColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Invite Members',
          style: TextStyle(fontWeight: FontWeight.bold, color: titleColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: titleColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'GROW YOUR CHAMA',
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add members to your group by entering their phone number or email address.',
              style: TextStyle(
                color: titleColor.withValues(alpha: 0.7),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildLabel('Phone Number or Email', titleColor),
            _buildInputField(
              controller: _inviteController,
              hintText: 'e.g. +254 700 000 000',
              inputColor: inputColor,
              titleColor: titleColor,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please only invite people you know. Spamming may result in account suspension.',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text(
                      'Send Invitation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Color titleColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: titleColor.withValues(alpha: 0.4),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required Color inputColor,
    required Color titleColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: titleColor.withValues(alpha: 0.05)),
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: titleColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: titleColor.withValues(alpha: 0.2)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
      ),
    );
  }
}
