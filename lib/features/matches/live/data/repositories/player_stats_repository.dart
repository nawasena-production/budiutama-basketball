import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';

/// Repository untuk subcollection `matches/{matchId}/player_stats`.
///
/// Ini adalah "materialized stats" — diperbarui INSTAN setiap kali
/// Statistician mencatat event, menggunakan `FieldValue.increment()`
/// (PRD Section 4.5 — Live Match Materialized Stats). Dipakai untuk
/// Tab 2 Live Player Stats yang dipantau real-time oleh Coach & Manager
/// (SRS FR-LMS-16).
///
/// Kalkulasi FINAL (verifikasi ulang dari seluruh event log) dilakukan
/// oleh Cloud Function `onMatchFinished` saat `POST_MATCH` — lihat
/// Step 15 / functions/src/index.ts.
class PlayerStatsRepository {
  PlayerStatsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Stream seluruh player_stats — untuk Tab 2 Live Player Stats.
  Stream<List<PlayerStatsModel>> watchLiveStats(String matchId) {
    return _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => PlayerStatsModel.fromFirestore(d)).toList());
  }

  /// Ambil satu dokumen player_stats sekali (non-stream) — dipakai saat
  /// menghitung total_seconds_played di akhir substitusi.
  Future<PlayerStatsModel?> getOne(String matchId, String statsDocId) async {
    final doc = await _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .doc(statsDocId)
        .get();
    if (!doc.exists) return null;
    return PlayerStatsModel.fromFirestore(doc);
  }

  /// Inisialisasi dokumen player_stats kosong (dipanggil oleh
  /// [MatchRepository.startMatch] saat 5 starter dipilih — lihat Step 9).
  /// Disediakan di sini juga agar bisa dipanggil ulang manual jika
  /// dokumen ternyata belum ada saat pemain pengganti pertama kali masuk
  /// lapangan di tengah pertandingan.
  Future<void> ensureInitialized({
    required String matchId,
    required String statsDocId,
    required String playerId,
    required String fullName,
    required int jerseyNumber,
  }) async {
    final ref = _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .doc(statsDocId);
    final existing = await ref.get();
    if (existing.exists) return;

    await ref.set({
      'player_id': playerId,
      'full_name': fullName,
      'jersey_number': jerseyNumber,
      'points': 0,
      'ft_made': 0, 'ft_attempted': 0,
      'fg2_made': 0, 'fg2_attempted': 0,
      'fg3_made': 0, 'fg3_attempted': 0,
      'assists': 0,
      'offensive_rebounds': 0,
      'defensive_rebounds': 0,
      'steals': 0,
      'turnovers': 0,
      'blocks': 0,
      'fouls': 0,
      'shot_zones': _emptyShotZones(),
      'total_seconds_played': 0,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Helper batch update — dipakai oleh [MatchActionNotifier] supaya
  /// penulisan increment stats selalu konsisten formatnya dan tidak
  /// duplikasi `updated_at`.
  void addIncrementToBatch({
    required WriteBatch batch,
    required String matchId,
    required String statsDocId,
    required Map<String, dynamic> increments,
  }) {
    final ref = _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .doc(statsDocId);
    batch.update(ref, {
      ...increments,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Tambah detik bermain ke total_seconds_played — dipanggil saat
  /// substitusi (pemain keluar) untuk mengakumulasi waktu bermainnya
  /// (SRS FR-LMS-17).
  void addPlayedSecondsToBatch({
    required WriteBatch batch,
    required String matchId,
    required String statsDocId,
    required int additionalSeconds,
  }) {
    final ref = _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .doc(statsDocId);
    batch.update(ref, {
      'total_seconds_played': FieldValue.increment(additionalSeconds),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, dynamic> _emptyShotZones() {
    const zones = [
      'PAINT',
      'MEDIUM_LEFT',
      'MEDIUM_CENTER',
      'MEDIUM_RIGHT',
      'CORNER_LEFT',
      'CORNER_RIGHT',
      'WING_LEFT',
      'WING_RIGHT',
      'CENTER_3',
    ];
    return {
      for (final z in zones) z: {'made': 0, 'attempted': 0},
    };
  }
}
