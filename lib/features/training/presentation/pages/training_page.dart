import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/training/data/models/training_session_model.dart';
import 'package:budiutama_basketball/features/training/domain/providers/training_provider.dart';
import 'package:budiutama_basketball/features/training/presentation/widgets/add_training_bottom_sheet.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';

/// Halaman daftar jadwal latihan.
///
/// - Tab 0: Mendatang — sesi yang belum berlangsung
/// - Tab 1: Histori — sesi yang sudah lewat
///
/// Manager: bisa tambah dan batalkan sesi.
/// Coach, Player: read-only.
///
/// Sesuai SRS FR-TRN-01 s.d FR-TRN-03.
class TrainingPage extends ConsumerStatefulWidget {
  final String teamId;
  final String role;
  final String createdBy;

  const TrainingPage({
    super.key,
    required this.teamId,
    required this.role,
    required this.createdBy,
  });

  @override
  ConsumerState<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends ConsumerState<TrainingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(trainingTabIndexProvider.notifier).state =
            _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTeamId = ref.watch(activeTeamIdProvider);
    final effectiveTeamId =
        activeTeamId.isNotEmpty ? activeTeamId : widget.teamId;

    return AppPageScaffold(
      title: 'Latihan',
      subtitle: 'Jadwal dan histori program latihan tim',
      icon: Icons.calendar_today_outlined,
      bottom: Column(
        children: [
          const TeamToggleWidget(),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Mendatang'),
              Tab(text: 'Histori'),
            ],
          ),
        ],
      ),
      floatingActionButton: widget.role == 'manager'
          ? FloatingActionButton(
              onPressed: _showAddTrainingSheet,
              tooltip: 'Buat Jadwal Latihan',
              child: const Icon(Icons.add),
            )
          : null,
      child: TabBarView(
        controller: _tabController,
        children: [
          _TrainingList(
            teamId: effectiveTeamId,
            role: widget.role,
            isUpcoming: true,
            onCancel: _cancelSession,
          ),
          _TrainingList(
            teamId: effectiveTeamId,
            role: widget.role,
            isUpcoming: false,
            onCancel: _cancelSession,
          ),
        ],
      ),
    );
  }

  void _showAddTrainingSheet() {
    final activeTeamId = ref.read(activeTeamIdProvider);
    final effectiveTeamId =
        activeTeamId.isNotEmpty ? activeTeamId : widget.teamId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTrainingBottomSheet(
        teamId: effectiveTeamId,
        createdBy: widget.createdBy,
      ),
    );
  }

  Future<void> _cancelSession(
      BuildContext context, TrainingSessionModel session) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Batalkan Sesi Latihan',
      content:
          'Sesi "${session.title}" akan dibatalkan. Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Batalkan Sesi',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(trainingActionsProvider.notifier)
          .cancelSession(session.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi latihan dibatalkan.')),
        );
      }
    }
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────────────────────

class _TrainingList extends ConsumerWidget {
  final String teamId;
  final String role;
  final bool isUpcoming;
  final Future<void> Function(BuildContext, TrainingSessionModel) onCancel;

  const _TrainingList({
    required this.teamId,
    required this.role,
    required this.isUpcoming,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamAsync = isUpcoming
        ? ref.watch(upcomingTrainingsProvider(teamId))
        : ref.watch(pastTrainingsProvider(teamId));

    return streamAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (sessions) {
        if (sessions.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.calendar_today_outlined,
            message: isUpcoming
                ? 'Belum ada jadwal latihan mendatang.'
                : 'Belum ada histori latihan.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: sessions.length,
          itemBuilder: (context, i) => _TrainingCard(
            session: sessions[i],
            role: role,
            isUpcoming: isUpcoming,
            onCancel: () => onCancel(context, sessions[i]),
          ),
        );
      },
    );
  }
}

class _TrainingCard extends StatelessWidget {
  final TrainingSessionModel session;
  final String role;
  final bool isUpcoming;
  final VoidCallback onCancel;

  const _TrainingCard({
    required this.session,
    required this.role,
    required this.isUpcoming,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final typeConfig = _typeConfig(session.sessionType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: session.isCancelled
              ? Colors.red.shade200
              : const Color(0xFFC8D6E5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tipe sesi icon + label
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeConfig.bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeConfig.icon,
                          size: 12, color: typeConfig.textColor),
                      const SizedBox(width: 4),
                      Text(
                        typeConfig.label,
                        style: TextStyle(
                          color: typeConfig.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // Label tim
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDFE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group_outlined,
                          size: 12, color: Color(0xFF3C3489)),
                      const SizedBox(width: 4),
                      Text(
                        _teamLabel(session.teamId),
                        style: const TextStyle(
                          color: Color(0xFF3C3489),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Dibatalkan badge
                if (session.isCancelled)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Dibatalkan',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                // Menu batalkan (Manager, upcoming, belum dibatalkan)
                if (role == 'manager' && isUpcoming && !session.isCancelled)
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined,
                        size: 18, color: Color(0xFF6B7A8D)),
                    tooltip: 'Batalkan Sesi',
                    onPressed: onCancel,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Judul
            Text(
              session.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: session.isCancelled
                    ? const Color(0xFF6B7A8D)
                    : const Color(0xFF1A3A5C),
                decoration:
                    session.isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 6),

            // Tanggal, waktu, durasi, lokasi
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (session.scheduledAt != null)
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat('EEE, dd MMM yyyy', 'id_ID')
                        .format(session.scheduledAt!),
                  ),
                if (session.scheduledAt != null)
                  _InfoChip(
                    icon: Icons.access_time,
                    label: DateFormat('HH:mm', 'id_ID')
                        .format(session.scheduledAt!),
                  ),
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: '${session.durationMinutes} menit',
                ),
                if (session.location.isNotEmpty)
                  _InfoChip(
                    icon: Icons.location_on_outlined,
                    label: session.location,
                  ),
              ],
            ),

            // Deskripsi (jika ada)
            if (session.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                session.description,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A8D)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Derive label tim yang readable dari teamId.
  /// Contoh: "putra_2526" → "SMA Putra"
  ///         "smp_putri_2526" → "SMP Putri"
  String _teamLabel(String teamId) {
    final id = teamId.toLowerCase();
    final level = id.contains('smp') ? 'SMP' : 'SMA';
    final gender =
        (id.contains('putri') || id.contains('female')) ? 'Putri' : 'Putra';
    return '$level $gender';
  }

  ({String label, IconData icon, Color bgColor, Color textColor}) _typeConfig(
      String type) {
    switch (type) {
      case 'physical':
        return (
          label: 'Fisik',
          icon: Icons.directions_run,
          bgColor: const Color(0xFFEAF3DE),
          textColor: const Color(0xFF27500A),
        );
      case 'technical':
        return (
          label: 'Teknik',
          icon: Icons.sports_basketball,
          bgColor: const Color(0xFFE6F1FB),
          textColor: const Color(0xFF0C447C),
        );
      case 'tactical':
        return (
          label: 'Taktik',
          icon: Icons.analytics_outlined,
          bgColor: const Color(0xFFEEEDFE),
          textColor: const Color(0xFF3C3489),
        );
      case 'scrimmage':
        return (
          label: 'Scrimmage',
          icon: Icons.group_outlined,
          bgColor: const Color(0xFFFAEEDA),
          textColor: const Color(0xFF633806),
        );
      case 'recovery':
        return (
          label: 'Recovery',
          icon: Icons.spa_outlined,
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF444441),
        );
      default:
        return (
          label: type,
          icon: Icons.fitness_center,
          bgColor: const Color(0xFFF1EFE8),
          textColor: const Color(0xFF444441),
        );
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF6B7A8D)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A8D)),
        ),
      ],
    );
  }
}
