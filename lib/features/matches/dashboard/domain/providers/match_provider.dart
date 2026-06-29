import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/dashboard/data/models/match_model.dart';
import 'package:budiutama_basketball/features/matches/dashboard/data/repositories/match_repository.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

// ── REPOSITORY ────────────────────────────────────────────────────────────

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

/// Stream semua pertandingan dalam satu event — real-time.
final matchesByEventStreamProvider =
    StreamProvider.family<List<MatchModel>, String>((ref, eventId) {
  return ref.watch(matchRepositoryProvider).watchByEvent(eventId);
});

/// Stream satu pertandingan berdasarkan ID — digunakan di Match Mode.
final matchStreamProvider =
    StreamProvider.family<MatchModel?, String>((ref, matchId) {
  return ref.watch(matchRepositoryProvider).watchById(matchId);
});

/// Stream pertandingan yang sedang berlangsung untuk satu tim.
final ongoingMatchesProvider =
    StreamProvider.family<List<MatchModel>, String>((ref, teamId) {
  return ref.watch(matchRepositoryProvider).watchOngoing(teamId);
});

// ── SELECTED MATCH STATE ──────────────────────────────────────────────────

/// Match yang sedang dipilih — digunakan untuk konteks navigasi.
final selectedMatchIdProvider = StateProvider<String?>((ref) => null);

// ── STARTER SELECTION STATE ───────────────────────────────────────────────

/// Daftar pemain yang dipilih sebagai starter sebelum START MATCH.
/// Maksimal 5 pemain, minimal 5 pemain sebelum bisa mulai.
final selectedStartersProvider = StateProvider<List<PlayerModel>>((ref) => []);

// ── NOTIFIER ──────────────────────────────────────────────────────────────

class MatchActionsNotifier extends AsyncNotifier<void> {
  MatchRepository get _repo => ref.read(matchRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> createMatch({
    required String matchId,
    required MatchModel match,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.create(matchId: matchId, match: match);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateMatch(String matchId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repo.update(matchId, data);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> transitionState({
    required String matchId,
    required String nextState,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.transitionState(matchId: matchId, nextState: nextState);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateTimerConfig(
    String matchId, {
    required int quarterDurationMinutes,
    required int numPeriods,
    required int otDurationMinutes,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.updateTimerConfig(
        matchId,
        quarterDurationMinutes: quarterDurationMinutes,
        numPeriods: numPeriods,
        otDurationMinutes: otDurationMinutes,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Mulai pertandingan — batch write ke Firestore:
  /// update match status + init lineup + init player_stats + init timer_state.
  Future<bool> startMatch({
    required String matchId,
    required List<PlayerModel> starters,
    required int quarterDurationMinutes,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.startMatch(
        matchId: matchId,
        starters: starters,
        quarterDurationMinutes: quarterDurationMinutes,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> cancelMatch(String matchId) async {
    state = const AsyncLoading();
    try {
      await _repo.cancelMatch(matchId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final matchActionsProvider = AsyncNotifierProvider<MatchActionsNotifier, void>(
  MatchActionsNotifier.new,
);
