import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/matches/live/data/models/lineup_model.dart';
import 'package:budiutama_basketball/features/matches/live/data/repositories/lineup_repository.dart';
export 'package:budiutama_basketball/core/utils/timer_calculator.dart'
    show currentRemainingSeconds, formatSeconds;

// ── REPOSITORY ────────────────────────────────────────────────────────────

final lineupRepositoryProvider = Provider<LineupRepository>((ref) {
  return LineupRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

/// Stream 5 pemain di lapangan — sumber data Left Panel (FR-LMS-02).
final onCourtLineupStreamProvider =
    StreamProvider.family<List<LineupModel>, String>((ref, matchId) {
  return ref.watch(lineupRepositoryProvider).watchOnCourt(matchId);
});

/// Stream seluruh lineup (di lapangan + bangku) — dipakai
/// [SubstitutionPanel] untuk menampilkan dua daftar pilihan.
final allLineupStreamProvider =
    StreamProvider.family<List<LineupModel>, String>((ref, matchId) {
  return ref.watch(lineupRepositoryProvider).watchAll(matchId);
});

// ── NOTIFIER: SUBSTITUSI ─────────────────────────────────────────────────

class SubstitutionNotifier extends FamilyAsyncNotifier<void, String> {
  String get matchId => arg;

  @override
  Future<void> build(String arg) async {}

  /// Eksekusi substitusi satu pemain KELUAR, satu pemain MASUK.
  ///
  /// [currentQuarter] dan [currentTimeRemaining] diambil dari state
  /// terbaru match + timer (caller di UI bertanggung jawab membaca dari
  /// [matchStreamProvider] dan menghitung `currentRemainingSeconds()`
  /// dari [timerStateStreamProvider] sesaat sebelum memanggil method
  /// ini, supaya waktu yang tercatat di event SUBSTITUTION akurat).
  Future<bool> substitute({
    required LineupModel playerOut,
    required LineupModel playerIn,
    required int currentQuarter,
    required double currentTimeRemaining,
    required String createdBy,
  }) async {
    state = const AsyncLoading();
    try {
      // Hitung berapa detik pemain yang KELUAR sudah bermain sejak
      // terakhir masuk lapangan: selisih antara saat ia masuk
      // (entered_at_clock, dalam detik tersisa) dan waktu sekarang.
      // Karena clock berjalan MUNDUR, durasi bermain = enteredAtClock -
      // currentTimeRemaining (bukan sebaliknya).
      final enteredAt = playerOut.enteredAtClock ?? currentTimeRemaining;
      final secondsPlayedThisStint =
          (enteredAt - currentTimeRemaining).clamp(0.0, double.infinity);

      await ref.read(lineupRepositoryProvider).substitute(
            matchId: matchId,
            quarter: currentQuarter,
            timeRemaining: currentTimeRemaining,
            createdBy: createdBy,
            playerOut: playerOut,
            playerIn: playerIn,
            secondsPlayedThisStint: secondsPlayedThisStint,
          );

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Shortcut untuk substitusi pemain yang BELUM PERNAH bermain (tidak
  /// punya dokumen lineup) — otomatis membuat dokumen lineup terlebih
  /// dahulu via [ensureInitialized], lalu membaca dokumen baru yang
  /// terbentuk, lalu menjalankan [substitute] secara atomik.
  ///
  /// Dipanggil oleh [SubstitutionPanel] ketika pemain "MASUK" yang dipilih
  /// tidak ditemukan di [allLineupStreamProvider] (pemain pertama kali
  /// masuk lapangan, sebelumnya ada di roster tapi belum pernah aktif).
  Future<bool> substituteWithNewPlayer({
    required LineupModel playerOut,
    required String newPlayerStatsDocId,
    required String newPlayerId,
    required String newPlayerFullName,
    required int newPlayerJerseyNumber,
    required String newPlayerPosition,
    required int currentQuarter,
    required double currentTimeRemaining,
    required String createdBy,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(lineupRepositoryProvider);

      // 1. Buat dokumen lineup pemain baru (is_on_court: false dulu)
      await repo.ensureInitialized(
        matchId: matchId,
        statsDocId: newPlayerStatsDocId,
        playerId: newPlayerId,
        fullName: newPlayerFullName,
        jerseyNumber: newPlayerJerseyNumber,
        position: newPlayerPosition,
      );

      // 2. Baca dokumen yang baru dibuat
      final newPlayerLineup = await repo.getOne(matchId, newPlayerStatsDocId);
      if (newPlayerLineup == null) {
        state = const AsyncData(null);
        return false;
      }

      // 3. Eksekusi substitusi normal
      return await substitute(
        playerOut: playerOut,
        playerIn: newPlayerLineup,
        currentQuarter: currentQuarter,
        currentTimeRemaining: currentTimeRemaining,
        createdBy: createdBy,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Pastikan dokumen lineup pemain bangku (non-starter, belum pernah
  /// bermain) tersedia sebelum ditampilkan sebagai opsi "MASUK" —
  /// dipanggil oleh [SubstitutionPanel] saat memuat daftar roster penuh
  /// dan membandingkannya dengan dokumen lineup yang sudah ada.
  Future<void> ensureBenchPlayerInitialized({
    required String statsDocId,
    required String playerId,
    required String fullName,
    required int jerseyNumber,
    required String position,
  }) async {
    await ref.read(lineupRepositoryProvider).ensureInitialized(
          matchId: matchId,
          statsDocId: statsDocId,
          playerId: playerId,
          fullName: fullName,
          jerseyNumber: jerseyNumber,
          position: position,
        );
  }
}

final substitutionProvider =
    AsyncNotifierProvider.family<SubstitutionNotifier, void, String>(
  SubstitutionNotifier.new,
);
