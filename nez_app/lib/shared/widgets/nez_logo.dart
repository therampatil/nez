import 'package:flutter/material.dart';

/// The Nez logo loaded from assets.
/// Used consistently at the top of Login, Signup, and Preferences screens.
class NezLogo extends StatelessWidget {
  const NezLogo({super.key, this.height = 48});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/nez_logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}
