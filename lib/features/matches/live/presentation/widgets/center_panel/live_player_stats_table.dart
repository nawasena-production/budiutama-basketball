import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/utils/stats_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';
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

        // Urutkan berdasarkan poin terbanyak — paling relevan untuk
        // dipantau Coach/Manager selama pertandingan berlangsung.
        final sorted = [...stats]..sort((a, b) => b.points.compareTo(a.points));

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
                DataColumn(label: Text('PTS'), numeric: true),
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
              rows: sorted.map((s) => _buildRow(s)).toList(),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildRow(PlayerStatsModel s) {
    final ftPct = StatsCalculator.ftPercentage(s.ftMade, s.ftAttempted);
    final fg2Pct = StatsCalculator.fg2Percentage(s.fg2Made, s.fg2Attempted);
    final fg3Pct = StatsCalculator.fg3Percentage(s.fg3Made, s.fg3Attempted);
    final fgPct = StatsCalculator.fgPercentage(
      s.fg2Made,
      s.fg2Attempted,
      s.fg3Made,
      s.fg3Attempted,
    );

    return DataRow(
      cells: [
        DataCell(Text('${s.jerseyNumber}')),
        DataCell(Text(s.fullName)),
        DataCell(
          Text(
            '${s.points}',
            style: const TextStyle(
              color: Color(0xFFE8420A),
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

  String _fmtPct(double value) => '${value.toStringAsFixed(0)}%';
}
