import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';
import 'package:budiutama_basketball/shared/models/user_model.dart';

/// Repository untuk Account Management (Step 12).
///
/// Operasi sensitif (create/update role/deactivate/reactivate) dilakukan
/// melalui Cloud Functions callable agar custom claims Firebase Auth bisa
/// di-set dengan aman oleh Admin SDK di server — tidak bisa dilakukan
/// langsung dari client.
///
/// Pembacaan daftar user tetap langsung dari Firestore (real-time).
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  // ── READS ──────────────────────────────────────────────────────────────

  /// Stream semua user — untuk halaman User Management (Manager-only).
  Stream<List<UserModel>> watchAllUsers() {
    return _db
        .collection(FirestorePaths.users)
        .orderBy('full_name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  /// Stream user berdasarkan role tertentu.
  Stream<List<UserModel>> watchByRole(String role) {
    return _db
        .collection(FirestorePaths.users)
        .where('role', isEqualTo: role)
        .orderBy('full_name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ── WRITES (via Cloud Functions) ─────────────────────────────────────────

  /// Membuat akun baru. Hanya bisa dipanggil oleh Manager
  /// (divalidasi ulang di server lewat Cloud Function `createUser`).
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
        error: e.message ?? e.code
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

  /// Mengubah role pengguna.
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
      return (result.data as Map<String, dynamic>)['success'] == true;
    } on FirebaseFunctionsException {
      return false;
    }
  }

  /// Menonaktifkan akun (disable di Firebase Auth + is_active=false).
  Future<bool> deactivateUser({
    required String docId,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('deactivateUser');
      final result = await callable.call({'docId': docId, 'uid': uid});
      return (result.data as Map<String, dynamic>)['success'] == true;
    } on FirebaseFunctionsException {
      return false;
    }
  }

  /// Mengaktifkan kembali akun yang dinonaktifkan.
  Future<bool> reactivateUser({
    required String docId,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('reactivateUser');
      final result = await callable.call({'docId': docId, 'uid': uid});
      return (result.data as Map<String, dynamic>)['success'] == true;
    } on FirebaseFunctionsException {
      return false;
    }
  }

  /// Menghapus akun permanen dari Firebase Auth dan collection users.
  Future<bool> deleteUser({
    required String docId,
    required String uid,
  }) async {
    try {
      final callable = _functions.httpsCallable('deleteUser');
      final result = await callable.call({'docId': docId, 'uid': uid});
      return (result.data as Map<String, dynamic>)['success'] == true;
    } on FirebaseFunctionsException {
      return false;
    }
  }
}
