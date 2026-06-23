import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/utils/timer_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/repositories/timer_repository.dart';

/// Notifier untuk kontrol manual timer pertandingan (FR-LMS-05):
/// START (pertama kali di quarter), PAUSE, RESUME.
///
/// Catatan penting soal RESUME: nilai `seconds_at_start` yang dipakai
/// SAMA dengan nilai yang sudah tersimpan di Firestore saat terakhir
/// PAUSE (karena `pauseTimer()` di [TimerRepository] menulis
/// `currentRemaining` sebagai `seconds_at_start` baru) — sehingga
/// RESUME tidak perlu menghitung ulang apa pun selain membaca state
/// terkini sebelum menulis `started_at` baru via Server Timestamp.
class TimerControlNotifier extends FamilyAsyncNotifier<void, String> {
  String get matchId => arg;

  TimerRepository get _repo => TimerRepository();

  @override
  Future<void> build(String arg) async {}

  /// START timer untuk PERTAMA KALI di sebuah quarter (durasi penuh).
  /// Dipakai saat transisi state misal Q1_BREAK → Q2_ACTIVE lalu
  /// Statistician menekan START.
  Future<void> start({
    required double fullDurationSeconds,
    required int quarter,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.startTimer(
        matchId: matchId,
        secondsAtStart: fullDurationSeconds,
        quarter: quarter,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// RESUME setelah PAUSE — membaca `seconds_at_start` TERKINI dari
  /// Firestore (yang sudah berisi sisa waktu sejak PAUSE terakhir),
  /// lalu menulis ulang `started_at` baru via Server Timestamp.
  Future<void> resume({required int currentQuarter}) async {
    state = const AsyncLoading();
    try {
      final current = await _repo.getTimer(matchId);
      await _repo.resumeTimer(
        matchId: matchId,
        secondsAtStart: current.secondsAtStart,
        quarter: currentQuarter,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// PAUSE — menghitung sisa waktu TERKINI secara lokal (berdasarkan
  /// `started_at` yang sedang aktif) sebelum menuliskannya sebagai
  /// `seconds_at_start` baru dan menghentikan `is_running`.
  Future<void> pause() async {
    state = const AsyncLoading();
    try {
      final current = await _repo.getTimer(matchId);
      final remaining = currentRemainingSeconds(current);
      await _repo.pauseTimer(matchId: matchId, currentRemaining: remaining);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Reset timer ke durasi penuh quarter baru (belum berjalan) — dipakai
  /// bersamaan dengan transisi state pertandingan.
  Future<void> resetForNewQuarter({
    required double fullDurationSeconds,
    required int quarter,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.resetForNewQuarter(
        matchId: matchId,
        fullDurationSeconds: fullDurationSeconds,
        quarter: quarter,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final timerControlProvider =
    AsyncNotifierProvider.family<TimerControlNotifier, void, String>(
  TimerControlNotifier.new,
);
