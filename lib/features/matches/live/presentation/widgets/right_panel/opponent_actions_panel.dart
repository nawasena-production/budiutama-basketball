import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/match_action_provider.dart';

/// Right Panel — aksi agregat tim lawan (SRS FR-LMS-04 / PRD Section
/// 7.2 "Tim Lawan — Agregat Tim"). Hanya 4 tombol: +1, +2, +3, FOUL.
///
/// Tim lawan TIDAK memiliki pencatatan tembakan gagal (tidak ada
/// breakdown per pemain) — hanya skor masuk dan foul yang dicatat,
/// sehingga panel ini jauh lebih sederhana daripada [ActionButtons]
/// milik tim sendiri dan tidak pernah memunculkan Court Overlay.
class OpponentActionsPanel extends ConsumerWidget {
  final String matchId;
  const OpponentActionsPanel({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchStreamProvider(matchId));

    // Foul tim lawan tidak punya dokumen player_stats (PRD 7.2 — agregat
    // saja), tapi event log tetap tercatat. Untuk tampilan ringkas di
    // panel ini cukup ambil opponent_score dari dokumen match — total
    // foul agregat lawan ditampilkan dari match jika tersedia,
    // selebihnya cukup mengandalkan Event Timeline untuk audit detail.
    final opponentScore = matchAsync.valueOrNull?.opponentScore ?? 0;

    return Container(
      color: const Color(0xFF162032),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'TIM LAWAN',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$opponentScore',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _OpponentButton(
            label: '+1',
            color: const Color(0xFF1B4332),
            borderColor: const Color(0xFF2D6A4F),
            onTap: () => _record(context, ref, '1PT_MADE'),
          ),
          const SizedBox(height: 6),
          _OpponentButton(
            label: '+2',
            color: const Color(0xFF1B4332),
            borderColor: const Color(0xFF2D6A4F),
            onTap: () => _record(context, ref, '2PT_MADE'),
          ),
          const SizedBox(height: 6),
          _OpponentButton(
            label: '+3',
            color: const Color(0xFF14532D),
            borderColor: const Color(0xFF166534),
            textColor: const Color(0xFF86EFAC),
            onTap: () => _record(context, ref, '3PT_MADE'),
          ),
          const SizedBox(height: 6),
          _OpponentButton(
            label: 'FOUL',
            color: const Color(0xFF451A03),
            borderColor: const Color(0xFF92400E),
            textColor: const Color(0xFFFCD34D),
            onTap: () => _record(context, ref, 'FOUL'),
          ),
          const Spacer(),
          const Text(
            'Tembakan gagal tim lawan tidak dicatat — '
            'hanya skor masuk dan foul.',
            style: TextStyle(color: Color(0xFF475569), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Future<void> _record(
    BuildContext context,
    WidgetRef ref,
    String actionType,
  ) async {
    final match = ref.read(matchStreamProvider(matchId)).valueOrNull;
    final timerState = ref.read(timerStateStreamProvider(matchId)).valueOrNull;
    final userId = await ref.read(currentUserDocIdProvider.future);

    if (match == null || timerState == null || userId == null) return;

    try {
      await ref.read(matchActionProvider(matchId).notifier).recordAction(
            currentMatchState: match.currentState,
            playerId: '', // diabaikan secara efektif karena isOpponent:true
            actionType: actionType,
            quarter: timerState.quarter,
            timeRemaining: timerState.secondsAtStart,
            createdBy: userId,
            isOpponent: true,
          );
    } on AppException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }
}

class _OpponentButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onTap;

  const _OpponentButton({
    required this.label,
    required this.color,
    required this.borderColor,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
