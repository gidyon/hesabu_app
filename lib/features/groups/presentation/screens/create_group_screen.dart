import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:provider/provider.dart';

class CreateGroupScreen extends StatefulWidget {
  final Group? group;

  const CreateGroupScreen({super.key, this.group});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _locationController = TextEditingController();
  String _frequency = 'Monthly';
  bool _isLoading = false;
  bool _acceptedTerms = false;

  bool get isEditMode => widget.group != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.group!.name;
      _descriptionController.text = widget.group!.description;
      _locationController.text = widget.group!.location;
      _targetController.text = widget.group!.goal.toString();
      _frequency = widget.group!.frequency;
      _acceptedTerms = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms and Conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await context.read<AuthRepository>().getUser();
      final msisdn = user?['msisdn']?.toString() ?? '';

      final success = isEditMode
          ? await context.read<GroupsRepository>().editGroup(widget.group!.id, {
              "name": _nameController.text,
              "location": _locationController.text.isNotEmpty
                  ? _locationController.text
                  : "Utawala",
              "group_type": "normal",
              "configs": _descriptionController.text,
            })
          : await context.read<GroupsRepository>().createGroup({
              "name": _nameController.text,
              "treasurer_msisdn": msisdn,
              "location": _locationController.text.isNotEmpty
                  ? _locationController.text
                  : "Utawala",
              "group_type": "normal",
              "configs": _descriptionController.text,
            });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Group updated successfully!'
                  : 'Group created successfully!',
            ),
            backgroundColor: const Color(0xFF2ecc71),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ApiException: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = InheritedThemeController.of(context);
    final accent = themeController.accentColor.primary;
    final isDark = themeController.isDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Edit Group Profile' : 'Create New Group',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('Group Name'),
              _buildInputField(
                controller: _nameController,
                hintText: 'e.g. Family Savings, Chama 2024',
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel('Description'),
              _buildInputField(
                controller: _descriptionController,
                hintText: 'What is this group for?',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildLabel('Location'),
              _buildInputField(
                controller: _locationController,
                hintText: 'e.g. Utawala, Nairobi',
                validator: (v) => v!.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Contribution Target'),
                        _buildInputField(
                          controller: _targetController,
                          hintText: 'KSh 0.00',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              v!.isEmpty ? 'Target is required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildLabel('Frequency'), _buildDropdown()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTermsAndConditions(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: isDark
                      ? AppColors.backgroundDark
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditMode ? 'Save Changes' : 'Create Group',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.slate400,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = InheritedThemeController.of(context).isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c271f) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3b5443) : AppColors.slate200,
        ),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF9db9a6) : AppColors.slate400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final isDark = InheritedThemeController.of(context).isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c271f) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF3b5443) : AppColors.slate200,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _frequency,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1c271f) : Colors.white,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          items: [
            'Daily',
            'Weekly',
            'Monthly',
            'Quarterly',
          ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (v) => setState(() => _frequency = v!),
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    final theme = Theme.of(context);
    final accent = InheritedThemeController.of(context).accentColor.primary;
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = v!),
            activeColor: accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ' of Hesabu Online groups.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
