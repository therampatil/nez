import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_button.dart';
import '../../../shared/widgets/nez_logo.dart';
import '../data/auth_provider.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  bool _isSendingAgain = false;
  bool _resentSuccess = false;
  String? _resendError;

  bool _isChecking = false;
  String? _checkError;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String get _email =>
      ref.read(authProvider).pendingVerificationEmail ?? 'your email';

  // ── Resend verification email ──────────────────────────────────────────────

  Future<void> _resend() async {
    setState(() {
      _isSendingAgain = true;
      _resentSuccess = false;
      _resendError = null;
    });

    final error = await ref
        .read(authProvider.notifier)
        .resendVerification(_email);

    if (!mounted) return;
    setState(() {
      _isSendingAgain = false;
      if (error == null) {
        _resentSuccess = true;
      } else {
        _resendError = error;
      }
    });

    // Auto-clear the success badge after 4 seconds.
    if (error == null) {
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _resentSuccess = false);
      });
    }
  }

  // ── "I've verified" — auto-login and go to preferences ─────────────────────

  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
      _checkError = null;
    });

    // Attempt to log in with the stored signup credentials.
    final error = await ref
        .read(authProvider.notifier)
        .loginAfterVerification();

    if (!mounted) return;
    setState(() => _isChecking = false);

    if (error == null) {
      // Login succeeded — this is a fresh signup, send to preferences.
      ref.read(needsPreferencesProvider.notifier).state = true;
      context.go('/preferences');
    } else if (error.contains('verify') || error.contains('verified')) {
      // Email still not verified — show friendly message.
      setState(
        () => _checkError =
            'Your email is not verified yet. Please click the link in your inbox first.',
      );
    } else {
      // Other error (e.g. session expired) — fall back to login screen.
      setState(() => _checkError = error);
    }
  }

  // ── Navigate back to signup ────────────────────────────────────────────────

  void _goBack() {
    ref.read(authProvider.notifier).clearPendingVerification();
    context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo ────────────────────────────────────────────────
                    const Center(child: NezLogo(height: 52)),

                    const SizedBox(height: 40),

                    // ── Envelope icon ────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF000000),
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mark_email_unread_outlined,
                            size: 38,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Heading ──────────────────────────────────────────────
                    Text(
                      'Check your inbox',
                      style: AppTextStyles.displayMedium,
                    ),

                    const SizedBox(height: 10),

                    // ── Body copy ────────────────────────────────────────────
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                          fontSize: 14,
                        ),
                        children: [
                          const TextSpan(
                            text: 'We sent a verification link to\n',
                          ),
                          TextSpan(
                            text: _email,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '\n\nClick the link in that email to activate '
                                'your account. Once verified, tap the button '
                                'below and we\'ll take you straight in.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── CTA ──────────────────────────────────────────────────
                    NezButton(
                      label: "I've verified — Continue",
                      isLoading: _isChecking,
                      onPressed: _isChecking ? null : _checkVerification,
                    ),

                    if (_checkError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _checkError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Divider ──────────────────────────────────────────────
                    const Divider(color: AppColors.divider, thickness: 1),

                    const SizedBox(height: 20),

                    // ── Resend section ───────────────────────────────────────
                    Text(
                      "Didn't receive it?",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Check your spam folder first. If it\'s not there, '
                      'tap below to resend.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Resend button — outlined style
                    SizedBox(
                      width: double.infinity,
                      child: _isSendingAgain
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: _resend,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF000000),
                                      offset: Offset(3, 3),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Resend verification email',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),

                    // Resend feedback
                    if (_resentSuccess) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verification email sent!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (_resendError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _resendError!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // ── Wrong email? go back ─────────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _goBack,
                        child: Text(
                          'Wrong email? Go back',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
