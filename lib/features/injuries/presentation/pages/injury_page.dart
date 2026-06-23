import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/injuries/data/models/injury_report_model.dart';
import 'package:budiutama_basketball/features/injuries/domain/providers/injury_provider.dart';
import 'package:budiutama_basketball/features/injuries/presentation/widgets/add_injury_bottom_sheet.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';

/// Halaman manajemen cedera pemain.
///
/// Tab 0: Aktif — cedera berstatus 'active' dan 'recovery'
/// Tab 1: Histori — semua termasuk 'cleared'
///
/// Coach & Manager: akses penuh.
/// Sesuai SRS FR-INJ-01 s.d FR-INJ-04.
class InjuryPage extends ConsumerStatefulWidget {
  final String teamId;
  final String role;
  final String createdBy;

  const InjuryPage({
    super.key,
    required this.teamId,
    required this.role,
    required this.createdBy,
  });

  @override
  ConsumerState<InjuryPage> createState() => _InjuryPageState();
}

class _InjuryPageState extends ConsumerState<InjuryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(injuryTabIndexProvider.notifier).state = _tabController.index;
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
    return AppPageScaffold(
      title: 'Cedera Pemain',
      subtitle: 'Monitoring cedera aktif, recovery, dan histori medis',
      icon: Icons.healing_outlined,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInjurySheet,
        tooltip: 'Laporan Cedera Baru',
        child: const Icon(Icons.add),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Aktif'),
          Tab(text: 'Histori'),
        ],
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _InjuryList(
            teamId: widget.teamId,
            isActive: true,
            onUpdateStatus: _updateStatus,
          ),
          _InjuryList(
            teamId: widget.teamId,
            isActive: false,
            onUpdateStatus: _updateStatus,
          ),
        ],
      ),
    );
  }

  void _showAddInjurySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddInjuryBottomSheet(
        teamId: widget.teamId,
        createdBy: widget.createdBy,
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext ctx, InjuryReportModel report, String newStatus) async {
    String confirmLabel;
    String content;
    switch (newStatus) {
      case 'recovery':
        confirmLabel = 'Tandai Recovery';
        content = '${report.bodyPart} — tandai sebagai dalam masa recovery?';
        break;
      case 'cleared':
        confirmLabel = 'Nyatakan Pulih';
        content =
            'Pemain akan dinyatakan pulih dan status dikembalikan menjadi Aktif.';
        break;
      default:
        return;
    }

    final confirmed = await showConfirmDialog(
      ctx,
      title: 'Perbarui Status Cedera',
      content: content,
      confirmLabel: confirmLabel,
    );

    if (confirmed == true) {
      await ref
          .read(injuryActionsProvider.notifier)
          .updateStatus(report.id, newStatus);
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(
            content: Text('Status cedera diperbarui.'),
            backgroundColor: Color(0xFF3B6D11),
          ),
        );
      }
    }
  }
}

// ── PRIVATE WIDGETS ───────────────────────────────────────────────────────

class _InjuryList extends ConsumerWidget {
  final String teamId;
  final bool isActive;
  final Future<void> Function(BuildContext, InjuryReportModel, String)
      onUpdateStatus;

  const _InjuryList({
    required this.teamId,
    required this.isActive,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamAsync = isActive
        ? ref.watch(activeInjuriesProvider(teamId))
        : ref.watch(allInjuriesProvider(teamId));

    return streamAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (reports) {
        if (reports.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.healing_outlined,
            message: isActive
                ? 'Tidak ada cedera aktif.\nTim dalam kondisi fit!'
                : 'Belum ada riwayat cedera.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: reports.length,
          itemBuilder: (ctx, i) => _InjuryCard(
            report: reports[i],
            onUpdateStatus: (status) => onUpdateStatus(ctx, reports[i], status),
          ),
        );
      },
    );
  }
}

class _InjuryCard extends StatelessWidget {
  final InjuryReportModel report;
  final void Function(String newStatus) onUpdateStatus;

  const _InjuryCard({required this.report, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    final sevConfig = _severityConfig(report.severity);
    final statConfig = _statusConfig(report.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: sevConfig.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row atas: severity + status + menu
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sevConfig.bgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(sevConfig.label,
                      style: TextStyle(
                          color: sevConfig.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statConfig.bgColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(statConfig.label,
                      style: TextStyle(
                          color: statConfig.textColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                // Menu aksi (hanya untuk yang belum cleared)
                if (report.status != 'cleared')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: 18, color: Color(0xFF6B7A8D)),
                    itemBuilder: (_) => [
                      if (report.status == 'active')
                        const PopupMenuItem(
                          value: 'recovery',
                          child: Row(children: [
                            Icon(Icons.directions_walk, size: 16),
                            SizedBox(width: 8),
                            Text('Tandai Recovery'),
                          ]),
                        ),
                      const PopupMenuItem(
                        value: 'cleared',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: Color(0xFF3B6D11)),
                          SizedBox(width: 8),
                          Text('Nyatakan Pulih',
                              style: TextStyle(color: Color(0xFF3B6D11))),
                        ]),
                      ),
                    ],
                    onSelected: onUpdateStatus,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Nama pemain + bagian tubuh
            Text(
              report.bodyPart,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A3A5C)),
            ),
            const SizedBox(height: 2),
            Text(
              'ID Pemain: ${report.playerId}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A8D)),
            ),
            const SizedBox(height: 6),
            Text(
              report.description,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1C2B3A)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Info bawah: tanggal + estimasi pulih
            Wrap(
              spacing: 12,
              children: [
                if (report.injuryDate != null)
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: DateFormat('dd MMM yyyy', 'id_ID')
                        .format(report.injuryDate!),
                  ),
                if (report.estimatedRecoveryDays != null)
                  _InfoChip(
                    icon: Icons.timer_outlined,
                    label: 'Est. ${report.estimatedRecoveryDays} hari pulih',
                  ),
                if (report.clearedAt != null)
                  _InfoChip(
                    icon: Icons.check_circle_outline,
                    label:
                        'Pulih: ${DateFormat('dd MMM yyyy', 'id_ID').format(report.clearedAt!)}',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ({String label, Color bgColor, Color borderColor, Color textColor})
      _severityConfig(String s) {
    switch (s) {
      case 'mild':
        return (
          label: 'Ringan',
          bgColor: const Color(0xFFEAF3DE),
          borderColor: const Color(0xFF639922),
          textColor: const Color(0xFF27500A),
        );
      case 'severe':
        return (
          label: 'Berat',
          bgColor: const Color(0xFFFCEBEB),
          borderColor: const Color(0xFFE24B4A),
          textColor: const Color(0xFF791F1F),
        );
      default: // moderate
        return (
          label: 'Sedang',
          bgColor: const Color(0xFFFAEEDA),
          borderColor: const Color(0xFFEF9F27),
          textColor: const Color(0xFF633806),
        );
    }
  }

  ({String label, Color bgColor, Color textColor}) _statusConfig(String s) {
    switch (s) {
      case 'active':
        return (
          label: 'Aktif',
          bgColor: const Color(0xFFFCEBEB),
          textColor: const Color(0xFF791F1F),
        );
      case 'recovery':
        return (
          label: 'Recovery',
          bgColor: const Color(0xFFFAEEDA),
          textColor: const Color(0xFF633806),
        );
      default: // cleared
        return (
          label: 'Pulih',
          bgColor: const Color(0xFFEAF3DE),
          textColor: const Color(0xFF27500A),
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
        Text(label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A8D))),
      ],
    );
  }
}
