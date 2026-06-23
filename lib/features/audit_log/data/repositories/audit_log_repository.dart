import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/features/audit_log/data/models/audit_log_model.dart';

/// Filter pencarian audit log — sesuai FR-AUD-02 ("Filter: Tanggal,
/// pengguna, tipe aksi"). Semua field opsional; `null` berarti tidak
/// difilter pada dimensi tersebut.
class AuditLogFilter {
  final String? userId;
  final String? actionType;
  final DateTime? startDate;
  final DateTime? endDate;

  const AuditLogFilter({
    this.userId,
    this.actionType,
    this.startDate,
    this.endDate,
  });

  bool get isEmpty =>
      userId == null &&
      actionType == null &&
      startDate == null &&
      endDate == null;

  AuditLogFilter copyWith({
    String? userId,
    String? actionType,
    DateTime? startDate,
    DateTime? endDate,
    bool clearUserId = false,
    bool clearActionType = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return AuditLogFilter(
      userId: clearUserId ? null : (userId ?? this.userId),
      actionType: clearActionType ? null : (actionType ?? this.actionType),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}

/// Repository untuk Audit Log (FR-AUD-01 s.d 03). Read-only — write hanya
/// dilakukan Cloud Functions Admin SDK (Step 15), Security Rules
/// `allow write: if false` untuk client.
///
/// Memakai *one-shot fetch* (`get()`), bukan listener real-time —
/// halaman Audit Log adalah alat audit/investigasi historis, bukan
/// tampilan yang perlu update otomatis saat dibuka, konsisten dengan
/// pendekatan `StatsRepository` di Step 18.
class AuditLogRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Ambil halaman pertama (atau halaman berikutnya via [startAfter])
  /// log audit, diurutkan terbaru lebih dulu, dengan [filter] opsional.
  ///
  /// Catatan index: kombinasi `where(user_id)` ATAU `where(action_type)`
  /// bersama `orderBy(created_at)` masing-masing memerlukan composite
  /// index terpisah (lihat catatan di README) — Firestore tidak
  /// mendukung `where` pada dua field berbeda yang exact-match
  /// bersamaan dengan `orderBy` field ketiga tanpa index gabungan
  /// eksplisit, sehingga jika KEDUA filter (`userId` dan `actionType`)
  /// diisi bersamaan, query difilter ganda di SISI CLIENT untuk
  /// `actionType` setelah query server-side `userId` (volume data log
  /// audit historis untuk satu user cukup kecil agar pendekatan ini
  /// tetap efisien tanpa index tambahan yang rumit).
  Future<List<AuditLogModel>> getLogs({
    AuditLogFilter filter = const AuditLogFilter(),
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _db
        .collection(FirestorePaths.auditLogs)
        .orderBy('created_at', descending: true);

    if (filter.userId != null) {
      query = query.where('user_id', isEqualTo: filter.userId);
    }

    if (filter.startDate != null) {
      query = query.where(
        'created_at',
        isGreaterThanOrEqualTo: Timestamp.fromDate(filter.startDate!),
      );
    }
    if (filter.endDate != null) {
      // endDate bersifat inklusif sampai akhir hari tersebut.
      final endOfDay = DateTime(
        filter.endDate!.year,
        filter.endDate!.month,
        filter.endDate!.day,
        23,
        59,
        59,
      );
      query = query.where(
        'created_at',
        isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
      );
    }

    query = query.limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    var logs = snap.docs.map((d) => AuditLogModel.fromFirestore(d)).toList();

    // Filter actionType di client HANYA jika userId juga diisi (lihat
    // catatan index di docstring) — kalau actionType adalah satu-satunya
    // filter, ia sudah bisa diterapkan langsung sebagai where() di atas.
    if (filter.actionType != null && filter.userId != null) {
      logs = logs.where((l) => l.actionType == filter.actionType).toList();
    }

    return logs;
  }

  /// Versi sederhana: filter actionType TANPA userId — bisa langsung
  /// sebagai query server-side (tidak perlu post-filter client).
  Future<List<AuditLogModel>> getLogsByActionType(
    String actionType, {
    int limit = 50,
  }) async {
    final snap = await _db
        .collection(FirestorePaths.auditLogs)
        .where('action_type', isEqualTo: actionType)
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => AuditLogModel.fromFirestore(d)).toList();
  }

  /// Daftar distinct `action_type` yang pernah tercatat — dipakai untuk
  /// mengisi dropdown filter tanpa hardcode daftar statis yang bisa
  /// kadaluarsa seiring bertambahnya jenis aksi baru.
  Future<List<String>> getDistinctActionTypes({int sampleSize = 200}) async {
    final snap = await _db
        .collection(FirestorePaths.auditLogs)
        .orderBy('created_at', descending: true)
        .limit(sampleSize)
        .get();
    final types = snap.docs
        .map((d) => (d.data())['action_type'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    types.sort();
    return types;
  }
}
