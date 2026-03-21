import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyDebateState {
  const DailyDebateState({
    this.userVote,
    this.forVotes = 6100,
    this.againstVotes = 3900,
  });

  final String? userVote;
  final int forVotes;
  final int againstVotes;

  DailyDebateState copyWith({
    String? userVote,
    int? forVotes,
    int? againstVotes,
  }) {
    return DailyDebateState(
      userVote: userVote ?? this.userVote,
      forVotes: forVotes ?? this.forVotes,
      againstVotes: againstVotes ?? this.againstVotes,
    );
  }
}

class DailyDebateController extends StateNotifier<DailyDebateState> {
  DailyDebateController() : super(const DailyDebateState());

  void vote(String side) {
    if (state.userVote != null) return;
    state = state.copyWith(
      userVote: side,
      forVotes: side == 'for' ? state.forVotes + 1 : state.forVotes,
      againstVotes: side == 'against'
          ? state.againstVotes + 1
          : state.againstVotes,
    );
  }
}

final dailyDebateControllerProvider =
    StateNotifierProvider.autoDispose<DailyDebateController, DailyDebateState>(
      (ref) => DailyDebateController(),
    );
