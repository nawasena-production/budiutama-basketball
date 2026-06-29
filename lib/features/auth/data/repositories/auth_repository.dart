import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/errors/app_exceptions.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Stream<User?> get authStateStream => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException {
      throw const AuthException('Email atau password tidak valid.');
    } catch (_) {
      throw const AuthException('Login gagal. Silakan coba lagi.');
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<String?> getRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return getRoleForUser(user);
  }

  Future<String?> getRoleForUser(User user) async {
    final snapshot = await _db
        .collection(FirestorePaths.users)
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final documentRole =
          _normalizeRole(snapshot.docs.first.data()['role'] as String?);
      if (documentRole != null) return documentRole;
    }

    final token = await user.getIdTokenResult(true);
    return _normalizeRole(token.claims?['role'] as String?);
  }

  String? _normalizeRole(String? role) {
    if (role == null) return null;
    final normalized = role.trim().toLowerCase();
    if (normalized == 'statistican') return 'statistician';
    const validRoles = {'manager', 'coach', 'statistician', 'player'};
    return validRoles.contains(normalized) ? normalized : null;
  }

  Future<String?> getCurrentUserDocumentId() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return getCurrentUserDocumentIdForUid(user.uid);
  }

  Future<String?> getCurrentUserDocumentIdForUid(String uid) async {
    final snapshot = await _db
        .collection(FirestorePaths.users)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  Future<bool> isDeviceTrusted(String userId, String deviceHash) async {
    final doc = await _db.doc(FirestorePaths.user(userId)).get();
    final data = doc.data() ?? {};
    final trustedDeviceIds =
        List<String>.from(data['trusted_device_ids'] as List? ?? const []);
    return trustedDeviceIds.contains(deviceHash);
  }

  Future<void> addTrustedDevice(String userId, String deviceHash) async {
    await _db.doc(FirestorePaths.user(userId)).update({
      'trusted_device_ids': FieldValue.arrayUnion([deviceHash]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
