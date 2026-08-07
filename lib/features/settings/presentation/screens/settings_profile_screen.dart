import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';
import 'package:provider/provider.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  static const _appVersion = '1.1.0+2';

  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await context.read<SettingsRepository>().getUserProfile();
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {
      if (mounted) setState(() => _profile = null);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openProfileEditor() async {
    final updated = await context.push<bool>('/settings/profile');
    if (!mounted || updated != true) return;
    setState(() => _isLoading = true);
    await _loadProfile();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.logout_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: const Text('Log out of Hesabu Online?'),
        content: const Text(
          'You will need to authenticate again to access your groups and ledger.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (!mounted || shouldLogout != true) return;
    await context.read<AuthRepository>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeController = InheritedThemeController.of(context);
    final profile = _profile;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings'),
            Text(
              'Account & preferences',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? _SettingsLoadError(onRetry: _loadProfile)
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _ProfileCard(profile: profile, onEdit: _openProfileEditor),
                  const SizedBox(height: 18),
                  const _SectionLabel(
                    title: 'Account',
                    subtitle: 'Identity, access and account protection',
                  ),
                  const SizedBox(height: 7),
                  _SettingsSection(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Personal details',
                        subtitle: 'Name, phone number and profile photo',
                        onTap: _openProfileEditor,
                      ),
                      _SettingsTile(
                        icon: Icons.shield_outlined,
                        title: 'Security & biometrics',
                        subtitle: 'Sign-in, password and device protection',
                        onTap: () => context.push('/settings/security'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel(
                    title: 'Preferences',
                    subtitle: 'Make Hesabu Online work your way',
                  ),
                  const SizedBox(height: 7),
                  _SettingsSection(
                    children: [
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle:
                            '${themeController.isDark ? 'Dark' : 'Light'} theme · ${themeController.accentColor.label}',
                        onTap: () => context.push('/settings/appearance'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel(
                    title: 'Support',
                    subtitle: 'Help, product details and assistance',
                  ),
                  const SizedBox(height: 7),
                  _SettingsSection(
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & support',
                        subtitle: 'Get answers or contact the Hesabu team',
                        onTap: () => context.push('/settings/help'),
                      ),
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About Hesabu Online',
                        subtitle: 'Version $_appVersion',
                        onTap: () => context.push('/settings/about'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _LogoutTile(onTap: _confirmLogout),
                  const SizedBox(height: 16),
                  Text(
                    'Secure group savings, collections and accountable records.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.tertiaryText(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          accent.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.08 : 0.04,
          ),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          _ProfileAvatar(profile: profile),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 13,
                      color: AppColors.secondaryText(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        profile.msisdn.trim().isEmpty
                            ? 'Phone number not set'
                            : profile.msisdn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.secondaryText(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    profile.membershipType.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            onPressed: onEdit,
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final initials = profile.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    Widget fallback() => ColoredBox(
      color: accent.withValues(alpha: 0.14),
      child: Center(
        child: Text(
          initials.isEmpty ? 'H' : initials,
          style: TextStyle(
            color: accent,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    final avatarUrl = profile.avatarUrl.trim();
    Widget avatar = fallback();
    if (avatarUrl.startsWith('/') && File(avatarUrl).existsSync()) {
      avatar = Image.file(
        File(avatarUrl),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } else if (avatarUrl.startsWith('http')) {
      avatar = Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 58,
          height: 58,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accent.withValues(alpha: 0.28), width: 2),
          ),
          child: avatar,
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 11,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.children});

  final List<_SettingsTile> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(
                height: 1,
                indent: 62,
                color: Theme.of(context).colorScheme.outline,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedIcon(context),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return Material(
      color: error.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: error.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Log out',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: error, size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLoadError extends StatelessWidget {
  const _SettingsLoadError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off_outlined,
              color: AppColors.mutedIcon(context),
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              'We could not load your account settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
