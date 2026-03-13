import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/api_client.dart';
import '../../auth/data/auth_provider.dart';
import '../../insights/data/insights_provider.dart';
import '../../onboarding/data/preferences_provider.dart';
import '../../onboarding/presentation/preferences_screen.dart';

// ── All bundled profile photo asset paths ──
const _kProfilePhotos = [
  'assets/profile_photos/___11_-removebg-preview 2.png',
  'assets/profile_photos/___11_-removebg-preview 3.png',
  'assets/profile_photos/___11_-removebg-preview 4.png',
  'assets/profile_photos/___11_-removebg-preview 5.png',
  'assets/profile_photos/___11_-removebg-preview 6.png',
  'assets/profile_photos/___11_-removebg-preview 7.png',
  'assets/profile_photos/___11_-removebg-preview 8.png',
  'assets/profile_photos/___11_-removebg-preview 9.png',
  'assets/profile_photos/___11_-removebg-preview 10.png',
  'assets/profile_photos/___11_-removebg-preview 13.png',
  'assets/profile_photos/___11_-removebg-preview 14.png',
  'assets/profile_photos/___11_-removebg-preview 15.png',
];

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final prefsAsync = ref.watch(preferencesProvider);
    final insightsAsync = ref.watch(insightsProvider);

    // Display name: username if set, otherwise part before @ in email
    final displayName = (authState.username?.isNotEmpty == true)
        ? authState.username!
        : (authState.email?.split('@').first ?? 'User');

    // Current avatar asset
    final avatarAsset =
        authState.profilePhoto ?? 'assets/images/profile picture.png';

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

                      // ── Avatar + Name row ──
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
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: AppColors.textPrimary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 14,
                                      color: Colors.white,
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

                      // ── Email ──
                      Text(
                        authState.email ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 28),

                      // ── Preferences ──
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
                        error: (_, _) => Text(
                          'Could not load preferences',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        data: (cats) => cats.isEmpty
                            ? GestureDetector(
                                onTap: () =>
                                    _showEditPreferences(context, ref, []),
                                child: Text(
                                  'No preferences set. Tap to add →',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: cats
                                    .map((l) => _PreferenceChip(label: l))
                                    .toList(),
                              ),
                      ),

                      const SizedBox(height: 32),

                      // ── Streak mini-insights ──
                      Text('Streak', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 12),
                      insightsAsync.when(
                        loading: () => const SizedBox(
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        error: (_, _) => Text(
                          "You're building a consistent reading habit.",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        data: (data) => _StreakMiniCard(data: data),
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

  // ── Edit username bottom sheet ──────────────────────────────
  void _showEditUsername(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => _EditUsernameSheet(current: current, ref: ref),
    );
  }

  // ── Profile photo picker bottom sheet ───────────────────────
  void _showPickAvatar(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => _PickAvatarSheet(ref: ref),
    );
  }

  // ── Edit preferences bottom sheet ──────────────────────────
  void _showEditPreferences(
    BuildContext context,
    WidgetRef ref,
    List<String> current,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (_) => _EditPreferencesSheet(current: current, ref: ref),
    );
  }
}

// ──────────────────────────────────────────────
// STREAK MINI-CARD  (inline insights on profile)
// ──────────────────────────────────────────────
class _StreakMiniCard extends StatelessWidget {
  const _StreakMiniCard({required this.data});
  final dynamic data; // InsightsData

  @override
  Widget build(BuildContext context) {
    final streak = data.currentStreak as int;
    final total = data.totalArticlesRead as int;
    final longest = data.longestStreak as int;

    String streakMsg;
    if (streak == 0) {
      streakMsg = 'No active streak — open an article to start one!';
    } else if (streak < 3) {
      streakMsg = 'Great start! Keep reading daily to build your streak.';
    } else if (streak < 7) {
      streakMsg = "You're on a roll! $streak days and counting 🔥";
    } else {
      streakMsg = "Incredible! $streak-day streak — you're unstoppable 🚀";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big streak number
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$streak',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 48),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'day streak 🔥',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            streakMsg,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Mini stat row
          Row(
            children: [
              _MiniStat(label: 'Articles Read', value: '$total'),
              Container(
                width: 1,
                height: 32,
                color: AppColors.divider,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              _MiniStat(label: 'Longest Streak', value: '$longest days'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(fontSize: 18)),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// PICK AVATAR BOTTOM SHEET
// ──────────────────────────────────────────────
class _PickAvatarSheet extends StatefulWidget {
  const _PickAvatarSheet({required this.ref});
  final WidgetRef ref;
  @override
  State<_PickAvatarSheet> createState() => _PickAvatarSheetState();
}

class _PickAvatarSheetState extends State<_PickAvatarSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected =
        widget.ref.read(authProvider).profilePhoto ??
        'assets/images/profile picture.png';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Choose Photo', style: AppTextStyles.headlineLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select a profile picture.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Grid of photo options
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: _kProfilePhotos.map((path) {
              final isSelected = _selected == path;
              return GestureDetector(
                onTap: () => setState(() => _selected = path),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.border,
                      width: isSelected ? 3 : 1.5,
                    ),
                  ),
                  child: ClipOval(child: Image.asset(path, fit: BoxFit.cover)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                widget.ref
                    .read(authProvider.notifier)
                    .updateProfilePhoto(_selected);
                Navigator.of(context).pop();
              },
              child: Text(
                'Save Photo',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.background,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EDIT USERNAME BOTTOM SHEET
// ──────────────────────────────────────────────
class _EditUsernameSheet extends StatefulWidget {
  const _EditUsernameSheet({required this.current, required this.ref});
  final String current;
  final WidgetRef ref;
  @override
  State<_EditUsernameSheet> createState() => _EditUsernameSheetState();
}

class _EditUsernameSheetState extends State<_EditUsernameSheet> {
  late final TextEditingController _ctrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name cannot be empty.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final dio = widget.ref.read(apiClientProvider).client;
    final err = await widget.ref
        .read(authProvider.notifier)
        .updateUsername(dio, name);
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _saving = false;
        _error = err;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Name', style: AppTextStyles.headlineLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Your display name',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textHint,
              ),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.border,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppColors.textPrimary,
                  width: 1.5,
                ),
              ),
              errorText: _error,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Name',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.background,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EDIT PREFERENCES BOTTOM SHEET
// ──────────────────────────────────────────────
class _EditPreferencesSheet extends StatefulWidget {
  const _EditPreferencesSheet({required this.current, required this.ref});
  final List<String> current;
  final WidgetRef ref;
  @override
  State<_EditPreferencesSheet> createState() => _EditPreferencesSheetState();
}

class _EditPreferencesSheetState extends State<_EditPreferencesSheet> {
  late Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.current);
  }

  void _toggle(String cat) {
    setState(() {
      if (_selected.contains(cat)) {
        _selected.remove(cat);
      } else {
        _selected.add(cat);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.ref
        .read(preferencesProvider.notifier)
        .save(_selected.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Preferences', style: AppTextStyles.headlineLarge),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pick the topics you care about.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kAvailableCategories.map((cat) {
              final isSelected = _selected.contains(cat);
              return GestureDetector(
                onTap: _saving ? null : () => _toggle(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.chipSelected
                        : AppColors.chipUnselected,
                    border: Border.all(color: AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    cat,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: (_selected.isNotEmpty && !_saving) ? _save : null,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save Preferences',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.background,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// PREFERENCE CHIP (display only)
// ──────────────────────────────────────────────
class _PreferenceChip extends StatelessWidget {
  const _PreferenceChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.chipSelected,
        border: Border.all(color: AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}
