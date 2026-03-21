import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/services/api_client.dart';
import '../../../auth/data/auth_provider.dart';
import '../../../onboarding/data/preferences_provider.dart';
import '../../../onboarding/presentation/preferences_screen.dart';

const kProfilePhotos = [
  'assets/profile_photos/01_boston_terrier.png',
  'assets/profile_photos/01_cat1.jpeg',
  'assets/profile_photos/01_pet1.png',
  'assets/profile_photos/02_cat2.jpeg',
  'assets/profile_photos/02_papillon.png',
  'assets/profile_photos/02_pet2.png',
  'assets/profile_photos/03_cat3.jpeg',
  'assets/profile_photos/03_miniature_pinscher.png',
  'assets/profile_photos/03_pet3.png',
  'assets/profile_photos/04_cat4.jpeg',
  'assets/profile_photos/04_doberman.png',
  'assets/profile_photos/04_pet4.png',
  'assets/profile_photos/05_cat5.jpeg',
  'assets/profile_photos/05_poodle.png',
  'assets/profile_photos/06_cat6.jpeg',
  'assets/profile_photos/06_pug.png',
  'assets/profile_photos/07_cat7.jpeg',
  'assets/profile_photos/08_cat8.jpeg',
  'assets/profile_photos/09_cat9.jpeg',
  'assets/profile_photos/10_cat10.jpeg',
];

class PickAvatarSheet extends StatefulWidget {
  const PickAvatarSheet({required this.ref, super.key});

  final WidgetRef ref;

  @override
  State<PickAvatarSheet> createState() => _PickAvatarSheetState();
}

class _PickAvatarSheetState extends State<PickAvatarSheet> {
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
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: kProfilePhotos.map((path) {
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
                shape: RoundedRectangleBorder(
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

class EditUsernameSheet extends StatefulWidget {
  const EditUsernameSheet({
    required this.current,
    required this.ref,
    super.key,
  });

  final String current;
  final WidgetRef ref;

  @override
  State<EditUsernameSheet> createState() => _EditUsernameSheetState();
}

class _EditUsernameSheetState extends State<EditUsernameSheet> {
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
    final err = await widget.ref.read(authProvider.notifier).updateUsername(
      dio,
      name,
    );
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
                shape: RoundedRectangleBorder(
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

class EditPreferencesSheet extends StatefulWidget {
  const EditPreferencesSheet({
    required this.current,
    required this.ref,
    super.key,
  });

  final List<String> current;
  final WidgetRef ref;

  @override
  State<EditPreferencesSheet> createState() => _EditPreferencesSheetState();
}

class _EditPreferencesSheetState extends State<EditPreferencesSheet> {
  late Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.current);
  }

  void _toggle(String category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.ref
        .read(preferencesProvider.notifier)
        .save(_selected.toList());
    if (mounted) {
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
            children: kAvailableCategories.map((category) {
              final isSelected = _selected.contains(category);
              return GestureDetector(
                onTap: _saving ? null : () => _toggle(category),
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
                    category,
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
                shape: RoundedRectangleBorder(
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
