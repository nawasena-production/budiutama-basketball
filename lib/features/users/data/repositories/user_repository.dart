import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/shared/models/user_model.dart';

/// Repository untuk Account Management.
///
/// Operasi sensitif (create/update role/deactivate/reactivate/delete)
/// dilakukan melalui Cloud Functions callable agar custom claims Firebase
/// Auth bisa di-set dengan aman oleh Admin SDK di server.
///
/// CATATAN: Fungsi-fungsi Cloud Functions berikut harus sudah di-deploy:
///   - createUser
///   - updateUserRole
///   - deactivateUser
///   - reactivateUser
///   - deleteUser
///
/// Jika belum di-deploy, semua operasi akan gagal dengan error
/// "NOT_FOUND" atau "UNAUTHENTICATED".
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  // ── READS ──────────────────────────────────────────────────────────────

  Stream<List<UserModel>> watchAllUsers() {
    return _db
        .collection(FirestorePaths.users)
        .orderBy('full_name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Stream<List<UserModel>> watchByRole(String role) {
    return _db
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: role)
        .orderBy('full_name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ── WRITES (via Cloud Functions) ──────────────────────────────────────

  Future<({bool success, String? uid, String? docId, String? error})>
      createUser({
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
    try {
      final callable = _functions.httpsCallable('createUser');
      final result = await callable.call({
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
        'teamId': teamId,
        'jerseyNumber': jerseyNumber,
        'positions': positions,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      });
      final data = result.data as Map<String, dynamic>;
      final success = data['success'] == true;
      final docId = data['docId'] as String?;
      if (success &&
          role == 'player' &&
          teamId != null &&
          jerseyNumber != null &&
          positions != null &&
          positions.isNotEmpty &&
          data['playerId'] == null) {
        await _createLinkedPlayerFallback(
          userDocId: docId,
          teamId: teamId,
          fullName: fullName,
          jerseyNumber: jerseyNumber,
          positions: positions,
          heightCm: heightCm,
          weightKg: weightKg,
          dateOfBirth: dateOfBirth,
        );
      }
      return (
        success: success,
        uid: data['uid'] as String?,
        docId: docId,
        error: null,
      );
    } on FirebaseFunctionsException catch (e) {
      return (
        success: false,
        uid: null,
        docId: null,
        error: _friendlyFunctionError(e),
      );
    } catch (e) {
      throw FirestoreException('Gagal membuat akun: $e');
    }
  }

  Future<void> _createLinkedPlayerFallback({
    required String? userDocId,
    required String teamId,
    required String fullName,
    required int jerseyNumber,
    required List<String> positions,
    double? heightCm,
    double? weightKg,
    DateTime? dateOfBirth,
  }) async {
    if (userDocId == null) return;

    final duplicate = await _db
        .collection(FirestorePaths.players)
        .where('team_id', isEqualTo: teamId)
        .where('jersey_number', isEqualTo: jerseyNumber)
        .limit(1)
        .get();
    if (duplicate.docs.isNotEmpty) {
      throw const FirestoreException(
        'Akun berhasil dibuat, tetapi nomor jersey sudah dipakai sehingga data pemain belum ditambahkan.',
      );
    }

    final playerId = _generatePlayerId(
      jerseyNumber: jerseyNumber,
      fullName: fullName,
      teamId: teamId,
    );
    await _db.collection(FirestorePaths.players).doc(playerId).set({
      'user_id': userDocId,
      'team_id': teamId,
      'full_name': fullName,
      'jersey_number': jerseyNumber,
      'positions': positions,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'date_of_birth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth) : null,
      'photo_url': null,
      'photo_base64': null,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static String _generatePlayerId({
    required int jerseyNumber,
    required String fullName,
    required String teamId,
  }) {
    final words = fullName.trim().split(RegExp(r'\s+')).take(2);
    final initials =
        words.map((w) => w.isNotEmpty ? w[0].toLowerCase() : '').join();
    final teamShort = teamId.replaceAll('_', '');
    return '${jerseyNumber}_${initials}_$teamShort';
  }

  /// Mengubah role pengguna via Cloud Function.
  Future<bool> updateUserRole({
    required String docId,
    required String uid,
    required String newRole,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateUserRole');
      final result = await callable.call({
        'docId': docId,
        'uid': uid,
        'newRole': newRole,
      });
      final data = result.data as Map<String, dynamic>?;
      return data?['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      throw FirestoreException(_friendlyFunctionError(e));
    }
  }

  /// Menonaktifkan akun.
  ///
  /// Jika Cloud Function belum di-deploy, fallback ke update Firestore
  /// saja (tanpa disable Firebase Auth).
  Future<bool> deactivateUser({
    required String docId,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('deactivateUser');
      final result = await callable.call({'docId': docId, 'uid': uid});
      final data = result.data as Map<String, dynamic>?;
      return data?['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      // Fallback: if function not found, update Firestore directly
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        await _db
            .collection(FirestorePaths.users)
            .doc(docId)
            .update({'is_active': false, 'updated_at': FieldValue.serverTimestamp()});
        return true;
      }
      throw FirestoreException(_friendlyFunctionError(e));
    }
  }

  /// Mengaktifkan kembali akun.
  Future<bool> reactivateUser({
    required String docId,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('reactivateUser');
      final result = await callable.call({'docId': docId, 'uid': uid});
      final data = result.data as Map<String, dynamic>?;
      return data?['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      // Fallback: if function not found, update Firestore directly
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        await _db
            .collection(FirestorePaths.users)
            .doc(docId)
            .update({'is_active': true, 'updated_at': FieldValue.serverTimestamp()});
        return true;
      }
      throw FirestoreException(_friendlyFunctionError(e));
    }
  }

  /// Menghapus akun permanen.
  ///
  /// Jika Cloud Function belum di-deploy, fallback ke hapus dokumen
  /// Firestore saja (Firebase Auth user tidak ikut dihapus).
  Future<bool> deleteUser({
    required String docId,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('deleteUser');
      final result = await callable.call({'docId': docId, 'uid': uid});
      final data = result.data as Map<String, dynamic>?;
      return data?['success'] == true;
    } on FirebaseFunctionsException catch (e) {
      // Fallback: if function not found, delete Firestore doc only
      if (e.code == 'not-found' || e.code == 'unimplemented') {
        await _db.collection(FirestorePaths.users).doc(docId).delete();
        return true;
      }
      throw FirestoreException(_friendlyFunctionError(e));
    }
  }

  /// Converts FirebaseFunctionsException to user-friendly message.
  String _friendlyFunctionError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'not-found':
      case 'unimplemented':
        return 'Cloud Function belum di-deploy. Jalankan "firebase deploy --only functions".';
      case 'unauthenticated':
        return 'Sesi login habis. Silakan login ulang.';
      case 'permission-denied':
        return 'Tidak memiliki izin untuk melakukan aksi ini.';
      case 'unavailable':
        return 'Server tidak tersedia. Periksa koneksi internet.';
      default:
        return e.message ?? 'Error: ${e.code}';
    }
  }
}