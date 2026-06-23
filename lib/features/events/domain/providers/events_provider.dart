import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/events/data/models/event_model.dart';
import 'package:budiutama_basketball/features/events/data/repositories/event_repository.dart';

// ── REPOSITORY ────────────────────────────────────────────────────────────

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

/// Stream semua event satu tim — update real-time dari Firestore.
final eventsStreamProvider =
    StreamProvider.family<List<EventModel>, String>((ref, teamId) {
  return ref.watch(eventRepositoryProvider).watchByTeam(teamId);
});

/// Stream event aktif/upcoming saja.
final activeEventsStreamProvider =
    StreamProvider.family<List<EventModel>, String>((ref, teamId) {
  return ref.watch(eventRepositoryProvider).watchActive(teamId);
});

// ── SELECTED EVENT ────────────────────────────────────────────────────────

/// Event yang sedang dipilih/dibuka (untuk context di halaman matches).
final selectedEventProvider = StateProvider<EventModel?>((ref) => null);

// ── NOTIFIER ──────────────────────────────────────────────────────────────

class EventActionsNotifier extends AsyncNotifier<void> {
  EventRepository get _repo => ref.read(eventRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> createEvent({
    required String eventId,
    required EventModel event,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.create(eventId: eventId, event: event);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repo.update(eventId, data);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(String eventId, String status) async {
    state = const AsyncLoading();
    try {
      await _repo.updateStatus(eventId, status);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final eventActionsProvider =
    AsyncNotifierProvider<EventActionsNotifier, void>(
  EventActionsNotifier.new,
);
