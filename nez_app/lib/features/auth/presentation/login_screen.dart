import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_button.dart';
import '../../../shared/widgets/nez_card.dart';
import '../../../shared/widgets/nez_logo.dart';
import '../../../shared/widgets/nez_text_field.dart';
import '../data/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Tracks whether the last login attempt failed because email is unverified.
  bool _isUnverified = false;
  bool _isSendingResend = false;
  bool _resentSuccess = false;

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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  static const _unverifiedMsg = 'Please verify your email before logging in.';

  Future<void> _onLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() {
      _isUnverified = false;
      _resentSuccess = false;
    });

    ref.read(authProvider.notifier).clearError();
    await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      // Login always goes to /home — preferences are only set on first signup.
      context.go('/home');
    } else if (auth.errorMessage == _unverifiedMsg) {
      setState(() => _isUnverified = true);
    }
  }

  Future<void> _resendVerification() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isSendingResend = true;
      _resentSuccess = false;
    });

    // Set pending verification email so the verify screen knows which address.
    ref.read(authProvider.notifier).clearError();

    final error = await ref
        .read(authProvider.notifier)
        .resendVerification(email);

    if (!mounted) return;
    setState(() {
      _isSendingResend = false;
      _resentSuccess = error == null;
    });
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

                              const SizedBox(height: 10),

                              // ── Tagline ──
                              Text(
                                'News that matters, impact you can see.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  letterSpacing: 0.2,
                                ),
                              ),

                              const SizedBox(height: 28),

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
                                      'Login',
                                      style: AppTextStyles.displayMedium,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Welcome back — your feed is waiting.',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    // Email field
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

                                    // Password field
                                    NezTextField(
                                      hint: 'Password',
                                      controller: _passwordCtrl,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      autofillHints: const [
                                        AutofillHints.password,
                                      ],
                                    ),

                                    // Forgot password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Forgot Password?',
                                            style: AppTextStyles.labelSmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      AppColors.textSecondary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Error / unverified banner
                                    Builder(
                                      builder: (context) {
                                        final error = ref.watch(
                                          authProvider.select(
                                            (s) => s.errorMessage,
                                          ),
                                        );

                                        // Unverified email — special banner.
                                        if (_isUnverified) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3CD),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE6A817,
                                                  ),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Email not verified',
                                                    style: AppTextStyles
                                                        .labelSmall
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFF7B5200,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Please check your inbox and click the verification link before logging in.',
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFF7B5200,
                                                          ),
                                                          fontSize: 12,
                                                          height: 1.4,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  if (_resentSuccess)
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          size: 14,
                                                          color: Color(
                                                            0xFF2E7D32,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          'Verification email sent!',
                                                          style: AppTextStyles
                                                              .bodySmall
                                                              .copyWith(
                                                                color:
                                                                    const Color(
                                                                      0xFF2E7D32,
                                                                    ),
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    GestureDetector(
                                                      onTap: _isSendingResend
                                                          ? null
                                                          : _resendVerification,
                                                      child: _isSendingResend
                                                          ? const SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color: Color(
                                                                      0xFF7B5200,
                                                                    ),
                                                                  ),
                                                            )
                                                          : Text(
                                                              'Resend verification email →',
                                                              style: AppTextStyles.labelSmall.copyWith(
                                                                color:
                                                                    const Color(
                                                                      0xFF7B5200,
                                                                    ),
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                                decorationColor:
                                                                    const Color(
                                                                      0xFF7B5200,
                                                                    ),
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        // Generic error.
                                        if (error == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Text(
                                            error,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: AppColors.error,
                                                  fontSize: 13,
                                                ),
                                          ),
                                        );
                                      },
                                    ),

                                    // Get Started button
                                    Builder(
                                      builder: (context) {
                                        final isLoading = ref.watch(
                                          authProvider.select(
                                            (s) => s.isLoading,
                                          ),
                                        );
                                        return NezButton(
                                          label: 'Get Started',
                                          isLoading: isLoading,
                                          onPressed: isLoading
                                              ? null
                                              : _onLogin,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // ── Or divider ──
                              const _OrDivider(label: 'Or continue with'),

                              const SizedBox(height: 20),

                              // Social row
                              const _SocialRow(),

                              const SizedBox(height: 36),

                              // Sign up link — bordered chip style
                              GestureDetector(
                                onTap: () => context.go('/signup'),
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
                                    text: TextSpan(
                                      text: 'New to Nez?  ',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Create Account',
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
// OR DIVIDER — line · text · line
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
          child: Image.asset(
            'assets/images/googleicon.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          onTap: isLoading
              ? null
              : () {
                  ref.read(authProvider.notifier).signInWithGoogle().then((_) {
                    if (context.mounted) {
                      final auth = ref.read(authProvider);
                      if (auth.isAuthenticated) {
                        // Google sign-in from login → go home directly.
                        context.go('/home');
                      }
                    }
                  });
                },
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
              color: Color(0xFF000000),
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
