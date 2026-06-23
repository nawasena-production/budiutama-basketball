import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/lineup_model.dart';

/// Repository untuk subcollection `matches/{matchId}/lineups`.
///
/// Dokumen lineup diinisialisasi untuk 5 starter saat
/// [MatchRepository.startMatch] dipanggil (Step 9). Repository ini
/// menambahkan operasi yang baru relevan setelah pertandingan berjalan:
/// query pemain di lapangan vs bangku cadangan, dan substitusi
/// (FR-LMS-07 / SRS UC-07).
class LineupRepository {
  LineupRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _lineupsRef(String matchId) {
    return _db.collection(FirestorePaths.matchLineups(matchId));
  }

  /// Stream 5 pemain yang sedang di lapangan — sumber data Left Panel
  /// (FR-LMS-02).
  Stream<List<LineupModel>> watchOnCourt(String matchId) {
    return _lineupsRef(matchId)
        .where('is_on_court', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => LineupModel.fromFirestore(d)).toList());
  }

  /// Stream seluruh lineup (starter + non-starter yang sudah pernah
  /// dimasukkan dokumennya) — dipakai [SubstitutionPanel] untuk
  /// menentukan daftar "pemain KELUAR" (yang `is_on_court == true`).
  Stream<List<LineupModel>> watchAll(String matchId) {
    return _lineupsRef(matchId).snapshots().map((snap) =>
        snap.docs.map((d) => LineupModel.fromFirestore(d)).toList());
  }

  /// Ambil satu dokumen lineup sekali (non-stream).
  Future<LineupModel?> getOne(String matchId, String statsDocId) async {
    final doc = await _lineupsRef(matchId).doc(statsDocId).get();
    if (!doc.exists) return null;
    return LineupModel.fromFirestore(doc);
  }

  /// Pastikan dokumen lineup untuk seorang pemain bangku cadangan sudah
  /// ada sebelum disubstitusikan masuk untuk PERTAMA KALI di pertandingan
  /// ini (starter sudah diinisialisasi otomatis oleh `startMatch()`,
  /// tapi pemain bangku yang belum pernah bermain belum punya dokumen
  /// lineup sama sekali).
  Future<void> ensureInitialized({
    required String matchId,
    required String statsDocId,
    required String playerId,
    required String fullName,
    required int jerseyNumber,
    required String position,
  }) async {
    final ref = _lineupsRef(matchId).doc(statsDocId);
    final existing = await ref.get();
    if (existing.exists) return;

    await ref.set({
      'player_id': playerId,
      'full_name': fullName,
      'jersey_number': jerseyNumber,
      'position': position,
      'is_starter': false,
      'is_on_court': false,
      'entered_at_clock': null,
      'entered_at_quarter': null,
      'total_seconds_played': 0,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Substitusi: satu pemain KELUAR, satu pemain MASUK — dieksekusi
  /// sebagai batch atomik bersama dengan pencatatan event SUBSTITUTION
  /// dan akumulasi `total_seconds_played` pemain yang keluar
  /// (SRS FR-LMS-07, FR-LMS-17).
  ///
  /// [outStatsDocId] dan [inStatsDocId] adalah doc ID pendek
  /// (`{jersey}_{inisial}`), BUKAN player ID penuh.
  ///
  /// [secondsPlayedThisStint] adalah durasi bermain pemain yang keluar
  /// sejak terakhir kali ia masuk lapangan — dihitung oleh caller
  /// (biasanya `SubstitutionNotifier`) berdasarkan
  /// `currentRemainingSeconds()` saat ini dikurangi `entered_at_clock`.
  Future<void> substitute({
    required String matchId,
    required int quarter,
    required double timeRemaining,
    required String createdBy,
    required LineupModel playerOut,
    required LineupModel playerIn,
    required double secondsPlayedThisStint,
  }) async {
    if (!playerOut.isOnCourt) {
      throw const MatchStateException(
        'Pemain yang dipilih KELUAR tidak sedang berada di lapangan.',
      );
    }
    if (playerIn.isOnCourt) {
      throw const MatchStateException(
        'Pemain yang dipilih MASUK sudah berada di lapangan.',
      );
    }

    final batch = _db.batch();

    // 1. Update lineup pemain KELUAR
    batch.update(_lineupsRef(matchId).doc(playerOut.id), {
      'is_on_court': false,
      'entered_at_clock': null,
      'entered_at_quarter': null,
      'total_seconds_played': FieldValue.increment(
        secondsPlayedThisStint.round(),
      ),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // 2. Update lineup pemain MASUK
    batch.update(_lineupsRef(matchId).doc(playerIn.id), {
      'is_on_court': true,
      'entered_at_clock': timeRemaining,
      'entered_at_quarter': quarter,
      'updated_at': FieldValue.serverTimestamp(),
    });

    // 3. Catat event SUBSTITUTION (immutable, untuk Event Timeline)
    final seq = await _nextSequenceFor(matchId, quarter);
    final eventId = 'q${quarter}_${seq.toString().padLeft(3, '0')}';
    batch.set(
      _db.doc('${FirestorePaths.matchEvents(matchId)}/$eventId'),
      {
        'quarter': quarter,
        'time_remaining': timeRemaining,
        'player_id': playerIn.playerId,
        'action_type': 'SUBSTITUTION',
        'value': 0,
        'zone': null,
        'shot_x': null,
        'shot_y': null,
        'shot_distance_ft': null,
        'is_opponent': false,
        'is_undone': false,
        'undo_ref_id': null,
        'sub_out_player_id': playerOut.playerId,
        'sub_out_jersey': playerOut.jerseyNumber,
        'sub_in_jersey': playerIn.jerseyNumber,
        'created_by': createdBy,
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    // 4. Tambahkan total_seconds_played ke player_stats pemain KELUAR
    //    (materialized stats — bukan hanya field di lineup) supaya Tab 2
    //    Live Player Stats menit bermainnya ikut akurat real-time.
    final outStatsRef =
        _db.collection(FirestorePaths.matchPlayerStats(matchId)).doc(
              playerOut.id,
            );
    batch.update(outStatsRef, {
      'total_seconds_played': FieldValue.increment(
        secondsPlayedThisStint.round(),
      ),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<int> _nextSequenceFor(String matchId, int quarter) async {
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('quarter', isEqualTo: quarter)
        .count()
        .get();
    return (snap.count ?? 0) + 1;
  }
}
