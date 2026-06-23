// Jalankan: dart run scripts/seed_test_match.dart
// HANYA untuk Firebase Emulator — menambah SATU pertandingan
// berstatus `scheduled` lengkap dengan starter lineup, dipakai sebagai
// data tetap (fixture) oleh integration_test/full_match_flow_test.dart.
//
// Jalankan SETELAH scripts/seed_emulator.dart (Step 6.5) — script ini
// mengasumsikan team `putra_2526`, user `statistician_reza`, dan player
// `7_ar_putra2526` (dkk.) sudah ada. Jika belum, jalankan dulu seeding
// dasar tersebut.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // ── 1. Pastikan akun Statistician ada di Auth Emulator ────────────
  const statisticianEmail = 'statistician@budiutama.sch.id';
  const statisticianPassword = 'Test1234!';
  String statisticianUid;

  try {
    final cred = await auth.createUserWithEmailAndPassword(
      email: statisticianEmail,
      password: statisticianPassword,
    );
    statisticianUid = cred.user!.uid;
    print('✅ Akun Statistician dibuat: $statisticianUid');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      // Sudah ada dari run sebelumnya — lanjutkan dengan UID dari
      // dokumen users yang sudah tersimpan.
      final existing = await db
          .collection('users')
          .where('email', isEqualTo: statisticianEmail)
          .limit(1)
          .get();
      statisticianUid = existing.docs.isNotEmpty
          ? (existing.docs.first.data()['uid'] as String)
          : 'statistician_reza_uid';
      print('ℹ️  Akun Statistician sudah ada, lanjut: $statisticianUid');
    } else {
      rethrow;
    }
  }

  // Custom Claims tidak bisa diset langsung dari client SDK — di
  // Emulator, set lewat REST API Auth Emulator atau Emulator UI secara
  // manual jika diperlukan untuk Security Rules. Untuk integration test
  // UI murni (tanpa menguji Security Rules), dokumen `users` dengan
  // field `role` sudah cukup karena AuthRepository.getRole() membaca
  // dari token claims SETELAH login — pastikan claims sudah diset
  // manual sekali di Emulator UI (Authentication > pilih user > Edit >
  // Custom Claims: {"role": "statistician"}) sebelum menjalankan test.

  await db.collection('users').doc('statistician_reza').set({
    'uid': statisticianUid,
    'email': statisticianEmail,
    'full_name': 'Reza Pratama',
    'role': 'statistician',
    'is_active': true,
    'trusted_device_ids': [],
    'created_at': FieldValue.serverTimestamp(),
  });

  // ── 2. Event ────────────────────────────────────────────────────
  await db.collection('events').doc('friendly_sman1_2526').set({
    'team_id': 'putra_2526',
    'name': 'Pertandingan Persahabatan vs SMAN 1',
    'organizer': 'SMA Budi Utama',
    'event_type': 'persahabatan',
    'location': 'GOR Amongraga',
    'start_date': Timestamp.fromDate(DateTime(2026, 3, 15)),
    'end_date': Timestamp.fromDate(DateTime(2026, 3, 15)),
    'academic_year': '2025/2026',
    'status': 'ongoing',
    'notes': '',
    'created_by': 'manager_andi',
    'created_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });

  // ── 3. Match berstatus scheduled ───────────────────────────────
  const matchId = 'friendly_sman1_2526_vs_sman1_20260315';
  await db.collection('matches').doc(matchId).set({
    'home_team_id': 'putra_2526',
    'event_id': 'friendly_sman1_2526',
    'opponent_name': 'SMAN 1 Yogyakarta',
    'venue': 'GOR Amongraga',
    'match_type': 'home',
    'phase': 'persahabatan',
    'scheduled_at': Timestamp.fromDate(DateTime(2026, 3, 15, 15, 0)),
    'status': 'scheduled',
    'current_state': 'PRE_MATCH',
    'home_score': 0,
    'opponent_score': 0,
    'quarter_duration_minutes': 10,
    'num_periods': 4,
    'ot_duration_minutes': 5,
    'timer_config_locked': false,
    'notes': 'Data fixture untuk integration test Match Mode.',
    'started_at': null,
    'finished_at': null,
    'created_by': 'manager_andi',
    'created_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });

  // ── 4. Timer state awal ─────────────────────────────────────────
  await db.doc('matches/$matchId/timer_state/state').set({
    'is_running': false,
    'seconds_at_start': 600.0,
    'started_at': null,
    'quarter': 1,
  });

  // ── 5. Lima starter lineup (jersey #7, #4, #9, #15, #2) ──────────
  final starters = [
    {'jersey': 7, 'initial': 'ar', 'name': 'Ahmad Rizki', 'pos': 'PG'},
    {'jersey': 4, 'initial': 'dp', 'name': 'Dimas Pratama', 'pos': 'C'},
    {'jersey': 9, 'initial': 'fh', 'name': 'Fajar Hidayat', 'pos': 'SG'},
    {'jersey': 15, 'initial': 'gw', 'name': 'Galih Wibowo', 'pos': 'PF'},
    {'jersey': 2, 'initial': 'hn', 'name': 'Hendra Nugroho', 'pos': 'SF'},
  ];

  for (final s in starters) {
    final statsDocId = '${s['jersey']}_${s['initial']}';
    final playerId = '${s['jersey']}_${s['initial']}_putra2526';

    // Pastikan dokumen player ada di roster (jika belum dari seed dasar).
    await db.collection('players').doc(playerId).set({
      'user_id': null,
      'team_id': 'putra_2526',
      'full_name': s['name'],
      'jersey_number': s['jersey'],
      'positions': [s['pos']],
      'height_cm': 175.0,
      'weight_kg': 68.0,
      'photo_url': null,
      'photo_base64': null,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await db.doc('matches/$matchId/lineups/$statsDocId').set({
      'player_id': playerId,
      'full_name': s['name'],
      'jersey_number': s['jersey'],
      'position': s['pos'],
      'is_starter': true,
      'is_on_court': true,
      'entered_at_clock': 600.0,
      'entered_at_quarter': 1,
      'total_seconds_played': 0,
      'updated_at': FieldValue.serverTimestamp(),
    });

    await db.doc('matches/$matchId/player_stats/$statsDocId').set({
      'player_id': playerId,
      'full_name': s['name'],
      'jersey_number': s['jersey'],
      'points': 0,
      'ft_made': 0, 'ft_attempted': 0,
      'fg2_made': 0, 'fg2_attempted': 0,
      'fg3_made': 0, 'fg3_attempted': 0,
      'assists': 0,
      'offensive_rebounds': 0, 'defensive_rebounds': 0,
      'steals': 0, 'turnovers': 0, 'blocks': 0, 'fouls': 0,
      'shot_zones': <String, dynamic>{},
      'total_seconds_played': 0,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  print('✅ Fixture pertandingan "$matchId" berhasil di-seed!');
  print('   Status: scheduled, 5 starter siap, timer belum berjalan.');
  print('   Login sebagai: $statisticianEmail / $statisticianPassword');
  print('   ⚠️  Set Custom Claims {"role": "statistician"} di Emulator UI '
      'jika belum, sebelum login.');
}
