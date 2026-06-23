import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  final db = FirebaseFirestore.instance;

  await _seedTeams(db);
  await _seedUsers(db);
  await _seedPlayers(db);
  await _seedEvents(db);

  // ignore: avoid_print
  print('Seed data emulator selesai.');
}

Future<void> _seedTeams(FirebaseFirestore db) async {
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
    await db.doc(FirestorePaths.team(entry.key)).set({
      ...entry.value,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}

Future<void> _seedUsers(FirebaseFirestore db) async {
  final users = {
    'manager_andi': {
      'uid': 'manager_andi_uid',
      'email': 'manager@budiutama.sch.id',
      'full_name': 'Andi Pratama',
      'role': 'manager',
      'is_active': true,
      'trusted_device_ids': <String>[],
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    },
    'coach_budi': {
      'uid': 'coach_budi_uid',
      'email': 'coach@budiutama.sch.id',
      'full_name': 'Budi Santoso',
      'role': 'coach',
      'is_active': true,
      'trusted_device_ids': <String>[],
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    },
  };

  for (final entry in users.entries) {
    await db.doc(FirestorePaths.user(entry.key)).set(entry.value);
  }
}

Future<void> _seedPlayers(FirebaseFirestore db) async {
  final players = {
    '7_ar_smaputra2526': {
      'user_id': 'player_7_ar',
      'team_id': 'sma_putra_2526',
      'full_name': 'Ahmad Rizki',
      'jersey_number': 7,
      'positions': ['PG', 'SG'],
      'height_cm': 175.5,
      'weight_kg': 68.2,
      'date_of_birth': Timestamp.fromDate(DateTime(2008, 3, 15)),
      'photo_url': null,
      'photo_base64': null,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    },
    '11_bs_smaputra2526': {
      'user_id': 'player_11_bs',
      'team_id': 'sma_putra_2526',
      'full_name': 'Budi Santoso',
      'jersey_number': 11,
      'positions': ['SF'],
      'height_cm': 180.0,
      'weight_kg': 72.5,
      'date_of_birth': Timestamp.fromDate(DateTime(2007, 8, 20)),
      'photo_url': null,
      'photo_base64': null,
      'status': 'injured',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    },
    '3_rn_smaputri2526': {
      'user_id': 'player_3_rn',
      'team_id': 'sma_putri_2526',
      'full_name': 'Rina Nuraini',
      'jersey_number': 3,
      'positions': ['PG'],
      'height_cm': 164.0,
      'weight_kg': 55.3,
      'date_of_birth': Timestamp.fromDate(DateTime(2009, 1, 10)),
      'photo_url': null,
      'photo_base64': null,
      'status': 'active',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    },
  };

  for (final entry in players.entries) {
    await db.doc(FirestorePaths.player(entry.key)).set(entry.value);
  }
}

Future<void> _seedEvents(FirebaseFirestore db) async {
  await db.doc(FirestorePaths.event('porseni_kota_2526')).set({
    'team_id': 'sma_putra_2526',
    'name': 'Porseni Tingkat Kota 2025/2026',
    'organizer': 'Dinas Pendidikan Kota Yogyakarta',
    'event_type': 'porseni',
    'location': 'GOR Amongraga',
    'start_date': Timestamp.fromDate(DateTime(2026, 3, 1)),
    'end_date': Timestamp.fromDate(DateTime(2026, 3, 31)),
    'academic_year': '2025/2026',
    'status': 'upcoming',
    'notes': '',
    'created_by': 'manager_andi',
    'created_at': FieldValue.serverTimestamp(),
    'updated_at': FieldValue.serverTimestamp(),
  });
}
