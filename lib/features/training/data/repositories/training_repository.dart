import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/training/data/models/training_session_model.dart';

class TrainingRepository {
  TrainingRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── STREAMS ───────────────────────────────────────────────────────────

  /// Stream semua sesi latihan satu tim — mendatang dan lampau.
  Stream<List<TrainingSessionModel>> watchByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.trainingSessions)
        .where('team_id', isEqualTo: teamId)
        .orderBy('scheduled_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrainingSessionModel.fromFirestore(d))
            .toList());
  }

  /// Stream sesi latihan yang belum dibatalkan dan masih akan datang.
  Stream<List<TrainingSessionModel>> watchUpcoming(String teamId) {
    final now = Timestamp.now();
    return _db
        .collection(FirestorePaths.trainingSessions)
        .where('team_id', isEqualTo: teamId)
        .where('is_cancelled', isEqualTo: false)
        .where('scheduled_at', isGreaterThanOrEqualTo: now)
        .orderBy('scheduled_at')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrainingSessionModel.fromFirestore(d))
            .toList());
  }

  /// Stream sesi latihan yang sudah lewat (histori).
  Stream<List<TrainingSessionModel>> watchPast(String teamId) {
    final now = Timestamp.now();
    return _db
        .collection(FirestorePaths.trainingSessions)
        .where('team_id', isEqualTo: teamId)
        .where('is_cancelled', isEqualTo: false)
        .where('scheduled_at', isLessThan: now)
        .orderBy('scheduled_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrainingSessionModel.fromFirestore(d))
            .toList());
  }

  // ── READS ──────────────────────────────────────────────────────────────

  Future<TrainingSessionModel?> getById(String sessionId) async {
    final doc = await _db
        .collection(FirestorePaths.trainingSessions)
        .doc(sessionId)
        .get();
    if (!doc.exists) return null;
    return TrainingSessionModel.fromFirestore(doc);
  }

  // ── WRITES ─────────────────────────────────────────────────────────────

  /// Buat sesi latihan baru.
  /// Document ID format: {teamId}_{tipe}_{YYYYMMDD}
  /// Contoh: putra2526_fisik_20260110
  Future<void> create({
    required String sessionId,
    required TrainingSessionModel session,
  }) async {
    try {
      final data = session.toJson()
        ..remove('id')
        ..['created_at'] = FieldValue.serverTimestamp()
        ..['updated_at'] = FieldValue.serverTimestamp();

      await _db
          .collection(FirestorePaths.trainingSessions)
          .doc(sessionId)
          .set(data);
    } catch (e) {
      throw FirestoreException('Gagal membuat jadwal latihan: $e');
    }
  }

  Future<void> update(String sessionId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _db
          .collection(FirestorePaths.trainingSessions)
          .doc(sessionId)
          .update(data);
    } catch (e) {
      throw FirestoreException('Gagal memperbarui jadwal latihan: $e');
    }
  }

  /// Batalkan sesi latihan (soft delete — data tetap tersimpan).
  Future<void> cancel(String sessionId) async {
    await update(sessionId, {'is_cancelled': true});
  }

  // ── HELPERS ────────────────────────────────────────────────────────────

  /// Generate Document ID sesuai konvensi:
  /// {teamId_tanpa_underscore}_{tipe}_{YYYYMMDD}
  /// Contoh: putra2526_fisik_20260110
  static String generateSessionId({
    required String teamId,
    required String sessionType,
    required DateTime scheduledAt,
  }) {
    final teamShort = teamId.replaceAll('_', '');
    final datePart =
        '${scheduledAt.year}${scheduledAt.month.toString().padLeft(2, '0')}${scheduledAt.day.toString().padLeft(2, '0')}';
    return '${teamShort}_${sessionType}_$datePart';
  }
}
