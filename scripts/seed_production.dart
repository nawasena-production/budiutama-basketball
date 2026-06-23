// Jalankan: dart run scripts/seed_production.dart
// HANYA untuk go-live PERTAMA KALI — JANGAN dijalankan lagi setelah ada
// data production asli, karena akan menimpa ulang dokumen teams yang
// mungkin sudah diedit Manager dari dalam app.
//
// Catatan perbaikan dari skeleton dev guide (Step 23.2): versi asli
// memanggil `stdin.readLineSync()` TANPA mengimpor `dart:io`, yang akan
// gagal compile. Diperbaiki di sini dengan import yang benar.

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // PRODUCTION — TIDAK redirect ke emulator. Pastikan kamu BENAR-BENAR
  // menjalankan ini terhadap project Firebase production
  // (`budiutama-basketball`), bukan secara tidak sengaja menimpa data
  // staging/develop.

  final db = FirebaseFirestore.instance;

  stdout.write(
    '⚠️  Anda akan men-seed data PRODUCTION ke project Firebase yang '
    'sedang aktif (cek firebase_options.dart). Tindakan ini idealnya '
    'HANYA dijalankan SEKALI saat go-live pertama. Ketik "yes" untuk '
    'melanjutkan: ',
  );
  final confirm = stdin.readLineSync();
  if (confirm != 'yes') {
    print('Dibatalkan. Tidak ada perubahan dilakukan.');
    exit(0);
  }

  // ── Seed teams ──────────────────────────────────────────────────
  final teamsSnapshot = await db.collection('teams').limit(1).get();
  if (teamsSnapshot.docs.isNotEmpty) {
    stdout.write(
      '⚠️  Collection "teams" SUDAH BERISI data (kemungkinan production '
      'sudah pernah di-seed sebelumnya). Lanjutkan tetap menimpa '
      '("sma_putra_2526", "sma_putri_2526", "smp_putra_2526", '
      '"smp_putri_2526" akan di-overwrite)? Ketik "yes" '
      'untuk lanjut, apa pun selain itu untuk batal: ',
    );
    final overwriteConfirm = stdin.readLineSync();
    if (overwriteConfirm != 'yes') {
      print('Dibatalkan — collection teams tidak diubah.');
      exit(0);
    }
  }

  const teams = {
    'sma_putra_2526': {
      'name': 'SMA Putra',
      'gender': 'male',
      'academic_year': '2025/2026',
      'is_active': true,
    },
    'sma_putri_2526': {
      'name': 'SMA Putri',
      'gender': 'female',
      'academic_year': '2025/2026',
      'is_active': true,
    },
    'smp_putra_2526': {
      'name': 'SMP Putra',
      'gender': 'male',
      'academic_year': '2025/2026',
      'is_active': true,
    },
    'smp_putri_2526': {
      'name': 'SMP Putri',
      'gender': 'female',
      'academic_year': '2025/2026',
      'is_active': true,
    },
  };

  for (final entry in teams.entries) {
    await db.collection('teams').doc(entry.key).set({
      ...entry.value,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Seed data production (teams) selesai!');
  print('');
  print('Langkah selanjutnya (WAJIB, tidak bisa diotomasi dari script ini');
  print('karena pembuatan akun dengan Custom Claims memerlukan Admin SDK,');
  print('bukan client SDK):');
  print('  1. Buka app production, login sementara sebagai diri sendiri');
  print('     via akun Google Cloud Console dengan akses Firebase Admin,');
  print('     ATAU panggil Cloud Function `createUser` (Step 12) langsung');
  print('     lewat Firebase Console > Functions > createUser > Testing tab');
  print('     untuk membuat akun Manager PERTAMA.');
  print('  2. Login sebagai Manager pertama tersebut di app.');
  print('  3. Gunakan halaman User Management di app untuk membuat akun');
  print('     Coach, Statistician, dan Player lainnya secara normal.');
}
