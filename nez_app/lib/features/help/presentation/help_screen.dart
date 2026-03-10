import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

// ──────────────────────────────────────────────
// FAQ DATA
// ──────────────────────────────────────────────
const _faqAccount = [
  (
    q: 'How do I reset my email?',
    a:
        'Go to Settings → Account Settings → Change Email. Enter your new email address '
        'and confirm it. A verification link will be sent to your new address.',
  ),
  (
    q: 'How do I reset my password?',
    a:
        'Go to Settings → Account Settings → Change Password. Enter your current password '
        'and then type your new password twice to confirm.',
  ),
  (
    q: 'How do I log out of Nez?',
    a:
        'Open the side drawer from the home screen and scroll to the bottom where '
        'you\'ll find the "Log Out" option.',
  ),
];

const _faqPersonalization = [
  (
    q: 'How do I change my interests?',
    a:
        'Visit your Profile screen and tap "Edit Preferences". You can select or '
        'deselect categories to customise your feed at any time.',
  ),
  (
    q: 'How does Nez personalise my news?',
    a:
        'Nez uses the categories you selected during onboarding, combined with your '
        'reading history and bookmarks, to surface the most relevant stories for you.',
  ),
  (
    q: 'Is my reading data private?',
    a:
        'Yes. Your reading activity is stored locally and is never sold to third parties. '
        'See our full Privacy Policy in Settings → Data & Privacy.',
  ),
];

// ──────────────────────────────────────────────
// HELP SCREEN
// ──────────────────────────────────────────────
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
                        'Help',
                        style: AppTextStyles.displayMedium,
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: constraints.maxHeight * 0.08),

                      // ── Account ──
                      Text('Account', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 12),
                      ..._faqAccount.map(
                        (item) => _FaqTile(question: item.q, answer: item.a),
                      ),

                      const SizedBox(height: 32),

                      // ── Personalization ──
                      Text(
                        'Personalisation',
                        style: AppTextStyles.headlineLarge,
                      ),
                      const SizedBox(height: 12),
                      ..._faqPersonalization.map(
                        (item) => _FaqTile(question: item.q, answer: item.a),
                      ),

                      const SizedBox(height: 40),
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
// EXPANDABLE FAQ TILE
// ──────────────────────────────────────────────
class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _ctrl;
  late final Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Question row ──
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Answer — animated expand ──
        SizeTransition(
          sizeFactor: _expand,
          axisAlignment: -1,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              widget.answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
          ),
        ),

        // Divider
        const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
