import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/audit_log/data/models/audit_log_model.dart';
import 'package:budiutama_basketball/features/audit_log/data/repositories/audit_log_repository.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepository();
});

/// Filter aktif di halaman Audit Log — disimpan sebagai state lokal
/// (bukan Firestore) supaya berubah seketika saat pengguna mengubah
/// dropdown/date picker tanpa perlu konfirmasi tambahan.
final auditLogFilterProvider = StateProvider<AuditLogFilter>((ref) {
  return const AuditLogFilter();
});

/// Daftar action_type unik untuk dropdown filter (FR-AUD-02).
final auditLogActionTypesProvider = FutureProvider<List<String>>((ref) {
  return ref.read(auditLogRepositoryProvider).getDistinctActionTypes();
});

/// Notifier untuk daftar log dengan dukungan pagination ("muat lebih
/// banyak") — di-reset otomatis setiap kali [auditLogFilterProvider]
/// berubah.
class AuditLogListNotifier extends AsyncNotifier<List<AuditLogModel>> {
  static const _pageSize = 50;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  @override
  Future<List<AuditLogModel>> build() async {
    final filter = ref.watch(auditLogFilterProvider);
    _hasMore = true;
    final repo = ref.read(auditLogRepositoryProvider);
    final logs = await repo.getLogs(filter: filter, limit: _pageSize);
    _hasMore = logs.length == _pageSize;
    return logs;
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull ?? [];
    if (current.isEmpty || !_hasMore) return;

    final filter = ref.read(auditLogFilterProvider);
    final repo = ref.read(auditLogRepositoryProvider);

    // Pagination berbasis cursor memerlukan DocumentSnapshot asli, yang
    // tidak disimpan di AuditLogModel (model bersifat plain data class).
    // Untuk kesederhanaan MVP, "muat lebih banyak" mengambil ulang
    // dengan limit yang diperbesar — cukup efisien untuk volume log
    // audit yang realistis (puluhan ribu dokumen, bukan jutaan), dan
    // menghindari kompleksitas menyimpan cursor terpisah dari model data.
    final newLimit = current.length + _pageSize;
    final logs = await repo.getLogs(filter: filter, limit: newLimit);
    _hasMore = logs.length == newLimit;
    state = AsyncData(logs);
  }
}

final auditLogListProvider =
    AsyncNotifierProvider<AuditLogListNotifier, List<AuditLogModel>>(
  AuditLogListNotifier.new,
);
