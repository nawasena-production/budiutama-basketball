import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/utils/stats_calculator.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/events/domain/providers/events_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/features/statistics/data/repositories/stats_repository.dart';
import 'package:budiutama_basketball/features/statistics/domain/providers/stats_provider.dart';
import 'package:budiutama_basketball/features/statistics/presentation/widgets/shot_chart_widget.dart';
import 'package:budiutama_basketball/features/users/domain/providers/user_provider.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';

/// Halaman utama Statistics Dashboard (FR-STT-01 s.d 05 / PRD Section 8).
///
/// Selalu menampilkan data dalam konteks event/turnamen tertentu (PRD:
/// "Dashboard statistik selalu menampilkan data dalam konteks
/// event/turnamen tertentu") — sehingga halaman ini mensyaratkan
/// pengguna memilih event terlebih dahulu dari dropdown sebelum
/// leaderboard dan shot chart ditampilkan.
class StatisticsDashboardPage extends ConsumerStatefulWidget {
  const StatisticsDashboardPage({super.key});

  @override
  ConsumerState<StatisticsDashboardPage> createState() =>
      _StatisticsDashboardPageState();
}

class _StatisticsDashboardPageState
    extends ConsumerState<StatisticsDashboardPage> {
  String? _selectedEventId;
  String? _selectedPlayerIdForShotChart;

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(activeTeamIdProvider);
    final eventsAsync = ref.watch(eventsStreamProvider(teamId));
    final role = ref.watch(userRoleProvider).valueOrNull ?? 'player';
    final userDocIdAsync = ref.watch(currentUserDocIdProvider);
    final userDocId = userDocIdAsync.valueOrNull;
    final linkedPlayerAsync = role == 'player' && userDocId != null
        ? ref.watch(linkedPlayerForUserProvider(userDocId))
        : null;
    final ownPlayerId = role == 'player'
        ? linkedPlayerAsync?.valueOrNull?.id
        : null;
    final isResolvingPlayer = role == 'player' &&
        (userDocIdAsync.isLoading || linkedPlayerAsync?.isLoading == true);

    return AppPageScaffold(
      title: 'Statistik',
      subtitle: 'Leaderboard, performa pemain, dan shot chart event',
      icon: Icons.bar_chart_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TeamToggleWidget(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: eventsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Gagal memuat event: $e'),
              data: (events) {
                if (events.isEmpty) {
                  return const Text(
                    'Belum ada event/turnamen untuk tim ini.',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                // Default ke event pertama bila belum ada pilihan.
                _selectedEventId ??= events.first.id;
                return DropdownButtonFormField<String>(
                  initialValue: _selectedEventId,
                  decoration: const InputDecoration(
                    labelText: 'Event / Turnamen',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: events
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child:
                                Text(e.name, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (id) => setState(() {
                    _selectedEventId = id;
                    _selectedPlayerIdForShotChart = null;
                  }),
                );
              },
            ),
          ),
          Expanded(
            child: _buildStatsBody(
              role: role,
              ownPlayerId: ownPlayerId,
              isResolvingPlayer: isResolvingPlayer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBody({
    required String role,
    required String? ownPlayerId,
    required bool isResolvingPlayer,
  }) {
    if (_selectedEventId == null) {
      return const Center(
        child: Text(
          'Pilih event untuk melihat statistik.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (isResolvingPlayer) {
      return const Center(child: CircularProgressIndicator());
    }

    if (role == 'player' && ownPlayerId == null) {
      return const Center(
        child: Text(
          'Profil pemain belum terhubung dengan akun ini.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _EventStatsBody(
      eventId: _selectedEventId!,
      selectedPlayerId: _selectedPlayerIdForShotChart,
      restrictedPlayerId: ownPlayerId,
      onPlayerSelected: (id) => setState(
        () => _selectedPlayerIdForShotChart = id,
      ),
    );
  }
}

class _EventStatsBody extends ConsumerWidget {
  final String eventId;
  final String? selectedPlayerId;
  final String? restrictedPlayerId;
  final ValueChanged<String?> onPlayerSelected;

  const _EventStatsBody({
    required this.eventId,
    required this.selectedPlayerId,
    required this.restrictedPlayerId,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aggregatedAsync = ref.watch(eventAggregatedStatsProvider(eventId));

    return aggregatedAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat statistik: $e')),
      data: (stats) {
        if (stats.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada pertandingan selesai untuk event ini.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final visibleStats = restrictedPlayerId == null
            ? stats
            : stats.where((s) => s.playerId == restrictedPlayerId).toList();

        if (visibleStats.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada statistik untuk pemain ini pada event terpilih.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final sorted = [...visibleStats]
          ..sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
        final effectivePlayerFilter = restrictedPlayerId ?? selectedPlayerId;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Leaderboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _LeaderboardTable(
                stats: sorted,
                selectedPlayerId: effectivePlayerFilter,
                onPlayerTap: restrictedPlayerId == null
                    ? onPlayerSelected
                    : (_) {},
              ),
              const SizedBox(height: 24),
              const Text(
                'Shot Chart',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                restrictedPlayerId != null
                    ? 'Menampilkan statistik pribadi pemain.'
                    : selectedPlayerId == null
                    ? 'Menampilkan seluruh tembakan tim — tap nama pemain di '
                        'leaderboard untuk filter per pemain.'
                    : 'Menampilkan tembakan pemain terpilih. Tap lagi untuk '
                        'kembali ke tampilan tim.',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _EventShotChart(
                eventId: eventId,
                playerIdFilter: effectivePlayerFilter,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeaderboardTable extends StatelessWidget {
  final List<AggregatedPlayerStats> stats;
  final String? selectedPlayerId;
  final ValueChanged<String?> onPlayerTap;

  const _LeaderboardTable({
    required this.stats,
    required this.selectedPlayerId,
    required this.onPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('GP'), numeric: true),
          DataColumn(label: Text('PPG'), numeric: true),
          DataColumn(label: Text('RPG'), numeric: true),
          DataColumn(label: Text('APG'), numeric: true),
          DataColumn(label: Text('SPG'), numeric: true),
          DataColumn(label: Text('BPG'), numeric: true),
          DataColumn(label: Text('EF'), numeric: true),
          DataColumn(label: Text('FG%'), numeric: true),
          DataColumn(label: Text('FT%'), numeric: true),
        ],
        rows: stats.map((s) {
          final isSelected = selectedPlayerId == s.playerId;
          final fgPct = StatsCalculator.fgPercentage(
            s.totalFg2Made,
            s.totalFg2Attempted,
            s.totalFg3Made,
            s.totalFg3Attempted,
          );
          final ftPct =
              StatsCalculator.ftPercentage(s.totalFtMade, s.totalFtAttempted);
          final efficiency = StatsCalculator.efficiency(
            points: s.totalPoints,
            offensiveRebounds: s.totalOffensiveRebounds,
            defensiveRebounds: s.totalDefensiveRebounds,
            assists: s.totalAssists,
            steals: s.totalSteals,
            blocks: s.totalBlocks,
            fg2Made: s.totalFg2Made,
            fg2Attempted: s.totalFg2Attempted,
            fg3Made: s.totalFg3Made,
            fg3Attempted: s.totalFg3Attempted,
            ftMade: s.totalFtMade,
            ftAttempted: s.totalFtAttempted,
            turnovers: s.totalTurnovers,
          );

          return DataRow(
            selected: isSelected,
            onSelectChanged: (_) => onPlayerTap(isSelected ? null : s.playerId),
            cells: [
              DataCell(Text('${s.jerseyNumber}')),
              DataCell(Text(s.fullName)),
              DataCell(Text('${s.gamesPlayed}')),
              DataCell(Text(s.ppg.toStringAsFixed(1))),
              DataCell(Text(s.rpg.toStringAsFixed(1))),
              DataCell(Text(s.apg.toStringAsFixed(1))),
              DataCell(Text(s.spg.toStringAsFixed(1))),
              DataCell(Text(s.bpg.toStringAsFixed(1))),
              DataCell(Text('$efficiency')),
              DataCell(Text('${fgPct.toStringAsFixed(0)}%')),
              DataCell(Text('${ftPct.toStringAsFixed(0)}%')),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Mengambil titik tembakan dari SELURUH pertandingan `finished` dalam
/// event terpilih (bukan hanya satu match) — menggabungkan
/// `getFinishedMatchIdsForEvent` + `getShotPointsForMatch` per match
/// untuk membangun shot chart musim/turnamen, bukan hanya per
/// pertandingan tunggal (yang sudah dilayani [matchShotChartProvider]
/// terpisah untuk kebutuhan box score pasca-pertandingan).
class _EventShotChart extends ConsumerWidget {
  final String eventId;
  final String? playerIdFilter;

  const _EventShotChart({required this.eventId, this.playerIdFilter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shotsAsync = ref.watch(_eventShotChartProvider(eventId));

    return shotsAsync.when(
      loading: () => const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('Gagal memuat shot chart: $e'),
      data: (entries) => Center(
        child: SizedBox(
          width: 320,
          child: ShotChartWidget(
            shotEntries: entries,
            playerIdFilter: playerIdFilter,
          ),
        ),
      ),
    );
  }
}

final _eventShotChartProvider =
    FutureProvider.family<List<ShotChartEntry>, String>((ref, eventId) async {
  final repo = ref.read(statsRepositoryProvider);
  final matchIds = await repo.getFinishedMatchIdsForEvent(eventId);
  if (matchIds.isEmpty) return [];
  final allLists = await Future.wait(
    matchIds.map((id) => repo.getShotPointsForMatch(id)),
  );
  return allLists.expand((entries) => entries).toList();
});
