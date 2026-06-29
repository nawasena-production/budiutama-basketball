// Jalankan: dart run scripts/create_auth_users_from_firestore.dart
//
// Script ini membaca dokumen 'users' dari Firestore Emulator,
// membuat corresponding user di Firebase Auth Emulator, dan set Custom Claims.
//
// Gunakan untuk setup emulator testing:
// 1. Jalankan seed_emulator.dart (create Firestore data)
// 2. Jalankan script ini (create Auth users + set custom claims)
// 3. Jalankan seed_test_match.dart (create pertandingan)
// 4. Jalankan integration tests
//
// CATATAN: Semua Firestore user docs HARUS punya field 'uid' yang unique.
// Jika uid tidak ada, user akan di-skip.
//
// Requirement:
// - Node.js dan firebase-admin sudah ter-install di functions/
// - Firestore Emulator berjalan (localhost:8080)
// - Auth Emulator berjalan (localhost:9099)
// - GOOGLE_APPLICATION_CREDENTIALS variable sudah set
//
// Example passwords (untuk testing only!):
// - All users: Test1234!
//

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

const String _testPassword = 'Test1234!';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  print('📄 Reading users dari Firestore...');
  
  try {
    final userDocs = await db.collection('users').get();
    
    if (userDocs.docs.isEmpty) {
      print('⚠️  Tidak ada user di Firestore. Jalankan seed_emulator.dart terlebih dahulu.');
      return;
    }

    int createdCount = 0;
    int claimsSetCount = 0;
    int skipCount = 0;

    for (final doc in userDocs.docs) {
      final data = doc.data();
      final uid = data['uid'] as String?;
      final email = data['email'] as String?;
      final role = data['role'] as String?;
      final teamId = data['team_id'] as String?;

      if (uid == null || role == null) {
        print('⚠️  Dokumen ${doc.id} tidak punya uid atau role. Lewati.');
        skipCount++;
        continue;
      }

      if (email == null) {
        print('⚠️  Dokumen ${doc.id} tidak punya email. Lewati.');
        skipCount++;
        continue;
      }

      try {
        // Cek apakah user sudah ada di Auth dengan coba sign in
        try {
          final signInMethods = await auth.fetchSignInMethodsForEmail(email);
          if (signInMethods.isNotEmpty) {
            print('ℹ️  User $uid ($email) sudah ada di Auth. Skip create, lanjut set claims.');
          } else {
            throw Exception('User belum ada, perlu dibuat');
          }
        } catch (e) {
          // User belum ada, buat baru
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: _testPassword,
          );
          print('✅ User dibuat: $uid ($email)');
          createdCount++;
        }

        // Set Custom Claims
        await _setCustomClaimsForUser(uid, role, teamId: teamId);
        claimsSetCount++;
      } catch (e) {
        print('❌ Gagal untuk ${doc.id}: $e');
        skipCount++;
      }
    }

    print('\n✅ Selesai!');
    print('   Users created: $createdCount');
    print('   Custom Claims set: $claimsSetCount');
    print('   Skipped: $skipCount');
    
    if (skipCount > 0) {
      print('\n⚠️  Ada yang di-skip. Periksa dokumen users di Firestore:');
      print('   - Pastikan semua punya field "uid" yang unique');
      print('   - Pastikan semua punya field "role"');
      print('   - Pastikan semua punya field "email"');
    }
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

/// Helper untuk set Custom Claims ke Auth via Node.js helper script
/// Memanggil: node functions/lib/setCustomClaims.js <uid> <role> [team_id]
Future<void> _setCustomClaimsForUser(
  String uid,
  String role, {
  String? teamId,
}) async {
  try {
    // Construct path dengan path separator yang sesuai platform
    final scriptPath = [
      'functions',
      'lib',
      'setCustomClaims.js',
    ].join(Platform.pathSeparator);
    
    final scriptFile = File(scriptPath);
    if (!scriptFile.existsSync()) {
      throw Exception('Script tidak ditemukan: $scriptPath');
    }

    final result = await Process.run('node', [
      scriptPath,
      uid,
      role,
      if (teamId != null) teamId,
    ]);

    if (result.exitCode != 0) {
      throw Exception('${result.stderr}');
    }
    
    // Print output dari Node.js helper (tanpa newline duplikat)
    final output = result.stdout.toString().trim();
    if (output.isNotEmpty) {
      // ignore: avoid_print
      print(output);
    }
  } catch (e) {
    rethrow;
  }
}
