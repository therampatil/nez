import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/data/auth_provider.dart';
import '../features/auth/data/auth_state.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/verify_email_screen.dart';
import '../features/onboarding/presentation/preferences_screen.dart';
import '../features/main_shell.dart';
import '../features/impact/presentation/impact_screen.dart';
import '../features/feed/data/feed_provider.dart';

/// Public routes that do NOT require authentication.
const _publicPaths = {'/welcome', '/login', '/signup', '/verify-email'};

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
    ref.listen<bool>(needsPreferencesProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/welcome',
    refreshListenable: refreshNotifier,
    // Handle incoming deep links: nez://article/<id>
    redirect: (BuildContext context, GoRouterState state) {
      final auth = ref.read(authProvider);
      final needsPrefs = ref.read(needsPreferencesProvider);

      if (auth.isLoading) return null;

      final isPublic = _publicPaths.contains(state.matchedLocation);
      final isPrefsPage = state.matchedLocation == '/preferences';
      final isVerifyPage = state.matchedLocation == '/verify-email';

      // If awaiting email verification, keep user on verify screen.
      if (auth.needsEmailVerification && !isVerifyPage) return '/verify-email';

      if (!auth.isAuthenticated && !isPublic) return '/login';

      if (auth.isAuthenticated && isPublic) {
        // Fresh signup flow sets needsPrefs = true → go to preferences once.
        // Normal login never sets needsPrefs → go straight to /home.
        return needsPrefs ? '/preferences' : '/home';
      }

      // Allow navigating to /preferences from settings; don't block it.
      if (auth.isAuthenticated && isPrefsPage) return null;

      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/preferences',
        builder: (_, __) => const PreferencesScreen(),
      ),
      GoRoute(
        path: '/article/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return ArticleDeepLinkPage(articleId: id ?? '0');
        },
      ),
      GoRoute(path: '/home', builder: (_, __) => const MainShell()),
    ],
  );
});

/// Temporary small page that resolves an article id into an [ApiArticle]
/// from the live feed and opens the ImpactScreen. If the article isn't
/// present in the cached feed, it displays a friendly message.
class ArticleDeepLinkPage extends ConsumerWidget {
  const ArticleDeepLinkPage({required this.articleId, super.key});
  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    final parsedId = int.tryParse(articleId) ?? 0;

    return feedAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(
          child: Text(
            'Could not load article.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
      data: (articles) {
        final idx = articles.indexWhere((a) => a.id == parsedId);
        if (idx == -1) {
          return Scaffold(
            body: Center(
              child: Text(
                'Article not available in feed.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          );
        }
        // Found — show ImpactScreen directly.
        return ImpactScreen(article: articles[idx], articleIndex: idx);
      },
    );
  }
}
