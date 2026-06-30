import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/utils/stats_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/lineup_model.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/lineup_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';

/// Tab 2 Center Panel — tabel statistik real-time seluruh pemain yang
/// sudah bermain (SRS FR-LMS-16). Terlihat oleh Statistician, Coach, dan
/// Manager selama pertandingan berlangsung.
///
/// Sumber data: Firestore listener pada `matches/{matchId}/player_stats`
/// — diperbarui otomatis setiap kali [MatchActionNotifier] menulis
/// increment via `FieldValue.increment()`, tanpa polling.
class LivePlayerStatsTable extends ConsumerWidget {
  final String matchId;
  const LivePlayerStatsTable({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(livePlayerStatsStreamProvider(matchId));
    final lineups = ref.watch(allLineupStreamProvider(matchId)).valueOrNull;
    final timerState = ref.watch(timerStateStreamProvider(matchId)).valueOrNull;
    final currentRemaining =
        timerState == null ? null : currentRemainingSeconds(timerState);

    return statsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF64748B)),
      ),
      error: (e, _) => Center(
        child: Text(
          'Gagal memuat statistik: $e',
          style: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
      ),
      data: (stats) {
        if (stats.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada statistik tercatat.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          );
        }

        final mergedStats = _mergeStatsByPlayer(stats);
        final sorted = [...mergedStats]
          ..sort((a, b) {
            final efCompare = _efficiencyFor(b).compareTo(_efficiencyFor(a));
            if (efCompare != 0) return efCompare;
            return b.points.compareTo(a.points);
          });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 32,
              dataRowMinHeight: 30,
              dataRowMaxHeight: 34,
              columnSpacing: 14,
              headingTextStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              dataTextStyle: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 11,
              ),
              columns: const [
                DataColumn(label: Text('#')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('MIN'), numeric: true),
                DataColumn(label: Text('PTS'), numeric: true),
                DataColumn(label: Text('EF'), numeric: true),
                DataColumn(label: Text('FT%'), numeric: true),
                DataColumn(label: Text('FG2%'), numeric: true),
                DataColumn(label: Text('FG3%'), numeric: true),
                DataColumn(label: Text('FG%'), numeric: true),
                DataColumn(label: Text('AST'), numeric: true),
                DataColumn(label: Text('OREB'), numeric: true),
                DataColumn(label: Text('DREB'), numeric: true),
                DataColumn(label: Text('STL'), numeric: true),
                DataColumn(label: Text('TO'), numeric: true),
                DataColumn(label: Text('BLK'), numeric: true),
                DataColumn(label: Text('FOUL'), numeric: true),
              ],
              rows: sorted
                  .map(
                    (s) => _buildRow(
                      s,
                      displaySeconds: _displaySecondsFor(
                        s,
                        lineups,
                        currentRemaining,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  List<PlayerStatsModel> _mergeStatsByPlayer(List<PlayerStatsModel> stats) {
    final byPlayerId = <String, PlayerStatsModel>{};

    for (final item in stats) {
      final existing = byPlayerId[item.playerId];
      if (existing == null) {
        byPlayerId[item.playerId] = item;
        continue;
      }

      byPlayerId[item.playerId] = existing.copyWith(
        id: existing.id,
        fullName:
            existing.fullName.isNotEmpty ? existing.fullName : item.fullName,
        jerseyNumber: existing.jerseyNumber != 0
            ? existing.jerseyNumber
            : item.jerseyNumber,
        points: existing.points + item.points,
        ftMade: existing.ftMade + item.ftMade,
        ftAttempted: existing.ftAttempted + item.ftAttempted,
        fg2Made: existing.fg2Made + item.fg2Made,
        fg2Attempted: existing.fg2Attempted + item.fg2Attempted,
        fg3Made: existing.fg3Made + item.fg3Made,
        fg3Attempted: existing.fg3Attempted + item.fg3Attempted,
        assists: existing.assists + item.assists,
        offensiveRebounds:
            existing.offensiveRebounds + item.offensiveRebounds,
        defensiveRebounds:
            existing.defensiveRebounds + item.defensiveRebounds,
        steals: existing.steals + item.steals,
        turnovers: existing.turnovers + item.turnovers,
        blocks: existing.blocks + item.blocks,
        fouls: existing.fouls + item.fouls,
        totalSecondsPlayed:
            existing.totalSecondsPlayed + item.totalSecondsPlayed,
      );
    }

    return byPlayerId.values.toList();
  }

  int _displaySecondsFor(
    PlayerStatsModel stats,
    List<LineupModel>? lineups,
    double? currentRemaining,
  ) {
    if (lineups == null || currentRemaining == null) {
      return stats.totalSecondsPlayed;
    }

    for (final lineup in lineups) {
      if (lineup.id != stats.id && lineup.playerId != stats.playerId) continue;
      final enteredAt = lineup.enteredAtClock;
      if (!lineup.isOnCourt || enteredAt == null) {
        return lineup.totalSecondsPlayed;
      }
      final currentStint =
          (enteredAt - currentRemaining).clamp(0.0, double.infinity).round();
      return lineup.totalSecondsPlayed + currentStint;
    }

    return stats.totalSecondsPlayed;
  }

  DataRow _buildRow(PlayerStatsModel s, {required int displaySeconds}) {
    final ftPct = StatsCalculator.ftPercentage(s.ftMade, s.ftAttempted);
    final fg2Pct = StatsCalculator.fg2Percentage(s.fg2Made, s.fg2Attempted);
    final fg3Pct = StatsCalculator.fg3Percentage(s.fg3Made, s.fg3Attempted);
    final fgPct = StatsCalculator.fgPercentage(
      s.fg2Made,
      s.fg2Attempted,
      s.fg3Made,
      s.fg3Attempted,
    );
    final efficiency = _efficiencyFor(s);

    return DataRow(
      cells: [
        DataCell(Text('${s.jerseyNumber}')),
        DataCell(Text(s.fullName)),
        DataCell(Text(StatsCalculator.formatMinutes(displaySeconds))),
        DataCell(
          Text(
            '${s.points}',
            style: const TextStyle(
              color: Color(0xFFE8420A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            '$efficiency',
            style: TextStyle(
              color: efficiency >= 0
                  ? const Color(0xFF86EFAC)
                  : const Color(0xFFFCA5A5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(Text(_fmtPct(ftPct))),
        DataCell(Text(_fmtPct(fg2Pct))),
        DataCell(Text(_fmtPct(fg3Pct))),
        DataCell(Text(_fmtPct(fgPct))),
        DataCell(Text('${s.assists}')),
        DataCell(Text('${s.offensiveRebounds}')),
        DataCell(Text('${s.defensiveRebounds}')),
        DataCell(Text('${s.steals}')),
        DataCell(Text('${s.turnovers}')),
        DataCell(Text('${s.blocks}')),
        DataCell(
          Text(
            '${s.fouls}',
            style: TextStyle(
              color: s.fouls >= 5
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE2E8F0),
            ),
          ),
        ),
      ],
    );
  }

  int _efficiencyFor(PlayerStatsModel s) {
    return StatsCalculator.efficiency(
      points: s.points,
      offensiveRebounds: s.offensiveRebounds,
      defensiveRebounds: s.defensiveRebounds,
      assists: s.assists,
      steals: s.steals,
      blocks: s.blocks,
      fg2Made: s.fg2Made,
      fg2Attempted: s.fg2Attempted,
      fg3Made: s.fg3Made,
      fg3Attempted: s.fg3Attempted,
      ftMade: s.ftMade,
      ftAttempted: s.ftAttempted,
      turnovers: s.turnovers,
    );
  }

  String _fmtPct(double value) => '${value.toStringAsFixed(0)}%';
}
