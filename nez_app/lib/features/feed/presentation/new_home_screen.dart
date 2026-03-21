import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../notifications/providers/notifications_provider.dart';
import '../../../shared/widgets/nez_top_bar.dart';
import '../data/feed_provider.dart';
import 'controllers/daily_debate_controller.dart';
import 'widgets/daily_twelve_section.dart';
import 'widgets/for_you_insights_section.dart';
import 'widgets/the_big_picture_section.dart';
import 'widgets/the_divide_section.dart';

/// New Home Screen - Top 12 Headlines
class NewHomeScreen extends ConsumerStatefulWidget {
  const NewHomeScreen({super.key});

  @override
  ConsumerState<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends ConsumerState<NewHomeScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final double _viewportFraction = 0.85;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _viewportFraction,
      initialPage: 0,
    );
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    if (_pageController.page != null) {
      final page = _pageController.page!.round();
      if (page != _currentPage) {
        setState(() => _currentPage = page);
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(headlinesProvider);
    await ref.read(headlinesProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final headlinesAsync = ref.watch(headlinesProvider);
    final debateState = ref.watch(dailyDebateControllerProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NezTopBar(showNotificationBadge: unreadCount > 0),

            Expanded(
              child: RefreshIndicator(
                color: AppColors.textPrimary,
                backgroundColor: AppColors.card,
                strokeWidth: 2,
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      DailyTwelveSection(
                        headlinesAsync: headlinesAsync,
                        pageController: _pageController,
                        currentPage: _currentPage,
                        onRetry: () => ref.invalidate(headlinesProvider),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TheDivideSection(
                          userVote: debateState.userVote,
                          forVotes: debateState.forVotes,
                          againstVotes: debateState.againstVotes,
                          onVote: ref
                              .read(dailyDebateControllerProvider.notifier)
                              .vote,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const TheBigPictureSection(),
                      ),
                      const SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const ForYouInsightsSection(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
