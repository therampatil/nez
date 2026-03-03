import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/nez_logo.dart';

/// Welcome / splash screen.
/// Logo fades IN (800ms) → holds (1.4s) → fades OUT (600ms) → auto-navigates to /login.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Fade-in: 0.0 → 0.4 of the total timeline
  late final Animation<double> _fadeIn;

  // Fade-out: 0.7 → 1.0 of the total timeline
  late final Animation<double> _fadeOut;

  // Total duration: fade-in (800ms) + hold (1400ms) + fade-out (600ms) = 2800ms
  static const _total = Duration(milliseconds: 2800);

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(vsync: this, duration: _total);

    _fadeIn = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.29, curve: Curves.easeOut),
    );

    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
    );

    _ctrl.forward().whenComplete(_navigateToLogin);
  }

  void _navigateToLogin() {
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            // Combine fade-in rising and fade-out falling into one opacity value
            final opacity = _fadeIn.value * (1.0 - _fadeOut.value);
            return Opacity(opacity: opacity.clamp(0.0, 1.0), child: child);
          },
          child: const Center(child: NezLogo(height: 100)),
        ),
      ),
    );
  }
}
