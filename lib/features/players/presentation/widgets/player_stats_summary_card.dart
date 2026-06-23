import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/utils/stats_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';

/// Card ringkasan statistik satu pemain, dipakai di PlayerDetailPage.
/// Data bersumber dari `player_stats` dokumen Firestore per pertandingan
/// yang diagregasi di layer provider.
///
/// Sesuai SRS FR-PLY-04 dan FR-STT-02.
class PlayerStatsSummaryCard extends StatelessWidget {
  /// Aggregated stats dari semua pertandingan dalam satu event/season.
  final PlayerStatsModel? stats;
  final int gamesPlayed;

  const PlayerStatsSummaryCard({
    super.key,
    required this.stats,
    required this.gamesPlayed,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFC8D6E5)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Belum ada data statistik.',
              style: TextStyle(color: Color(0xFF6B7A8D)),
            ),
          ),
        ),
      );
    }

    final s = stats!;
    final games = gamesPlayed > 0 ? gamesPlayed : 1;

    // Kalkulasi persentase menggunakan StatsCalculator
    final ftPct = StatsCalculator.ftPercentage(s.ftMade, s.ftAttempted);
    final fg2Pct = StatsCalculator.fg2Percentage(s.fg2Made, s.fg2Attempted);
    final fg3Pct = StatsCalculator.fg3Percentage(s.fg3Made, s.fg3Attempted);
    final fgPct = StatsCalculator.fgPercentage(
        s.fg2Made, s.fg2Attempted, s.fg3Made, s.fg3Attempted);

    // Per-game averages
    final ppg = (s.points / games);
    final rpg = ((s.offensiveRebounds + s.defensiveRebounds) / games);
    final apg = (s.assists / games);
    final spg = (s.steals / games);
    final bpg = (s.blocks / games);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistik',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A3A5C),
                  ),
                ),
                Text(
                  '$gamesPlayed pertandingan',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7A8D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Per-game averages row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _avgStat('PPG', ppg),
                _avgStat('RPG', rpg),
                _avgStat('APG', apg),
                _avgStat('SPG', spg),
                _avgStat('BPG', bpg),
              ],
            ),
            const Divider(height: 24),

            // Shooting percentages
            const Text(
              'Persentase Tembakan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF6B7A8D),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: _pctBar('FG%', fgPct, s.fg2Made + s.fg3Made,
                        s.fg2Attempted + s.fg3Attempted)),
                const SizedBox(width: 8),
                Expanded(
                    child: _pctBar('FG2%', fg2Pct, s.fg2Made, s.fg2Attempted)),
                const SizedBox(width: 8),
                Expanded(
                    child: _pctBar('FG3%', fg3Pct, s.fg3Made, s.fg3Attempted)),
                const SizedBox(width: 8),
                Expanded(child: _pctBar('FT%', ftPct, s.ftMade, s.ftAttempted)),
              ],
            ),
            const Divider(height: 24),

            // Total stats grid
            const Text(
              'Total Statistik',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Color(0xFF6B7A8D),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _totalStat('PTS', s.points),
                _totalStat('AST', s.assists),
                _totalStat('OREB', s.offensiveRebounds),
                _totalStat('DREB', s.defensiveRebounds),
                _totalStat('STL', s.steals),
                _totalStat('BLK', s.blocks),
                _totalStat('TO', s.turnovers),
                _totalStat('FOUL', s.fouls),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avgStat(String label, double value) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A5C),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6B7A8D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _pctBar(String label, double pct, int made, int attempted) {
    final pctColor = pct >= 50
        ? const Color(0xFF3B6D11)
        : pct >= 33
            ? const Color(0xFFBA7517)
            : const Color(0xFFA32D2D);

    return Column(
      children: [
        Text(
          '${pct.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: pctColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7A8D),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$made/$attempted',
          style: const TextStyle(fontSize: 9, color: Color(0xFF6B7A8D)),
        ),
      ],
    );
  }

  Widget _totalStat(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D6E5)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A3A5C),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF6B7A8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
