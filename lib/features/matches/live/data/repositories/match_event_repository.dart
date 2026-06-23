import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/match_event_model.dart';

/// Action types yang TIDAK bisa di-undo lewat tombol UNDO statistik biasa.
///
/// Ini adalah event "sistem" (kontrol pertandingan), bukan aksi statistik
/// pemain — sesuai SRS FR-LMS-08: hanya aksi statistik terakhir yang
/// di-undo, bukan event kontrol seperti timer atau substitusi.
const kNonUndoableActionTypes = {
  'UNDO',
  'STATE_TRANSITION',
  'TIMER_START',
  'TIMER_PAUSE',
  'TIMER_RESUME',
  'SUBSTITUTION',
  'TIMEOUT',
};

/// Repository untuk subcollection `matches/{matchId}/events`.
///
/// Event bersifat IMMUTABLE setelah dibuat (SDD Section 3.1 — Immutability
/// First). Security Rules hanya mengizinkan field `is_undone` diubah,
/// itu pun hanya oleh Statistician. Repository ini tidak pernah melakukan
/// `.delete()` atau update field selain `is_undone`.
class MatchEventRepository {
  MatchEventRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Stream seluruh event, terbaru di atas — untuk Event Timeline
  /// (SRS FR-LMS-09).
  Stream<List<MatchEventModel>> watchEvents(String matchId) {
    return _db
        .collection(FirestorePaths.matchEvents(matchId))
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MatchEventModel.fromFirestore(d)).toList());
  }

  /// Stream event untuk shot chart / heatmap — hanya event tembakan
  /// (shot_x terisi) yang belum di-undo dan bukan milik lawan
  /// (SRS FR-STT-03).
  Stream<List<MatchEventModel>> watchShotEvents(String matchId) {
    return _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('is_undone', isEqualTo: false)
        .where('is_opponent', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MatchEventModel.fromFirestore(d))
            .where((e) => e.shotX != null && e.shotY != null)
            .toList());
  }

  /// Ambil event statistik terakhir yang masih bisa di-undo.
  ///
  /// Mengecualikan event sistem (lihat [kNonUndoableActionTypes]) dan
  /// event yang sudah ditandai `is_undone: true`.
  Future<MatchEventModel?> getLastUndoableEvent(String matchId) async {
    // whereNotIn Firestore dibatasi maksimal 30 nilai — kNonUndoableActionTypes
    // jauh di bawah limit itu sehingga aman dipakai langsung.
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('is_undone', isEqualTo: false)
        .where('action_type', whereNotIn: kNonUndoableActionTypes.toList())
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return MatchEventModel.fromFirestore(snap.docs.first);
  }

  /// Hitung sequence berikutnya untuk quarter tertentu, dipakai untuk
  /// menyusun event ID `q{quarter}_{urutan3digit}` (SDD Section 3.1).
  ///
  /// CATATAN DESAIN: pendekatan "hitung dokumen lalu +1" rawan race
  /// condition jika dua Statistician menulis bersamaan pada quarter yang
  /// sama persis di waktu yang sama. Karena hanya SATU Statistician yang
  /// aktif per pertandingan pada satu waktu (sesuai role matrix PRD
  /// Section 3), risiko ini diterima secara sadar — bukan kelalaian.
  /// Jika di masa depan dibutuhkan multi-statistician per match, ganti
  /// dengan counter dokumen tunggal yang diupdate via transaction.
  Future<int> getNextSequence(String matchId, int quarter) async {
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('quarter', isEqualTo: quarter)
        .count()
        .get();
    return (snap.count ?? 0) + 1;
  }

  /// Generate event ID dengan format `q{quarter}_{seq3digit}`.
  static String buildEventId(int quarter, int sequence) {
    return 'q${quarter}_${sequence.toString().padLeft(3, '0')}';
  }

  /// Ambil satu event spesifik (dipakai saat menampilkan detail di
  /// Event Timeline, misal untuk dialog konfirmasi undo).
  Future<MatchEventModel?> getById(String matchId, String eventId) async {
    final doc = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .doc(eventId)
        .get();
    if (!doc.exists) return null;
    return MatchEventModel.fromFirestore(doc);
  }

  /// Ambil event tunggal melalui referensi langsung — dipakai oleh
  /// [MatchActionNotifier] yang sudah memiliki [DocumentReference] dari
  /// hasil query lain, untuk menghindari fetch ganda.
  DocumentReference<Map<String, dynamic>> eventRef(
      String matchId, String eventId) {
    return _db.collection(FirestorePaths.matchEvents(matchId)).doc(eventId);
  }

  /// Validasi sebelum mencatat aksi: pertandingan harus dalam state aktif.
  ///
  /// Dipanggil dari [MatchActionNotifier] sebelum menulis batch, bukan di
  /// sini — repository ini sengaja TIDAK membaca dokumen match, supaya
  /// tidak terjadi dependency silang antar repository. Helper ini hanya
  /// untuk dokumentasi kontrak: jika `currentState` bukan salah satu di
  /// bawah, pemanggil harus melempar [MatchStateException] SEBELUM
  /// memanggil repository ini.
  static const validActiveStates = {
    'Q1_ACTIVE',
    'Q2_ACTIVE',
    'Q3_ACTIVE',
    'Q4_ACTIVE',
    'OT_ACTIVE',
  };

  static void assertMatchIsActive(String currentState) {
    if (!validActiveStates.contains(currentState)) {
      throw MatchStateException(
        'Tidak bisa mencatat aksi — pertandingan tidak dalam state aktif '
        '(state saat ini: $currentState).',
      );
    }
  }
}
