import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/events/data/models/event_model.dart';
import 'package:budiutama_basketball/features/events/domain/providers/events_provider.dart';
import 'package:budiutama_basketball/features/events/presentation/widgets/add_event_bottom_sheet.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';

/// Halaman daftar event/turnamen.
///
/// Sesuai SRS FR-EVENT (buat event, lihat daftar, arsip per tahun ajaran).
/// Manager: bisa tambah dan ubah status event.
/// Coach/Statistician: read-only.
class EventsPage extends ConsumerWidget {
  final String teamId;
  final String role;
  final String academicYear;
  final String createdBy;

  /// Callback saat event dipilih (navigasi ke daftar match event tersebut).
  final void Function(EventModel event)? onEventSelected;

  const EventsPage({
    super.key,
    required this.teamId,
    required this.role,
    required this.academicYear,
    required this.createdBy,
    this.onEventSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsStreamProvider(teamId));

    return AppPageScaffold(
      title: 'Events',
      subtitle: 'Turnamen, agenda kompetisi, dan konteks pertandingan',
      icon: Icons.emoji_events_outlined,
      bottom: const TeamToggleWidget(),
      floatingActionButton: role == 'manager'
          ? FloatingActionButton(
              onPressed: () => _showAddEventSheet(context),
              tooltip: 'Buat Event',
              child: const Icon(Icons.add),
            )
          : null,
      child: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          if (events.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              message: 'Belum ada event yang dibuat.\nBuat event pertama!',
              ctaLabel: role == 'manager' ? 'Buat Event' : null,
              onCtaPressed:
                  role == 'manager' ? () => _showAddEventSheet(context) : null,
            );
          }

          // Pisahkan event berdasarkan status
          final ongoing = events.where((e) => e.status == 'ongoing').toList();
          final upcoming = events.where((e) => e.status == 'upcoming').toList();
          final finished = events
              .where((e) => e.status == 'finished' || e.status == 'archived')
              .toList();

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              if (ongoing.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Sedang Berlangsung', color: Color(0xFF3B6D11)),
                ...ongoing.map((e) => _EventCard(
                      event: e,
                      role: role,
                      onTap: () => onEventSelected?.call(e),
                      onStatusChange: (status) =>
                          _updateStatus(context, ref, e.id, status),
                    )),
              ],
              if (upcoming.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Akan Datang', color: Color(0xFF1A3A5C)),
                ...upcoming.map((e) => _EventCard(
                      event: e,
                      role: role,
                      onTap: () => onEventSelected?.call(e),
                      onStatusChange: (status) =>
                          _updateStatus(context, ref, e.id, status),
                    )),
              ],
              if (finished.isNotEmpty) ...[
                const _SectionHeader(
                    label: 'Selesai / Arsip', color: Color(0xFF6B7A8D)),
                ...finished.map((e) => _EventCard(
                      event: e,
                      role: role,
                      onTap: () => onEventSelected?.call(e),
                      onStatusChange: (status) =>
                          _updateStatus(context, ref, e.id, status),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showAddEventSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEventBottomSheet(
        teamId: teamId,
        academicYear: academicYear,
        createdBy: createdBy,
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref,
      String eventId, String newStatus) async {
    await ref
        .read(eventActionsProvider.notifier)
        .updateStatus(eventId, newStatus);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status event diperbarui: $newStatus'),
          backgroundColor: const Color(0xFF3B6D11),
        ),
      );
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final EventModel event;
  final String role;
  final VoidCallback? onTap;
  final void Function(String status) onStatusChange;

  const _EventCard({
    required this.event,
    required this.role,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusConfig = _statusConfig(event.status);
    final dateRange = _formatDateRange(event.startDate, event.endDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Tipe event chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEDFE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _eventTypeLabel(event.eventType),
                      style: const TextStyle(
                        color: Color(0xFF3C3489),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusConfig.bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusConfig.label,
                      style: TextStyle(
                        color: statusConfig.textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Menu aksi (Manager only)
                  if (role == 'manager') _buildActionsMenu(context, ref),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              if (event.organizer.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  event.organizer,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7A8D),
                  ),
                ),
              ],
              if (event.location.isNotEmpty || dateRange.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (event.location.isNotEmpty) ...[
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF6B7A8D)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF6B7A8D)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (dateRange.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Color(0xFF6B7A8D)),
                      const SizedBox(width: 4),
                      Text(
                        dateRange,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF6B7A8D)),
                      ),
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 8),
              // Tap untuk lihat pertandingan
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Lihat Pertandingan',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF1A3A5C).withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 16, color: Color(0xFF1A3A5C)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF6B7A8D)),
      itemBuilder: (_) => [
        if (event.status == 'upcoming')
          const PopupMenuItem(
            value: 'ongoing',
            child: Row(children: [
              Icon(Icons.play_arrow_outlined, size: 16),
              SizedBox(width: 8),
              Text('Mulai Event'),
            ]),
          ),
        if (event.status == 'ongoing')
          const PopupMenuItem(
            value: 'finished',
            child: Row(children: [
              Icon(Icons.check_circle_outline, size: 16),
              SizedBox(width: 8),
              Text('Selesaikan Event'),
            ]),
          ),
        if (event.status != 'archived')
          const PopupMenuItem(
            value: 'archived',
            child: Row(children: [
              Icon(Icons.archive_outlined, size: 16),
              SizedBox(width: 8),
              Text('Arsipkan'),
            ]),
          ),
      ],
      onSelected: (value) => onStatusChange(value),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final fmt = DateFormat('dd MMM', 'id_ID');
    if (start == null && end == null) return '';
    if (start != null && end == null) return fmt.format(start);
    if (start == null && end != null) return fmt.format(end);
    return '${fmt.format(start!)} – ${fmt.format(end!)}';
  }

  String _eventTypeLabel(String type) {
    switch (type) {
      case 'porseni':
        return 'Porseni';
      case 'popda':
        return 'Popda';
      case 'dbl':
        return 'DBL';
      case 'liga_pelajar':
        return 'Liga Pelajar';
      case 'antar_sekolah':
        return 'Antar Sekolah';
      case 'persahabatan':
        return 'Persahabatan';
      default:
        return 'Lainnya';
    }
  }

  ({String label, Color bgColor, Color textColor}) _statusConfig(String s) {
    switch (s) {
      case 'upcoming':
        return (
          label: 'Akan Datang',
          bgColor: const Color(0xFFE6F1FB),
          textColor: const Color(0xFF0C447C),
        );
      case 'ongoing':
        return (
          label: 'Berlangsung',
          bgColor: const Color(0xFFEAF3DE),
          textColor: const Color(0xFF27500A),
        );
      case 'finished':
        return (
          label: 'Selesai',
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF444441),
        );
      case 'archived':
        return (
          label: 'Arsip',
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF888780),
        );
      default:
        return (
          label: s,
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF444441),
        );
    }
  }
}
