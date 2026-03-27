import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class SettingsUpdateProfileScreen extends StatefulWidget {
  const SettingsUpdateProfileScreen({super.key});

  @override
  State<SettingsUpdateProfileScreen> createState() =>
      _SettingsUpdateProfileScreenState();
}

class _SettingsUpdateProfileScreenState
    extends State<SettingsUpdateProfileScreen> {
  final _firstNameController = TextEditingController();
  final _otherNamesController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _profile;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final settingsRepository = context.read<SettingsRepository>();
    final profile = await settingsRepository.getUserProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _firstNameController.text = profile.firstName;
        _otherNamesController.text = profile.otherNames;
        _phoneController.text = profile.msisdn;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _otherNamesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  void _save() async {
    setState(() => _isSaving = true);
    try {
      final success = await context.read<SettingsRepository>().updateProfile({
        'first_name': _firstNameController.text,
        'other_names': _otherNamesController.text,
        'msisdn': _phoneController.text,
        'avatar_url': _selectedImage?.path ?? _profile?.avatarUrl,
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF2ecc71),
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final isDark = InheritedThemeController.of(context).isDark;
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : AppColors.slate200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: accent.withOpacity(0.3),
                                      width: 4,
                                    ),
                                    image: _selectedImage != null
                                        ? DecorationImage(
                                            image: FileImage(_selectedImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : (_profile?.avatarUrl != null &&
                                                _profile!.avatarUrl.startsWith('/'))
                                            ? DecorationImage(
                                                image: FileImage(
                                                    File(_profile!.avatarUrl)),
                                                fit: BoxFit.cover,
                                              )
                                            : DecorationImage(
                                                image: NetworkImage(
                                                  _profile?.avatarUrl ??
                                                      'https://i.pravatar.cc/200?img=12',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: accent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Tap to change photo',
                            style: TextStyle(color: accent, fontSize: 13),
                          ),
                        ),

                        const SizedBox(height: 32),

                        _label('First Name', isDark),
                        _field(
                          context,
                          _firstNameController,
                          Icons.person_outline,
                          'Your first name',
                          cardBg,
                          cardBorder,
                        ),
                        const SizedBox(height: 20),

                        _label('Other Names', isDark),
                        _field(
                          context,
                          _otherNamesController,
                          Icons.person_outline,
                          'Your other names',
                          cardBg,
                          cardBorder,
                        ),
                        const SizedBox(height: 20),

                        _label('Phone Number', isDark),
                        _field(
                          context,
                          _phoneController,
                          Icons.phone_outlined,
                          '+254 7XX XXX XXX',
                          cardBg,
                          cardBorder,
                          enabled: false,
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: isDark
                                  ? AppColors.backgroundDark
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, bool isDark) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? AppColors.slate400 : AppColors.slate500,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _field(
    BuildContext context,
    TextEditingController controller,
    IconData icon,
    String hint,
    Color bg,
    Color border, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: AppColors.slate400),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              enabled: enabled,
              style: TextStyle(
                color: enabled
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : AppColors.slate400,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.slate400),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
