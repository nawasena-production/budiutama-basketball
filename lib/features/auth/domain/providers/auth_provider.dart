import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/auth/data/repositories/auth_repository.dart';

class PendingOtp {
  final String email;
  final String userId;
  final String deviceHash;

  const PendingOtp({
    required this.email,
    required this.userId,
    required this.deviceHash,
  });
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateStream;
});

final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = await ref.watch(authStateProvider.selectAsync((user) => user));
  if (user == null) return null;
  return ref.watch(authRepositoryProvider).getRoleForUser(user);
});

final pendingOtpProvider = StateProvider<PendingOtp?>((ref) => null);

// ── TAMBAHAN BARU (dibutuhkan Step 8 & 9) ────────────────────────────────

/// Document ID pengguna yang sedang login di collection `users`.
/// Format: {role}_{namaDepan} — misal "manager_andi", "coach_budi"
///
/// Digunakan sebagai nilai field `created_by` saat membuat event,
/// training session, match, injury report, dll.
final currentUserDocIdProvider = FutureProvider<String?>((ref) async {
  final user = await ref.watch(authStateProvider.selectAsync((user) => user));
  if (user == null) return null;
  return ref
      .watch(authRepositoryProvider)
      .getCurrentUserDocumentIdForUid(user.uid);
});

/// UID Firebase Auth dari pengguna yang sedang login.
/// Digunakan untuk keperluan yang membutuhkan Firebase Auth UID
/// (berbeda dengan Document ID di Firestore).
final currentUserUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});
