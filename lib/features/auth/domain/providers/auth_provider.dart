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

/// UID pengguna yang sedang login — dipakai sebagai kunci session agar
/// provider role/profil tidak memakai cache dari user sebelumnya.
final authUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

final userRoleProvider = FutureProvider.autoDispose<String?>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return null;
  // ref.read (bukan watch) — authUidProvider sudah cukup sebagai trigger.
  // ref.watch(authStateProvider) akan rebuild setiap token refresh (~1 jam)
  // karena idTokenChanges() memancarkan event baru meski UID tidak berubah,
  // menyebabkan Firestore read yang tidak perlu (L3).
  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null || user.uid != uid) return null;
  return ref.read(authRepositoryProvider).getRoleForUser(user);
});

final pendingOtpProvider = StateProvider<PendingOtp?>((ref) => null);

/// True selama _handleLogin sedang memeriksa trusted-device / mengirim OTP.
/// Tidak di-reset oleh authSessionCoordinatorProvider agar tidak dibersihkan
/// bersamaan dengan auth state change (yang menyebabkan race condition).
final isOtpCheckPendingProvider = StateProvider<bool>((ref) => false);

// ── TAMBAHAN BARU (dibutuhkan Step 8 & 9) ────────────────────────────────

/// Document ID pengguna yang sedang login di collection `users`.
/// Format: {role}_{namaDepan} — misal "manager_andi", "coach_budi"
///
/// Digunakan sebagai nilai field `created_by` saat membuat event,
/// training session, match, injury report, dll.
final currentUserDocIdProvider =
    FutureProvider.autoDispose<String?>((ref) async {
  final uid = ref.watch(authUidProvider);
  if (uid == null) return null;
  return ref.read(authRepositoryProvider).getCurrentUserDocumentIdForUid(uid);
});

/// UID Firebase Auth dari pengguna yang sedang login.
/// Digunakan untuk keperluan yang membutuhkan Firebase Auth UID
/// (berbeda dengan Document ID di Firestore).
final currentUserUidProvider = Provider<String?>((ref) {
  return ref.watch(authUidProvider);
});
