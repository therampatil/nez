import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/design_constants.dart';
import '../../../shared/widgets/nez_button.dart';
import '../../../shared/widgets/nez_card.dart';
import '../../../shared/widgets/nez_logo.dart';
import '../../../shared/widgets/onboarding_progress.dart';
import '../data/preferences_provider.dart';
import '../../auth/data/auth_provider.dart';

// ──────────────────────────────────────────────
// The canonical list of categories — single source of truth.
// These string values are stored directly in the database.
// ──────────────────────────────────────────────
const List<String> kAvailableCategories = [
  'Technology',
  'Business',
  'Laws',
  'Society',
  'Global',
  'Money',
  'Environment',
  'Career',
  'Social',
  'Education',
];

// ──────────────────────────────────────────────
// LOCAL SELECTION STATE (chip toggles)
// ──────────────────────────────────────────────
final _localSelectionProvider =
    StateNotifierProvider.autoDispose<_LocalSelectionNotifier, Set<String>>((
      ref,
    ) {
      // Pre-populate with whatever is already saved on the backend.
      final saved = ref.watch(preferencesProvider).valueOrNull ?? [];
      return _LocalSelectionNotifier(Set<String>.from(saved));
    });

class _LocalSelectionNotifier extends StateNotifier<Set<String>> {
  _LocalSelectionNotifier(super.initial);

  void toggle(String category) {
    if (state.contains(category)) {
      state = {...state}..remove(category);
    } else {
      state = {...state, category};
    }
  }
}

// ──────────────────────────────────────────────
// SCREEN
// ──────────────────────────────────────────────
class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_localSelectionProvider);
    final isSaving = ref.watch(preferencesProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          const NezLogo(height: 60),
                          const SizedBox(height: 16),
                          const OnboardingProgress(
                            currentStep: 2,
                            totalSteps: 2,
                          ),
                          const SizedBox(height: 16),

                          NezCard(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shape Your\nFeed',
                                  style: AppTextStyles.displayMedium,
                                  softWrap: true,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pick at least one topic you care about.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: kAvailableCategories.map((cat) {
                                    final isSelected = selected.contains(cat);
                                    return _CategoryChip(
                                      label: cat,
                                      isSelected: isSelected,
                                      onTap: () => ref
                                          .read(
                                            _localSelectionProvider.notifier,
                                          )
                                          .toggle(cat),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              Expanded(
                                child: NezButton(
                                  label: 'Back',
                                  variant: NezButtonVariant.outlined,
                                  onPressed: isSaving
                                      ? null
                                      : () => context.go('/signup'),
                                ),
                              ),
                              const SizedBox(width: DesignConstants.spacingMD),
                              Expanded(
                                child: NezButton(
                                  label: isSaving ? 'Saving…' : 'Get Started',
                                  onPressed: selected.isNotEmpty && !isSaving
                                      ? () => _save(context, ref, selected)
                                      : null,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    Set<String> selected,
  ) async {
    await ref.read(preferencesProvider.notifier).save(selected.toList());

    // Signup flow is complete — clear the "needs preferences" gate.
    ref.read(needsPreferencesProvider.notifier).state = false;

    if (context.mounted) context.go('/home');
  }
}

// ──────────────────────────────────────────────
// CHIP
// ──────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.chipSelected : AppColors.chipUnselected,
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
