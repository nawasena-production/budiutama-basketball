import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';
import 'package:budiutama_basketball/features/matches/live/data/repositories/timer_repository.dart';
import 'package:budiutama_basketball/features/matches/live/data/repositories/match_event_repository.dart';
import 'package:budiutama_basketball/features/matches/live/data/repositories/player_stats_repository.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/match_event_model.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';

// ── REPOSITORIES ────────────────────────────────────────────────────────

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository();
});

final matchEventRepositoryProvider = Provider<MatchEventRepository>((ref) {
  return MatchEventRepository();
});

final playerStatsRepositoryProvider = Provider<PlayerStatsRepository>((ref) {
  return PlayerStatsRepository();
});

// ── STREAMS ─────────────────────────────────────────────────────────────

/// Stream `timer_state` real-time — dipakai [MatchTimerWidget] sebagai
/// sumber `secondsAtStart` + `startedAt` + `isRunning` untuk dihitung
/// ulang secara lokal tiap frame via `currentRemainingSeconds()`.
final timerStateStreamProvider =
    StreamProvider.family<TimerStateModel, String>((ref, matchId) {
  return ref.watch(timerRepositoryProvider).watchTimer(matchId);
});

/// Stream seluruh event pertandingan, terbaru di atas — dipakai
/// [EventTimeline] (FR-LMS-09).
final matchEventsStreamProvider =
    StreamProvider.family<List<MatchEventModel>, String>((ref, matchId) {
  return ref.watch(matchEventRepositoryProvider).watchEvents(matchId);
});

/// Versi terbatas (N event terakhir) — dipakai jika timeline hanya
/// menampilkan sebagian kecil history demi performa render.
final recentMatchEventsStreamProvider =
    StreamProvider.family<List<MatchEventModel>, ({String matchId, int limit})>(
        (ref, params) {
  return ref
      .watch(matchEventRepositoryProvider)
      .watchEvents(params.matchId)
      .map((events) => events.take(params.limit).toList());
});

/// Stream `player_stats` real-time seluruh pemain — dipakai Tab 2
/// Live Player Stats (FR-LMS-16) dan juga oleh [PlayerListPanel] untuk
/// menampilkan poin pemain di kartu Left Panel.
final livePlayerStatsStreamProvider =
    StreamProvider.family<List<PlayerStatsModel>, String>((ref, matchId) {
  return ref.watch(playerStatsRepositoryProvider).watchLiveStats(matchId);
});

// ── UI STATE LOKAL (BUKAN FIRESTORE) ──────────────────────────────────────

/// Pemain yang sedang dipilih di Left Panel sebelum tap tombol aksi.
/// Key: matchId — supaya tidak bocor antar pertandingan berbeda jika
/// Riverpod scope di-reuse (meski dalam praktiknya MatchModePage selalu
/// fresh karena push/pop route).
final selectedPlayerLineupIdProvider =
    StateProvider.family<String?, String>((ref, matchId) => null);

/// Index tab aktif di Center Panel: 0 = Input Mode, 1 = Live Player Stats.
final centerPanelTabIndexProvider =
    StateProvider.family<int, String>((ref, matchId) => 0);

/// Action type yang sedang menunggu input lokasi di Court Overlay.
/// Null artinya court overlay tidak ditampilkan.
final pendingShotActionProvider =
    StateProvider.family<String?, String>((ref, matchId) => null);
