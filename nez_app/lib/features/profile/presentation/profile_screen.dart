import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_provider.dart';
import '../../insights/data/insights_provider.dart';
import '../../onboarding/data/preferences_provider.dart';
import 'widgets/profile_sections.dart';
import 'widgets/profile_sheets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final prefsAsync = ref.watch(preferencesProvider);
    final insightsAsync = ref.watch(insightsProvider);

    final displayName = (authState.username?.isNotEmpty == true)
        ? authState.username!
        : (authState.email?.split('@').first ?? 'User');
    final avatarAsset =
        authState.profilePhoto ?? 'assets/profile_photos/05_calico_tabby.jpeg';

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
                      Text(
                        'Profile',
                        style: AppTextStyles.displayMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: constraints.maxHeight * 0.06),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _showPickAvatar(context, ref),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Image.asset(
                                    avatarAsset,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: AppColors.textPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    displayName,
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      fontSize: 30,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _showEditUsername(
                                    context,
                                    ref,
                                    authState.username ?? '',
                                  ),
                                  child: Image.asset(
                                    'assets/images/edit-text.png',
                                    width: 16,
                                    height: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authState.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Text(
                            'Preferences',
                            style: AppTextStyles.headlineLarge,
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showEditPreferences(
                              context,
                              ref,
                              prefsAsync.valueOrNull ?? [],
                            ),
                            child: Image.asset(
                              'assets/images/edit-text.png',
                              width: 18,
                              height: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      prefsAsync.when(
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (error, stackTrace) => Text(
                          'Could not load preferences',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        data: (categories) => categories.isEmpty
                            ? GestureDetector(
                                onTap: () =>
                                    _showEditPreferences(context, ref, []),
                                child: Text(
                                  'No preferences set. Tap to add ->',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: categories
                                    .map(
                                      (label) =>
                                          ProfilePreferenceChip(label: label),
                                    )
                                    .toList(),
                              ),
                      ),
                      const SizedBox(height: 32),
                      Text('Streak', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 12),
                      insightsAsync.when(
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (error, stackTrace) => Text(
                          'You\'re building a consistent reading habit.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        data: (data) => ProfileStreakMiniCard(data: data),
                      ),
                      const SizedBox(height: 32),
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

  void _showEditUsername(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => EditUsernameSheet(current: current, ref: ref),
    );
  }

  void _showPickAvatar(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => PickAvatarSheet(ref: ref),
    );
  }

  void _showEditPreferences(
    BuildContext context,
    WidgetRef ref,
    List<String> current,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => EditPreferencesSheet(current: current, ref: ref),
    );
  }
}
