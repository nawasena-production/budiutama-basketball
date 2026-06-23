import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/injuries/data/models/injury_report_model.dart';
import 'package:budiutama_basketball/features/injuries/data/repositories/injury_repository.dart';

// ── REPOSITORY ────────────────────────────────────────────────────────────

final injuryRepositoryProvider = Provider<InjuryRepository>((ref) {
  return InjuryRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

/// Stream cedera aktif + recovery satu tim (untuk halaman utama).
final activeInjuriesProvider =
    StreamProvider.family<List<InjuryReportModel>, String>((ref, teamId) {
  return ref.watch(injuryRepositoryProvider).watchActiveByTeam(teamId);
});

/// Stream semua cedera satu tim termasuk cleared (untuk histori).
final allInjuriesProvider =
    StreamProvider.family<List<InjuryReportModel>, String>((ref, teamId) {
  return ref.watch(injuryRepositoryProvider).watchAllByTeam(teamId);
});

// ── TAB STATE ─────────────────────────────────────────────────────────────

/// Index tab di halaman Injury: 0 = Aktif, 1 = Histori.
final injuryTabIndexProvider = StateProvider<int>((ref) => 0);

// ── NOTIFIER ──────────────────────────────────────────────────────────────

class InjuryActionsNotifier extends AsyncNotifier<void> {
  InjuryRepository get _repo => ref.read(injuryRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> createReport({
    required String reportId,
    required InjuryReportModel report,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.create(reportId: reportId, report: report);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(String reportId, String status) async {
    state = const AsyncLoading();
    try {
      await _repo.updateStatus(reportId, status);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateNotes(String reportId, String notes) async {
    state = const AsyncLoading();
    try {
      await _repo.updateNotes(reportId, notes);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final injuryActionsProvider =
    AsyncNotifierProvider<InjuryActionsNotifier, void>(
  InjuryActionsNotifier.new,
);
