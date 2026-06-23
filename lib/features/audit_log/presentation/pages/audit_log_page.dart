import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/audit_log/data/models/audit_log_model.dart';
import 'package:budiutama_basketball/features/audit_log/data/repositories/audit_log_repository.dart';
import 'package:budiutama_basketball/features/audit_log/domain/providers/audit_log_provider.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';

/// Halaman Audit Log (SRS Section 3.9, FR-AUD-02) — read-only, hanya
/// diakses Coach dan Manager. Menampilkan log yang ditulis otomatis
/// oleh Cloud Functions (Step 15: `onMatchEventCreated`, dan trigger
/// CRUD lain di Fase berikutnya).
class AuditLogPage extends ConsumerWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogListProvider);
    final filter = ref.watch(auditLogFilterProvider);

    return AppPageScaffold(
      title: 'Audit Log',
      subtitle: 'Riwayat aktivitas sistem dan perubahan data',
      icon: Icons.receipt_long_outlined,
      actions: [
        if (!filter.isEmpty)
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'Hapus semua filter',
            onPressed: () => ref.read(auditLogFilterProvider.notifier).state =
                const AuditLogFilter(),
          ),
      ],
      child: Column(
        children: [
          const _FilterBar(),
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat log: $e')),
              data: (logs) {
                if (logs.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.history_toggle_off_outlined,
                    message: 'Tidak ada log yang cocok dengan filter ini.',
                  );
                }
                final notifier = ref.read(auditLogListProvider.notifier);
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(auditLogListProvider);
                    await ref.read(auditLogListProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: logs.length + (notifier.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      if (i >= logs.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: OutlinedButton(
                              onPressed: () => notifier.loadMore(),
                              child: const Text('Muat lebih banyak'),
                            ),
                          ),
                        );
                      }
                      return _AuditLogTile(log: logs[i]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(auditLogFilterProvider);
    final actionTypesAsync = ref.watch(auditLogActionTypesProvider);
    final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Filter tipe aksi
          actionTypesAsync.when(
            loading: () => const SizedBox(
              width: 140,
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (types) => SizedBox(
              width: 180,
              child: DropdownButtonFormField<String?>(
                initialValue: filter.actionType,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'Tipe Aksi',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Semua')),
                  ...types.map(
                    (t) => DropdownMenuItem(value: t, child: Text(t)),
                  ),
                ],
                onChanged: (value) => ref
                    .read(auditLogFilterProvider.notifier)
                    .state = filter.copyWith(
                  actionType: value,
                  clearActionType: value == null,
                ),
              ),
            ),
          ),

          // Filter tanggal mulai
          _DateChip(
            label: filter.startDate == null
                ? 'Dari Tanggal'
                : dateFmt.format(filter.startDate!),
            isActive: filter.startDate != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: filter.startDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('id', 'ID'),
              );
              if (picked != null) {
                ref.read(auditLogFilterProvider.notifier).state =
                    filter.copyWith(startDate: picked);
              }
            },
            onClear: filter.startDate == null
                ? null
                : () => ref.read(auditLogFilterProvider.notifier).state =
                    filter.copyWith(clearStartDate: true),
          ),

          // Filter tanggal akhir
          _DateChip(
            label: filter.endDate == null
                ? 'Sampai Tanggal'
                : dateFmt.format(filter.endDate!),
            isActive: filter.endDate != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: filter.endDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                locale: const Locale('id', 'ID'),
              );
              if (picked != null) {
                ref.read(auditLogFilterProvider.notifier).state =
                    filter.copyWith(endDate: picked);
              }
            },
            onClear: filter.endDate == null
                ? null
                : () => ref.read(auditLogFilterProvider.notifier).state =
                    filter.copyWith(clearEndDate: true),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DateChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      avatar: const Icon(Icons.calendar_today_outlined, size: 14),
      selected: isActive,
      onPressed: onTap,
      onDeleted: onClear,
      deleteIcon: onClear != null ? const Icon(Icons.close, size: 14) : null,
    );
  }
}

class _AuditLogTile extends StatelessWidget {
  final AuditLogModel log;
  const _AuditLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final ts = log.createdAt;
    final timeLabel = ts != null
        ? DateFormat('dd MMM yyyy HH:mm:ss', 'id_ID').format(ts)
        : '-';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor:
            _colorForAction(log.actionType).withValues(alpha: 0.15),
        child: Icon(
          _iconForAction(log.actionType),
          size: 16,
          color: _colorForAction(log.actionType),
        ),
      ),
      title: Text(
        log.actionType,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${log.entityType}'
        '${log.entityId != null ? " · ${log.entityId}" : ""}\n'
        '${log.userId}${log.role != null ? " (${log.role})" : ""} · $timeLabel',
        style: const TextStyle(fontSize: 11),
      ),
      isThreeLine: true,
      trailing: (log.oldValue != null || log.newValue != null)
          ? IconButton(
              icon: const Icon(Icons.info_outline, size: 18),
              tooltip: 'Lihat detail perubahan',
              onPressed: () => _showDetailDialog(context),
            )
          : null,
    );
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(log.actionType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (log.oldValue != null) ...[
                const Text('Nilai Lama:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${log.oldValue}', style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 12),
              ],
              if (log.newValue != null) ...[
                const Text('Nilai Baru:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${log.newValue}', style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Color _colorForAction(String actionType) {
    if (actionType.contains('CREATED') || actionType.contains('ADDED')) {
      return const Color(0xFF22C55E);
    }
    if (actionType.contains('DELETED') || actionType.contains('REMOVED')) {
      return const Color(0xFFEF4444);
    }
    if (actionType.contains('UPDATED') || actionType.contains('CHANGED')) {
      return const Color(0xFF2563EB);
    }
    return const Color(0xFF64748B);
  }

  IconData _iconForAction(String actionType) {
    if (actionType.contains('CREATED') || actionType.contains('ADDED')) {
      return Icons.add_circle_outline;
    }
    if (actionType.contains('DELETED') || actionType.contains('REMOVED')) {
      return Icons.remove_circle_outline;
    }
    if (actionType.contains('UPDATED') || actionType.contains('CHANGED')) {
      return Icons.edit_outlined;
    }
    return Icons.history;
  }
}
