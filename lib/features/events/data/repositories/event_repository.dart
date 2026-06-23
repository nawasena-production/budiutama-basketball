import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/events/data/models/event_model.dart';

class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── STREAMS ───────────────────────────────────────────────────────────

  /// Real-time stream semua event satu tim, diurutkan terbaru dulu.
  Stream<List<EventModel>> watchByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.events)
        .where('team_id', isEqualTo: teamId)
        .orderBy('start_date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
  }

  /// Stream event yang masih aktif/upcoming saja.
  Stream<List<EventModel>> watchActive(String teamId) {
    return _db
        .collection(FirestorePaths.events)
        .where('team_id', isEqualTo: teamId)
        .where('status', whereIn: ['upcoming', 'ongoing'])
        .orderBy('start_date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
  }

  // ── READS ──────────────────────────────────────────────────────────────

  Future<EventModel?> getById(String eventId) async {
    final doc = await _db.collection(FirestorePaths.events).doc(eventId).get();
    if (!doc.exists) return null;
    return EventModel.fromFirestore(doc);
  }

  // ── WRITES ─────────────────────────────────────────────────────────────

  /// Buat event baru.
  /// Document ID format: {tipe}_{namasingkat}_{tahun}
  /// Contoh: porseni_kota_2526
  Future<void> create({
    required String eventId,
    required EventModel event,
  }) async {
    try {
      final data = event.toJson()
        ..remove('id')
        ..['created_at'] = FieldValue.serverTimestamp()
        ..['updated_at'] = FieldValue.serverTimestamp();

      await _db.collection(FirestorePaths.events).doc(eventId).set(data);
    } catch (e) {
      throw FirestoreException('Gagal membuat event: $e');
    }
  }

  Future<void> update(String eventId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _db.collection(FirestorePaths.events).doc(eventId).update(data);
    } catch (e) {
      throw FirestoreException('Gagal memperbarui event: $e');
    }
  }

  Future<void> updateStatus(String eventId, String status) async {
    await update(eventId, {'status': status});
  }

  // ── HELPERS ────────────────────────────────────────────────────────────

  /// Generate Document ID sesuai konvensi:
  /// {tipe}_{namasingkat}_{tahunAjaran}
  ///
  /// Contoh:
  /// - tipe="porseni", namaEvent="Porseni Kota Yogyakarta", tahun="2526"
  ///   → "porseni_kota_2526"
  static String generateEventId({
    required String eventType,
    required String eventName,
    required String academicYearCode, // "2526"
  }) {
    // Ambil kata pertama yang bermakna dari nama event (bukan kata umum)
    const skipWords = {'tim', 'dan', 'di', 'ke', 'yang', 'sma', 'sman', 'tingkat'};
    final words = eventName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !skipWords.contains(w))
        .take(2)
        .toList();

    final namePart = words.join('_');
    return '${eventType}_${namePart}_$academicYearCode';
  }

  /// Konversi tahun ajaran "2025/2026" → "2526"
  static String academicYearToCode(String academicYear) {
    final parts = academicYear.split('/');
    if (parts.length != 2) return academicYear;
    return '${parts[0].substring(2)}${parts[1].substring(2)}';
  }
}
