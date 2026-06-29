# Firebase Emulator Seeding Guide

## Overview

Proses seeding untuk development/testing dengan Firebase Emulator Suite terdiri dari beberapa tahap:

1. **Start Firebase Emulators** — Jalankan emulator Firestore, Auth, Functions
2. **Seed Firestore Base Data** — Buat teams, basic users, players
3. **Create Auth Users** — Buat corresponding users di Firebase Auth + set Custom Claims
4. **Seed Test Data** — Tambahkan test fixtures seperti pertandingan, events
5. **Run Integration Tests** — Jalankan tests

## Quick Start

### 1. Start Emulators

```bash
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```

Atau gunakan VS Code task: `start-firebase-emulators`

### 2. Seed Firestore Base Data

Terminal baru (emulator tetap berjalan):

```bash
dart run scripts/seed_emulator.dart
```

**Output yang diharapkan:**
```
✅ Team SMA Putra dibuat: sma_putra_2526
✅ Team SMA Putri dibuat: sma_putri_2526
...
Seed data emulator selesai.
```

### 3. Create Auth Users + Set Custom Claims

```bash
dart run scripts/create_auth_users_from_firestore.dart
```

**Output yang diharapkan:**
```
📄 Reading users dari Firestore...
✅ User dibuat: manager_andi_uid (manager@budiutama.sch.id)
✅ Custom Claims set untuk manager_andi_uid: {"role":"manager"}
...
✅ Selesai!
   Users created: 2
   Custom Claims set: 2
   Skipped: 0
```

**Users yang diciptakan:**
- **manager_andi** (manager@budiutama.sch.id) — Role: manager
- **coach_budi** (coach@budiutama.sch.id) — Role: coach

### 4. Seed Test Match Data

```bash
dart run scripts/seed_test_match.dart
```

**Output yang diharapkan:**
```
✅ Akun Statistician dibuat: statistician_<uid>
✅ Custom Claims set untuk statistician_...: {"role":"statistician"}
✅ Fixture pertandingan 'friendly_sman1_...' berhasil di-seed!
   Status: scheduled, 5 starter siap, timer belum berjalan.
   Login sebagai: statistician@budiutama.sch.id / Test1234!
   Custom Claims sudah di-set otomatis untuk statistician role.
```

**User yang diciptakan:**
- **statistician_reza** (statistician@budiutama.sch.id) — Role: statistician

## Test Credentials

Setelah seeding, login dengan:

### Manager
- Email: `manager@budiutama.sch.id`
- Password: `Test1234!`
- Role: `manager`

### Coach
- Email: `coach@budiutama.sch.id`
- Password: `Test1234!`
- Role: `coach`

### Statistician
- Email: `statistician@budiutama.sch.id`
- Password: `Test1234!`
- Role: `statistician`

## Troubleshooting

### Error: Node.js helper script not found

```
⚠️  Warning: Gagal set Custom Claims untuk uid
   Error: spawn node ENOENT
```

**Solusi:**
1. Pastikan Node.js ter-install: `node --version`
2. Pastikan `firebase-admin` sudah di-install di folder `functions/`:
   ```bash
   cd functions
   npm install
   cd ..
   ```

### Error: GOOGLE_APPLICATION_CREDENTIALS not set

```
⚠️  Warning: Gagal set Custom Claims
   Error: Unable to determine Project ID for Admin SDK
```

**Solusi:**
Untuk emulator lokal, set variable `GOOGLE_APPLICATION_CREDENTIALS`:

```bash
# Windows PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS = "serviceAccountKey.json"

# Linux/macOS bash
export GOOGLE_APPLICATION_CREDENTIALS="serviceAccountKey.json"
```

Catatan: File `serviceAccountKey.json` sudah ada di root project untuk Production. Untuk emulator lokal, file apapun cukup selama format JSON valid.

### Error: Auth Emulator not running

```
❌ Error: Connection refused at localhost:9099
```

**Solusi:**
```bash
firebase emulators:start
```

Pastikan emulator sudah jalan sebelum menjalankan seed scripts.

### Permission Denied Error saat Login

Jika login berhasil tapi page menunjukkan `[cloud_firestore/permission-denied]` saat membuka akun atau page statistician:

**Penyebab:** Custom Claims belum ter-set di Auth (mungkin script gagal atau tidak dijalankan).

**Solusi:**

#### Option 1: Batch Set Custom Claims

Jika user sudah ada di Auth tapi Custom Claims belum ter-set:

```bash
dart run scripts/set_custom_claims_batch.dart
```

#### Option 2: Manual Set via Emulator UI

1. Buka Emulator UI: http://localhost:4000
2. Pilih **Authentication**
3. Klik user yang akan diedit
4. Klik **Edit Custom Claims**
5. Masukkan:
   ```json
   {"role": "statistician"}
   ```
   atau
   ```json
   {"role": "coach", "team_id": "sma_putra_2526"}
   ```
6. Klik **Update**

Setelah itu, sign out/sign in ulang agar token ter-refresh.

### Script Timeout atau Hang

Jika script berhenti tanpa output:

1. **Cek Emulator Status:**
   ```bash
   firebase emulators:exec "echo 'emulator ok'"
   ```

2. **Restart Emulator:**
   ```bash
   firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
   ```

3. **Jalankan seed ulang:**
   ```bash
   dart run scripts/seed_emulator.dart
   dart run scripts/create_auth_users_from_firestore.dart
   dart run scripts/seed_test_match.dart
   ```

## Reset Emulator

Untuk menghapus semua data dan mulai dari awal:

```bash
# Hapus folder emulator-data
rm -r emulator-data

# Jalankan emulator ulang (akan buat data baru)
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data

# Jalankan seeding lagi
dart run scripts/seed_emulator.dart
dart run scripts/create_auth_users_from_firestore.dart
dart run scripts/seed_test_match.dart
```

## Integration Test

Setelah semua seeding selesai, jalankan integration test:

```bash
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/full_match_flow_test.dart
```

atau

```bash
flutter test integration_test/
```

## Reference

- [Firebase Auth Emulator Docs](https://firebase.google.com/docs/emulator-suite/auth-emulation)
- [Firestore Emulator Docs](https://firebase.google.com/docs/emulator-suite/firestore-emulation)
- [Security Rules Testing](https://firebase.google.com/docs/firestore/security/test-rules-emulator)
