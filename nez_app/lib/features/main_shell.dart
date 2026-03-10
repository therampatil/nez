import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/shell_tab_provider.dart';
import '../shared/widgets/nez_bottom_nav.dart';
import '../shared/widgets/nez_side_drawer.dart';
import 'auth/data/auth_provider.dart';
import 'feed/presentation/home_screen.dart';
import 'insights/presentation/insights_screen.dart';
import 'bookmarks/presentation/bookmarks_screen.dart';
import 'profile/presentation/profile_screen.dart';
import 'settings/presentation/setting_screen.dart';
import 'help/presentation/help_screen.dart';
import 'about/presentation/about_screen.dart';

/// Main shell — hosts bottom nav + side drawer + page body.
/// Bottom nav : 0=Home, 1=Insights, 2=Profile
/// Side drawer: 0=Profile, 1=Saved, 2=Settings, 3=Help, 4=About
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _bottomIndex = 0;
  int _drawerIndex = 0;

  // Side drawer pages — index matches NezSideDrawer items
  static const _drawerPages = <Widget>[
    ProfileScreen(), // 0 – Profile
    BookmarksScreen(), // 1 – Saved
    SettingScreen(), // 2 – Settings
    HelpScreen(), // 3 – Help
    AboutScreen(), // 4 – About
  ];

  static const _bottomPages = <Widget>[
    HomeScreen(), // 0
    InsightsScreen(), // 1
  ];

  Widget get _currentPage {
    if (_bottomIndex < 2) return _bottomPages[_bottomIndex];
    return _drawerPages[_drawerIndex];
  }

  void _onBottomTap(int index) {
    setState(() {
      _bottomIndex = index;
      if (index == 2) _drawerIndex = 0; // default to Profile
    });
    ref.read(shellTabProvider.notifier).state = index;
  }

  void _onDrawerTap(int index) {
    setState(() {
      _drawerIndex = index;
      _bottomIndex = 2;
    });
  }

  void _onLogout() {
    ref.read(authProvider.notifier).logout();
    context.go('/login');
  }

  String get _pageKey {
    if (_bottomIndex < 2) return 'bottom_$_bottomIndex';
    return 'drawer_$_drawerIndex';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(shellTabProvider, (_, newIndex) {
      if (newIndex != _bottomIndex) {
        setState(() {
          _bottomIndex = newIndex;
          if (newIndex == 2) _drawerIndex = 0;
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ── Page body with dissolve animation ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(key: ValueKey(_pageKey), child: _currentPage),
          ),

          // ── Side drawer — always visible on profile/drawer tab ──
          if (_bottomIndex == 2)
            NezSideDrawer(
              currentIndex: _drawerIndex,
              onTap: _onDrawerTap,
              onLogout: _onLogout,
            ),
        ],
      ),
      bottomNavigationBar: NezBottomNav(
        currentIndex: _bottomIndex,
        onTap: _onBottomTap,
      ),
    );
  }
}
