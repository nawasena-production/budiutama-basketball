import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/training/data/models/training_session_model.dart';
import 'package:budiutama_basketball/features/training/data/repositories/training_repository.dart';

// ── REPOSITORY ────────────────────────────────────────────────────────────

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  return TrainingRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

/// Stream semua sesi latihan satu tim (mendatang + lampau).
final trainingsStreamProvider =
    StreamProvider.family<List<TrainingSessionModel>, String>((ref, teamId) {
  return ref.watch(trainingRepositoryProvider).watchByTeam(teamId);
});

/// Stream sesi latihan mendatang saja.
final upcomingTrainingsProvider =
    StreamProvider.family<List<TrainingSessionModel>, String>((ref, teamId) {
  return ref.watch(trainingRepositoryProvider).watchUpcoming(teamId);
});

/// Stream histori sesi latihan yang sudah lewat.
final pastTrainingsProvider =
    StreamProvider.family<List<TrainingSessionModel>, String>((ref, teamId) {
  return ref.watch(trainingRepositoryProvider).watchPast(teamId);
});

// ── TAB STATE ─────────────────────────────────────────────────────────────

/// Index tab aktif di halaman Training (0 = Mendatang, 1 = Histori).
final trainingTabIndexProvider = StateProvider<int>((ref) => 0);

// ── NOTIFIER ──────────────────────────────────────────────────────────────

class TrainingActionsNotifier extends AsyncNotifier<void> {
  TrainingRepository get _repo => ref.read(trainingRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> createSession({
    required String sessionId,
    required TrainingSessionModel session,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.create(sessionId: sessionId, session: session);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateSession(
      String sessionId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repo.update(sessionId, data);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> cancelSession(String sessionId) async {
    state = const AsyncLoading();
    try {
      await _repo.cancel(sessionId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final trainingActionsProvider =
    AsyncNotifierProvider<TrainingActionsNotifier, void>(
  TrainingActionsNotifier.new,
);
