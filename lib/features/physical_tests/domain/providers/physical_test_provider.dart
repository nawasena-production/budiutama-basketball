import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_result_model.dart';
import 'package:budiutama_basketball/features/physical_tests/data/models/physical_test_session_model.dart';
import 'package:budiutama_basketball/features/physical_tests/data/repositories/physical_test_repository.dart';

// ── REPOSITORY ────────────────────────────────────────────────────────────

final physicalTestRepositoryProvider =
    Provider<PhysicalTestRepository>((ref) {
  return PhysicalTestRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

/// Stream sesi berdasarkan tim dan tipe tes.
final physicalTestSessionsProvider = StreamProvider.family<
    List<PhysicalTestSessionModel>,
    ({String teamId, String testType})>((ref, args) {
  return ref
      .watch(physicalTestRepositoryProvider)
      .watchByTeam(args.teamId, args.testType);
});

/// Stream hasil satu sesi aktif (real-time saat sesi berjalan).
final physicalTestResultsStreamProvider =
    StreamProvider.family<List<PhysicalTestResultModel>, String>(
        (ref, sessionId) {
  return ref.watch(physicalTestRepositoryProvider).watchResults(sessionId);
});

/// Stream satu sesi tes fisik berdasarkan ID.
final physicalTestSessionProvider =
    StreamProvider.family<PhysicalTestSessionModel?, String>((ref, sessionId) {
  return ref
      .watch(physicalTestRepositoryProvider)
      .watchSessionById(sessionId);
});

// ── SELECTED SESSION ──────────────────────────────────────────────────────

/// ID sesi yang sedang aktif berjalan.
final activeSessionIdProvider = StateProvider<String?>((ref) => null);

/// Team ID sesi aktif. Dibutuhkan saat sesi baru dibuat dari form dengan
/// pilihan tim eksplisit, agar panel input menampilkan roster tim yang benar.
final activeSessionTeamIdProvider = StateProvider<String?>((ref) => null);

/// Tipe tes yang sedang dipilih di tab: beep_test | t_test | sprint_20m
final selectedTestTypeProvider =
    StateProvider<String>((ref) => 'beep_test');

// ── NOTIFIER ──────────────────────────────────────────────────────────────

class PhysicalTestActionsNotifier extends AsyncNotifier<void> {
  PhysicalTestRepository get _repo =>
      ref.read(physicalTestRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> createSession({
    required String sessionId,
    required PhysicalTestSessionModel session,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.createSession(sessionId: sessionId, session: session);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> saveBeepResult({
    required String sessionId,
    required String playerDocId,
    required String fullPlayerId,
    required String fullName,
    required int beepLevel,
    required int beepShuttle,
  }) async {
    try {
      await _repo.saveBeepResult(
        sessionId: sessionId,
        playerDocId: playerDocId,
        fullPlayerId: fullPlayerId,
        fullName: fullName,
        beepLevel: beepLevel,
        beepShuttle: beepShuttle,
      );
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> saveTimedResult({
    required String sessionId,
    required String playerDocId,
    required String fullPlayerId,
    required String fullName,
    required double timeSeconds,
  }) async {
    try {
      await _repo.saveTimedResult(
        sessionId: sessionId,
        playerDocId: playerDocId,
        fullPlayerId: fullPlayerId,
        fullName: fullName,
        timeSeconds: timeSeconds,
      );
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> stopSessionEarly(String sessionId) async {
    state = const AsyncLoading();
    try {
      await _repo.stopSessionEarly(sessionId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final physicalTestActionsProvider =
    AsyncNotifierProvider<PhysicalTestActionsNotifier, void>(
  PhysicalTestActionsNotifier.new,
);
