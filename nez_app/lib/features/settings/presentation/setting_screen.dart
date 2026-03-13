import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/api_client.dart';
import '../../../shared/widgets/nez_button.dart';
import '../../../shared/widgets/nez_text_field.dart';
import '../../auth/data/auth_provider.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool _pushNotificationsEnabled = true;
  bool _emailDigestEnabled = false;

  // ── Change Email dialog ──
  void _showChangeEmail() {
    final emailCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String? errorMsg;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => _NezDialog(
          title: 'Change Email',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NezTextField(
                hint: 'New Email Address',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                controller: emailCtrl,
              ),
              const SizedBox(height: 16),
              NezTextField(
                hint: 'Confirm New Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                controller: confirmCtrl,
              ),
              const SizedBox(height: 16),
              NezTextField(
                hint: 'Current Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                controller: passCtrl,
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMsg!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              NezButton(
                label: 'Update Email',
                onPressed: () async {
                  if (emailCtrl.text.trim().isEmpty ||
                      confirmCtrl.text.trim().isEmpty ||
                      passCtrl.text.isEmpty) {
                    setDialogState(() => errorMsg = 'All fields are required.');
                    return;
                  }
                  if (emailCtrl.text.trim() != confirmCtrl.text.trim()) {
                    setDialogState(() => errorMsg = 'Emails do not match.');
                    return;
                  }
                  final dio = ref.read(apiClientProvider).client;
                  final err = await ref
                      .read(authProvider.notifier)
                      .changeEmail(dio, emailCtrl.text.trim(), passCtrl.text);
                  if (err != null) {
                    setDialogState(() => errorMsg = err);
                  } else {
                    Navigator.of(ctx).pop();
                    _showConfirmSnack('Email updated successfully.');
                  }
                },
              ),
              const SizedBox(height: 12),
              NezButton(
                label: 'Cancel',
                variant: NezButtonVariant.outlined,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Change Password dialog (real backend) ──
  void _showChangePassword() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? errorMsg;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => _NezDialog(
          title: 'Change Password',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NezTextField(
                hint: 'Current Password',
                obscureText: true,
                textInputAction: TextInputAction.next,
                controller: currentCtrl,
              ),
              const SizedBox(height: 16),
              NezTextField(
                hint: 'New Password',
                obscureText: true,
                textInputAction: TextInputAction.next,
                controller: newCtrl,
              ),
              const SizedBox(height: 16),
              NezTextField(
                hint: 'Confirm New Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                controller: confirmCtrl,
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMsg!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              NezButton(
                label: 'Update Password',
                onPressed: () async {
                  if (newCtrl.text != confirmCtrl.text) {
                    setDialogState(() => errorMsg = 'Passwords do not match.');
                    return;
                  }
                  if (newCtrl.text.length < 6) {
                    setDialogState(
                      () =>
                          errorMsg = 'Password must be at least 6 characters.',
                    );
                    return;
                  }
                  final dio = ref.read(apiClientProvider).client;
                  final err = await ref
                      .read(authProvider.notifier)
                      .changePassword(dio, currentCtrl.text, newCtrl.text);
                  if (err != null) {
                    setDialogState(() => errorMsg = err);
                  } else {
                    Navigator.of(ctx).pop();
                    _showConfirmSnack('Password updated successfully.');
                  }
                },
              ),
              const SizedBox(height: 12),
              NezButton(
                label: 'Cancel',
                variant: NezButtonVariant.outlined,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Manage Notifications sheet ──
  void _showManageNotifications() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Notifications',
                    style: AppTextStyles.headlineLarge,
                  ),
                  const SizedBox(height: 24),
                  _NotifToggleTile(
                    label: 'Push Notifications',
                    subtitle: 'Breaking news & updates',
                    value: _pushNotificationsEnabled,
                    onChanged: (v) {
                      setSheetState(() => _pushNotificationsEnabled = v);
                      setState(() => _pushNotificationsEnabled = v);
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _NotifToggleTile(
                    label: 'Daily Email Digest',
                    subtitle: 'Morning summary of top stories',
                    value: _emailDigestEnabled,
                    onChanged: (v) {
                      setSheetState(() => _emailDigestEnabled = v);
                      setState(() => _emailDigestEnabled = v);
                    },
                  ),
                  const SizedBox(height: 28),
                  NezButton(
                    label: 'Save Preferences',
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showConfirmSnack('Notification preferences saved.');
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Delete Account confirmation dialog ──
  void _showDeleteAccount() {
    String? errorMsg;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => _NezDialog(
          title: 'Delete Account',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent and cannot be undone. All your data, '
                'bookmarks, and preferences will be erased.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Text(
                  errorMsg!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              NezButton(
                label: 'Yes, Delete My Account',
                onPressed: () async {
                  final dio = ref.read(apiClientProvider).client;
                  final err = await ref
                      .read(authProvider.notifier)
                      .deleteAccount(dio);
                  if (err != null) {
                    setDialogState(() => errorMsg = err);
                  } else {
                    Navigator.of(ctx).pop();
                    // authProvider state is already reset; router redirects to login
                  }
                },
                isDestructive: true,
              ),
              const SizedBox(height: 12),
              NezButton(
                label: 'Cancel',
                variant: NezButtonVariant.outlined,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Data & Privacy Policy (stub) ──
  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _NezDialog(
        title: 'Privacy Policy',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your data is processed in accordance with Nez\'s Privacy Policy. '
              'We do not sell your personal data to third parties. '
              'For full details, visit nez.app/privacy.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            NezButton(
              label: 'Close',
              variant: NezButtonVariant.outlined,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Clear Search History ──
  void _clearSearchHistory() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _NezDialog(
        title: 'Clear Search History',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will remove all your recent searches. This action cannot be undone.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            NezButton(
              label: 'Clear History',
              onPressed: () {
                Navigator.of(ctx).pop();
                _showConfirmSnack('Search history cleared.');
              },
              isDestructive: true,
            ),
            const SizedBox(height: 12),
            NezButton(
              label: 'Cancel',
              variant: NezButtonVariant.outlined,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodySmall),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 80, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ──
                      Text(
                        'Setting',
                        style: AppTextStyles.displayMedium,
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.08),

                      // ── Account Settings ──
                      Text(
                        'Account Settings',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 1),
                      _SettingTile(
                        title: 'Change email',
                        onTap: _showChangeEmail,
                      ),
                      _SettingTile(
                        title: 'Change password',
                        onTap: _showChangePassword,
                      ),

                      const SizedBox(height: 20),

                      // ── Notifications ──
                      Text('Notifications', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 1),
                      _SettingTile(
                        title: 'Manage Notifications',
                        onTap: _showManageNotifications,
                      ),

                      const SizedBox(height: 20),

                      // ── Data & Privacy ──
                      Text(
                        'Data & Privacy',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 1),
                      _SettingTile(
                        title: 'Data & Privacy Policy',
                        onTap: _showPrivacyPolicy,
                      ),
                      _SettingTile(
                        title: 'Search History',
                        onTap: _clearSearchHistory,
                      ),
                      _SettingTile(
                        title: 'Delete Account',
                        onTap: _showDeleteAccount,
                        isDestructive: true,
                      ),

                      const SizedBox(height: 20),

                      // ── Session ──
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SETTING TILE
// ──────────────────────────────────────────────
class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
                softWrap: true,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDestructive ? AppColors.error : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// NOTIFICATION TOGGLE TILE (used in bottom sheet)
// ──────────────────────────────────────────────
class _NotifToggleTile extends StatelessWidget {
  const _NotifToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.textPrimary,
            activeTrackColor: AppColors.textSecondary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// NEZ DIALOG — shared styled dialog wrapper
// ──────────────────────────────────────────────
class _NezDialog extends StatelessWidget {
  const _NezDialog({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppTextStyles.headlineLarge),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
