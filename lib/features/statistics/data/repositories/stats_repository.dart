import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/match_event_model.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/player_stats_model.dart';

/// Statistik teragregasi satu pemain lintas BEBERAPA pertandingan dalam
/// satu event/turnamen (FR-STT-01, FR-STT-02) — dibedakan dari
/// [PlayerStatsModel] yang merepresentasikan statistik dalam SATU
/// pertandingan saja.
class AggregatedPlayerStats {
  final String playerId;
  final String fullName;
  final int jerseyNumber;
  final int gamesPlayed;

  final int totalPoints;
  final int totalFtMade;
  final int totalFtAttempted;
  final int totalFg2Made;
  final int totalFg2Attempted;
  final int totalFg3Made;
  final int totalFg3Attempted;
  final int totalAssists;
  final int totalOffensiveRebounds;
  final int totalDefensiveRebounds;
  final int totalSteals;
  final int totalTurnovers;
  final int totalBlocks;
  final int totalFouls;

  const AggregatedPlayerStats({
    required this.playerId,
    required this.fullName,
    required this.jerseyNumber,
    required this.gamesPlayed,
    required this.totalPoints,
    required this.totalFtMade,
    required this.totalFtAttempted,
    required this.totalFg2Made,
    required this.totalFg2Attempted,
    required this.totalFg3Made,
    required this.totalFg3Attempted,
    required this.totalAssists,
    required this.totalOffensiveRebounds,
    required this.totalDefensiveRebounds,
    required this.totalSteals,
    required this.totalTurnovers,
    required this.totalBlocks,
    required this.totalFouls,
  });

  double get ppg => gamesPlayed > 0 ? totalPoints / gamesPlayed : 0.0;
  double get apg => gamesPlayed > 0 ? totalAssists / gamesPlayed : 0.0;
  double get rpg => gamesPlayed > 0
      ? (totalOffensiveRebounds + totalDefensiveRebounds) / gamesPlayed
      : 0.0;
  double get spg => gamesPlayed > 0 ? totalSteals / gamesPlayed : 0.0;
  double get bpg => gamesPlayed > 0 ? totalBlocks / gamesPlayed : 0.0;
}

/// Satu titik tembakan untuk shot chart heatmap (FR-STT-03), sudah
/// memuat metadata pemain supaya bisa di-filter per pemain di UI tanpa
/// query tambahan.
class ShotChartEntry {
  final String? playerId;
  final String zone;
  final double x;
  final double y;
  final bool isMade;
  final bool isOpponent;

  const ShotChartEntry({
    required this.playerId,
    required this.zone,
    required this.x,
    required this.y,
    required this.isMade,
    required this.isOpponent,
  });
}

/// Repository untuk kebutuhan Statistics Dashboard (FR-STT-01 s.d 05).
///
/// Berbeda dengan repository di Live Match Engine (yang memakai
/// Firestore *listener* real-time untuk satu pertandingan aktif),
/// repository ini mengutamakan *one-shot fetch* (`get()`, bukan
/// `snapshots()`) karena data dashboard adalah data pertandingan yang
/// SUDAH SELESAI — tidak perlu real-time sync, query lebih hemat kuota
/// Firestore dengan fetch sekali per buka halaman / per filter berubah.
class StatsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Statistik seluruh pemain dalam SATU pertandingan — dipakai untuk
  /// box score dan sebagai sumber data Live Player Stats versi
  /// post-match (read-only, sudah final via Cloud Function
  /// `onMatchFinished`).
  Future<List<PlayerStatsModel>> getPlayerStatsForMatch(String matchId) async {
    final snap = await _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .get();
    return snap.docs
        .map((d) => PlayerStatsModel.fromFirestore(d))
        .toList();
  }

  /// Titik-titik tembakan untuk shot chart heatmap SATU pertandingan
  /// (FR-STT-03) — hanya event valid (`is_undone == false`) dan yang
  /// memiliki koordinat (`shot_x != null`, otomatis mengecualikan free
  /// throw sesuai PRD: "Free throw tidak masuk heatmap").
  Future<List<ShotChartEntry>> getShotPointsForMatch(String matchId) async {
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('is_undone', isEqualTo: false)
        .get();

    return snap.docs
        .map((d) => MatchEventModel.fromFirestore(d))
        .where((e) => e.shotX != null && e.shotY != null && e.zone != null)
        .map((e) => ShotChartEntry(
              playerId: e.playerId,
              zone: e.zone!,
              x: e.shotX!,
              y: e.shotY!,
              isMade: e.actionType.contains('MADE'),
              isOpponent: e.isOpponent,
            ))
        .toList();
  }

  /// Daftar ID pertandingan berstatus `finished` dalam satu event —
  /// dipakai sebagai dasar agregasi season/event-level (FR-STT-01).
  Future<List<String>> getFinishedMatchIdsForEvent(String eventId) async {
    final snap = await _db
        .collection(FirestorePaths.matches)
        .where('event_id', isEqualTo: eventId)
        .where('status', isEqualTo: 'finished')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  /// Agregasi statistik pemain lintas SEMUA pertandingan `finished`
  /// dalam satu event/turnamen (FR-STT-01, FR-STT-02 — PPG/RPG/APG/dst).
  ///
  /// Catatan implementasi: agregasi dilakukan di client (Dart), BUKAN
  /// Cloud Function, karena ini murni penjumlahan data yang sudah final
  /// dan immutable (player_stats pasca `onMatchFinished`) — tidak ada
  /// concurrent write yang perlu race-condition-safe seperti
  /// `FieldValue.increment()` di Live Match Engine. Untuk jumlah
  /// pertandingan per event yang realistis (puluhan, bukan ribuan),
  /// pendekatan fetch-then-aggregate ini cukup efisien tanpa perlu
  /// materialized aggregate document tambahan.
  Future<List<AggregatedPlayerStats>> getAggregatedStatsForEvent(
    String eventId,
  ) async {
    final matchIds = await getFinishedMatchIdsForEvent(eventId);
    if (matchIds.isEmpty) return [];

    final Map<String, _AggregateAccumulator> accByPlayer = {};

    for (final matchId in matchIds) {
      final statsList = await getPlayerStatsForMatch(matchId);
      for (final s in statsList) {
        final acc = accByPlayer.putIfAbsent(
          s.playerId,
          () => _AggregateAccumulator(
            playerId: s.playerId,
            fullName: s.fullName,
            jerseyNumber: s.jerseyNumber,
          ),
        );
        acc.addGame(s);
      }
    }

    return accByPlayer.values.map((a) => a.toAggregatedStats()).toList();
  }
}

/// Akumulator internal — dipisah dari [AggregatedPlayerStats] (yang
/// immutable) supaya proses penjumlahan tidak perlu membuat objek baru
/// di setiap iterasi pertandingan.
class _AggregateAccumulator {
  final String playerId;
  final String fullName;
  final int jerseyNumber;
  int gamesPlayed = 0;
  int totalPoints = 0;
  int totalFtMade = 0;
  int totalFtAttempted = 0;
  int totalFg2Made = 0;
  int totalFg2Attempted = 0;
  int totalFg3Made = 0;
  int totalFg3Attempted = 0;
  int totalAssists = 0;
  int totalOffensiveRebounds = 0;
  int totalDefensiveRebounds = 0;
  int totalSteals = 0;
  int totalTurnovers = 0;
  int totalBlocks = 0;
  int totalFouls = 0;

  _AggregateAccumulator({
    required this.playerId,
    required this.fullName,
    required this.jerseyNumber,
  });

  void addGame(PlayerStatsModel s) {
    gamesPlayed += 1;
    totalPoints += s.points;
    totalFtMade += s.ftMade;
    totalFtAttempted += s.ftAttempted;
    totalFg2Made += s.fg2Made;
    totalFg2Attempted += s.fg2Attempted;
    totalFg3Made += s.fg3Made;
    totalFg3Attempted += s.fg3Attempted;
    totalAssists += s.assists;
    totalOffensiveRebounds += s.offensiveRebounds;
    totalDefensiveRebounds += s.defensiveRebounds;
    totalSteals += s.steals;
    totalTurnovers += s.turnovers;
    totalBlocks += s.blocks;
    totalFouls += s.fouls;
  }

  AggregatedPlayerStats toAggregatedStats() => AggregatedPlayerStats(
        playerId: playerId,
        fullName: fullName,
        jerseyNumber: jerseyNumber,
        gamesPlayed: gamesPlayed,
        totalPoints: totalPoints,
        totalFtMade: totalFtMade,
        totalFtAttempted: totalFtAttempted,
        totalFg2Made: totalFg2Made,
        totalFg2Attempted: totalFg2Attempted,
        totalFg3Made: totalFg3Made,
        totalFg3Attempted: totalFg3Attempted,
        totalAssists: totalAssists,
        totalOffensiveRebounds: totalOffensiveRebounds,
        totalDefensiveRebounds: totalDefensiveRebounds,
        totalSteals: totalSteals,
        totalTurnovers: totalTurnovers,
        totalBlocks: totalBlocks,
        totalFouls: totalFouls,
      );
}
