import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';
import 'match_timer_widget.dart';
import 'connection_status.dart';

/// Header Match Mode — menampilkan skor, label quarter, timer, info
/// timeout & foul, serta status koneksi Firestore (SRS FR-LMS-01).
///
/// Skor dan quarter diambil real-time dari [matchStreamProvider] (Step 9),
/// bukan dari hardcoded value seperti versi skeleton dev guide.
class MatchHeader extends ConsumerWidget {
  final String matchId;
  const MatchHeader({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchStreamProvider(matchId));
    final statsAsync = ref.watch(livePlayerStatsStreamProvider(matchId));

    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: matchAsync.when(
        loading: () => const SizedBox(
          height: 56,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        error: (e, _) => SizedBox(
          height: 56,
          child: Center(
            child: Text(
              'Gagal memuat data pertandingan',
              style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            ),
          ),
        ),
        data: (match) {
          if (match == null) {
            return const SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  'Pertandingan tidak ditemukan',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            );
          }

          // Total foul tim dihitung agregat dari materialized player_stats
          // (sum field `fouls` semua pemain) — tidak ada field foul
          // terpisah di dokumen match, sesuai struktur Firestore di SDD
          // Section 3.2 (foul disimpan per-pemain di player_stats, bukan
          // sebagai counter tim independen).
          final totalFouls = statsAsync.valueOrNull
                  ?.fold<int>(0, (sum, s) => sum + s.fouls) ??
              0;

          return Row(
            children: [
              Expanded(
                child: _ScoreColumn(
                  label: 'BUDI UTAMA',
                  score: match.homeScore,
                ),
              ),
              Column(
                children: [
                  Text(
                    _quarterLabel(match.currentState),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                  MatchTimerWidget(matchId: matchId),
                  const Text(
                    'Server Timestamp sync',
                    style: TextStyle(color: Color(0xFF334155), fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              _InfoColumn(
                label: 'FOUL TIM',
                value: '$totalFouls',
                valueColor: totalFouls >= 5
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFFCD34D),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: _ScoreColumn(
                  label: 'LAWAN',
                  score: match.opponentScore,
                ),
              ),
              const ConnectionStatusIndicator(),
            ],
          );
        },
      ),
    );
  }

  /// Menerjemahkan `current_state` menjadi label singkat untuk header.
  /// Contoh: Q1_ACTIVE → "Q1", Q1_BREAK → "Q1 BREAK", HALFTIME →
  /// "HALFTIME", OT_ACTIVE → "OT", POST_MATCH → "SELESAI".
  static String _quarterLabel(String currentState) {
    switch (currentState) {
      case 'PRE_MATCH':
        return 'PRA-PERTANDINGAN';
      case 'Q1_ACTIVE':
        return 'Q1';
      case 'Q1_BREAK':
        return 'Q1 — JEDA';
      case 'Q2_ACTIVE':
        return 'Q2';
      case 'HALFTIME':
        return 'HALFTIME';
      case 'Q3_ACTIVE':
        return 'Q3';
      case 'Q3_BREAK':
        return 'Q3 — JEDA';
      case 'Q4_ACTIVE':
        return 'Q4';
      case 'CHECK_SCORE':
        return 'CEK SKOR';
      case 'OT_ACTIVE':
        return 'OT';
      case 'POST_MATCH':
        return 'SELESAI';
      default:
        return currentState;
    }
  }
}

class _ScoreColumn extends StatelessWidget {
  final String label;
  final int score;

  const _ScoreColumn({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        Text(
          '$score',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
