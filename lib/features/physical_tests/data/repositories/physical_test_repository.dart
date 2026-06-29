import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_result_model.dart';
import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_session_model.dart';

class PhysicalTestRepository {
  PhysicalTestRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── STREAMS ───────────────────────────────────────────────────────────

  /// Stream semua sesi tes fisik satu tim berdasarkan tipe.
  Stream<List<PhysicalTestSessionModel>> watchByTeam(
      String teamId, String testType) {
    return _db
        .collection(FirestorePaths.physicalTestSessions)
        .where('team_id', isEqualTo: teamId)
        .where('test_type', isEqualTo: testType)
        .orderBy('scheduled_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PhysicalTestSessionModel.fromFirestore(d))
            .toList());
  }

  /// Stream hasil (results) satu sesi — real-time saat sesi berjalan.
  Stream<List<PhysicalTestResultModel>> watchResults(String sessionId) {
    return _db
        .collection(FirestorePaths.physicalTestResults(sessionId))
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PhysicalTestResultModel.fromFirestore(d))
            .toList());
  }

  /// Stream satu sesi tes fisik berdasarkan ID.
  Stream<PhysicalTestSessionModel?> watchSessionById(String sessionId) {
    return _db
        .collection(FirestorePaths.physicalTestSessions)
        .doc(sessionId)
        .snapshots()
        .map((doc) => doc.exists
            ? PhysicalTestSessionModel.fromFirestore(doc)
            : null);
  }

  // ── READS ──────────────────────────────────────────────────────────────

  Future<PhysicalTestSessionModel?> getSessionById(String sessionId) async {
    final doc = await _db
        .collection(FirestorePaths.physicalTestSessions)
        .doc(sessionId)
        .get();
    if (!doc.exists) return null;
    return PhysicalTestSessionModel.fromFirestore(doc);
  }

  Future<List<PhysicalTestResultModel>> getResults(String sessionId) async {
    final snap = await _db
        .collection(FirestorePaths.physicalTestResults(sessionId))
        .get();
    return snap.docs
        .map((d) => PhysicalTestResultModel.fromFirestore(d))
        .toList();
  }

  /// Ambil semua hasil satu pemain di semua sesi (tren per semester).
  Future<List<Map<String, dynamic>>> getPlayerTrend({
    required String teamId,
    required String playerId,  // format: jersey_inisial
    required String testType,
    required String academicYear,
    required int semester,
  }) async {
    final sessionsSnap = await _db
        .collection(FirestorePaths.physicalTestSessions)
        .where('team_id', isEqualTo: teamId)
        .where('test_type', isEqualTo: testType)
        .where('academic_year', isEqualTo: academicYear)
        .where('semester', isEqualTo: semester)
        .orderBy('scheduled_at')
        .get();

    final results = <Map<String, dynamic>>[];
    for (final sessionDoc in sessionsSnap.docs) {
      final resultDoc = await _db
          .collection(
              FirestorePaths.physicalTestResults(sessionDoc.id))
          .doc(playerId)
          .get();
      if (resultDoc.exists) {
        results.add({
          'session_id': sessionDoc.id,
          'scheduled_at': sessionDoc.data()['scheduled_at'],
          ...resultDoc.data() as Map<String, dynamic>,
        });
      }
    }
    return results;
  }

  // ── WRITES ─────────────────────────────────────────────────────────────

  /// Buat sesi tes fisik baru.
  /// Document ID format: {tipe}_{teamId_tanpa_underscore}_{YYYYMMDD}
  /// Contoh: beep_putra2526_20260120
  Future<void> createSession({
    required String sessionId,
    required PhysicalTestSessionModel session,
  }) async {
    try {
      final data = session.toJson()
        ..remove('id')
        ..['created_at'] = FieldValue.serverTimestamp();
      await _db
          .collection(FirestorePaths.physicalTestSessions)
          .doc(sessionId)
          .set(data);
    } catch (e) {
      throw FirestoreException('Gagal membuat sesi tes fisik: $e');
    }
  }

  /// Simpan hasil Beep Test satu pemain.
  Future<void> saveBeepResult({
    required String sessionId,
    required String playerDocId,   // format: jersey_inisial (doc ID)
    required String fullPlayerId,  // format: jersey_inisial_teamId
    required String fullName,
    required int beepLevel,
    required int beepShuttle,
  }) async {
    await _db
        .collection(FirestorePaths.physicalTestResults(sessionId))
        .doc(playerDocId)
        .set({
      'player_id': fullPlayerId,
      'full_name': fullName,
      'beep_level': beepLevel,
      'beep_shuttle': beepShuttle,
      'time_seconds': null,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Simpan hasil T-Test atau Sprint 20m.
  Future<void> saveTimedResult({
    required String sessionId,
    required String playerDocId,
    required String fullPlayerId,
    required String fullName,
    required double timeSeconds,
  }) async {
    await _db
        .collection(FirestorePaths.physicalTestResults(sessionId))
        .doc(playerDocId)
        .set({
      'player_id': fullPlayerId,
      'full_name': fullName,
      'beep_level': null,
      'beep_shuttle': null,
      'time_seconds': timeSeconds,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  /// Hentikan sesi lebih awal (data yang sudah diinput tetap tersimpan).
  Future<void> stopSessionEarly(String sessionId) async {
    await _db
        .collection(FirestorePaths.physicalTestSessions)
        .doc(sessionId)
        .update({'is_stopped_early': true});
  }

  // ── HELPERS ────────────────────────────────────────────────────────────

  /// Generate Document ID sesi: {tipe}_{teamShort}_{YYYYMMDD}
  /// Contoh: beep_putra2526_20260120
  static String generateSessionId({
    required String testType,
    required String teamId,
    required DateTime scheduledAt,
  }) {
    final teamShort = teamId.replaceAll('_', '');
    final datePart =
        '${scheduledAt.year}${scheduledAt.month.toString().padLeft(2, '0')}${scheduledAt.day.toString().padLeft(2, '0')}';
    return '${testType}_${teamShort}_$datePart';
  }

  /// Derive player doc ID dari full player ID.
  /// Contoh: "7_ar_putra2526" → "7_ar"
  static String derivePlayerDocId(String fullPlayerId) {
    final parts = fullPlayerId.split('_');
    return parts.length >= 2 ? '${parts[0]}_${parts[1]}' : fullPlayerId;
  }
}
