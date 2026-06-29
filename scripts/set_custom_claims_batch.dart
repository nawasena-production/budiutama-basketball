// Jalankan: dart run scripts/set_custom_claims_batch.dart
// 
// Script ini membaca dokumen 'users' dari Firestore, mengekstrak role + team_id,
// dan set Custom Claims ke Firebase Auth untuk setiap user.
// 
// Gunakan ketika:
// - Ingin re-sync Custom Claims setelah membersihkan Auth Emulator
// - Seeding user di Firestore sebelum set claims di Auth
// - Migrasi data dari Firestore ke Auth Custom Claims
//
// Requirement:
// - Node.js dan firebase-admin sudah ter-install di functions/
// - Firestore Emulator berjalan (localhost:8080)
// - Auth Emulator berjalan (localhost:9099)
// - GOOGLE_APPLICATION_CREDENTIALS variable sudah set (untuk Admin SDK)
//
// Contoh command:
//   dart run scripts/set_custom_claims_batch.dart
//   
// Dengan GOOGLE_APPLICATION_CREDENTIALS:
//   $env:GOOGLE_APPLICATION_CREDENTIALS="serviceAccountKey.json"
//   dart run scripts/set_custom_claims_batch.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  final db = FirebaseFirestore.instance;

  print('📄 Reading users dari Firestore...');
  
  try {
    final userDocs = await db.collection('users').get();
    
    if (userDocs.docs.isEmpty) {
      print('⚠️  Tidak ada user di Firestore. Jalankan seed_emulator.dart terlebih dahulu.');
      return;
    }

    int successCount = 0;
    int failCount = 0;

    for (final doc in userDocs.docs) {
      final data = doc.data();
      final uid = data['uid'] as String?;
      final role = data['role'] as String?;
      final teamId = data['team_id'] as String?;

      if (uid == null || role == null) {
        print('⚠️  Dokumen ${doc.id} tidak punya uid atau role. Lewati.');
        failCount++;
        continue;
      }

      try {
        await _setCustomClaimsForUser(uid, role, teamId: teamId);
        successCount++;
      } catch (e) {
        print('❌ Gagal set Custom Claims untuk ${doc.id}: $e');
        failCount++;
      }
    }

    print('\n✅ Selesai!');
    print('   Success: $successCount');
    print('   Failed: $failCount');
    
    if (failCount > 0) {
      print('\n⚠️  Ada yang gagal. Pastikan:');
      print('   1. Node.js ter-install');
      print('   2. firebase-admin sudah di-install di functions/');
      print('   3. GOOGLE_APPLICATION_CREDENTIALS variable sudah set');
      print('   4. Auth Emulator berjalan di localhost:9099');
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
    
    // Print output dari Node.js helper
    if (result.stdout.toString().isNotEmpty) {
      // ignore: avoid_print
      print(result.stdout);
    }
  } catch (e) {
    rethrow;
  }
}
