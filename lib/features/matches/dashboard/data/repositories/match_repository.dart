import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/core/utils/match_state_machine.dart';
import 'package:budiutama_basketball/features/matches/dashboard/data/models/match_model.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';

class MatchRepository {
  MatchRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── STREAMS ───────────────────────────────────────────────────────────

  /// Real-time stream pertandingan dalam satu event.
  Stream<List<MatchModel>> watchByEvent(String eventId) {
    return _db
        .collection(FirestorePaths.matches)
        .where('event_id', isEqualTo: eventId)
        .orderBy('scheduled_at')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MatchModel.fromFirestore(d)).toList());
  }

  /// Real-time stream pertandingan yang sedang berlangsung (status: ongoing).
  Stream<List<MatchModel>> watchOngoing(String teamId) {
    return _db
        .collection(FirestorePaths.matches)
        .where('home_team_id', isEqualTo: teamId)
        .where('status', isEqualTo: 'ongoing')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MatchModel.fromFirestore(d)).toList());
  }

  /// Real-time stream satu dokumen pertandingan (untuk Match Mode).
  Stream<MatchModel?> watchById(String matchId) {
    return _db
        .collection(FirestorePaths.matches)
        .doc(matchId)
        .snapshots()
        .map((doc) => doc.exists ? MatchModel.fromFirestore(doc) : null);
  }

  // ── READS ──────────────────────────────────────────────────────────────

  Future<MatchModel?> getById(String matchId) async {
    final doc = await _db.collection(FirestorePaths.matches).doc(matchId).get();
    if (!doc.exists) return null;
    return MatchModel.fromFirestore(doc);
  }

  // ── WRITES ─────────────────────────────────────────────────────────────

  /// Buat pertandingan baru.
  /// Document ID format: {eventId}_vs_{lawan}_{tgl}
  /// Contoh: porseni_kota_2526_vs_sman1_20260315
  Future<void> create({
    required String matchId,
    required MatchModel match,
  }) async {
    try {
      final data = match.toJson()
        ..remove('id')
        ..['created_at'] = FieldValue.serverTimestamp()
        ..['updated_at'] = FieldValue.serverTimestamp();

      await _db.collection(FirestorePaths.matches).doc(matchId).set(data);
    } catch (e) {
      throw FirestoreException('Gagal membuat pertandingan: $e');
    }
  }

  Future<void> update(String matchId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _db.collection(FirestorePaths.matches).doc(matchId).update(data);
    } catch (e) {
      throw FirestoreException('Gagal memperbarui pertandingan: $e');
    }
  }

  Future<void> transitionState({
    required String matchId,
    required String nextState,
  }) async {
    final matchRef = _db.collection(FirestorePaths.matches).doc(matchId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(matchRef);
      if (!snapshot.exists) {
        throw const FirestoreException('Pertandingan tidak ditemukan.');
      }

      final data = snapshot.data() ?? {};
      final currentState = data['current_state'] as String? ?? 'PRE_MATCH';
      if (!isValidTransition(currentState, nextState)) {
        throw MatchStateException(
          'Transisi state tidak valid: $currentState → $nextState.',
        );
      }

      transaction.update(matchRef, {
        'current_state': nextState,
        if (nextState == 'Q1_ACTIVE') 'status': 'ongoing',
        if (nextState == 'POST_MATCH') 'status': 'finished',
        if (nextState == 'POST_MATCH')
          'finished_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Perbarui konfigurasi timer sebelum pertandingan dimulai.
  /// Hanya bisa dilakukan saat timer_config_locked == false.
  Future<void> updateTimerConfig(
    String matchId, {
    required int quarterDurationMinutes,
    required int numPeriods,
    required int otDurationMinutes,
  }) async {
    // Cek apakah config sudah dikunci
    final match = await getById(matchId);
    if (match == null) {
      throw const FirestoreException('Pertandingan tidak ditemukan.');
    }
    if (match.timerConfigLocked) {
      throw const FirestoreException(
          'Konfigurasi timer sudah dikunci. Pertandingan sudah dimulai.');
    }
    await update(matchId, {
      'quarter_duration_minutes': quarterDurationMinutes,
      'num_periods': numPeriods,
      'ot_duration_minutes': otDurationMinutes,
    });
  }

  /// Mulai pertandingan:
  /// 1. Update status match → ongoing, PRE_MATCH
  /// 2. Kunci konfigurasi timer
  /// 3. Inisialisasi dokumen lineup untuk setiap starter
  /// 4. Inisialisasi dokumen player_stats untuk setiap starter
  /// 5. Inisialisasi dokumen timer_state
  ///
  /// Dipanggil oleh Statistician saat tap "Mulai Pertandingan".
  /// Sesuai SRS FR-MCH-05 dan UC-05.
  Future<void> startMatch({
    required String matchId,
    required List<PlayerModel> starters, // tepat 5 pemain starter
    required int quarterDurationMinutes,
  }) async {
    if (starters.length != 5) {
      throw const MatchStateException(
          'Harus memilih tepat 5 pemain starter sebelum memulai pertandingan.');
    }

    final batch = _db.batch();
    final matchRef = _db.collection(FirestorePaths.matches).doc(matchId);

    // 1. Update dokumen match
    batch.update(matchRef, {
      'status': 'ongoing',
      'current_state': 'PRE_MATCH',
      'timer_config_locked': true,
      'started_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // 2. Inisialisasi timer_state
    final timerRef =
        _db.collection(FirestorePaths.matchTimerState(matchId)).doc('state');
    batch.set(timerRef, {
      'is_running': false,
      'seconds_at_start': (quarterDurationMinutes * 60).toDouble(),
      'started_at': null,
      'quarter': 1,
    });

    // 3. Inisialisasi lineup dan player_stats untuk setiap starter
    for (final player in starters) {
      // Derive doc ID: jersey_inisial (bagian sebelum _putra / _putri)
      final docId = _deriveStatsDocId(player.id);

      // Lineup document
      final lineupRef =
          _db.collection(FirestorePaths.matchLineups(matchId)).doc(docId);
      batch.set(lineupRef, {
        'player_id': player.id,
        'full_name': player.fullName,
        'jersey_number': player.jerseyNumber,
        'position': player.primaryPosition,
        'is_starter': true,
        'is_on_court': true,
        'entered_at_clock': (quarterDurationMinutes * 60).toDouble(),
        'entered_at_quarter': 1,
        'total_seconds_played': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Player stats document (diinisialisasi nol semua)
      final statsRef =
          _db.collection(FirestorePaths.matchPlayerStats(matchId)).doc(docId);
      batch.set(statsRef, {
        'player_id': player.id,
        'full_name': player.fullName,
        'jersey_number': player.jerseyNumber,
        'points': 0,
        'ft_made': 0,
        'ft_attempted': 0,
        'fg2_made': 0,
        'fg2_attempted': 0,
        'fg3_made': 0,
        'fg3_attempted': 0,
        'assists': 0,
        'offensive_rebounds': 0,
        'defensive_rebounds': 0,
        'steals': 0,
        'turnovers': 0,
        'blocks': 0,
        'fouls': 0,
        'shot_zones': {
          'PAINT': {'made': 0, 'attempted': 0},
          'MEDIUM_LEFT': {'made': 0, 'attempted': 0},
          'MEDIUM_CENTER': {'made': 0, 'attempted': 0},
          'MEDIUM_RIGHT': {'made': 0, 'attempted': 0},
          'CORNER_LEFT': {'made': 0, 'attempted': 0},
          'CORNER_RIGHT': {'made': 0, 'attempted': 0},
          'WING_LEFT': {'made': 0, 'attempted': 0},
          'WING_RIGHT': {'made': 0, 'attempted': 0},
          'CENTER_3': {'made': 0, 'attempted': 0},
        },
        'total_seconds_played': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> cancelMatch(String matchId) async {
    await update(matchId, {'status': 'cancelled'});
  }

  // ── HELPERS ────────────────────────────────────────────────────────────

  /// Generate Document ID pertandingan:
  /// {eventId}_vs_{lawanShort}_{YYYYMMDD}
  /// Contoh: porseni_kota_2526_vs_sman1_20260315
  static String generateMatchId({
    required String eventId,
    required String opponentName,
    required DateTime scheduledAt,
  }) {
    // Normalisasi nama lawan: ambil kata pertama yang bermakna, lowercase
    final opponentShort = opponentName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .join('');

    final datePart =
        '${scheduledAt.year}${scheduledAt.month.toString().padLeft(2, '0')}${scheduledAt.day.toString().padLeft(2, '0')}';

    return '${eventId}_vs_${opponentShort}_$datePart';
  }

  /// Derive stats/lineup doc ID dari player ID.
  /// Player ID format: {jersey}_{inisial}_{teamPart}
  /// Stats doc ID format: {jersey}_{inisial}
  /// Contoh: "7_ar_putra2526" → "7_ar"
  static String _deriveStatsDocId(String playerId) {
    final parts = playerId.split('_');
    if (parts.length >= 2) {
      return '${parts[0]}_${parts[1]}';
    }
    return playerId;
  }
}
