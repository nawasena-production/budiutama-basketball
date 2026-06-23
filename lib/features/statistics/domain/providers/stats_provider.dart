import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';
import 'package:budiutama_basketball/features/statistics/data/repositories/stats_repository.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository();
});

/// Box score satu pertandingan (one-shot fetch — pertandingan sudah
/// selesai, tidak perlu listener real-time).
final matchBoxScoreProvider =
    FutureProvider.family<List<PlayerStatsModel>, String>((ref, matchId) {
  return ref.read(statsRepositoryProvider).getPlayerStatsForMatch(matchId);
});

/// Titik tembakan untuk shot chart heatmap satu pertandingan.
final matchShotChartProvider =
    FutureProvider.family<List<ShotChartEntry>, String>((ref, matchId) {
  return ref.read(statsRepositoryProvider).getShotPointsForMatch(matchId);
});

/// Statistik teragregasi seluruh pemain dalam satu event/turnamen
/// (leaderboard — FR-STT-01).
final eventAggregatedStatsProvider =
    FutureProvider.family<List<AggregatedPlayerStats>, String>((ref, eventId) {
  return ref.read(statsRepositoryProvider).getAggregatedStatsForEvent(eventId);
});

// ── UI STATE LOKAL ──────────────────────────────────────────────────────

/// Filter pemain terpilih untuk shot chart (null = tampilkan semua
/// pemain tim sendiri).
final shotChartPlayerFilterProvider = StateProvider<String?>((ref) => null);
