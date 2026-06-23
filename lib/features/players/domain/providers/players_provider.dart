import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/data/repositories/player_repository.dart';

// ── REPOSITORY PROVIDER ───────────────────────────────────────────────────

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository();
});

// ── STREAM PROVIDERS ──────────────────────────────────────────────────────

/// Stream semua pemain dalam satu tim, diurutkan berdasarkan nomor jersey.
/// Widget yang listen provider ini akan rebuild otomatis saat data berubah.
final playersStreamProvider =
    StreamProvider.family<List<PlayerModel>, String>((ref, teamId) {
  return ref.watch(playerRepositoryProvider).watchByTeam(teamId);
});

/// Stream pemain aktif saja (untuk lineup picker di Match Mode).
final activePLayersStreamProvider =
    StreamProvider.family<List<PlayerModel>, String>((ref, teamId) {
  return ref.watch(playerRepositoryProvider).watchByStatus(teamId, 'active');
});

// ── SELECTED PLAYER STATE ─────────────────────────────────────────────────

/// ID pemain yang sedang dipilih di halaman Players (untuk highlight / detail).
final selectedPlayerIdProvider = StateProvider<String?>((ref) => null);

/// Filter status yang aktif di halaman Players.
/// Null = tampilkan semua.
final playerStatusFilterProvider = StateProvider<String?>((ref) => null);

// ── FILTERED PLAYERS ──────────────────────────────────────────────────────

/// Players yang sudah difilter berdasarkan status dan query pencarian.
final filteredPlayersProvider = Provider.family<
    AsyncValue<List<PlayerModel>>,
    ({String teamId, String? statusFilter, String searchQuery})>((ref, args) {
  final playersAsync = ref.watch(playersStreamProvider(args.teamId));

  return playersAsync.whenData((players) {
    var result = players;

    // Filter berdasarkan status
    if (args.statusFilter != null && args.statusFilter!.isNotEmpty) {
      result = result.where((p) => p.status == args.statusFilter).toList();
    }

    // Filter berdasarkan search query (nama atau nomor jersey)
    if (args.searchQuery.isNotEmpty) {
      final query = args.searchQuery.toLowerCase();
      result = result.where((p) {
        return p.fullName.toLowerCase().contains(query) ||
            p.jerseyNumber.toString().contains(query) ||
            p.positions.any((pos) => pos.toLowerCase().contains(query));
      }).toList();
    }

    return result;
  });
});

// ── NOTIFIER UNTUK AKSI CRUD ──────────────────────────────────────────────

class PlayerActionsNotifier extends AsyncNotifier<void> {
  PlayerRepository get _repo => ref.read(playerRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<bool> addPlayer({
    required PlayerModel player,
    required String playerId,
  }) async {
    state = const AsyncLoading();
    try {
      await _repo.create(playerId: playerId, player: player);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updatePlayer(
      String playerId, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await _repo.update(playerId, data);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deactivatePlayer(String playerId) async {
    state = const AsyncLoading();
    try {
      await _repo.deactivate(playerId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> updateStatus(String playerId, String status) async {
    state = const AsyncLoading();
    try {
      await _repo.updateStatus(playerId, status);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final playerActionsProvider =
    AsyncNotifierProvider<PlayerActionsNotifier, void>(
  PlayerActionsNotifier.new,
);
