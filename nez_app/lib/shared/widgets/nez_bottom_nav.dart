import 'package:flutter/material.dart';

/// Bottom navigation bar matching the mockup — dark pill-shaped bar with icons.
class NezBottomNav extends StatelessWidget {
  const NezBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(80, 0, 80, 40),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 27, 26, 26),
          borderRadius: BorderRadius.circular(120),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              assetPath: 'assets/images/home.png',
              index: 0,
              currentIndex: currentIndex,
              onTap: () => onTap(0),
            ),
            _NavItem(
              assetPath: 'assets/images/clock.png',
              index: 1,
              currentIndex: currentIndex,
              onTap: () => onTap(1),
            ),
            _NavItem(
              assetPath: 'assets/images/user.png',
              index: 2,
              currentIndex: currentIndex,
              onTap: () => onTap(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.assetPath,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final String assetPath;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: Image.asset(
            assetPath,
            width: 26,
            height: 26,
            color: Colors.white,
            fit: BoxFit.contain,
            opacity: AlwaysStoppedAnimation(isSelected ? 1.0 : 0.5),
          ),
        ),
      ),
    );
  }
}
