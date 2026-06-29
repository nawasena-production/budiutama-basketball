import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/users/data/repositories/user_repository.dart';
import 'package:budiutama_basketball/shared/models/user_model.dart';

// ── REPOSITORY ────────────────────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// ── STREAMS ───────────────────────────────────────────────────────────────

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(userRepositoryProvider).watchAllUsers();
});

final usersByRoleProvider =
    StreamProvider.family<List<UserModel>, String>((ref, role) {
  return ref.watch(userRepositoryProvider).watchByRole(role);
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchByUid(uid);
});

final linkedPlayerForUserProvider =
    StreamProvider.family<PlayerModel?, String>((ref, userDocId) {
  return ref.watch(userRepositoryProvider).watchLinkedPlayer(userDocId);
});

// ── FILTER STATE ──────────────────────────────────────────────────────────

/// Filter role di halaman User Management: null = semua role.
final userRoleFilterProvider = StateProvider<String?>((ref) => null);

final filteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final usersAsync = ref.watch(allUsersProvider);
  final filterRole = ref.watch(userRoleFilterProvider);

  return usersAsync.whenData((users) {
    if (filterRole == null) return users;
    return users.where((u) => u.role == filterRole).toList();
  });
});

// ── NOTIFIER (actions) ────────────────────────────────────────────────────

class UserActionsNotifier extends AsyncNotifier<void> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Mengembalikan error message jika gagal, null jika sukses.
  Future<String?> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? teamId,
    int? jerseyNumber,
    List<String>? positions,
    double? heightCm,
    double? weightKg,
    DateTime? dateOfBirth,
  }) async {
    state = const AsyncLoading();
    try {
      final result = await _repo.createUser(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        teamId: teamId,
        jerseyNumber: jerseyNumber,
        positions: positions,
        heightCm: heightCm,
        weightKg: weightKg,
        dateOfBirth: dateOfBirth,
      );
      state = const AsyncData(null);
      return result.success ? null : (result.error ?? 'Gagal membuat akun.');
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString();
    }
  }

  Future<bool> updateUserRole({
    required String docId,
    required String uid,
    required String newRole,
  }) async {
    state = const AsyncLoading();
    try {
      final success = await _repo.updateUserRole(
        docId: docId,
        uid: uid,
        newRole: newRole,
      );
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deactivateUser({required String docId, required String uid}) async {
    state = const AsyncLoading();
    try {
      final success = await _repo.deactivateUser(docId: docId, uid: uid);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> reactivateUser({required String docId, required String uid}) async {
    state = const AsyncLoading();
    try {
      final success = await _repo.reactivateUser(docId: docId, uid: uid);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> deleteUser({required String docId, required String uid}) async {
    state = const AsyncLoading();
    try {
      final success = await _repo.deleteUser(docId: docId, uid: uid);
      state = const AsyncData(null);
      return success;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// Pindahkan pemain SMP ke tim SMA (via Cloud Function).
  Future<String?> transferPlayerTeam({
    required String playerId,
    required String targetTeamId,
  }) async {
    state = const AsyncLoading();
    try {
      final error = await _repo.transferPlayerTeam(
        playerId: playerId,
        targetTeamId: targetTeamId,
      );
      state = const AsyncData(null);
      return error;
    } catch (e, st) {
      state = AsyncError(e, st);
      return e.toString();
    }
  }
}

final userActionsProvider =
    AsyncNotifierProvider<UserActionsNotifier, void>(UserActionsNotifier.new);
