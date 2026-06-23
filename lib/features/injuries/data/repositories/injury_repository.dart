import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/injuries/data/models/injury_report_model.dart';

class InjuryRepository {
  InjuryRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── STREAMS ───────────────────────────────────────────────────────────

  /// Stream cedera aktif dan recovery satu tim (tidak termasuk cleared).
  /// Digunakan di halaman utama Injury Management.
  Stream<List<InjuryReportModel>> watchActiveByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.injuryReports)
        .where('team_id', isEqualTo: teamId)
        .where('status', whereIn: ['active', 'recovery'])
        .orderBy('injury_date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => InjuryReportModel.fromFirestore(d)).toList());
  }

  /// Stream semua laporan cedera satu tim (termasuk cleared — histori).
  Stream<List<InjuryReportModel>> watchAllByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.injuryReports)
        .where('team_id', isEqualTo: teamId)
        .orderBy('injury_date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => InjuryReportModel.fromFirestore(d)).toList());
  }

  // ── READS ──────────────────────────────────────────────────────────────

  /// Semua riwayat cedera satu pemain — dipakai di profil pemain.
  Future<List<InjuryReportModel>> getByPlayer(String playerId) async {
    final snap = await _db
        .collection(FirestorePaths.injuryReports)
        .where('player_id', isEqualTo: playerId)
        .orderBy('injury_date', descending: true)
        .get();
    return snap.docs
        .map((d) => InjuryReportModel.fromFirestore(d))
        .toList();
  }

  Future<InjuryReportModel?> getById(String reportId) async {
    final doc = await _db
        .collection(FirestorePaths.injuryReports)
        .doc(reportId)
        .get();
    if (!doc.exists) return null;
    return InjuryReportModel.fromFirestore(doc);
  }

  // ── WRITES ─────────────────────────────────────────────────────────────

  /// Buat laporan cedera baru.
  ///
  /// Document ID format: {playerId}_{YYYYMMDD}
  /// Contoh: 7_ar_putra2526_20260205
  ///
  /// Sekaligus update status pemain menjadi 'injured' dalam satu batch write.
  Future<void> create({
    required String reportId,
    required InjuryReportModel report,
  }) async {
    try {
      final batch = _db.batch();

      final data = report.toJson()
        ..remove('id')
        ..['created_at'] = FieldValue.serverTimestamp()
        ..['updated_at'] = FieldValue.serverTimestamp();

      // Simpan laporan cedera
      batch.set(
        _db.collection(FirestorePaths.injuryReports).doc(reportId),
        data,
      );

      // Update status pemain → injured (atomic dengan save laporan)
      batch.update(
        _db.collection(FirestorePaths.players).doc(report.playerId),
        {
          'status': 'injured',
          'updated_at': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();
    } catch (e) {
      throw FirestoreException('Gagal membuat laporan cedera: $e');
    }
  }

  /// Update status laporan cedera: active → recovery → cleared.
  ///
  /// Saat status = 'cleared', Cloud Function `onInjuryStatusChanged`
  /// otomatis mengubah player.status kembali ke 'active'.
  Future<void> updateStatus(String reportId, String status) async {
    try {
      await _db.collection(FirestorePaths.injuryReports).doc(reportId).update({
        'status': status,
        if (status == 'cleared') 'cleared_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Gagal memperbarui status cedera: $e');
    }
  }

  Future<void> updateNotes(String reportId, String notes) async {
    await _db
        .collection(FirestorePaths.injuryReports)
        .doc(reportId)
        .update({
      'notes': notes,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // ── HELPERS ────────────────────────────────────────────────────────────

  /// Generate Document ID sesuai konvensi: {playerId}_{YYYYMMDD}
  /// Contoh: 7_ar_putra2526_20260205
  static String generateReportId({
    required String playerId,
    required DateTime injuryDate,
  }) {
    final datePart =
        '${injuryDate.year}${injuryDate.month.toString().padLeft(2, '0')}${injuryDate.day.toString().padLeft(2, '0')}';
    return '${playerId}_$datePart';
  }
}
