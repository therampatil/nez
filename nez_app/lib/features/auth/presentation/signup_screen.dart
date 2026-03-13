import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_button.dart';
import '../../../shared/widgets/nez_card.dart';
import '../../../shared/widgets/nez_logo.dart';
import '../../../shared/widgets/nez_text_field.dart';
import '../../../shared/widgets/onboarding_progress.dart';
import '../data/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _localError;

  Future<void> _onSignup() async {
    setState(() => _localError = null);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Email and password are required.');
      return;
    }
    if (password != confirm) {
      setState(() => _localError = 'Passwords do not match.');
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _localError = 'Please agree to the Terms of Service.');
      return;
    }

    ref.read(authProvider.notifier).clearError();
    await ref
        .read(authProvider.notifier)
        .signup(email: email, password: password);

    if (!mounted) return;
    final auth = ref.read(authProvider);

    if (auth.needsEmailVerification) {
      // Backend sent a verification email — navigate to pending screen.
      context.go('/verify-email');
      return;
    }

    if (auth.isAuthenticated) {
      // Mark that this is a fresh signup → router will redirect to /preferences.
      ref.read(needsPreferencesProvider.notifier).state = true;
      context.go('/preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 12),

                              // ── Logo ──
                              const NezLogo(height: 60),

                              const SizedBox(height: 16),

                              // ── Onboarding progress: step 1 of 2 ──
                              const OnboardingProgress(
                                currentStep: 1,
                                totalSteps: 2,
                              ),

                              const SizedBox(height: 8),

                              // ── Step label ──
                              Text(
                                'Step 1 of 2 — Create your account',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ── Card ──
                              NezCard(
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  28,
                                  24,
                                  28,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Heading + subtitle
                                    Text(
                                      'Sign Up',
                                      style: AppTextStyles.displayMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Join Nez — see news differently.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Full Name
                                    NezTextField(
                                      hint: 'Full Name',
                                      controller: _nameCtrl,
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.name],
                                    ),

                                    const SizedBox(height: 20),

                                    // Email
                                    NezTextField(
                                      hint: 'Email',
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Password
                                    NezTextField(
                                      hint: 'Password',
                                      controller: _passwordCtrl,
                                      obscureText: true,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                    ),

                                    const SizedBox(height: 20),

                                    // Confirm Password
                                    NezTextField(
                                      hint: 'Confirm Password',
                                      controller: _confirmCtrl,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                    ),

                                    const SizedBox(height: 16),

                                    // ── Terms checkbox ──
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _agreedToTerms = !_agreedToTerms,
                                      ),
                                      behavior: HitTestBehavior.opaque,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            width: 20,
                                            height: 20,
                                            margin: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _agreedToTerms
                                                  ? AppColors.textPrimary
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: AppColors.border,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: _agreedToTerms
                                                ? const Icon(
                                                    Icons.check_rounded,
                                                    size: 14,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                text: 'I agree to the ',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontSize: 12,
                                                    ),
                                                children: [
                                                  TextSpan(
                                                    text: 'Terms of Service',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                          color: AppColors
                                                              .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              AppColors
                                                                  .textPrimary,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: ' and ',
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          color: AppColors
                                                              .textSecondary,
                                                          fontSize: 12,
                                                        ),
                                                  ),
                                                  TextSpan(
                                                    text: 'Privacy Policy',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                          color: AppColors
                                                              .textPrimary,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              AppColors
                                                                  .textPrimary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // Error message
                                    Builder(
                                      builder: (context) {
                                        final serverError = ref.watch(
                                          authProvider.select(
                                            (s) => s.errorMessage,
                                          ),
                                        );
                                        final msg = _localError ?? serverError;
                                        if (msg == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Text(
                                            msg,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.error,
                                                  fontSize: 13,
                                                ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Next button
                                    Builder(
                                      builder: (context) {
                                        final isLoading = ref.watch(
                                          authProvider.select(
                                            (s) => s.isLoading,
                                          ),
                                        );
                                        return NezButton(
                                          label: 'Next',
                                          isLoading: isLoading,
                                          onPressed: isLoading
                                              ? null
                                              : _onSignup,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // ── Or divider ──
                              const _OrDivider(label: 'Or sign up with'),

                              const SizedBox(height: 20),

                              // Social row
                              const _SocialRow(),

                              const SizedBox(height: 36),

                              // Login link — bordered chip style
                              GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: 'Already on Nez?  ',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Login',
                                          style: AppTextStyles.labelMedium
                                              .copyWith(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
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
}

// ──────────────────────────────────────────────
// OR DIVIDER
// ──────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider, thickness: 1)),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// SOCIAL BUTTON ROW — Google + Apple
// ──────────────────────────────────────────────
class _SocialRow extends ConsumerWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          onTap: isLoading
              ? null
              : () {
                  ref.read(authProvider.notifier).signInWithGoogle().then((_) {
                    if (context.mounted) {
                      final auth = ref.read(authProvider);
                      if (auth.isAuthenticated) {
                        context.go('/preferences');
                      }
                    }
                  });
                },
          child: Image.asset(
            'assets/images/googleicon.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        _SocialButton(
          child: const Icon(
            Icons.apple_rounded,
            size: 28,
            color: AppColors.textPrimary,
          ),
          onTap: () {
            // TODO: Implement Apple Sign-In
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Apple Sign-In coming soon'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// SOCIAL BUTTON — bordered square, Nez hard shadow
// ──────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.background,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
