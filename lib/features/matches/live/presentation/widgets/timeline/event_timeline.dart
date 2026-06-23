import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/utils/timer_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/match_event_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';

/// Sidebar — log real-time seluruh event pertandingan, terbaru di atas
/// (SRS FR-LMS-09). Format baris: `Q3 06:24 #7 3PT MADE`.
///
/// Event bertipe sistem (TIMER_START/PAUSE/RESUME, STATE_TRANSITION,
/// UNDO) ditampilkan dengan gaya visual berbeda (lebih redup, tanpa
/// label pemain) supaya tidak mengganggu pembacaan event statistik
/// utama, tapi tetap terlihat untuk keperluan audit (SDD 3.2 — Audit
/// Log System bergantung pada event log ini sebagai sumber kebenaran).
class EventTimeline extends ConsumerWidget {
  final String matchId;
  const EventTimeline({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(matchEventsStreamProvider(matchId));

    return Container(
      color: const Color(0xFF0F172A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Text(
              'FIRESTORE EVENTS',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF64748B)),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Gagal memuat timeline: $e',
                  style: const TextStyle(
                    color: Color(0xFFFCA5A5),
                    fontSize: 10,
                  ),
                ),
              ),
              data: (events) {
                if (events.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Belum ada event.',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 10),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: events.length,
                  itemBuilder: (context, i) => _EventRow(event: events[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final MatchEventModel event;
  const _EventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        'Q${event.quarter} ${formatSeconds(event.timeRemaining)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
        ),
        padding: const EdgeInsets.only(bottom: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            children: [
              TextSpan(text: '$timeLabel '),
              ..._describeAction(event),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _describeAction(MatchEventModel e) {
    if (e.actionType == 'SUBSTITUTION') {
      return [
        const TextSpan(
          text: 'SUB ',
          style: TextStyle(color: Color(0xFF64748B)),
        ),
        TextSpan(
          text: '#${e.subOutJersey ?? "?"} OUT',
          style: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
        const TextSpan(text: ' → '),
        TextSpan(
          text: '#${e.subInJersey ?? "?"} IN',
          style: const TextStyle(color: Color(0xFF86EFAC)),
        ),
      ];
    }

    if (e.actionType == 'STATE_TRANSITION') {
      return [
        TextSpan(
          text: 'Transisi state pertandingan',
          style: const TextStyle(color: Color(0xFF7C3AED)),
        ),
      ];
    }

    if (e.actionType == 'TIMER_START' ||
        e.actionType == 'TIMER_PAUSE' ||
        e.actionType == 'TIMER_RESUME') {
      return [
        TextSpan(
          text: e.actionType.replaceAll('_', ' '),
          style: const TextStyle(color: Color(0xFF475569)),
        ),
      ];
    }

    if (e.actionType == 'UNDO') {
      return [
        const TextSpan(
          text: 'UNDO ',
          style: TextStyle(
            color: Color(0xFFFCD34D),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: '(ref: ${e.undoRefId ?? "-"})',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
      ];
    }

    // Event statistik biasa — tim sendiri atau tim lawan.
    final playerLabel = e.isOpponent ? 'LAWAN' : '#${_jerseyFromPlayerId(e.playerId)}';
    final actionLabel = _humanActionLabel(e.actionType);
    final isMade = e.actionType.contains('MADE');
    final isMiss = e.actionType.startsWith('MISS');

    final List<TextSpan> spans = [
      TextSpan(
        text: '$playerLabel ',
        style: TextStyle(
          color: e.isOpponent
              ? const Color(0xFF94A3B8)
              : const Color(0xFFE2E8F0),
          fontWeight: FontWeight.w600,
        ),
      ),
      TextSpan(
        text: actionLabel,
        style: TextStyle(
          color: isMade
              ? const Color(0xFF86EFAC)
              : isMiss
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFE2E8F0),
        ),
      ),
    ];

    if (e.isUndone) {
      spans.add(
        const TextSpan(
          text: '  (dibatalkan)',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return spans;
  }

  String _humanActionLabel(String actionType) {
    switch (actionType) {
      case '1PT_MADE':
        return '1PT MADE';
      case '2PT_MADE':
        return '2PT MADE';
      case '3PT_MADE':
        return '3PT MADE';
      case 'MISS_1PT':
        return 'MISS 1PT';
      case 'MISS_2PT':
        return 'MISS 2PT';
      case 'MISS_3PT':
        return 'MISS 3PT';
      case 'ASSIST':
        return 'ASSIST';
      case 'REBOUND_OFF':
        return 'OREB';
      case 'REBOUND_DEF':
        return 'DREB';
      case 'STEAL':
        return 'STEAL';
      case 'TURNOVER':
        return 'TURNOVER';
      case 'BLOCK':
        return 'BLOCK';
      case 'FOUL':
        return 'FOUL';
      default:
        return actionType;
    }
  }

  /// `player_id` berformat `{jersey}_{inisial}_{teamId}` — ekstrak
  /// jersey number (segmen pertama sebelum underscore pertama) untuk
  /// tampilan ringkas di timeline tanpa perlu query tambahan ke
  /// collection `players`.
  String _jerseyFromPlayerId(String? playerId) {
    if (playerId == null || playerId.isEmpty) return '?';
    final firstUnderscore = playerId.indexOf('_');
    if (firstUnderscore == -1) return playerId;
    return playerId.substring(0, firstUnderscore);
  }
}
