import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/core/utils/zone_classifier.dart';
import 'package:budiutama_basketball/features/matches/live/data/repositories/match_event_repository.dart';

/// Action types yang valid untuk tim sendiri (PRD Section 7.2,
/// SDD Section 3.2 — subcollection events).
const kSelfActionTypes = {
  '1PT_MADE',
  '2PT_MADE',
  '3PT_MADE',
  'MISS_1PT',
  'MISS_2PT',
  'MISS_3PT',
  'ASSIST',
  'REBOUND_OFF',
  'REBOUND_DEF',
  'STEAL',
  'TURNOVER',
  'BLOCK',
  'FOUL',
};

/// Action types yang valid untuk tim lawan — TIDAK ada pencatatan
/// tembakan gagal untuk lawan (PRD Section 7.2).
const kOpponentActionTypes = {'1PT_MADE', '2PT_MADE', '3PT_MADE', 'FOUL'};

/// Notifier inti Live Match Engine — bertanggung jawab atas SELURUH
/// penulisan Firestore terkait pencatatan statistik pertandingan:
/// event log (immutable), materialized player_stats (incremental), dan
/// skor pertandingan. Satu instance per `matchId` ([FamilyNotifier]).
///
/// PRINSIP DESAIN (SDD Section 1.2 — Dual-Write Strategy):
/// - Setiap aksi ditulis sebagai SATU batch atomik: event baru + stats
///   increment + skor increment. Jika salah satu gagal, semuanya gagal
///   (Firestore batch bersifat all-or-nothing).
/// - Event tidak pernah dihapus atau diubah selain field `is_undone`.
/// - Undo TIDAK menghapus event asli — menandainya `is_undone: true` dan
///   menambahkan event baru bertipe `UNDO` yang mereferensikannya, lalu
///   melakukan decrement stats yang berlawanan dengan increment asli.
class MatchActionNotifier extends FamilyNotifier<void, String> {
  String get matchId => arg;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  MatchEventRepository get _eventRepo => MatchEventRepository(firestore: _db);

  bool _isProcessing = false;

  @override
  void build(String arg) {
    // Tidak ada state yang disimpan — notifier ini stateless, hanya
    // wadah untuk action methods. State loading/error per-aksi
    // ditangani oleh AsyncValue di provider terpisah jika UI
    // membutuhkan indikator (lihat match_action_ui_provider, opsional).
  }

  // ── RECORD ACTION ─────────────────────────────────────────────────────

  /// Mencatat satu aksi statistik (tim sendiri atau lawan).
  ///
  /// Parameter [zone], [shotX], [shotY], [shotDistanceFt] HANYA diisi
  /// untuk aksi tembakan 2PT/3PT (made atau miss) — free throw (1PT)
  /// tidak memakai court overlay sama sekali (SRS FR-LMS-03).
  ///
  /// Melempar [MatchStateException] jika `currentMatchState` bukan state
  /// aktif (Q1_ACTIVE..OT_ACTIVE) — dicek SEBELUM melakukan write apa pun.
  ///
  /// Melempar [InvalidZoneConsistencyException] jika [zone] diberikan
  /// namun tidak konsisten dengan [actionType], KECUALI [forceConfirmed]
  /// bernilai true (dipakai setelah Statistician menekan "Lanjutkan" pada
  /// dialog konfirmasi ketidaksesuaian zona — SRS FR-LMS-14).
  Future<void> recordAction({
    required String currentMatchState,
    required String playerId, // null secara efektif diabaikan jika isOpponent
    required String actionType,
    required int quarter,
    required double timeRemaining,
    required String createdBy,
    String? playerFullName,
    int? jerseyNumber,
    String? zone,
    double? shotX,
    double? shotY,
    int? shotDistanceFt,
    bool isOpponent = false,
    bool forceConfirmed = false,
  }) async {
    if (_isProcessing) {
      throw const MatchStateException(
        'Aksi sebelumnya masih diproses. Tunggu sebentar lalu coba lagi.',
      );
    }
    _isProcessing = true;
    try {
    MatchEventRepository.assertMatchIsActive(currentMatchState);

    final allowedTypes = isOpponent ? kOpponentActionTypes : kSelfActionTypes;
    if (!allowedTypes.contains(actionType)) {
      throw MatchStateException(
        'Action type "$actionType" tidak valid untuk '
        '${isOpponent ? "tim lawan" : "tim sendiri"}.',
      );
    }

    if (zone != null && !forceConfirmed) {
      if (!validateZoneActionConsistency(actionType, zone)) {
        throw InvalidZoneConsistencyException(
          'Zona "$zone" tidak konsisten dengan aksi "$actionType". '
          'Konfirmasi ulang diperlukan sebelum melanjutkan.',
        );
      }
    }

    final sequence = await _eventRepo.getNextSequence(matchId, quarter);
    final eventId = MatchEventRepository.buildEventId(quarter, sequence);
    final value = _valueFromAction(actionType);

    final batch = _db.batch();

    // 1. Tulis event baru (immutable).
    batch.set(
      _db.collection(FirestorePaths.matchEvents(matchId)).doc(eventId),
      {
        'quarter': quarter,
        'time_remaining': timeRemaining,
        'player_id': isOpponent ? null : playerId,
        'action_type': actionType,
        'value': value,
        'zone': zone,
        'shot_x': shotX,
        'shot_y': shotY,
        'shot_distance_ft': shotDistanceFt,
        'is_opponent': isOpponent,
        'is_undone': false,
        'undo_ref_id': null,
        'created_by': createdBy,
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    // 2. Update materialized player_stats — HANYA untuk tim sendiri.
    //    Tim lawan tidak memiliki dokumen player_stats individual
    //    (PRD Section 7.2 — agregat tim saja, tidak ada breakdown pemain).
    if (!isOpponent) {
      final statsDocId = derivePlayerStatsDocId(playerId);
      final increments = buildStatsIncrement(actionType, zone);
      final statsDelta = expandDottedFieldPaths(increments);
      batch.set(
        _db
            .collection(FirestorePaths.matchPlayerStats(matchId))
            .doc(statsDocId),
        {
          'player_id': playerId,
          if (playerFullName != null) 'full_name': playerFullName,
          if (jerseyNumber != null) 'jersey_number': jerseyNumber,
          ...statsDelta,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    // 3. Update skor pertandingan jika aksi menghasilkan poin.
    if (value > 0) {
      final scoreField = isOpponent ? 'opponent_score' : 'home_score';
      batch.update(
        _db.collection(FirestorePaths.matches).doc(matchId),
        {
          scoreField: FieldValue.increment(value),
          'updated_at': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
    } finally {
      _isProcessing = false;
    }
  }

  // ── UNDO LAST ACTION ──────────────────────────────────────────────────

  /// Membatalkan aksi statistik terakhir yang tercatat (SRS FR-LMS-08).
  ///
  /// Mengembalikan `true` jika ada event yang berhasil di-undo, `false`
  /// jika tidak ada event yang bisa di-undo (misal log masih kosong).
  Future<bool> undoLastAction({required String createdBy}) async {
    if (_isProcessing) {
      throw const MatchStateException(
        'Aksi sebelumnya masih diproses. Tunggu sebentar lalu coba lagi.',
      );
    }
    _isProcessing = true;
    try {
    final eventToUndo = await _eventRepo.getLastUndoableEvent(matchId);
    if (eventToUndo == null) return false;

    final undoSequence = await _eventRepo.getNextSequence(
      matchId,
      eventToUndo.quarter,
    );
    final undoEventId =
        MatchEventRepository.buildEventId(eventToUndo.quarter, undoSequence);

    final batch = _db.batch();

    // 1. Tandai event asli sebagai undone — SATU-SATUNYA field yang
    //    boleh diubah pada event immutable (Security Rules SDD 4).
    batch.update(
      _db.collection(FirestorePaths.matchEvents(matchId)).doc(eventToUndo.id),
      {'is_undone': true},
    );

    // 2. Tambah event baru bertipe UNDO yang mereferensikan event asli.
    batch.set(
      _db.collection(FirestorePaths.matchEvents(matchId)).doc(undoEventId),
      {
        'quarter': eventToUndo.quarter,
        'time_remaining': eventToUndo.timeRemaining,
        'player_id': null,
        'action_type': 'UNDO',
        'value': 0,
        'zone': null,
        'shot_x': null,
        'shot_y': null,
        'shot_distance_ft': null,
        'is_opponent': false,
        'is_undone': false,
        'undo_ref_id': eventToUndo.id,
        'created_by': createdBy,
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    // 3. Reverse materialized player_stats — hanya jika event asli milik
    //    tim sendiri (tim lawan tidak punya dokumen player_stats).
    if (!eventToUndo.isOpponent && eventToUndo.playerId != null) {
      final statsDocId = derivePlayerStatsDocId(eventToUndo.playerId!);
      final decrements =
          buildStatsDecrement(eventToUndo.actionType, eventToUndo.zone);
      final statsDelta = expandDottedFieldPaths(decrements);
      batch.set(
        _db
            .collection(FirestorePaths.matchPlayerStats(matchId))
            .doc(statsDocId),
        {
          'player_id': eventToUndo.playerId,
          ...statsDelta,
          'updated_at': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    // 4. Reverse skor jika event asli menghasilkan poin.
    if (eventToUndo.value > 0) {
      final scoreField =
          eventToUndo.isOpponent ? 'opponent_score' : 'home_score';
      batch.update(
        _db.collection(FirestorePaths.matches).doc(matchId),
        {
          scoreField: FieldValue.increment(-eventToUndo.value),
          'updated_at': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
    return true;
    } finally {
      _isProcessing = false;
    }
  }

  // ── HELPERS ───────────────────────────────────────────────────────────

  int _valueFromAction(String actionType) {
    switch (actionType) {
      case '1PT_MADE':
        return 1;
      case '2PT_MADE':
        return 2;
      case '3PT_MADE':
        return 3;
      default:
        return 0;
    }
  }
}

// ── PROVIDER INSTANCE ───────────────────────────────────────────────────

/// Provider keluarga (family) — satu instance [MatchActionNotifier] per
/// `matchId`. Dipakai di UI Match Mode seperti:
/// `ref.read(matchActionProvider(matchId)).recordAction(...)`.
final matchActionProvider =
    NotifierProvider.family<MatchActionNotifier, void, String>(
  MatchActionNotifier.new,
);

/// Menurunkan ID dokumen `player_stats`/`lineups` (`{jersey}_{inisial}`)
/// dari full player ID (`{jersey}_{inisial}_{teamId}`) — konvensi SDD
/// Section 3.1.
///
/// Diekspos sebagai top-level function (bukan method privat) supaya bisa
/// dipakai ulang oleh repository lain (mis. PlayerStatsRepository,
/// LineupRepository di Step 16) tanpa duplikasi logika string-splitting.
String derivePlayerStatsDocId(String fullPlayerId) {
  final parts = fullPlayerId.split('_');
  if (parts.length >= 2) return '${parts[0]}_${parts[1]}';
  return fullPlayerId;
}

// ── STATS INCREMENT / DECREMENT BUILDERS ──────────────────────────────────
//
// Kedua fungsi ini SENGAJA terpisah dan SIMETRIS satu sama lain — bukan
// "decrement = negasi otomatis dari increment" karena FieldValue.increment
// adalah objek opaque yang nilainya tidak bisa diintrospeksi/dibalik saat
// runtime. Setiap field di buildStatsIncrement() punya pasangan persis
// di buildStatsDecrement() dengan tanda yang dibalik manual.
//
// Jika menambah action_type baru di masa depan, WAJIB update KEDUA
// fungsi ini secara bersamaan — lihat test di
// match_action_provider_test.dart yang memverifikasi simetri ini.

/// Bangun map increment untuk `player_stats` berdasarkan action type.
Map<String, dynamic> buildStatsIncrement(String actionType, String? zone) {
  return _buildStatsDelta(actionType, zone, sign: 1);
}

/// Bangun map decrement (kebalikan persis) untuk undo.
Map<String, dynamic> buildStatsDecrement(String actionType, String? zone) {
  return _buildStatsDelta(actionType, zone, sign: -1);
}

/// Mengubah field path bertitik dari format `update()` menjadi nested map
/// yang aman dipakai bersama `set(..., SetOptions(merge: true))`.
///
/// Contoh:
/// `{'shot_zones.PAINT.made': FieldValue.increment(1)}`
/// menjadi:
/// `{'shot_zones': {'PAINT': {'made': FieldValue.increment(1)}}}`.
Map<String, dynamic> expandDottedFieldPaths(Map<String, dynamic> data) {
  final expanded = <String, dynamic>{};

  for (final entry in data.entries) {
    final parts = entry.key.split('.');
    if (parts.length == 1) {
      expanded[entry.key] = entry.value;
      continue;
    }

    var cursor = expanded;
    for (var i = 0; i < parts.length - 1; i++) {
      final key = parts[i];
      final next = cursor[key];
      if (next is Map<String, dynamic>) {
        cursor = next;
      } else {
        final created = <String, dynamic>{};
        cursor[key] = created;
        cursor = created;
      }
    }
    cursor[parts.last] = entry.value;
  }

  return expanded;
}

Map<String, dynamic> _buildStatsDelta(
  String actionType,
  String? zone, {
  required int sign,
}) {
  final delta = <String, dynamic>{};

  void inc(String field, [int amount = 1]) {
    delta[field] = FieldValue.increment(amount * sign);
  }

  switch (actionType) {
    case '1PT_MADE':
      inc('ft_made');
      inc('ft_attempted');
      inc('points');
    case '2PT_MADE':
      inc('fg2_made');
      inc('fg2_attempted');
      inc('points', 2);
      if (zone != null) {
        inc('shot_zones.$zone.made');
        inc('shot_zones.$zone.attempted');
      }
    case '3PT_MADE':
      inc('fg3_made');
      inc('fg3_attempted');
      inc('points', 3);
      if (zone != null) {
        inc('shot_zones.$zone.made');
        inc('shot_zones.$zone.attempted');
      }
    case 'MISS_1PT':
      inc('ft_attempted');
    case 'MISS_2PT':
      inc('fg2_attempted');
      if (zone != null) {
        inc('shot_zones.$zone.attempted');
      }
    case 'MISS_3PT':
      inc('fg3_attempted');
      if (zone != null) {
        inc('shot_zones.$zone.attempted');
      }
    case 'ASSIST':
      inc('assists');
    case 'REBOUND_OFF':
      inc('offensive_rebounds');
    case 'REBOUND_DEF':
      inc('defensive_rebounds');
    case 'STEAL':
      inc('steals');
    case 'TURNOVER':
      inc('turnovers');
    case 'BLOCK':
      inc('blocks');
    case 'FOUL':
      inc('fouls');
    default:
      // Action type sistem (TIMEOUT, STATE_TRANSITION, dll.) tidak
      // memengaruhi player_stats — kembalikan map kosong dengan aman.
      break;
  }

  return delta;
}
