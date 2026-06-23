import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/live/data/models/lineup_model.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/lineup_provider.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/live_match_stream_providers.dart';
import 'package:budiutama_basketball/features/matches/live/domain/providers/match_action_provider.dart'
    show derivePlayerStatsDocId;

/// Left Panel — daftar 5 pemain di lapangan (SRS FR-LMS-02).
///
/// Statistician tap satu kartu pemain untuk memilihnya sebelum menekan
/// tombol aksi statistik di Tab 1 Input Mode (Center Panel). Pemain yang
/// dipilih di-highlight dengan border oranye.
class PlayerListPanel extends ConsumerWidget {
  final String matchId;
  const PlayerListPanel({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineupAsync = ref.watch(onCourtLineupStreamProvider(matchId));
    final statsAsync = ref.watch(livePlayerStatsStreamProvider(matchId));
    final selectedId = ref.watch(selectedPlayerLineupIdProvider(matchId));

    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ON COURT',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: lineupAsync.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              error: (e, _) => const Center(
                child: Text(
                  'Gagal memuat lineup',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
              data: (lineups) {
                if (lineups.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pemain\ndi lapangan',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF475569), fontSize: 11),
                    ),
                  );
                }

                final sorted = [...lineups]
                  ..sort((a, b) => a.jerseyNumber.compareTo(b.jerseyNumber));

                return ListView.separated(
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final player = sorted[i];
                    final isSelected = player.id == selectedId;
                    final points = _pointsFor(statsAsync.valueOrNull, player);

                    return _PlayerCard(
                      lineup: player,
                      points: points,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(
                              selectedPlayerLineupIdProvider(matchId).notifier,
                            )
                            .state = isSelected ? null : player.id;
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _pointsFor(List<dynamic>? stats, LineupModel player) {
    if (stats == null) return 0;
    final statsDocId = derivePlayerStatsDocId(player.playerId);
    for (final s in stats) {
      if (s.id == statsDocId) return s.points as int;
    }
    return 0;
  }
}

class _PlayerCard extends StatelessWidget {
  final LineupModel lineup;
  final int points;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlayerCard({
    required this.lineup,
    required this.points,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C1523) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFFE8420A) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '#${lineup.jerseyNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE8420A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lineup.fullName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    lineup.position,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$points',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
