import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/events/data/models/event_model.dart';
import 'package:budiutama_basketball/features/matches/dashboard/data/models/match_model.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';
import 'package:budiutama_basketball/features/matches/dashboard/presentation/widgets/add_match_bottom_sheet.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';
import 'match_detail_page.dart';

/// Halaman daftar semua pertandingan dalam satu event/turnamen.
///
/// - Dikelompokkan per status: Berlangsung → Terjadwal → Selesai → Dibatalkan
/// - Manager: bisa tambah pertandingan baru
/// - Statistician: bisa tap untuk buka detail → START MATCH
/// - Coach, Player: read-only
///
/// Sesuai SRS FR-MCH-01 s.d FR-MCH-05.
class MatchesPage extends ConsumerWidget {
  final EventModel event;
  final String role;
  final String homeTeamId;
  final String createdBy;

  const MatchesPage({
    super.key,
    required this.event,
    required this.role,
    required this.homeTeamId,
    required this.createdBy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesByEventStreamProvider(event.id));

    return AppPageScaffold(
      title: event.name,
      subtitle: _eventTypeLabel(event.eventType),
      icon: Icons.sports_basketball_outlined,
      floatingActionButton: role == 'manager'
          ? FloatingActionButton(
              onPressed: () => _showAddMatchSheet(context),
              tooltip: 'Tambah Pertandingan',
              child: const Icon(Icons.add),
            )
          : null,
      child: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (matches) {
          if (matches.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.sports_basketball_outlined,
              message: 'Belum ada pertandingan di event ini.',
              ctaLabel: role == 'manager' ? 'Tambah Pertandingan' : null,
              onCtaPressed:
                  role == 'manager' ? () => _showAddMatchSheet(context) : null,
            );
          }

          final ongoing = matches.where((m) => m.status == 'ongoing').toList();
          final scheduled =
              matches.where((m) => m.status == 'scheduled').toList();
          final finished =
              matches.where((m) => m.status == 'finished').toList();
          final cancelled =
              matches.where((m) => m.status == 'cancelled').toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              _buildEventSummary(matches),
              if (ongoing.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Sedang Berlangsung', color: Color(0xFF3B6D11)),
                ...ongoing.map((m) => _MatchCard(
                    match: m,
                    role: role,
                    homeTeamId: homeTeamId,
                    onTap: () => _openDetail(context, m))),
              ],
              if (scheduled.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Terjadwal', color: Color(0xFF1A3A5C)),
                ...scheduled.map((m) => _MatchCard(
                    match: m,
                    role: role,
                    homeTeamId: homeTeamId,
                    onTap: () => _openDetail(context, m))),
              ],
              if (finished.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Selesai', color: Color(0xFF6B7A8D)),
                ...finished.map((m) => _MatchCard(
                    match: m,
                    role: role,
                    homeTeamId: homeTeamId,
                    onTap: () => _openDetail(context, m))),
              ],
              if (cancelled.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Dibatalkan', color: Color(0xFFA32D2D)),
                ...cancelled.map((m) => _MatchCard(
                    match: m,
                    role: role,
                    homeTeamId: homeTeamId,
                    onTap: () => _openDetail(context, m))),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventSummary(List<MatchModel> matches) {
    final total = matches.length;
    final wins = matches
        .where((m) => m.status == 'finished' && m.homeScore > m.opponentScore)
        .length;
    final losses = matches
        .where((m) => m.status == 'finished' && m.homeScore < m.opponentScore)
        .length;
    final played = matches.where((m) => m.status == 'finished').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A5C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(label: 'Total', value: total.toString()),
          _SummaryStat(label: 'Dimainkan', value: played.toString()),
          _SummaryStat(
              label: 'Menang',
              value: wins.toString(),
              color: const Color(0xFF86EFAC)),
          _SummaryStat(
              label: 'Kalah',
              value: losses.toString(),
              color: const Color(0xFFFCA5A5)),
        ],
      ),
    );
  }

  void _showAddMatchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddMatchBottomSheet(
        event: event,
        homeTeamId: homeTeamId,
        createdBy: createdBy,
      ),
    );
  }

  void _openDetail(BuildContext context, MatchModel match) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MatchDetailPage(
        matchId: match.id,
        role: role,
        teamId: homeTeamId,
      ),
    ));
  }

  String _eventTypeLabel(String type) {
    switch (type) {
      case 'porseni':
        return 'Porseni';
      case 'popda':
        return 'Popda';
      case 'persahabatan':
        return 'Persahabatan';
      default:
        return type;
    }
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 14,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: color,
                  letterSpacing: 0.4)),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final String role;
  final String homeTeamId;
  final VoidCallback onTap;

  const _MatchCard(
      {required this.match,
      required this.role,
      required this.homeTeamId,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isFinished = match.status == 'finished';
    final isCancelled = match.status == 'cancelled';
    final isOngoing = match.status == 'ongoing';
    final homeWon = isFinished && match.homeScore > match.opponentScore;
    final homeLost = isFinished && match.homeScore < match.opponentScore;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOngoing
              ? const Color(0xFF639922)
              : isCancelled
                  ? Colors.red.shade200
                  : const Color(0xFFC8D6E5),
          width: isOngoing ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isCancelled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  _PhaseChip(phase: match.phase),
                  const Spacer(),
                  _StatusBadge(status: match.status),
                  if (isOngoing) ...[
                    const SizedBox(width: 8),
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFF3B6D11))),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Budi Utama',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A3A5C))),
                          if (isFinished || isOngoing)
                            Text(match.homeScore.toString(),
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: homeWon
                                        ? const Color(0xFF3B6D11)
                                        : homeLost
                                            ? const Color(0xFFA32D2D)
                                            : const Color(0xFF1A3A5C))),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(isFinished || isOngoing ? ':' : 'vs',
                        style: TextStyle(
                            fontSize: isFinished || isOngoing ? 24 : 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6B7A8D))),
                  ),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(match.opponentName,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A3A5C)),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis),
                          if (isFinished || isOngoing)
                            Text(match.opponentScore.toString(),
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: !homeWon && !homeLost && isFinished
                                        ? const Color(0xFF1A3A5C)
                                        : homeLost
                                            ? const Color(0xFF3B6D11)
                                            : homeWon
                                                ? const Color(0xFFA32D2D)
                                                : const Color(0xFF1A3A5C)),
                                textAlign: TextAlign.right),
                        ]),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: Color(0xFF6B7A8D)),
                  const SizedBox(width: 4),
                  Text(
                      match.scheduledAt != null
                          ? DateFormat('dd MMM yyyy · HH:mm', 'id_ID')
                              .format(match.scheduledAt!)
                          : '-',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7A8D))),
                  if (match.venue.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF6B7A8D)),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(match.venue,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF6B7A8D)),
                            overflow: TextOverflow.ellipsis)),
                  ],
                ],
              ),
              if (role == 'statistician' && match.status == 'scheduled') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Setup & Mulai Pertandingan',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE8420A),
                      side: const BorderSide(color: Color(0xFFE8420A)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
              if (match.status == 'ongoing') ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.open_in_full, size: 16),
                    label: const Text('Buka Match Mode',
                        style: TextStyle(fontSize: 12)),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A5C),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final String phase;
  const _PhaseChip({required this.phase});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFC8D6E5))),
      child: Text(_label(phase),
          style: const TextStyle(fontSize: 10, color: Color(0xFF6B7A8D))),
    );
  }

  String _label(String p) {
    switch (p) {
      case 'penyisihan':
        return 'Penyisihan';
      case 'perempat_final':
        return 'Perempat Final';
      case 'semifinal':
        return 'Semifinal';
      case 'final':
        return 'Final';
      case 'friendly':
        return 'Friendly';
      default:
        return p;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    final cfg = _cfg(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: cfg.$1, borderRadius: BorderRadius.circular(4)),
      child: Text(cfg.$2,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: cfg.$3)),
    );
  }

  (Color, String, Color) _cfg(String s) {
    switch (s) {
      case 'scheduled':
        return (const Color(0xFFE6F1FB), 'Terjadwal', const Color(0xFF0C447C));
      case 'ongoing':
        return (
          const Color(0xFFEAF3DE),
          'Berlangsung',
          const Color(0xFF27500A)
        );
      case 'finished':
        return (const Color(0xFFF1EFE8), 'Selesai', const Color(0xFF444441));
      case 'cancelled':
        return (const Color(0xFFFCEBEB), 'Dibatalkan', const Color(0xFF791F1F));
      default:
        return (const Color(0xFFF1EFE8), s, const Color(0xFF444441));
    }
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SummaryStat({required this.label, required this.value, this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color ?? Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }
}
