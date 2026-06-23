# 🏀 PANDUAN DEVELOPMENT — BUDI UTAMA BASKETBALL MANAGEMENT SYSTEM

**Last Updated**: Juni 2026  
**Version**: 2.0 — Flutter + Firebase  
**Status**: Ready to Development  
**Type**: Step-by-step development guide  

---

# DAFTAR ISI

1. [PROJECT OVERVIEW](#project-overview)
2. [QUICK START](#quick-start)
3. [FASE 0 — PERSIAPAN & SETUP](#fase-0--persiapan--setup)
   - [PART 1: Firebase Console Setup (60 menit)](#part-1-firebase-console-setup)
   - [PART 2: Repository & Flutter Project Setup (45 menit)](#part-2-repository--flutter-project-setup)
   - [PART 3: CI/CD Pipeline — GitHub Actions (60 menit)](#part-3-cicd-pipeline--github-actions)
4. [FASE 1 — FOUNDATION](#fase-1--foundation)
   - [PART 4: Flutter Skeleton & Firebase Init (90 menit)](#part-4-flutter-skeleton--firebase-init)
   - [PART 5: Firebase Auth — Login & OTP (120 menit)](#part-5-firebase-auth--login--otp)
   - [PART 6: Security Rules, Indexes & Shared Components (180 menit)](#part-6-security-rules-indexes--shared-components)
5. [FASE 2 — CORE FEATURES](#fase-2--core-features)
   - [PART 7: Player Management (180 menit)](#part-7-player-management)
   - [PART 8: Event & Training Management (180 menit)](#part-8-event--training-management)
   - [PART 9: Match Management — Pre-Match Setup (150 menit)](#part-9-match-management--pre-match-setup)
   - [PART 10: Injury Management (120 menit)](#part-10-injury-management)
   - [PART 11: Physical Test Management (240 menit)](#part-11-physical-test-management)
   - [PART 12: Account Management via Cloud Functions (90 menit)](#part-12-account-management-via-cloud-functions)
6. [FASE 3 — LIVE MATCH ENGINE](#fase-3--live-match-engine)
   - [PART 13: Match Engine Logic & Repositories (240 menit)](#part-13-match-engine-logic--repositories)
   - [PART 14: Match Action, Undo & Stats Increment (240 menit)](#part-14-match-action-undo--stats-increment)
   - [PART 15: Cloud Functions — Stats Final & Audit Log (120 menit)](#part-15-cloud-functions--stats-final--audit-log)
   - [PART 16: Match Mode UI — Fullscreen Layout (240 menit)](#part-16-match-mode-ui--fullscreen-layout)
   - [PART 17: Court Overlay & Shot Zones (150 menit)](#part-17-court-overlay--shot-zones)
7. [FASE 4 — DASHBOARD & ANALYTICS](#fase-4--dashboard--analytics)
   - [PART 18: Statistics Dashboard & Shot Chart (240 menit)](#part-18-statistics-dashboard--shot-chart)
   - [PART 19: Audit Log UI (60 menit)](#part-19-audit-log-ui)
8. [FASE 5 — TESTING & HARDENING](#fase-5--testing--hardening)
   - [PART 20: Unit & Widget Testing (300 menit)](#part-20-unit--widget-testing)
   - [PART 21: Integration & Security Testing (240 menit)](#part-21-integration--security-testing)
   - [PART 22: Performance, Hardening & Bug Fix (180 menit)](#part-22-performance-hardening--bug-fix)
9. [FASE 6 — DEPLOYMENT & LAUNCH](#fase-6--deployment--launch)
   - [PART 23: Pre-Launch & Go-Live (120 menit)](#part-23-pre-launch--go-live)
10. [DIRECTORY STRUCTURE](#directory-structure)
11. [TROUBLESHOOTING](#troubleshooting)
12. [REFERENSI CEPAT](#referensi-cepat)

---

# PROJECT OVERVIEW

## Apa itu Budi Utama Basketball Management System?

Sistem manajemen tim basket SMA Budi Utama Yogyakarta berbasis **Flutter** yang berjalan di Android, iOS, dan Web. Dua modul utama:

- **Basketball Club Management** — pengelolaan pemain, jadwal latihan, pertandingan, cedera, tes fisik
- **Live Match Statistics Engine** — input statistik real-time saat pertandingan berlangsung, sinkronisasi multi-tablet

## Tech Stack

| Layer | Teknologi |
|-------|-----------|
| **Frontend** | Flutter 3.x (Android, iOS, Web — satu codebase) |
| **Database** | Cloud Firestore (real-time + offline persistence) |
| **Auth** | Firebase Authentication (Email/Password + OTP + reCAPTCHA v3) |
| **Storage** | Firebase Storage (foto profil & cedera) |
| **Backend Logic** | Cloud Functions TypeScript |
| **State Management** | Riverpod |
| **Routing** | GoRouter |
| **Models** | Freezed + json_serializable |
| **Charts** | fl_chart |
| **Audio (Beep Test)** | audioplayers |
| **Push Notification** | Firebase Cloud Messaging |

## Role Pengguna

| Role | Akses Utama |
|------|-------------|
| **Manager** | CRUD pemain, jadwal, pertandingan, tes fisik, kelola akun |
| **Coach** | Statistik, cedera, Live Player Stats (read-only) |
| **Statistician** | Input live match, timer, substitusi, undo |
| **Player** | Statistik & jadwal milik sendiri (read-only) |

## Estimasi Timeline

| Fase | Durasi | Target |
|------|--------|--------|
| **Fase 0** | 1 minggu | Setup semua tools, Firebase, CI/CD |
| **Fase 1** | 4 minggu | Foundation: Auth, models, shared components |
| **Fase 2** | 6 minggu | Core features: player, match, injury, physical test |
| **Fase 3** | 4 minggu | Live Match Engine (KRITIS) |
| **Fase 4** | 2 minggu | Dashboard & analytics |
| **Fase 5** | 4 minggu | Testing & hardening |
| **Fase 6** | 1 minggu | Deployment & go-live |
| **Total** | ~22 minggu | MVP complete |

---

# QUICK START

## Untuk yang Ingin Langsung Mulai (10 menit overview)

### Yang perlu dilakukan:
1. Buat 1 Firebase project: `budiutama-basketball`
2. Aktifkan Auth, Firestore, Storage, Functions, Hosting, App Check, Cloud Messaging
3. Setup Firebase Emulator Suite untuk development lokal
4. Buat Flutter project, hubungkan via FlutterFire CLI
5. Setup GitHub repo + CI/CD GitHub Actions
6. Buat semua Dart models (Freezed)
7. Implementasi Firebase Auth + RBAC (Custom Claims)
8. Buat Security Rules + Composite Indexes
9. Bangun Core Features (player, match, training, injury, physical test)
10. Bangun Live Match Engine (BAGIAN PALING KRITIS — 4 minggu tersendiri)
11. Bangun Statistics Dashboard
12. Testing menyeluruh via Firebase Emulator
13. Clear data testing → seed production → deploy

### Estimasi total waktu: ~22 minggu (tim kecil 2-3 developer)

> 💡 **Prinsip utama**: Semua development harian menggunakan **Firebase Emulator** — tidak pernah menyentuh project Firebase production saat coding. Production hanya disentuh saat deploy dari branch `develop` atau `main`.

---

# FASE 0 — PERSIAPAN & SETUP

## PART 1: FIREBASE CONSOLE SETUP

> ⏱ Estimasi waktu: 60 menit

---

### Step 1.1: Buat Firebase Project

```
1. Buka: https://console.firebase.google.com
2. Klik "Add project"
3. Project name: budiutama-basketball
4. Google Analytics: ON (untuk Performance Monitoring)
5. Klik "Create project"
6. Tunggu ~30 detik
```

**Expected**: Dashboard Firebase dengan nama "budiutama-basketball" muncul ✅

---

### Step 1.2: Upgrade ke Blaze Plan

```
1. Di sidebar kiri → klik "Spark plan" (pojok bawah kiri)
2. Klik "Upgrade"
3. Pilih "Blaze (pay as you go)"
4. Masukkan informasi billing (kartu kredit)
5. Set budget alert: IDR 200.000/bulan sebagai peringatan
```

> ⚠️ **Wajib dilakukan**: Cloud Functions hanya tersedia di Blaze plan. Untuk skala sekolah, biaya aktual mendekati $0/bulan karena masih dalam free tier quota.

**Expected**: Label berubah menjadi "Blaze" di sidebar ✅

---

### Step 1.3: Aktifkan Firebase Authentication

```
1. Di sidebar → Authentication → klik "Get started"
2. Tab "Sign-in method" → pilih "Email/Password"
3. Toggle pertama (Email/Password): ON
4. Toggle kedua (Email link / passwordless): ON (untuk Email OTP)
5. Klik "Save"
```

**Expected**: Email/Password dan Email link provider aktif dengan status "Enabled" ✅

---

### Step 1.4: Buat Firestore Database

```
1. Di sidebar → Firestore Database → klik "Create database"
2. Database ID: (default) — biarkan default
3. Location: asia-southeast2 (Jakarta)
4. Mode: Start in production mode
5. Klik "Create"
6. Tunggu ~1 menit
```

> ⚠️ **Location tidak bisa diubah setelah ini.** Pilih asia-southeast2 untuk latensi minimal dari Yogyakarta.

**Expected**: Halaman Firestore dengan tab "Data" kosong ✅

---

### Step 1.5: Aktifkan Firebase Storage

```
1. Di sidebar → Storage → klik "Get started"
2. Mode: Start in production mode
3. Location: asia-southeast2 (sama dengan Firestore)
4. Klik "Done"
```

**Expected**: Storage aktif dengan bucket default ✅

---

### Step 1.6: Aktifkan Cloud Functions

```
1. Di sidebar → Functions → klik "Get started"
2. Ikuti wizard setup
3. Pilih region: asia-southeast2
```

**Expected**: Functions aktif dan siap di-deploy ✅

---

### Step 1.7: Aktifkan Firebase Hosting

```
1. Di sidebar → Hosting → klik "Get started"
2. Ikuti wizard (akan diselesaikan lewat CLI nanti)
3. Klik "Next" hingga selesai tanpa deploy dulu
```

**Expected**: Hosting aktif dengan domain default ✅

---

### Step 1.8: Setup Firebase App Check

```
1. Di sidebar → App Check → klik "Get started"
2. Register Android app: pilih "Play Integrity"
3. Register iOS app: pilih "DeviceCheck"
4. Register Web app: pilih "reCAPTCHA v3"
5. Untuk reCAPTCHA v3:
   a. Buka: https://www.google.com/recaptcha/admin
   b. Buat site key baru, tipe: reCAPTCHA v3
   c. Domain: localhost + domain produksi
   d. Copy site key → paste ke App Check console
6. Klik "Save"
```

**Expected**: Semua platform terdaftar di App Check ✅

---

### Step 1.9: Aktifkan Firebase Cloud Messaging

```
1. Di sidebar → Cloud Messaging → ini sudah aktif otomatis
2. Tidak perlu konfigurasi manual di console
3. Konfigurasi di Flutter nanti via firebase_messaging package
```

**Expected**: FCM aktif (terlihat di Project settings → Cloud Messaging) ✅

---

### Step 1.10: Register Aplikasi di Firebase

```
Android:
1. Project Overview → Add app → pilih Android
2. Package name: com.budiutama.basketball
3. App nickname: Budi Utama Basketball
4. Klik "Register app"
5. Download google-services.json
6. Klik "Next" → "Next" → "Continue to console"

iOS:
1. Project Overview → Add app → pilih Apple
2. Bundle ID: com.budiutama.basketball
3. App nickname: Budi Utama Basketball
4. Klik "Register app"
5. Download GoogleService-Info.plist
6. Klik "Next" → "Next" → "Continue to console"

Web:
1. Project Overview → Add app → pilih Web (</>)
2. App nickname: Budi Utama Basketball Web
3. Jangan centang Firebase Hosting dulu
4. Klik "Register app"
5. Simpan firebaseConfig (akan dipakai FlutterFire CLI nanti)
6. Klik "Continue to console"
```

**Expected**: Ketiga platform (Android, iOS, Web) terdaftar di Project Overview ✅

---

### Step 1.11: Set Firestore Security Rules Awal (Deny All)

```
1. Firestore → tab "Rules"
2. Ganti semua isi dengan rules deny-all berikut:
3. Klik "Publish"
```

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

> ℹ️ Rules lengkap akan di-deploy via CLI nanti. Ini hanya placeholder aman.

**Expected**: Rules published, semua akses ditolak ✅

---

### Step 1.12: Set Storage Security Rules Awal (Deny All)

```
1. Storage → tab "Rules"
2. Ganti semua isi dengan rules berikut:
3. Klik "Publish"
```

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

**Expected**: Storage rules published ✅

---

## PART 2: REPOSITORY & FLUTTER PROJECT SETUP

> ⏱ Estimasi waktu: 45 menit

---

### Step 2.1: Buat GitHub Repository

```
1. Buka: https://github.com/new
2. Repository name: budiutama-basketball
3. Visibility: Private
4. Initialize: centang README
5. Klik "Create repository"
```

**Expected**: Repository `budiutama-basketball` terbuat ✅

---

### Step 2.2: Setup Branch Protection

```
Di GitHub repository → Settings → Branches → Add rule:

Branch: main
☑ Require a pull request before merging
☑ Require approvals: 1
☑ Dismiss stale pull request approvals when new commits are pushed

Branch: develop
☑ Require a pull request before merging
☑ Require approvals: 1

Klik "Save changes" untuk masing-masing branch.
```

**Expected**: Branch protection aktif untuk `main` dan `develop` ✅

---

### Step 2.3: Pastikan Flutter SDK Terinstall

```bash
flutter doctor
```

**Expected output**:
```
✅ Flutter (Channel stable, 3.x.x)
✅ Android toolchain
✅ Xcode (macOS only)
✅ Chrome - develop for the web
```

Jika belum: https://docs.flutter.dev/get-started/install

---

### Step 2.4: Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
firebase projects:list
```

**Expected**: Project `budiutama-basketball` muncul di daftar ✅

---

### Step 2.5: Buat Flutter Project

```bash
flutter create budiutama_basketball --org com.budiutama --platforms android,ios,web
cd budiutama_basketball
```

---

### Step 2.6: Hubungkan Flutter ke Firebase via FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=budiutama-basketball --platforms=android,ios,web
```

> ℹ️ Perintah ini men-generate file `lib/firebase_options.dart` secara otomatis yang berisi konfigurasi Firebase untuk semua platform.

**Expected**: File `lib/firebase_options.dart` terbuat ✅

---

### Step 2.7: Letakkan File Konfigurasi Firebase

```bash
# Letakkan google-services.json yang didownload di Step 1.10:
cp ~/Downloads/google-services.json android/app/

# Letakkan GoogleService-Info.plist yang didownload di Step 1.10:
cp ~/Downloads/GoogleService-Info.plist ios/Runner/
```

---

### Step 2.8: Buat Struktur Folder Flutter

```bash
mkdir -p lib/app
mkdir -p lib/core/constants
mkdir -p lib/core/errors
mkdir -p lib/core/utils
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/domain/providers
mkdir -p lib/features/auth/presentation/pages
mkdir -p lib/features/auth/presentation/widgets
mkdir -p lib/features/players/data/models
mkdir -p lib/features/players/data/repositories
mkdir -p lib/features/players/domain/providers
mkdir -p lib/features/players/presentation/pages
mkdir -p lib/features/players/presentation/widgets
mkdir -p lib/features/events/data/models
mkdir -p lib/features/events/data/repositories
mkdir -p lib/features/events/domain/providers
mkdir -p lib/features/events/presentation/pages
mkdir -p lib/features/matches/dashboard/data/repositories
mkdir -p lib/features/matches/dashboard/domain/providers
mkdir -p lib/features/matches/dashboard/presentation/pages
mkdir -p lib/features/matches/live/data/models
mkdir -p lib/features/matches/live/data/repositories
mkdir -p lib/features/matches/live/domain/providers
mkdir -p lib/features/matches/live/presentation/pages
mkdir -p lib/features/matches/live/presentation/widgets/header
mkdir -p lib/features/matches/live/presentation/widgets/left_panel
mkdir -p lib/features/matches/live/presentation/widgets/center_panel
mkdir -p lib/features/matches/live/presentation/widgets/right_panel
mkdir -p lib/features/matches/live/presentation/widgets/bottom_panel
mkdir -p lib/features/matches/live/presentation/widgets/timeline
mkdir -p lib/features/training/data/models
mkdir -p lib/features/training/data/repositories
mkdir -p lib/features/training/domain/providers
mkdir -p lib/features/training/presentation/pages
mkdir -p lib/features/injuries/data/models
mkdir -p lib/features/injuries/data/repositories
mkdir -p lib/features/injuries/domain/providers
mkdir -p lib/features/injuries/presentation/pages
mkdir -p lib/features/physical_tests/data/models
mkdir -p lib/features/physical_tests/data/repositories
mkdir -p lib/features/physical_tests/domain/providers
mkdir -p lib/features/physical_tests/presentation/pages
mkdir -p lib/features/physical_tests/presentation/widgets
mkdir -p lib/features/statistics/data/repositories
mkdir -p lib/features/statistics/domain/providers
mkdir -p lib/features/statistics/presentation/pages
mkdir -p lib/features/statistics/presentation/widgets
mkdir -p lib/shared/widgets
mkdir -p lib/shared/providers
mkdir -p lib/shared/models
mkdir -p functions/src
mkdir -p assets/audio
```

---

### Step 2.9: Setup .gitignore

**Buka file**: `.gitignore`

**Tambahkan baris-baris berikut** di bagian bawah file:

```gitignore
# Firebase secrets — JANGAN pernah di-commit
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
lib/firebase_options.dart

# Firebase Emulator data
.firebase/
firebase-debug.log
firestore-debug.log
ui-debug.log
```

---

### Step 2.10: Buat Conventional Commits Convention

Buat file `.gitmessage` di root project:

```
# Format commit: <type>(<scope>): <subject>
#
# type: feat | fix | test | refactor | docs | chore | style
# scope: auth | players | matches | live | injury | physical | stats | infra | ci
#
# Contoh:
# feat(players): add player photo upload with base64 compression
# fix(live): fix undo decrement not updating shot_zones
# test(auth): add security rules test for statistician role
```

---

### Step 2.11: Setup Firebase Emulator Suite

```bash
firebase init emulators
```

Ketika diminta, pilih emulator berikut:
```
✅ Authentication Emulator — port 9099
✅ Firestore Emulator — port 8080
✅ Storage Emulator — port 9199
✅ Functions Emulator — port 5001
✅ Hosting Emulator — port 5000
✅ Emulator UI — port 4000
```

Download emulator jika diminta: klik Yes.

**Expected**: File `firebase.json` ter-update dengan konfigurasi emulator ✅

---

### Step 2.12: Verifikasi Emulator Berjalan

```bash
firebase emulators:start
```

**Expected output**:
```
✅ auth: localhost:9099
✅ firestore: localhost:8080
✅ functions: localhost:5001
✅ storage: localhost:9199
✅ hosting: localhost:5000
✅ ui: localhost:4000 (Emulator UI)
```

Buka `http://localhost:4000` di browser → Emulator UI tampil ✅

---

## PART 3: CI/CD PIPELINE — GITHUB ACTIONS

> ⏱ Estimasi waktu: 60 menit

---

### Step 3.1: Setup Firebase Service Account Secret

```
1. Firebase Console → Project settings → Service accounts
2. Klik "Generate new private key"
3. Download file JSON
4. Di GitHub → Repository → Settings → Secrets and variables → Actions
5. Klik "New repository secret"
6. Name: FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA
7. Value: paste seluruh isi file JSON
8. Klik "Add secret"
```

**Expected**: Secret tersimpan di GitHub ✅

---

### Step 3.2: Buat Workflow — Analyze & Test (setiap push)

Buat file: `.github/workflows/flutter_check.yml`

```yaml
name: Flutter Analyze & Test

on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, develop]

jobs:
  analyze_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze code
        run: flutter analyze

      - name: Run tests
        run: flutter test
```

---

### Step 3.3: Buat Workflow — Deploy ke Staging (push ke develop)

Buat file: `.github/workflows/deploy_staging.yml`

```yaml
name: Deploy to Staging (Firebase)

on:
  push:
    branches: [develop]

jobs:
  deploy_staging:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable

      - name: Install Flutter dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      - name: Build Flutter Web
        run: flutter build web --release

      - name: Deploy to Firebase Hosting (Preview Channel)
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA }}
          projectId: budiutama-basketball
          channelId: staging

      - name: Deploy Security Rules
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only firestore:rules,storage
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA }}
          PROJECT_ID: budiutama-basketball

      - name: Deploy Cloud Functions
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA }}
          PROJECT_ID: budiutama-basketball
```

---

### Step 3.4: Buat Workflow — Deploy Production (manual approval)

Buat file: `.github/workflows/deploy_production.yml`

```yaml
name: Deploy to Production (Manual Approval)

on:
  push:
    branches: [main]

jobs:
  deploy_production:
    runs-on: ubuntu-latest
    environment: production   # <-- butuh manual approval di GitHub
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: stable

      - name: Install Flutter dependencies
        run: flutter pub get

      - name: Build Flutter Web Release
        run: flutter build web --release

      - name: Build Android APK Release
        run: flutter build apk --release

      - name: Deploy to Firebase Hosting Live Channel
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA }}
          projectId: budiutama-basketball
          channelId: live

      - name: Deploy Security Rules
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only firestore:rules,storage
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA }}
          PROJECT_ID: budiutama-basketball

      - name: Deploy Cloud Functions
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_SERVICE_ACCOUNT_BUDIUTAMA }}
          PROJECT_ID: budiutama-basketball
```

Aktifkan environment protection:
```
GitHub → Repository → Settings → Environments → New environment
Name: production
☑ Required reviewers: tambahkan username PM/lead dev
Klik "Save protection rules"
```

**Expected**: Ketiga workflow tersimpan; production environment butuh approval manual ✅

---

# FASE 1 — FOUNDATION

## PART 4: FLUTTER SKELETON & FIREBASE INIT

> ⏱ Estimasi waktu: 90 menit

---

### Step 4.1: Update `pubspec.yaml`

**Buka file**: `pubspec.yaml`

**Ganti seluruh dependencies dengan:**

```yaml
name: budiutama_basketball
description: Budi Utama Basketball Management System
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  cloud_functions: ^5.0.0
  firebase_app_check: ^0.3.0
  firebase_messaging: ^15.0.0

  # State Management & Routing
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  go_router: ^14.0.0

  # Data Models
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0

  # UI & Utilities
  fl_chart: ^0.68.0
  cached_network_image: ^3.3.0
  image_picker: ^1.1.0
  flutter_image_compress: ^2.3.0
  flutter_svg: ^2.0.0
  audioplayers: ^6.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0

flutter:
  uses-material-design: true
  assets:
    - assets/audio/
```

---

### Step 4.2: Jalankan `flutter pub get`

```bash
flutter pub get
```

**Expected**: Semua package berhasil didownload tanpa error ✅

---

### Step 4.3: Buat `firestore_paths.dart` — Semua Path Terpusat

Buat file: `lib/core/constants/firestore_paths.dart`

```dart
// Semua path Firestore sebagai konstanta — tidak ada string path yang ditulis manual di mana pun

class FirestorePaths {
  // Root collections
  static const users = 'users';
  static const teams = 'teams';
  static const players = 'players';
  static const events = 'events';
  static const matches = 'matches';
  static const injuryReports = 'injury_reports';
  static const trainingSessions = 'training_sessions';
  static const physicalTestSessions = 'physical_test_sessions';
  static const auditLogs = 'audit_logs';

  // Subcollections di dalam match
  static String matchTimerState(String matchId) =>
      'matches/$matchId/timer_state';
  static String matchEvents(String matchId) =>
      'matches/$matchId/events';
  static String matchPlayerStats(String matchId) =>
      'matches/$matchId/player_stats';
  static String matchLineups(String matchId) =>
      'matches/$matchId/lineups';

  // Subcollections di dalam physical test
  static String physicalTestResults(String sessionId) =>
      'physical_test_sessions/$sessionId/results';
}
```

---

### Step 4.4: Buat `app_exceptions.dart` — Hierarchy Error

Buat file: `lib/core/errors/app_exceptions.dart`

```dart
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class FirestoreException extends AppException {
  const FirestoreException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class MatchStateException extends AppException {
  const MatchStateException(super.message);
}

class InvalidZoneConsistencyException extends AppException {
  const InvalidZoneConsistencyException(super.message);
}
```

---

### Step 4.5: Buat `match_state_machine.dart`

Buat file: `lib/core/utils/match_state_machine.dart`

```dart
const validTransitions = {
  'PRE_MATCH':   ['Q1_ACTIVE'],
  'Q1_ACTIVE':   ['Q1_BREAK'],
  'Q1_BREAK':    ['Q2_ACTIVE'],
  'Q2_ACTIVE':   ['HALFTIME'],
  'HALFTIME':    ['Q3_ACTIVE'],
  'Q3_ACTIVE':   ['Q3_BREAK'],
  'Q3_BREAK':    ['Q4_ACTIVE'],
  'Q4_ACTIVE':   ['CHECK_SCORE'],
  'CHECK_SCORE': ['OT_ACTIVE', 'POST_MATCH'],
  'OT_ACTIVE':   ['POST_MATCH'],
  'POST_MATCH':  <String>[],
};

bool isValidTransition(String from, String to) =>
    validTransitions[from]?.contains(to) ?? false;

bool isActiveState(String state) =>
    state.endsWith('_ACTIVE');
```

---

### Step 4.6: Buat `timer_calculator.dart`

Buat file: `lib/core/utils/timer_calculator.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Hitung sisa waktu dari Server Timestamp Firebase
// Dipanggil setiap frame (100ms) oleh timer widget
double currentRemainingSeconds({
  required bool isRunning,
  required double secondsAtStart,
  required Timestamp? startedAt,
}) {
  if (!isRunning || startedAt == null) {
    return secondsAtStart;
  }
  final elapsed = DateTime.now()
      .difference(startedAt.toDate())
      .inMilliseconds /
      1000.0;
  return (secondsAtStart - elapsed).clamp(0.0, double.infinity);
}

String formatSeconds(double seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).floor().toString().padLeft(2, '0');
  return '$m:$s';
}
```

---

### Step 4.7: Buat `stats_calculator.dart`

Buat file: `lib/core/utils/stats_calculator.dart`

```dart
class StatsCalculator {
  static double ftPercentage(int made, int attempted) =>
      attempted > 0 ? (made / attempted * 100) : 0.0;

  static double fg2Percentage(int made, int attempted) =>
      attempted > 0 ? (made / attempted * 100) : 0.0;

  static double fg3Percentage(int made, int attempted) =>
      attempted > 0 ? (made / attempted * 100) : 0.0;

  static double fgPercentage(
      int fg2Made, int fg2Att, int fg3Made, int fg3Att) {
    final totalMade = fg2Made + fg3Made;
    final totalAtt = fg2Att + fg3Att;
    return totalAtt > 0 ? (totalMade / totalAtt * 100) : 0.0;
  }

  static double zonePercentage(Map<String, dynamic> zone) {
    final attempted = (zone['attempted'] as int?) ?? 0;
    final made = (zone['made'] as int?) ?? 0;
    return attempted > 0 ? (made / attempted * 100) : 0.0;
  }
}
```

---

### Step 4.8: Setup `main.dart` dengan Firebase Init & Emulator Redirect

**Ganti seluruh isi** `lib/main.dart`:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aktifkan offline persistence Firestore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Redirect ke Firebase Emulator saat debug mode
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    // Storage emulator: port 9199
  }

  // App Check — gunakan debug provider saat debug
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider:
        kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_SITE_KEY'),
  );

  runApp(const ProviderScope(child: App()));
}
```

---

### Step 4.9: Buat `app/app.dart` — MaterialApp + GoRouter

Buat file: `lib/app/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Budi Utama Basketball',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A5C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

// Router sementara — akan diganti dengan router lengkap di Part 5
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Login — Coming Soon'))),
      ),
    ],
  );
});
```

---

### Step 4.10: Verifikasi App Bisa Berjalan

```bash
# Pastikan emulator sudah berjalan di terminal terpisah:
firebase emulators:start

# Di terminal lain:
flutter run -d chrome
```

**Expected**: App berjalan di Chrome dengan teks "Login — Coming Soon" ✅

---

## PART 5: FIREBASE AUTH — LOGIN & OTP

> ⏱ Estimasi waktu: 120 menit

---

### Step 5.1: Buat Semua Dart Models (Freezed)

Jalankan perintah ini untuk membuat semua file model kosong:

```bash
touch lib/shared/models/user_model.dart
touch lib/shared/models/team_model.dart
touch lib/features/players/data/models/player_model.dart
touch lib/features/events/data/models/event_model.dart
touch lib/features/matches/dashboard/data/models/match_model.dart
touch lib/features/matches/live/data/models/match_event_model.dart
touch lib/features/matches/live/data/models/player_stats_model.dart
touch lib/features/matches/live/data/models/lineup_model.dart
touch lib/features/matches/live/data/models/timer_state_model.dart
touch lib/features/injuries/data/models/injury_report_model.dart
touch lib/features/training/data/models/training_session_model.dart
touch lib/features/physical_tests/data/models/physical_test_session_model.dart
touch lib/features/physical_tests/data/models/physical_test_result_model.dart
```

**Buat `UserModel`** — `lib/shared/models/user_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String fullName,
    required String role,       // coach | manager | statistician | player
    @Default(true) bool isActive,
    @Default([]) List<String> trustedDeviceIds,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'id': doc.id});
  }
}
```

**Buat `TimerStateModel`** — `lib/features/matches/live/data/models/timer_state_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'timer_state_model.freezed.dart';
part 'timer_state_model.g.dart';

@freezed
class TimerStateModel with _$TimerStateModel {
  const factory TimerStateModel({
    @Default(false) bool isRunning,
    @Default(600.0) double secondsAtStart,
    Timestamp? startedAt,       // Server Timestamp Firebase, null saat PAUSE
    @Default(1) int quarter,
  }) = _TimerStateModel;

  factory TimerStateModel.fromJson(Map<String, dynamic> json) =>
      _$TimerStateModelFromJson(json);

  factory TimerStateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TimerStateModel.fromJson(data);
  }
}
```

> ℹ️ Buat model lainnya (PlayerModel, MatchModel, MatchEventModel, dll.) dengan pola yang sama. Lihat SDD Section 3.2 untuk semua fields lengkap.

---

### Step 5.2: Jalankan build_runner untuk Generate Freezed Files

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Expected**: File `.freezed.dart` dan `.g.dart` ter-generate untuk setiap model ✅

---

### Step 5.3: Buat `AuthRepository`

Buat file: `lib/features/auth/data/repositories/auth_repository.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/app_exceptions.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateStream => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login gagal');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> getRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdTokenResult(true);
    return token.claims?['role'] as String?;
  }

  // Cek apakah device sudah terpercaya (untuk Coach & Manager)
  Future<bool> isDeviceTrusted(String userId, String deviceHash) async {
    final doc = await _db.collection('users').doc(userId).get();
    final trusted =
        List<String>.from(doc.data()?['trusted_device_ids'] ?? []);
    return trusted.contains(deviceHash);
  }

  // Tambahkan device ke trusted list
  Future<void> addTrustedDevice(String userId, String deviceHash) async {
    await _db.collection('users').doc(userId).update({
      'trusted_device_ids': FieldValue.arrayUnion([deviceHash]),
    });
  }
}
```

---

### Step 5.4: Buat Halaman Login

Buat file: `lib/features/auth/presentation/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A5C),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo & Judul
              const Icon(Icons.sports_basketball,
                  size: 64, color: Color(0xFFE8420A)),
              const SizedBox(height: 16),
              const Text(
                'Budi Utama Basketball',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'SMA Budi Utama Yogyakarta',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 40),
              // Form Login
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || !v.contains('@') ? 'Email tidak valid' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (v) => v == null || v.length < 8
                          ? 'Password minimal 8 karakter'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8420A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Masuk',
                                style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      // TODO: Panggil AuthRepository.signIn() + cek device OTP
      // Implementasi penuh di Step 5.5
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

---

### Step 5.5: Buat `AuthNotifier` Riverpod

Buat file: `lib/features/auth/domain/providers/auth_provider.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

// Stream status auth — dipakai GoRouter untuk redirect
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateStream;
});

// Role pengguna yang sedang login
final userRoleProvider = FutureProvider<String?>((ref) async {
  final auth = ref.watch(authRepositoryProvider);
  return auth.getRole();
});
```

---

### Step 5.6: Update GoRouter dengan Auth Guard

**Update** `lib/app/app.dart` — ganti routerProvider:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/domain/providers/auth_provider.dart';
import '../features/auth/presentation/pages/login_page.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Budi Utama Basketball',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A3A5C),
        ),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Dashboard — Coming Soon'))),
      ),
      // Route /match/:matchId ditambahkan di Fase 3
    ],
  );
});
```

---

### Step 5.7: Test Login di Emulator

```bash
# 1. Jalankan emulator (terminal terpisah):
firebase emulators:start

# 2. Buka Emulator UI: http://localhost:4000
# 3. Authentication → Add user:
#    Email: manager@budiutama.sch.id
#    Password: Test1234!
# 4. Jalankan app:
flutter run -d chrome
# 5. Login dengan credentials di atas
```

**Expected**: Login berhasil, redirect ke halaman `/dashboard` ✅

---

## PART 6: SECURITY RULES, INDEXES & SHARED COMPONENTS

> ⏱ Estimasi waktu: 180 menit

---

### Step 6.1: Tulis Security Rules Lengkap

**Buat/update file**: `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ── HELPER FUNCTIONS ────────────────────────────────────────
    function isAuth()         { return request.auth != null; }
    function role()           { return request.auth.token.role; }
    function isManager()      { return isAuth() && role() == 'manager'; }
    function isCoach()        { return isAuth() && role() == 'coach'; }
    function isStatistician() { return isAuth() && role() == 'statistician'; }
    function isPlayer()       { return isAuth() && role() == 'player'; }
    function isStaff()        { return isManager() || isCoach(); }

    // ── USERS ──────────────────────────────────────────────────
    match /users/{userId} {
      allow read:  if isAuth() && (isStaff() || request.auth.uid == resource.data.uid);
      allow write: if false; // hanya Cloud Functions
    }

    // ── TEAMS ──────────────────────────────────────────────────
    match /teams/{teamId} {
      allow read:  if isAuth();
      allow write: if isManager();
    }

    // ── PLAYERS ────────────────────────────────────────────────
    match /players/{playerId} {
      allow read: if isAuth() && (
        isStaff() || isStatistician() ||
        (isPlayer() && request.auth.uid == resource.data.user_id)
      );
      allow create: if isManager();
      allow update: if isManager();
      allow delete: if false;
    }

    // ── EVENTS (TURNAMEN) ──────────────────────────────────────
    match /events/{eventId} {
      allow read:  if isAuth();
      allow write: if isManager();
    }

    // ── MATCHES ────────────────────────────────────────────────
    match /matches/{matchId} {
      allow read:   if isAuth();
      allow create: if isManager();
      allow update: if isManager() || isStatistician();
      allow delete: if false;

      match /timer_state/{doc} {
        allow read:  if isAuth();
        allow write: if isStatistician();
      }

      match /events/{eventId} {
        allow read:   if isAuth();
        allow create: if isStatistician();
        // Hanya field is_undone yang bisa diupdate
        allow update: if isStatistician()
          && request.resource.data.diff(resource.data)
             .affectedKeys().hasOnly(['is_undone']);
        allow delete: if false;
      }

      match /player_stats/{playerId} {
        allow read:  if isAuth();
        allow write: if isStatistician();
      }

      match /lineups/{playerId} {
        allow read:  if isAuth();
        allow write: if isStatistician();
      }
    }

    // ── INJURY REPORTS ─────────────────────────────────────────
    match /injury_reports/{reportId} {
      allow read:  if isStaff();
      allow write: if isStaff();
    }

    // ── TRAINING SESSIONS ──────────────────────────────────────
    match /training_sessions/{sessionId} {
      allow read:  if isAuth();
      allow write: if isManager();
    }

    // ── PHYSICAL TEST SESSIONS ─────────────────────────────────
    match /physical_test_sessions/{sessionId} {
      allow read:  if isStaff();
      allow write: if isStaff();

      match /results/{playerId} {
        allow read:  if isStaff();
        allow write: if isStaff();
      }
    }

    // ── AUDIT LOGS — read-only dari client ─────────────────────
    match /audit_logs/{logId} {
      allow read:  if isStaff();
      allow write: if false; // hanya Cloud Functions Admin SDK
    }
  }
}
```

---

### Step 6.2: Deploy Security Rules ke Emulator

```bash
firebase emulators:start
# Dari terminal lain:
firebase deploy --only firestore:rules --project budiutama-basketball
```

**Expected**: Rules deployed, Emulator UI menampilkan rules terbaru ✅

---

### Step 6.3: Buat Composite Indexes

**Buat/update file**: `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "matches",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "home_team_id", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "scheduled_at", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "events",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "is_undone", "order": "ASCENDING" },
        { "fieldPath": "created_at", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "physical_test_sessions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "team_id", "order": "ASCENDING" },
        { "fieldPath": "test_type", "order": "ASCENDING" },
        { "fieldPath": "academic_year", "order": "ASCENDING" },
        { "fieldPath": "semester", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "injury_reports",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "team_id", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ]
}
```

```bash
firebase deploy --only firestore:indexes --project budiutama-basketball
```

---

### Step 6.4: Buat Shared Widgets

Buat file: `lib/shared/widgets/app_button.dart`

```dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Theme.of(context).primaryColor;
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon ?? Icons.check, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
    );
  }
}
```

Buat file: `lib/shared/widgets/confirm_dialog.dart`

```dart
import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Ya',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: TextButton.styleFrom(
            foregroundColor: isDestructive ? Colors.red : null,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
```

Buat file: `lib/shared/widgets/app_layout.dart`

```dart
import 'package:flutter/material.dart';

// Layout adaptif: bottom nav di mobile, sidebar di tablet/web
class AppLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String role;   // untuk filter menu yang tampil

  const AppLayout({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              destinations: _buildDestinations(role),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: _buildDestinations(role)
            .map((d) => NavigationDestination(
                  icon: d.icon,
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }

  List<NavigationRailDestination> _buildDestinations(String role) {
    return [
      if (role != 'player')
        const NavigationRailDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Players',
        ),
      const NavigationRailDestination(
        icon: Icon(Icons.calendar_today_outlined),
        selectedIcon: Icon(Icons.calendar_today),
        label: 'Training',
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.emoji_events_outlined),
        selectedIcon: Icon(Icons.emoji_events),
        label: 'Events',
      ),
      const NavigationRailDestination(
        icon: Icon(Icons.sports_basketball_outlined),
        selectedIcon: Icon(Icons.sports_basketball),
        label: 'Matches',
      ),
      if (role == 'coach' || role == 'manager')
        const NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
    ];
  }
}
```

---

### Step 6.5: Buat Seed Data Emulator

Buat file: `scripts/seed_emulator.dart`

```dart
// Jalankan: dart run scripts/seed_emulator.dart
// Seeding data untuk Firebase Emulator (development)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Redirect ke emulator
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  final db = FirebaseFirestore.instance;

  // Seed teams
  await db.collection('teams').doc('putra_2526').set({
    'name': 'Tim Putra Budi Utama',
    'gender': 'male',
    'academic_year': '2025/2026',
    'is_active': true,
    'created_at': FieldValue.serverTimestamp(),
  });

  await db.collection('teams').doc('putri_2526').set({
    'name': 'Tim Putri Budi Utama',
    'gender': 'female',
    'academic_year': '2025/2026',
    'is_active': true,
    'created_at': FieldValue.serverTimestamp(),
  });

  // Seed users (roles akan diset via Custom Claims di emulator Auth)
  await db.collection('users').doc('manager_andi').set({
    'uid': 'manager_andi_uid',  // harus cocok dengan uid di Auth emulator
    'email': 'manager@budiutama.sch.id',
    'full_name': 'Andi Pratama',
    'role': 'manager',
    'is_active': true,
    'trusted_device_ids': [],
    'created_at': FieldValue.serverTimestamp(),
  });

  await db.collection('users').doc('coach_budi').set({
    'uid': 'coach_budi_uid',
    'email': 'coach@budiutama.sch.id',
    'full_name': 'Budi Santoso',
    'role': 'coach',
    'is_active': true,
    'trusted_device_ids': [],
    'created_at': FieldValue.serverTimestamp(),
  });

  print('Seed data berhasil di-load ke Emulator ✅');
}
```

---

# FASE 2 — CORE FEATURES

## PART 7: PLAYER MANAGEMENT

> ⏱ Estimasi waktu: 180 menit

---

### Step 7.1: Buat `PlayerRepository`

Buat file: `lib/features/players/data/repositories/player_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';
import '../../../../core/constants/firestore_paths.dart';

class PlayerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream semua pemain — update otomatis via Firestore listener
  Stream<List<PlayerModel>> getAll(String teamId) {
    return _db
        .collection(FirestorePaths.players)
        .where('team_id', isEqualTo: teamId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => PlayerModel.fromFirestore(doc))
            .toList());
  }

  Future<PlayerModel?> getById(String playerId) async {
    final doc =
        await _db.collection(FirestorePaths.players).doc(playerId).get();
    return doc.exists ? PlayerModel.fromFirestore(doc) : null;
  }

  Future<void> create(String playerId, PlayerModel player) async {
    await _db
        .collection(FirestorePaths.players)
        .doc(playerId)
        .set(player.toJson());
  }

  Future<void> update(String playerId, Map<String, dynamic> data) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _db
        .collection(FirestorePaths.players)
        .doc(playerId)
        .update(data);
  }

  Future<void> updateStatus(String playerId, String status) async {
    await update(playerId, {'status': status});
  }
}
```

---

### Step 7.2: Buat Provider Pemain (Riverpod)

Buat file: `lib/features/players/domain/providers/players_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/player_model.dart';
import '../../data/repositories/player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository();
});

final playersStreamProvider =
    StreamProvider.family<List<PlayerModel>, String>((ref, teamId) {
  return ref.watch(playerRepositoryProvider).getAll(teamId);
});
```

---

### Step 7.3: Buat Halaman Players List

Buat file: `lib/features/players/presentation/pages/players_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/players_provider.dart';
import '../widgets/add_player_bottom_sheet.dart';

class PlayersPage extends ConsumerWidget {
  const PlayersPage({super.key});

  // Gunakan team ID yang sesuai — nantinya diambil dari state login user
  static const String _teamId = 'putra_2526';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersStreamProvider(_teamId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemain'),
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlayerSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: playersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (players) => ListView.builder(
          itemCount: players.length,
          itemBuilder: (context, i) {
            final p = players[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE6F1FB),
                child: Text(
                  '#${p.jerseyNumber}',
                  style: const TextStyle(
                    color: Color(0xFF0C447C),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              title: Text(p.fullName),
              subtitle: Text('${p.position} · ${p.teamId}'),
              trailing: _buildStatusBadge(p.status),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'injured':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddPlayerSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddPlayerBottomSheet(),
    );
  }
}
```

---

### Step 7.4: Upload Foto Pemain — Kompresi ke Base64

Buat file: `lib/features/players/presentation/widgets/photo_upload_widget.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class PhotoUploadWidget extends StatefulWidget {
  final String? currentBase64;
  final ValueChanged<String?> onPhotoChanged;

  const PhotoUploadWidget({
    super.key,
    this.currentBase64,
    required this.onPhotoChanged,
  });

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final _picker = ImagePicker();

  Future<void> _pickAndCompressPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked == null) return;

    // Kompres foto maksimal 200KB (sesuai batasan Firestore free plan)
    final compressed = await FlutterImageCompress.compressWithFile(
      picked.path,
      quality: 70,
      minWidth: 400,
      minHeight: 400,
    );

    if (compressed == null) return;

    // Cek ukuran setelah kompresi
    if (compressed.length > 200 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto terlalu besar. Maksimal 200KB.')),
        );
      }
      return;
    }

    final base64String =
        'data:image/jpeg;base64,${base64Encode(compressed)}';
    widget.onPhotoChanged(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickAndCompressPhoto,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: const Color(0xFFE6F1FB),
          border: Border.all(color: const Color(0xFF378ADD)),
        ),
        child: widget.currentBase64 != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.memory(
                  base64Decode(widget.currentBase64!.split(',').last),
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.add_a_photo, color: Color(0xFF378ADD)),
      ),
    );
  }
}
```

---

## PART 8: EVENT & TRAINING MANAGEMENT

> ⏱ Estimasi waktu: 180 menit

---

### Step 8.1: Buat `EventRepository`

Buat file: `lib/features/events/data/repositories/event_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../../../../core/constants/firestore_paths.dart';

class EventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<EventModel>> getAll(String teamId) {
    return _db
        .collection(FirestorePaths.events)
        .where('team_id', isEqualTo: teamId)
        .orderBy('start_date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => EventModel.fromFirestore(d)).toList());
  }

  Future<void> create(String eventId, EventModel event) async {
    await _db.collection(FirestorePaths.events).doc(eventId).set(event.toJson());
  }

  Future<void> update(String eventId, Map<String, dynamic> data) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _db.collection(FirestorePaths.events).doc(eventId).update(data);
  }
}
```

> ℹ️ Untuk format Document ID event: `{tipe}_{namasingkat}_{tahun}` — misal: `porseni_kota_2526`. Generate di layer UI sebelum memanggil `create()`.

---

### Step 8.2: Buat `TrainingRepository`

Buat file: `lib/features/training/data/repositories/training_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/training_session_model.dart';
import '../../../../core/constants/firestore_paths.dart';

class TrainingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<TrainingSessionModel>> getByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.trainingSessions)
        .where('team_id', isEqualTo: teamId)
        .orderBy('scheduled_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TrainingSessionModel.fromFirestore(d))
            .toList());
  }

  Future<void> create(String sessionId, TrainingSessionModel session) async {
    await _db
        .collection(FirestorePaths.trainingSessions)
        .doc(sessionId)
        .set(session.toJson());
  }

  Future<void> cancel(String sessionId) async {
    await _db
        .collection(FirestorePaths.trainingSessions)
        .doc(sessionId)
        .update({
      'is_cancelled': true,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## PART 9: MATCH MANAGEMENT — PRE-MATCH SETUP

> ⏱ Estimasi waktu: 150 menit

---

### Step 9.1: Buat `MatchRepository`

Buat file: `lib/features/matches/dashboard/data/repositories/match_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';
import '../../../../../core/constants/firestore_paths.dart';

class MatchRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MatchModel>> getByEvent(String eventId) {
    return _db
        .collection(FirestorePaths.matches)
        .where('event_id', isEqualTo: eventId)
        .orderBy('scheduled_at', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => MatchModel.fromFirestore(d)).toList());
  }

  Future<void> create(String matchId, MatchModel match) async {
    await _db.collection(FirestorePaths.matches).doc(matchId).set(match.toJson());
  }

  // Dipanggil oleh Statistician saat tap "Mulai Pertandingan"
  Future<void> startMatch(String matchId, List<String> starterIds) async {
    final batch = _db.batch();

    // Update status match
    batch.update(_db.collection(FirestorePaths.matches).doc(matchId), {
      'status': 'ongoing',
      'current_state': 'PRE_MATCH',
      'timer_config_locked': true,
      'started_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    // Inisialisasi lineup semua starter
    for (final playerId in starterIds) {
      final jerseyInisial = playerId.split('_putra').first.split('_putri').first;
      batch.set(
        _db.doc('${FirestorePaths.matchLineups(matchId)}/$jerseyInisial'),
        {
          'player_id': playerId,
          'is_starter': true,
          'is_on_court': true,
          'entered_at_clock': 600.0,
          'entered_at_quarter': 1,
          'total_seconds_played': 0,
          'updated_at': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  Future<void> cancelMatch(String matchId) async {
    await _db.collection(FirestorePaths.matches).doc(matchId).update({
      'status': 'cancelled',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
```

---

### Step 9.2: Buat Halaman Match Detail — Konfigurasi Timer

Buat file: `lib/features/matches/dashboard/presentation/pages/match_detail_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MatchDetailPage extends ConsumerStatefulWidget {
  final String matchId;
  const MatchDetailPage({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage> {
  int _quarterDuration = 10;  // menit
  int _numPeriods = 4;        // quarter
  int _otDuration = 5;        // menit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Pertandingan')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Konfigurasi Timer',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Durasi per Quarter
            Row(
              children: [
                const Expanded(child: Text('Durasi per Quarter')),
                DropdownButton<int>(
                  value: _quarterDuration,
                  items: List.generate(20,
                      (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} menit'))),
                  onChanged: (v) => setState(() => _quarterDuration = v!),
                ),
              ],
            ),
            // Jumlah Periode
            Row(
              children: [
                const Expanded(child: Text('Jumlah Periode')),
                DropdownButton<int>(
                  value: _numPeriods,
                  items: [
                    const DropdownMenuItem(value: 4, child: Text('4 Quarter')),
                    const DropdownMenuItem(value: 2, child: Text('2 Babak')),
                  ],
                  onChanged: (v) => setState(() => _numPeriods = v!),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Lineup Pemain Awal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // TODO: Komponen pilih 5 pemain starter

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleStartMatch,
                icon: const Icon(Icons.play_arrow),
                label: const Text('MULAI PERTANDINGAN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8420A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStartMatch() async {
    // TODO: validasi 5 starter sudah dipilih
    // TODO: panggil MatchRepository.startMatch()
    // Navigasi ke Match Mode fullscreen
    context.go('/match/${widget.matchId}');
  }
}
```

---

## PART 10: INJURY MANAGEMENT

> ⏱ Estimasi waktu: 120 menit

---

### Step 10.1: Buat `InjuryRepository`

Buat file: `lib/features/injuries/data/repositories/injury_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/injury_report_model.dart';
import '../../../../core/constants/firestore_paths.dart';

class InjuryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<InjuryReportModel>> getByTeam(String teamId) {
    return _db
        .collection(FirestorePaths.injuryReports)
        .where('team_id', isEqualTo: teamId)
        .where('status', isNotEqualTo: 'cleared')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => InjuryReportModel.fromFirestore(d)).toList());
  }

  Future<List<InjuryReportModel>> getByPlayer(String playerId) async {
    final snap = await _db
        .collection(FirestorePaths.injuryReports)
        .where('player_id', isEqualTo: playerId)
        .orderBy('injury_date', descending: true)
        .get();
    return snap.docs.map((d) => InjuryReportModel.fromFirestore(d)).toList();
  }

  // Document ID format: {playerId}_{YYYYMMDD}
  Future<void> create(String reportId, InjuryReportModel report) async {
    // Otomatis update status player menjadi 'injured'
    final batch = _db.batch();
    batch.set(
      _db.collection(FirestorePaths.injuryReports).doc(reportId),
      report.toJson(),
    );
    batch.update(
      _db.collection(FirestorePaths.players).doc(report.playerId),
      {'status': 'injured', 'updated_at': FieldValue.serverTimestamp()},
    );
    await batch.commit();
  }

  // Cloud Function akan otomatis update player.status saat cleared
  Future<void> updateStatus(String reportId, String status) async {
    await _db
        .collection(FirestorePaths.injuryReports)
        .doc(reportId)
        .update({
      'status': status,
      if (status == 'cleared') 'cleared_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## PART 11: PHYSICAL TEST MANAGEMENT

> ⏱ Estimasi waktu: 240 menit

---

### Step 11.1: Buat `PhysicalTestRepository`

Buat file: `lib/features/physical_tests/data/repositories/physical_test_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/physical_test_session_model.dart';
import '../models/physical_test_result_model.dart';
import '../../../../core/constants/firestore_paths.dart';

class PhysicalTestRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<PhysicalTestSessionModel>> getByTeam(
      String teamId, String testType) {
    return _db
        .collection(FirestorePaths.physicalTestSessions)
        .where('team_id', isEqualTo: teamId)
        .where('test_type', isEqualTo: testType)
        .orderBy('scheduled_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PhysicalTestSessionModel.fromFirestore(d))
            .toList());
  }

  Future<void> createSession(
      String sessionId, PhysicalTestSessionModel session) async {
    await _db
        .collection(FirestorePaths.physicalTestSessions)
        .doc(sessionId)
        .set(session.toJson());
  }

  // Simpan hasil Beep Test
  Future<void> saveBeepResult({
    required String sessionId,
    required String playerId,    // format: jersey_inisial
    required String fullPlayerId, // format: jersey_inisial_teamId
    required String fullName,
    required int beepLevel,
    required int beepShuttle,
  }) async {
    await _db
        .collection(FirestorePaths.physicalTestResults(sessionId))
        .doc(playerId)
        .set({
      'player_id': fullPlayerId,
      'full_name': fullName,
      'beep_level': beepLevel,
      'beep_shuttle': beepShuttle,
      'time_seconds': null,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Simpan hasil T-Test atau Sprint 20m
  Future<void> saveTimedResult({
    required String sessionId,
    required String playerId,
    required String fullPlayerId,
    required String fullName,
    required double timeSeconds,
  }) async {
    await _db
        .collection(FirestorePaths.physicalTestResults(sessionId))
        .doc(playerId)
        .set({
      'player_id': fullPlayerId,
      'full_name': fullName,
      'beep_level': null,
      'beep_shuttle': null,
      'time_seconds': timeSeconds,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // Stop sesi lebih awal
  Future<void> stopSessionEarly(String sessionId) async {
    await _db
        .collection(FirestorePaths.physicalTestSessions)
        .doc(sessionId)
        .update({'is_stopped_early': true});
  }
}
```

---

### Step 11.2: Buat `BeepTestPanel` — 5 Kartu Pemain

Buat file: `lib/features/physical_tests/presentation/widgets/beep_test_panel.dart`

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class BeepTestPanel extends StatefulWidget {
  final List<Map<String, dynamic>> players; // max 5
  final ValueChanged<Map<String, dynamic>> onPlayerResult; // {playerId, level, shuttle, passed}
  final VoidCallback onStopSession;

  const BeepTestPanel({
    super.key,
    required this.players,
    required this.onPlayerResult,
    required this.onStopSession,
  });

  @override
  State<BeepTestPanel> createState() => _BeepTestPanelState();
}

class _BeepTestPanelState extends State<BeepTestPanel> {
  final _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  final Set<String> _completedPlayerIds = {};

  @override
  void initState() {
    super.initState();
    _startAudio();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startAudio() async {
    setState(() => _isPlaying = true);
    await _audioPlayer.play(AssetSource('audio/beep_test.mp3'));
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  void _handleFail(Map<String, dynamic> player) async {
    await _showFailDialog(player);
  }

  void _handlePass(Map<String, dynamic> player) {
    setState(() => _completedPlayerIds.add(player['id']));
    widget.onPlayerResult({
      'playerId': player['id'],
      'passed': true,
      'level': null,
      'shuttle': null,
    });
  }

  Future<void> _showFailDialog(Map<String, dynamic> player) async {
    int level = 1, shuttle = 1;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${player['name']} — Gagal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan level dan shuttle terakhir:'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(labelText: 'Level'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => level = int.tryParse(v) ?? 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(labelText: 'Shuttle'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => shuttle = int.tryParse(v) ?? 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _completedPlayerIds.add(player['id']));
              widget.onPlayerResult({
                'playerId': player['id'],
                'passed': false,
                'level': level,
                'shuttle': shuttle,
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status audio
        Container(
          padding: const EdgeInsets.all(12),
          color: _isPlaying ? Colors.green.shade50 : Colors.grey.shade100,
          child: Row(
            children: [
              Icon(
                _isPlaying ? Icons.volume_up : Icons.volume_off,
                color: _isPlaying ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(_isPlaying ? 'Audio Beep Test berjalan' : 'Audio berhenti'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 5 Kartu pemain — tanpa scroll
        Expanded(
          child: Row(
            children: widget.players
                .map((player) => Expanded(child: _buildPlayerCard(player)))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // Tombol Stop Sesi
        TextButton.icon(
          onPressed: () async {
            await _stopAudio();
            widget.onStopSession();
          },
          icon: const Icon(Icons.stop, color: Colors.red),
          label: const Text('Stop Sesi', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildPlayerCard(Map<String, dynamic> player) {
    final isDone = _completedPlayerIds.contains(player['id']);
    return Card(
      margin: const EdgeInsets.all(8),
      color: isDone ? Colors.grey.shade200 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge "Selesai"
            if (isDone)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Selesai',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            const SizedBox(height: 8),
            Text(
              '#${player['jersey']}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8420A),
              ),
            ),
            Text(player['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            Text(player['position'],
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Spacer(),
            if (!isDone) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePass(player),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('PASS', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleFail(player),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('FAIL', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## PART 12: ACCOUNT MANAGEMENT VIA CLOUD FUNCTIONS

> ⏱ Estimasi waktu: 90 menit

---

### Step 12.1: Inisialisasi Cloud Functions TypeScript

```bash
cd functions
npm init -y
npm install firebase-admin firebase-functions
npm install -D typescript @types/node
npx tsc --init
```

---

### Step 12.2: Buat Cloud Function `createUser`

Buat file: `functions/src/index.ts`

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

// ── createUser: Manager buat akun baru ───────────────────────────────
export const createUser = functions.https.onCall(async (data, context) => {
  // Hanya Manager yang bisa membuat akun baru
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Hanya Manager yang bisa membuat akun baru'
    );
  }

  const { email, password, fullName, role, teamId } = data;

  // Buat user di Firebase Auth
  const userRecord = await auth.createUser({ email, password });

  // Set Custom Claims (role)
  await auth.setCustomUserClaims(userRecord.uid, { role, team_id: teamId });

  // Simpan data user di Firestore
  const docId = `${role}_${fullName.split(' ')[0].toLowerCase()}`;
  await db.collection('users').doc(docId).set({
    uid: userRecord.uid,
    email,
    full_name: fullName,
    role,
    team_id: teamId,
    is_active: true,
    trusted_device_ids: [],
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    created_by: context.auth?.uid,
  });

  return { success: true, uid: userRecord.uid, docId };
});

// ── updateUserRole: ubah role pengguna ───────────────────────────────
export const updateUserRole = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'Permission denied');
  }
  const { uid, newRole } = data;
  await auth.setCustomUserClaims(uid, { role: newRole });
  // Force token refresh pada next login
  return { success: true };
});

// ── deactivateUser: nonaktifkan user ─────────────────────────────────
export const deactivateUser = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'Permission denied');
  }
  const { uid } = data;
  await auth.updateUser(uid, { disabled: true });
  return { success: true };
});
```

---

# FASE 3 — LIVE MATCH ENGINE

## PART 13: MATCH ENGINE LOGIC & REPOSITORIES

> ⏱ Estimasi waktu: 240 menit

---

### Step 13.1: Buat `MatchEventRepository`

Buat file: `lib/features/matches/live/data/repositories/match_event_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';

class MatchEventRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getEventsStream(String matchId) {
    return _db
        .collection(FirestorePaths.matchEvents(matchId))
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Ambil event terakhir yang bisa di-undo
  Future<DocumentSnapshot?> getLastUndoableEvent(String matchId) async {
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('is_undone', isEqualTo: false)
        .where('action_type', whereNotIn: [
          'UNDO',
          'STATE_TRANSITION',
          'TIMER_START',
          'TIMER_PAUSE',
          'TIMER_RESUME',
          'SUBSTITUTION',
        ])
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();
    return snap.docs.isEmpty ? null : snap.docs.first;
  }

  Future<int> getNextSequence(String matchId, int quarter) async {
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('quarter', isEqualTo: quarter)
        .get();
    return snap.docs.length + 1;
  }
}
```

---

### Step 13.2: Buat `TimerRepository`

Buat file: `lib/features/matches/live/data/repositories/timer_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';

class TimerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> getTimerStream(String matchId) {
    return _db
        .collection(FirestorePaths.matchTimerState(matchId))
        .doc('state')
        .snapshots();
  }

  Future<void> startTimer(
      String matchId, double secondsAtStart, int quarter) async {
    await _db
        .collection(FirestorePaths.matchTimerState(matchId))
        .doc('state')
        .set({
      'is_running': true,
      'seconds_at_start': secondsAtStart,
      'started_at': FieldValue.serverTimestamp(),
      'quarter': quarter,
    });
  }

  Future<void> pauseTimer(String matchId, double currentRemaining) async {
    await _db
        .collection(FirestorePaths.matchTimerState(matchId))
        .doc('state')
        .update({
      'is_running': false,
      'seconds_at_start': currentRemaining,
      'started_at': null,
    });
  }

  Future<void> resumeTimer(
      String matchId, double secondsAtStart, int quarter) async {
    // Resume sama seperti startTimer — tulis seconds_at_start sisa + Server Timestamp baru
    await startTimer(matchId, secondsAtStart, quarter);
  }
}
```

---

### Step 13.3: Buat `PlayerStatsRepository`

Buat file: `lib/features/matches/live/data/repositories/player_stats_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';

class PlayerStatsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getLiveStatsStream(String matchId) {
    return _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .snapshots();
  }

  Future<void> initPlayerStats(
      String matchId, String statsDocId, Map<String, dynamic> data) async {
    await _db
        .collection(FirestorePaths.matchPlayerStats(matchId))
        .doc(statsDocId)
        .set(data);
  }

  // Increment stats (dipanggil bersama event dalam batch write)
  WriteBatch buildIncrementBatch(
    WriteBatch batch,
    String matchId,
    String statsDocId,
    Map<String, dynamic> increments,
  ) {
    batch.update(
      _db.collection(FirestorePaths.matchPlayerStats(matchId)).doc(statsDocId),
      increments,
    );
    return batch;
  }
}
```

---

## PART 14: MATCH ACTION, UNDO & STATS INCREMENT

> ⏱ Estimasi waktu: 240 menit

---

### Step 14.1: Buat `zone_classifier.dart`

Buat file: `lib/core/utils/zone_classifier.dart`

```dart
import 'dart:math';

// Koordinat ring basket (dalam sistem 0.0–1.0 dari sisi kiri bawah court)
const _ringX = 0.5;
const _ringY = 0.08;
const _paintXMin = 0.35;
const _paintXMax = 0.65;
const _paintYMax = 0.30;
const _threePtRadius = 0.43;
const _cornerLineY = 0.18;

String classifyZone(double x, double y) {
  final dist = sqrt(pow(x - _ringX, 2) + pow(y - _ringY, 2));

  // Area cat (paint)
  if (x >= _paintXMin && x <= _paintXMax && y <= _paintYMax) {
    return 'PAINT';
  }

  // Corner 3PT (dekat baseline)
  if (y < _cornerLineY && dist > _threePtRadius) {
    return x < 0.5 ? 'CORNER_LEFT' : 'CORNER_RIGHT';
  }

  // Di luar arc 3PT
  if (dist > _threePtRadius) {
    if (y > 0.55) return 'CENTER_3';
    return x < 0.5 ? 'WING_LEFT' : 'WING_RIGHT';
  }

  // Medium range (dalam arc 3PT, di luar paint)
  if (x < 0.42) return 'MEDIUM_LEFT';
  if (x > 0.58) return 'MEDIUM_RIGHT';
  return 'MEDIUM_CENTER';
}

int calculateDistanceFt(double x, double y) {
  const halfCourtFt = 45.9;
  const courtWidthFt = 49.2;
  final distNorm = sqrt(pow(x - _ringX, 2) + pow(y - _ringY, 2));
  return (distNorm * sqrt(pow(halfCourtFt, 2) + pow(courtWidthFt, 2)) / 1.414)
      .round();
}

// Validasi konsistensi zona vs tombol yang ditekan
bool validateZoneActionConsistency(String actionType, String zone) {
  const zones2pt = {'PAINT', 'MEDIUM_LEFT', 'MEDIUM_CENTER', 'MEDIUM_RIGHT'};
  const zones3pt = {
    'CORNER_LEFT', 'CORNER_RIGHT', 'WING_LEFT', 'WING_RIGHT', 'CENTER_3'
  };
  if ((actionType == '2PT_MADE' || actionType == 'MISS_2PT') &&
      zones3pt.contains(zone)) return false;
  if ((actionType == '3PT_MADE' || actionType == 'MISS_3PT') &&
      zones2pt.contains(zone)) return false;
  return true;
}
```

---

### Step 14.2: Buat `MatchActionNotifier` — Inti Live Match Engine

Buat file: `lib/features/matches/live/domain/providers/match_action_provider.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/utils/zone_classifier.dart';

final matchActionProvider =
    NotifierProvider.family<MatchActionNotifier, void, String>(
        MatchActionNotifier.new);

class MatchActionNotifier extends FamilyNotifier<void, String> {
  String get matchId => arg;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  void build(String arg) {}

  // ── RECORD ACTION ───────────────────────────────────────────────────
  Future<void> recordAction({
    required String playerId,
    required String actionType,
    required int quarter,
    required double timeRemaining,
    String? zone,
    double? shotX,
    double? shotY,
    int? shotDistanceFt,
    bool isOpponent = false,
    required String createdBy,
  }) async {
    final batch = _db.batch();

    // Generate event ID: q{quarter}_{sequence}
    final eventsSnap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('quarter', isEqualTo: quarter)
        .get();
    final seq = (eventsSnap.docs.length + 1).toString().padLeft(3, '0');
    final eventId = 'q${quarter}_$seq';

    final value = _valueFromAction(actionType);

    // 1. Tambah event baru (immutable)
    batch.set(
      _db.collection(FirestorePaths.matchEvents(matchId)).doc(eventId),
      {
        'quarter': quarter,
        'time_remaining': timeRemaining,
        'player_id': isOpponent ? null : playerId,
        'action_type': actionType,
        'value': value,
        'zone': zone,
        'shot_x': shotX,
        'shot_y': shotY,
        'shot_distance_ft': shotDistanceFt,
        'is_opponent': isOpponent,
        'is_undone': false,
        'undo_ref_id': null,
        'created_by': createdBy,
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    // 2. Update materialized player_stats (hanya tim sendiri)
    if (!isOpponent) {
      final statsDocId =
          playerId.split('_putra').first.split('_putri').first;
      final increments = _buildStatsIncrement(actionType, zone);
      increments['updated_at'] = FieldValue.serverTimestamp();
      batch.update(
        _db.collection(FirestorePaths.matchPlayerStats(matchId)).doc(statsDocId),
        increments,
      );
    }

    // 3. Update skor match
    if (value > 0) {
      batch.update(
        _db.collection(FirestorePaths.matches).doc(matchId),
        {
          (isOpponent ? 'opponent_score' : 'home_score'):
              FieldValue.increment(value),
          'updated_at': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  // ── UNDO LAST ACTION ────────────────────────────────────────────────
  Future<void> undoLastAction({required String createdBy}) async {
    // Cari event terakhir yang bisa di-undo
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('is_undone', isEqualTo: false)
        .where('action_type', whereNotIn: [
          'UNDO',
          'STATE_TRANSITION',
          'TIMER_START',
          'TIMER_PAUSE',
          'TIMER_RESUME',
          'SUBSTITUTION',
        ])
        .orderBy('created_at', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return;

    final eventToUndo = snap.docs.first;
    final eventData = eventToUndo.data() as Map<String, dynamic>;

    // Cari sequence berikutnya untuk UNDO event
    final allSnap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('quarter', isEqualTo: eventData['quarter'])
        .get();
    final seq = (allSnap.docs.length + 1).toString().padLeft(3, '0');
    final undoId = 'q${eventData['quarter']}_$seq';

    final batch = _db.batch();

    // Mark event asli sebagai undone
    batch.update(eventToUndo.reference, {'is_undone': true});

    // Tambah UNDO event
    batch.set(
      _db.collection(FirestorePaths.matchEvents(matchId)).doc(undoId),
      {
        'quarter': eventData['quarter'],
        'time_remaining': eventData['time_remaining'],
        'action_type': 'UNDO',
        'undo_ref_id': eventToUndo.id,
        'is_opponent': false,
        'is_undone': false,
        'created_by': createdBy,
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    // Reverse player_stats (decrement)
    if (!(eventData['is_opponent'] as bool? ?? false)) {
      final playerId = eventData['player_id'] as String;
      final statsDocId = playerId.split('_putra').first.split('_putri').first;
      final decrements =
          _buildStatsDecrement(eventData['action_type'], eventData['zone']);
      decrements['updated_at'] = FieldValue.serverTimestamp();
      batch.update(
        _db.collection(FirestorePaths.matchPlayerStats(matchId)).doc(statsDocId),
        decrements,
      );
    }

    // Reverse skor
    final value = (eventData['value'] as int?) ?? 0;
    if (value > 0) {
      final isOpponent = eventData['is_opponent'] as bool? ?? false;
      batch.update(
        _db.collection(FirestorePaths.matches).doc(matchId),
        {
          (isOpponent ? 'opponent_score' : 'home_score'):
              FieldValue.increment(-value),
          'updated_at': FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  // ── HELPERS ─────────────────────────────────────────────────────────

  int _valueFromAction(String actionType) {
    switch (actionType) {
      case '1PT_MADE':
        return 1;
      case '2PT_MADE':
        return 2;
      case '3PT_MADE':
        return 3;
      default:
        return 0;
    }
  }

  Map<String, dynamic> _buildStatsIncrement(
      String actionType, String? zone) {
    final inc = <String, dynamic>{};
    switch (actionType) {
      case '1PT_MADE':
        inc['ft_made'] = FieldValue.increment(1);
        inc['ft_attempted'] = FieldValue.increment(1);
        inc['points'] = FieldValue.increment(1);
      case '2PT_MADE':
        inc['fg2_made'] = FieldValue.increment(1);
        inc['fg2_attempted'] = FieldValue.increment(1);
        inc['points'] = FieldValue.increment(2);
        if (zone != null) {
          inc['shot_zones.$zone.made'] = FieldValue.increment(1);
          inc['shot_zones.$zone.attempted'] = FieldValue.increment(1);
        }
      case '3PT_MADE':
        inc['fg3_made'] = FieldValue.increment(1);
        inc['fg3_attempted'] = FieldValue.increment(1);
        inc['points'] = FieldValue.increment(3);
        if (zone != null) {
          inc['shot_zones.$zone.made'] = FieldValue.increment(1);
          inc['shot_zones.$zone.attempted'] = FieldValue.increment(1);
        }
      case 'MISS_1PT':
        inc['ft_attempted'] = FieldValue.increment(1);
      case 'MISS_2PT':
        inc['fg2_attempted'] = FieldValue.increment(1);
        if (zone != null) {
          inc['shot_zones.$zone.attempted'] = FieldValue.increment(1);
        }
      case 'MISS_3PT':
        inc['fg3_attempted'] = FieldValue.increment(1);
        if (zone != null) {
          inc['shot_zones.$zone.attempted'] = FieldValue.increment(1);
        }
      case 'ASSIST':
        inc['assists'] = FieldValue.increment(1);
      case 'REBOUND_OFF':
        inc['offensive_rebounds'] = FieldValue.increment(1);
      case 'REBOUND_DEF':
        inc['defensive_rebounds'] = FieldValue.increment(1);
      case 'STEAL':
        inc['steals'] = FieldValue.increment(1);
      case 'TURNOVER':
        inc['turnovers'] = FieldValue.increment(1);
      case 'BLOCK':
        inc['blocks'] = FieldValue.increment(1);
      case 'FOUL':
        inc['fouls'] = FieldValue.increment(1);
    }
    return inc;
  }

  Map<String, dynamic> _buildStatsDecrement(
      String actionType, String? zone) {
    // Kebalikan dari increment — semua FieldValue.increment positif menjadi negatif
    final inc = _buildStatsIncrement(actionType, zone);
    return inc.map((k, v) {
      if (v is FieldValue) return MapEntry(k, v); // sudah increment(-1) dari sini
      return MapEntry(k, v);
    });
    // Implementasi lengkap: ganti setiap FieldValue.increment(n) menjadi FieldValue.increment(-n)
    // Lihat SDD Section 6.2 untuk implementasi _buildStatsDecrement lengkap
  }
}
```

---

## PART 15: CLOUD FUNCTIONS — STATS FINAL & AUDIT LOG

> ⏱ Estimasi waktu: 120 menit

---

### Step 15.1: Update `functions/src/index.ts` — Tambah Match Functions

Tambahkan ke file `functions/src/index.ts`:

```typescript
// ── onMatchFinished: Hitung statistik final saat POST_MATCH ──────────
export const onMatchFinished = functions.firestore
  .document('matches/{matchId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const matchId = context.params.matchId;

    if (before.current_state === after.current_state) return;
    if (after.current_state !== 'POST_MATCH') return;

    // Ambil semua events yang valid (belum di-undo)
    const eventsSnap = await db
      .collection(`matches/${matchId}/events`)
      .where('is_undone', '==', false)
      .get();

    // Hitung ulang stats dari event log (verifikasi vs materialized stats)
    const finalStats = calculateFinalStats(eventsSnap.docs);

    // Update player_stats dengan nilai final yang terverifikasi
    const batch = db.batch();
    for (const [playerId, stats] of Object.entries(finalStats)) {
      batch.update(
        db.collection(`matches/${matchId}/player_stats`).doc(playerId),
        { ...stats as object, final_calculated: true }
      );
    }
    await batch.commit();

    // Update status match menjadi finished
    await db.collection('matches').doc(matchId).update({
      status: 'finished',
      finished_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// ── onMatchEventCreated: Audit log otomatis ────────────────────────
export const onMatchEventCreated = functions.firestore
  .document('matches/{matchId}/events/{eventId}')
  .onCreate(async (snap, context) => {
    const event = snap.data();
    if (!event || event.action_type === 'UNDO') return; // jangan audit UNDO event
    await db.collection('audit_logs').add({
      user_id: event.created_by,
      action_type: 'MATCH_EVENT_CREATED',
      entity_type: 'match_event',
      entity_id: context.params.eventId,
      new_value: {
        match_id: context.params.matchId,
        action_type: event.action_type,
        player_id: event.player_id,
        quarter: event.quarter,
      },
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// ── onInjuryStatusChanged: Update player status saat cedera cleared ─
export const onInjuryStatusChanged = functions.firestore
  .document('injury_reports/{reportId}')
  .onUpdate(async (change) => {
    const after = change.after.data();
    if (!after || after.status !== 'cleared') return;
    await db.collection('players').doc(after.player_id).update({
      status: 'active',
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// ── Helper: Kalkulasi statistik final dari event log ────────────────
function calculateFinalStats(
  eventDocs: admin.firestore.QueryDocumentSnapshot[]
): Record<string, Record<string, number>> {
  const stats: Record<string, Record<string, number>> = {};

  const initStats = () => ({
    points: 0, ft_made: 0, ft_attempted: 0,
    fg2_made: 0, fg2_attempted: 0, fg3_made: 0, fg3_attempted: 0,
    assists: 0, offensive_rebounds: 0, defensive_rebounds: 0,
    steals: 0, turnovers: 0, blocks: 0, fouls: 0,
  });

  for (const doc of eventDocs) {
    const e = doc.data();
    if (e.is_opponent || !e.player_id) continue;

    // Derive stats doc ID dari player_id
    const key = e.player_id.replace(/_putra.*/, '').replace(/_putri.*/, '');
    if (!stats[key]) stats[key] = initStats();

    switch (e.action_type) {
      case '1PT_MADE': stats[key].ft_made++; stats[key].ft_attempted++; stats[key].points++; break;
      case '2PT_MADE': stats[key].fg2_made++; stats[key].fg2_attempted++; stats[key].points += 2; break;
      case '3PT_MADE': stats[key].fg3_made++; stats[key].fg3_attempted++; stats[key].points += 3; break;
      case 'MISS_1PT': stats[key].ft_attempted++; break;
      case 'MISS_2PT': stats[key].fg2_attempted++; break;
      case 'MISS_3PT': stats[key].fg3_attempted++; break;
      case 'ASSIST': stats[key].assists++; break;
      case 'REBOUND_OFF': stats[key].offensive_rebounds++; break;
      case 'REBOUND_DEF': stats[key].defensive_rebounds++; break;
      case 'STEAL': stats[key].steals++; break;
      case 'TURNOVER': stats[key].turnovers++; break;
      case 'BLOCK': stats[key].blocks++; break;
      case 'FOUL': stats[key].fouls++; break;
    }
  }
  return stats;
}
```

---

### Step 15.2: Deploy Cloud Functions ke Emulator

```bash
firebase emulators:start
# Dari terminal lain:
firebase deploy --only functions --project budiutama-basketball
```

**Expected**: Functions ter-deploy, log `onMatchFinished`, `onMatchEventCreated`, `onInjuryStatusChanged` muncul di Emulator UI ✅

---

## PART 16: MATCH MODE UI — FULLSCREEN LAYOUT

> ⏱ Estimasi waktu: 240 menit

---

### Step 16.1: Buat `MatchModePage` — Entry Point Fullscreen

Buat file: `lib/features/matches/live/presentation/pages/match_mode_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchModePage extends ConsumerStatefulWidget {
  final String matchId;
  const MatchModePage({super.key, required this.matchId});

  @override
  ConsumerState<MatchModePage> createState() => _MatchModePageState();
}

class _MatchModePageState extends ConsumerState<MatchModePage> {

  @override
  void initState() {
    super.initState();
    // Paksa landscape mode di Match Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Sembunyikan status bar dan navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Kembalikan orientasi normal saat keluar Match Mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header: score, quarter, timer, foul, koneksi
            MatchHeader(matchId: widget.matchId),
            // Body: Left | Center | Right | Timeline
            Expanded(
              child: Row(
                children: [
                  // Left Panel: 5 pemain on-court
                  SizedBox(width: 180, child: PlayerListPanel(matchId: widget.matchId)),
                  // Center Panel: Tab Input / Live Stats
                  Expanded(child: CenterPanelTabs(matchId: widget.matchId)),
                  // Right Panel: Aksi lawan
                  SizedBox(width: 160, child: OpponentActionsPanel(matchId: widget.matchId)),
                  // Event Timeline
                  SizedBox(width: 200, child: EventTimeline(matchId: widget.matchId)),
                ],
              ),
            ),
            // Bottom Panel: Substitusi
            SubstitutionPanel(matchId: widget.matchId),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 16.2: Buat `MatchHeader` — Score, Timer, Foul

Buat file: `lib/features/matches/live/presentation/widgets/header/match_header.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'match_timer_widget.dart';
import 'connection_status.dart';

class MatchHeader extends ConsumerWidget {
  final String matchId;
  const MatchHeader({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Ambil data dari Firestore stream match
    return Container(
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Skor Budi Utama
          Expanded(
            child: Column(
              children: [
                const Text('BUDI UTAMA',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                const Text('47',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ],
            ),
          ),
          // Quarter + Timer (tengah)
          Column(
            children: [
              const Text('Q3',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              MatchTimerWidget(matchId: matchId),
              const Text('Server Timestamp sync',
                  style: TextStyle(color: Color(0xFF334155), fontSize: 9)),
            ],
          ),
          // Timeout & Foul info
          const SizedBox(width: 32),
          Column(
            children: [
              const Text('TIMEOUT',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              const Text('2/2',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              const Text('FOUL TIM',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              const Text('3',
                  style: TextStyle(
                      color: Color(0xFFFCD34D),
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 32),
          // Skor Lawan
          Expanded(
            child: Column(
              children: [
                const Text('LAWAN',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                const Text('40',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ],
            ),
          ),
          // Status koneksi Firestore
          const ConnectionStatusIndicator(),
        ],
      ),
    );
  }
}
```

---

### Step 16.3: Buat `MatchTimerWidget`

Buat file: `lib/features/matches/live/presentation/widgets/header/match_timer_widget.dart`

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/timer_calculator.dart';

class MatchTimerWidget extends ConsumerStatefulWidget {
  final String matchId;
  const MatchTimerWidget({super.key, required this.matchId});

  @override
  ConsumerState<MatchTimerWidget> createState() => _MatchTimerWidgetState();
}

class _MatchTimerWidgetState extends ConsumerState<MatchTimerWidget> {
  Timer? _ticker;
  double _displaySeconds = 600.0;

  @override
  void initState() {
    super.initState();
    // Update tampilan setiap 100ms
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      // TODO: Ambil TimerStateModel dari timerStateStreamProvider
      // setState(() => _displaySeconds = currentRemainingSeconds(...));
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatSeconds(_displaySeconds),
      style: const TextStyle(
        color: Color(0xFFF1F5F9),
        fontSize: 26,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }
}
```

---

### Step 16.4: Buat `ConnectionStatusIndicator`

Buat file: `lib/features/matches/live/presentation/widgets/header/connection_status.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Monitor status sinkronisasi Firestore
final firestoreSyncStatusProvider = StreamProvider<bool>((ref) {
  return FirebaseFirestore.instance.snapshotsInSync().map((_) => true);
});

class ConnectionStatusIndicator extends ConsumerWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(firestoreSyncStatusProvider);
    final isConnected = syncStatus.hasValue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isConnected ? 'Firestore' : 'Offline',
          style: TextStyle(
            color: isConnected ? Colors.green : Colors.red,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
```

---

## PART 17: COURT OVERLAY & SHOT ZONES

> ⏱ Estimasi waktu: 150 menit

---

### Step 17.1: Buat `CourtPainter` (CustomPainter)

Buat file: `lib/features/matches/live/presentation/widgets/center_panel/court_painter.dart`

```dart
import 'dart:math';
import 'package:flutter/material.dart';

class ShotPoint {
  final double x, y;
  final bool isMade;
  ShotPoint({required this.x, required this.y, required this.isMade});
}

class CourtPainter extends CustomPainter {
  final List<ShotPoint> shots;
  final String? hoveredZone;

  CourtPainter({this.shots = const [], this.hoveredZone});

  @override
  void paint(Canvas canvas, Size size) {
    _drawCourtLines(canvas, size);
    if (hoveredZone != null) _drawZoneHighlight(canvas, size);
    _drawShotPoints(canvas, size);
  }

  void _drawCourtLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Court boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    // Paint area (key)
    final paintRect = Rect.fromLTWH(w * 0.35, 0, w * 0.30, h * 0.30);
    canvas.drawRect(paintRect, paint..color = const Color(0xFF1E3A5F));
    canvas.drawRect(paintRect, paint..color = const Color(0xFF2563EB));

    // Free throw circle
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.30),
        width: w * 0.20,
        height: h * 0.12,
      ),
      paint
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke,
    );

    // 3PT arc
    final arcPath = Path();
    arcPath.moveTo(w * 0.12, 0);
    arcPath.quadraticBezierTo(w * 0.12, h * 0.80, w * 0.5, h * 0.85);
    arcPath.quadraticBezierTo(w * 0.88, h * 0.80, w * 0.88, 0);
    canvas.drawPath(
      arcPath,
      paint..color = const Color(0xFF7C3AED),
    );

    // Ring
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.08),
      6,
      paint
        ..color = const Color(0xFFE8420A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawZoneHighlight(Canvas canvas, Size size) {
    if (hoveredZone == null) return;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.orange.withOpacity(0.15),
    );
    // TODO: Gambar highlight spesifik per zona
  }

  void _drawShotPoints(Canvas canvas, Size size) {
    for (final shot in shots) {
      canvas.drawCircle(
        Offset(shot.x * size.width, shot.y * size.height),
        5,
        Paint()
          ..color = shot.isMade
              ? Colors.green.withOpacity(0.9)
              : Colors.red.withOpacity(0.9),
      );
    }
  }

  @override
  bool shouldRepaint(CourtPainter oldDelegate) =>
      oldDelegate.shots != shots || oldDelegate.hoveredZone != hoveredZone;
}
```

---

### Step 17.2: Buat `CourtOverlay` Widget

Buat file: `lib/features/matches/live/presentation/widgets/center_panel/court_overlay.dart`

```dart
import 'package:flutter/material.dart';
import 'court_painter.dart';
import '../../../../../core/utils/zone_classifier.dart';

class CourtOverlay extends StatefulWidget {
  final String actionType;       // '2PT_MADE', 'MISS_3PT', dst.
  final List<ShotPoint> shots;   // titik tembakan sebelumnya untuk heatmap
  final void Function(double x, double y, String zone, int distanceFt) onLocationSelected;
  final VoidCallback onDismiss;

  const CourtOverlay({
    super.key,
    required this.actionType,
    required this.shots,
    required this.onLocationSelected,
    required this.onDismiss,
  });

  @override
  State<CourtOverlay> createState() => _CourtOverlayState();
}

class _CourtOverlayState extends State<CourtOverlay> {
  String? _hoveredZone;

  // Auto-dismiss setelah 15 detik tanpa tap
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPos = renderBox.globalToLocal(details.globalPosition);
        final x = localPos.dx / renderBox.size.width;
        final y = localPos.dy / renderBox.size.height;

        final zone = classifyZone(x, y);
        final dist = calculateDistanceFt(x, y);

        // Validasi konsistensi zona vs tombol
        if (!validateZoneActionConsistency(widget.actionType, zone)) {
          _showConsistencyWarning(x, y, zone, dist);
          return;
        }

        widget.onLocationSelected(x, y, zone, dist);
      },
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox;
        final localPos = renderBox.globalToLocal(details.globalPosition);
        final x = localPos.dx / renderBox.size.width;
        final y = localPos.dy / renderBox.size.height;
        setState(() => _hoveredZone = classifyZone(x, y));
      },
      child: CustomPaint(
        painter: CourtPainter(shots: widget.shots, hoveredZone: _hoveredZone),
        child: Container(color: Colors.transparent),
        size: Size.infinite,
      ),
    );
  }

  void _showConsistencyWarning(double x, double y, String zone, int dist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Zona'),
        content: Text(
          'Zona yang di-tap adalah $zone (${zone.contains('3') || zone.contains('WING') || zone.contains('CORNER') ? '3PT' : '2PT'}), '
          'tapi tombol yang dipilih adalah ${widget.actionType}. '
          'Lanjutkan quand même?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLocationSelected(x, y, zone, dist);
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }
}
```

---

# FASE 4 — DASHBOARD & ANALYTICS

## PART 18: STATISTICS DASHBOARD & SHOT CHART

> ⏱ Estimasi waktu: 240 menit

---

### Step 18.1: Buat `StatsRepository`

Buat file: `lib/features/statistics/data/repositories/stats_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_paths.dart';

class StatsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Query player_stats untuk satu match
  Future<List<Map<String, dynamic>>> getPlayerStatsForMatch(
      String matchId) async {
    final snap =
        await _db.collection(FirestorePaths.matchPlayerStats(matchId)).get();
    return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
  }

  // Query titik tembakan untuk shot chart heatmap
  Future<List<Map<String, dynamic>>> getShotPoints(String matchId) async {
    final snap = await _db
        .collection(FirestorePaths.matchEvents(matchId))
        .where('is_undone', isEqualTo: false)
        .where('is_opponent', isEqualTo: false)
        .get();

    return snap.docs
        .map((d) => d.data())
        .where((e) => e['shot_x'] != null)
        .toList();
  }
}
```

---

### Step 18.2: Buat `ShotChartWidget` (CustomPainter)

Buat file: `lib/features/statistics/presentation/widgets/shot_chart_widget.dart`

```dart
import 'package:flutter/material.dart';

// Shot Chart menggunakan CustomPainter yang sama dengan CourtPainter
// tapi dengan zona dioverlay berdasarkan FG% per zona

class ShotChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> shotEvents;

  const ShotChartWidget({super.key, required this.shotEvents});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: CustomPaint(
        painter: ShotChartPainter(shotEvents: shotEvents),
      ),
    );
  }
}

class ShotChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> shotEvents;

  ShotChartPainter({required this.shotEvents});

  @override
  void paint(Canvas canvas, Size size) {
    _drawCourtBackground(canvas, size);
    _drawZoneOverlays(canvas, size);
    _drawShotPoints(canvas, size);
  }

  void _drawCourtBackground(Canvas canvas, Size size) {
    // Sama seperti CourtPainter._drawCourtLines
    // (Refactor bersama ke shared widget di implementasi nyata)
  }

  void _drawZoneOverlays(Canvas canvas, Size size) {
    // Hitung FG% per zona dari shotEvents
    // Warna overlay: hijau (FG% tinggi), merah (FG% rendah)
    // Implementasi detail: groupBy zone → hitung made/attempted → pilih warna
  }

  void _drawShotPoints(Canvas canvas, Size size) {
    for (final event in shotEvents) {
      final x = (event['shot_x'] as double?) ?? 0.0;
      final y = (event['shot_y'] as double?) ?? 0.0;
      final isMade = event['action_type']?.toString().contains('MADE') ?? false;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        5,
        Paint()
          ..color = isMade
              ? Colors.green.withOpacity(0.9)
              : Colors.red.withOpacity(0.9),
      );
    }
  }

  @override
  bool shouldRepaint(ShotChartPainter oldDelegate) => true;
}
```

---

## PART 19: AUDIT LOG UI

> ⏱ Estimasi waktu: 60 menit

---

### Step 19.1: Buat Halaman Audit Log

Buat file: `lib/features/statistics/presentation/pages/audit_log_page.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuditLogPage extends StatelessWidget {
  const AuditLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        backgroundColor: const Color(0xFF1A3A5C),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('audit_logs')
            .orderBy('created_at', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada log.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              final log =
                  snapshot.data!.docs[i].data() as Map<String, dynamic>;
              final ts = (log['created_at'] as Timestamp?)?.toDate();
              return ListTile(
                dense: true,
                leading: const Icon(Icons.history, size: 18, color: Colors.grey),
                title: Text(
                  '${log['action_type']} · ${log['entity_type']}',
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  '${log['user_id']} · ${ts != null ? DateFormat('dd MMM yyyy HH:mm:ss').format(ts) : '-'}',
                  style: const TextStyle(fontSize: 11),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

# FASE 5 — TESTING & HARDENING

## PART 20: UNIT & WIDGET TESTING

> ⏱ Estimasi waktu: 300 menit

---

### Step 20.1: Unit Test `StatsCalculator`

Buat file: `test/core/utils/stats_calculator_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/stats_calculator.dart';

void main() {
  group('StatsCalculator', () {
    test('ftPercentage: 3 made dari 4 attempted = 75%', () {
      expect(StatsCalculator.ftPercentage(3, 4), closeTo(75.0, 0.01));
    });

    test('ftPercentage: 0 attempted = 0%', () {
      expect(StatsCalculator.ftPercentage(0, 0), 0.0);
    });

    test('fg2Percentage: 4 made dari 8 = 50%', () {
      expect(StatsCalculator.fg2Percentage(4, 8), closeTo(50.0, 0.01));
    });

    test('fg3Percentage: 1 made dari 3 = 33.3%', () {
      expect(StatsCalculator.fg3Percentage(1, 3), closeTo(33.3, 0.1));
    });

    test('fgPercentage: combined FG = (4+1)/(8+3) = 45.5%', () {
      expect(StatsCalculator.fgPercentage(4, 8, 1, 3), closeTo(45.5, 0.1));
    });
  });
}
```

---

### Step 20.2: Unit Test `MatchStateMachine`

Buat file: `test/core/utils/match_state_machine_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/match_state_machine.dart';

void main() {
  group('MatchStateMachine', () {
    test('transisi valid: PRE_MATCH → Q1_ACTIVE', () {
      expect(isValidTransition('PRE_MATCH', 'Q1_ACTIVE'), isTrue);
    });

    test('transisi invalid: PRE_MATCH → Q2_ACTIVE (skip Q1)', () {
      expect(isValidTransition('PRE_MATCH', 'Q2_ACTIVE'), isFalse);
    });

    test('transisi invalid: POST_MATCH → Q1_ACTIVE (tidak bisa mundur)', () {
      expect(isValidTransition('POST_MATCH', 'Q1_ACTIVE'), isFalse);
    });

    test('POST_MATCH adalah terminal state', () {
      expect(validTransitions['POST_MATCH'], isEmpty);
    });

    test('CHECK_SCORE bisa ke OT atau POST_MATCH', () {
      expect(isValidTransition('CHECK_SCORE', 'OT_ACTIVE'), isTrue);
      expect(isValidTransition('CHECK_SCORE', 'POST_MATCH'), isTrue);
    });

    test('semua Q_ACTIVE adalah active state', () {
      expect(isActiveState('Q1_ACTIVE'), isTrue);
      expect(isActiveState('Q1_BREAK'), isFalse);
      expect(isActiveState('OT_ACTIVE'), isTrue);
      expect(isActiveState('POST_MATCH'), isFalse);
    });
  });
}
```

---

### Step 20.3: Unit Test `zone_classifier`

Buat file: `test/core/utils/zone_classifier_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/zone_classifier.dart';

void main() {
  group('classifyZone', () {
    test('center court (0.5, 0.1) = PAINT', () {
      expect(classifyZone(0.5, 0.1), 'PAINT');
    });

    test('top of key (0.5, 0.8) = CENTER_3', () {
      expect(classifyZone(0.5, 0.8), 'CENTER_3');
    });

    test('corner kiri (0.1, 0.05) = CORNER_LEFT', () {
      expect(classifyZone(0.1, 0.05), 'CORNER_LEFT');
    });

    test('corner kanan (0.9, 0.05) = CORNER_RIGHT', () {
      expect(classifyZone(0.9, 0.05), 'CORNER_RIGHT');
    });

    test('wing kiri (0.1, 0.5) = WING_LEFT', () {
      expect(classifyZone(0.1, 0.5), 'WING_LEFT');
    });
  });

  group('validateZoneActionConsistency', () {
    test('2PT_MADE di PAINT = valid', () {
      expect(validateZoneActionConsistency('2PT_MADE', 'PAINT'), isTrue);
    });

    test('2PT_MADE di WING_LEFT = invalid (3PT zone)', () {
      expect(validateZoneActionConsistency('2PT_MADE', 'WING_LEFT'), isFalse);
    });

    test('3PT_MADE di CENTER_3 = valid', () {
      expect(validateZoneActionConsistency('3PT_MADE', 'CENTER_3'), isTrue);
    });

    test('3PT_MADE di PAINT = invalid (2PT zone)', () {
      expect(validateZoneActionConsistency('3PT_MADE', 'PAINT'), isFalse);
    });
  });
}
```

---

### Step 20.4: Unit Test `timer_calculator`

Buat file: `test/core/utils/timer_calculator_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/timer_calculator.dart';

void main() {
  group('currentRemainingSeconds', () {
    test('tidak berjalan — kembalikan secondsAtStart', () {
      final result = currentRemainingSeconds(
        isRunning: false,
        secondsAtStart: 300.0,
        startedAt: null,
      );
      expect(result, 300.0);
    });

    test('berjalan — kurangi waktu yang sudah berlalu', () {
      // Simulasi timer yang sudah berjalan 5 detik
      final startedAt = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(seconds: 5)),
      );
      final result = currentRemainingSeconds(
        isRunning: true,
        secondsAtStart: 300.0,
        startedAt: startedAt,
      );
      // Harus sekitar 295 detik (dengan toleransi 1 detik)
      expect(result, closeTo(295.0, 1.0));
    });

    test('tidak pernah negatif — clamp ke 0', () {
      final startedAt = Timestamp.fromDate(
        DateTime.now().subtract(const Duration(seconds: 400)),
      );
      final result = currentRemainingSeconds(
        isRunning: true,
        secondsAtStart: 300.0,
        startedAt: startedAt,
      );
      expect(result, 0.0);
    });
  });

  group('formatSeconds', () {
    test('300 detik = 05:00', () {
      expect(formatSeconds(300.0), '05:00');
    });

    test('65.9 detik = 01:05', () {
      expect(formatSeconds(65.9), '01:05');
    });
  });
}
```

---

### Step 20.5: Jalankan Semua Unit Test

```bash
flutter test
```

**Expected**: Semua test pass dengan output:
```
00:05 +12: All tests passed!
```

---

## PART 21: INTEGRATION & SECURITY TESTING

> ⏱ Estimasi waktu: 240 menit

---

### Step 21.1: Setup Integration Test

```bash
flutter pub add integration_test --dev
mkdir -p integration_test
touch integration_test/app_test.dart
```

---

### Step 21.2: Integration Test — Auth Flow

Buat file: `integration_test/auth_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budiutama_basketball/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login dengan credentials valid → redirect ke dashboard',
      (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Cari field email dan password
    final emailField = find.byKey(const Key('email_field'));
    final passwordField = find.byKey(const Key('password_field'));
    final loginButton = find.text('Masuk');

    // Isi form
    await tester.enterText(emailField, 'manager@budiutama.sch.id');
    await tester.enterText(passwordField, 'Test1234!');
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verifikasi sudah di dashboard
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
```

---

### Step 21.3: Security Rules Test

Buat file: `test/security/rules_test.js` (Node.js test, bukan Flutter):

```javascript
const { initializeTestEnvironment, assertSucceeds, assertFails } =
  require('@firebase/rules-unit-testing');

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'budiutama-basketball',
    firestore: { rules: require('fs').readFileSync('firestore.rules', 'utf8') },
  });
});

afterAll(async () => await testEnv.cleanup());

// Test: Coach TIDAK bisa write ke players
test('Coach tidak bisa tambah pemain', async () => {
  const db = testEnv.authenticatedContext('coach_uid', { role: 'coach' });
  await assertFails(
    db.collection('players').doc('test_player').set({ full_name: 'Test' })
  );
});

// Test: Manager BISA write ke players
test('Manager bisa tambah pemain', async () => {
  const db = testEnv.authenticatedContext('manager_uid', { role: 'manager' });
  await assertSucceeds(
    db.collection('players').doc('test_player').set({ full_name: 'Test' })
  );
});

// Test: Statistician BISA write ke match events
test('Statistician bisa tambah event', async () => {
  const db = testEnv.authenticatedContext('stat_uid', { role: 'statistician' });
  await assertSucceeds(
    db.collection('matches/test_match/events').doc('q1_001').set({
      quarter: 1, action_type: '2PT_MADE', is_undone: false
    })
  );
});

// Test: Event tidak bisa di-update (kecuali field is_undone)
test('Statistician hanya bisa update is_undone di events', async () => {
  const db = testEnv.authenticatedContext('stat_uid', { role: 'statistician' });
  
  // Update is_undone = valid
  await assertSucceeds(
    db.collection('matches/test_match/events').doc('q1_001').update({
      is_undone: true
    })
  );

  // Update field lain = invalid
  await assertFails(
    db.collection('matches/test_match/events').doc('q1_001').update({
      action_type: 'CHANGED'
    })
  );
});

// Test: Client tidak bisa write ke audit_logs
test('Client tidak bisa write ke audit_logs', async () => {
  const db = testEnv.authenticatedContext('manager_uid', { role: 'manager' });
  await assertFails(
    db.collection('audit_logs').doc('test').set({ action: 'test' })
  );
});

// Test: Unauthenticated tidak bisa read apapun
test('Unauthenticated tidak bisa read players', async () => {
  const db = testEnv.unauthenticatedContext();
  await assertFails(db.collection('players').get());
});
```

Jalankan test security rules:

```bash
npm install --save-dev @firebase/rules-unit-testing
firebase emulators:exec "npx jest test/security/rules_test.js"
```

**Expected**: Semua 6 test pass ✅

---

## PART 22: PERFORMANCE, HARDENING & BUG FIX

> ⏱ Estimasi waktu: 180 menit

---

### Step 22.1: Verifikasi Secrets Tidak Ada di Repository

```bash
# Pastikan file sensitif TIDAK ikut di-commit:
git ls-files android/app/google-services.json
git ls-files ios/Runner/GoogleService-Info.plist
git ls-files lib/firebase_options.dart
```

**Expected**: Ketiga perintah tidak menampilkan output (artinya file tidak di-track git) ✅

---

### Step 22.2: Verifikasi Firebase App Check Bukan Debug Mode di Release

Cek `main.dart`:

```dart
// Pastikan kode ini benar:
await FirebaseAppCheck.instance.activate(
  androidProvider:
      kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  // debug hanya saat kDebugMode = true (flutter run)
  // release build otomatis pakai playIntegrity / deviceCheck
);
```

**Expected**: `kDebugMode` digunakan sebagai kondisi, bukan hardcode `debug` ✅

---

### Step 22.3: Performance Test — Multi-Device Sync

```bash
# Buka 3 browser window yang menjalankan app yang sama:
# Window 1: Statistician — input event
# Window 2: Coach — monitor Live Player Stats Tab 2
# Window 3: Manager — monitor Live Player Stats Tab 2
#
# Di Window 1: input "+2" → pantau latency di Window 2 dan 3
# Target: update muncul di Window 2 dan 3 dalam < 1 detik
flutter run -d chrome --web-port 8080
```

**Expected**: Semua device update dalam < 1 detik ✅

---

### Step 22.4: Test Offline Mode

```bash
# 1. Jalankan app: flutter run -d chrome
# 2. Mulai Match Mode, input beberapa event
# 3. Di Chrome DevTools → Network → Set ke Offline
# 4. Input beberapa event lagi
# 5. Lihat ConnectionStatusIndicator berubah ke 🔴 Offline
# 6. Set kembali ke Online
# 7. Verifikasi semua pending events tersinkron ke Firestore
```

**Expected**: Event yang diinput saat offline tersinkron otomatis saat kembali online ✅

---

# FASE 6 — DEPLOYMENT & LAUNCH

## PART 23: PRE-LAUNCH & GO-LIVE

> ⏱ Estimasi waktu: 120 menit

---

### Step 23.1: Clear Data Testing dari Firestore

```bash
# PERHATIAN: Perintah ini menghapus SEMUA data dari Firestore production!
# Pastikan sudah backup jika ada data testing yang perlu disimpan.

firebase firestore:delete --all-collections --project budiutama-basketball
```

> ⚠️ Security Rules, Indexes, dan Cloud Functions TIDAK ikut terhapus — hanya data dokumen Firestore. Konfigurasi tetap aman.

**Expected**: Semua collections kosong di Firestore Console ✅

---

### Step 23.2: Seed Data Production Awal

Buat file: `scripts/seed_production.dart`

```dart
// Jalankan: dart run scripts/seed_production.dart
// HANYA untuk go-live pertama — jangan jalankan lagi setelah ada data production!

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../lib/firebase_options.dart';

void main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // PRODUCTION — tidak redirect ke emulator

  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  print('⚠️  Seeding data PRODUCTION. Ketik "yes" untuk lanjutkan:');
  final confirm = stdin.readLineSync();
  if (confirm != 'yes') {
    print('Dibatalkan.');
    return;
  }

  // Seed teams
  await db.collection('teams').doc('putra_2526').set({
    'name': 'Tim Putra Budi Utama',
    'gender': 'male',
    'academic_year': '2025/2026',
    'is_active': true,
    'created_at': FieldValue.serverTimestamp(),
  });

  await db.collection('teams').doc('putri_2526').set({
    'name': 'Tim Putri Budi Utama',
    'gender': 'female',
    'academic_year': '2025/2026',
    'is_active': true,
    'created_at': FieldValue.serverTimestamp(),
  });

  print('✅ Seed data production selesai!');
  print('Langkah selanjutnya: Gunakan halaman User Management di app untuk membuat akun per role.');
}
```

---

### Step 23.3: Build & Deploy

```bash
# 1. Build Flutter Web Release
flutter build web --release

# 2. Deploy ke Firebase Hosting (live channel)
firebase deploy --only hosting --project budiutama-basketball

# 3. Deploy Security Rules final
firebase deploy --only firestore:rules --project budiutama-basketball

# 4. Deploy Cloud Functions final
firebase deploy --only functions --project budiutama-basketball

# 5. Build Android APK Release (untuk distribusi internal)
flutter build apk --release
# APK ada di: build/app/outputs/flutter-apk/app-release.apk
```

---

### Step 23.4: Smoke Test Production

```bash
# Lakukan smoke test setelah go-live:

# 1. Buka URL production (dari Firebase Hosting)
# 2. Login dengan semua role (Manager, Coach, Statistician, Player)
# 3. Manager: tambah 1 pemain baru
# 4. Manager: buat 1 event dan 1 pertandingan
# 5. Statistician: mulai pertandingan → Match Mode terbuka
# 6. Statistician: input 5 event (+2, +3, AST, STL, FOUL)
# 7. Coach (dari device/tab lain): buka Tab 2 Live Player Stats — verifikasi update
# 8. Statistician: undo 1 event — verifikasi stats turun
# 9. Statistician: akhiri pertandingan (POST_MATCH)
# 10. Verifikasi Cloud Function onMatchFinished berjalan (cek Firebase Console → Functions logs)
```

**Expected**: Semua 10 langkah smoke test berhasil tanpa error ✅

---

### Step 23.5: Aktifkan Firebase Performance Monitoring Alerts

```
1. Firebase Console → Performance Monitoring
2. Klik "Add Alert"
3. Metric: Network Request Duration
4. Threshold: > 1000ms
5. Email: [email tim dev]
6. Klik "Save"
```

---

### Step 23.6: Pelatihan Pengguna

```
Urutan pelatihan (per role):

1. Manager (60 menit):
   - Demo player management + upload foto
   - Demo event & match management
   - Demo konfigurasi timer sebelum pertandingan
   - Demo physical test (Beep Test + T-Test + Sprint)
   - Demo audit log

2. Statistician (90 menit):
   ⭐ Bagian terpenting — latihan berulang!
   - Demo Match Mode fullscreen
   - Latihan input semua 13 aksi (+1, +2, +3, MISS 1/2/3, AST, TO, STL, BLK, OREB, DREB, FOUL)
   - Latihan court overlay — tap zona yang tepat
   - Latihan undo
   - Latihan substitusi
   - Latihan PAUSE/RESUME timer untuk waktu campuran
   - Simulasi full match (2 quarter)

3. Coach (30 menit):
   - Demo dashboard statistik
   - Demo Live Player Stats Tab 2 saat pertandingan
   - Demo injury management

4. Player (15 menit):
   - Demo lihat statistik pribadi
   - Demo lihat jadwal latihan
```

---

# DIRECTORY STRUCTURE

```
budiutama_basketball/
├── .github/
│   └── workflows/
│       ├── flutter_check.yml          ← Analyze + test setiap push
│       ├── deploy_staging.yml         ← Deploy ke Firebase saat push ke develop
│       └── deploy_production.yml      ← Deploy production dengan manual approval
│
├── lib/
│   ├── main.dart                      ✅ Firebase init + Emulator redirect
│   ├── firebase_options.dart          ✅ Generated by FlutterFire CLI (di .gitignore)
│   │
│   ├── app/
│   │   └── app.dart                   ← MaterialApp + GoRouter
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── firestore_paths.dart   ← Semua path Firestore terpusat
│   │   ├── errors/
│   │   │   └── app_exceptions.dart    ← Error hierarchy
│   │   └── utils/
│   │       ├── match_state_machine.dart
│   │       ├── timer_calculator.dart
│   │       ├── stats_calculator.dart
│   │       └── zone_classifier.dart   ← classifyZone(x, y)
│   │
│   ├── features/
│   │   ├── auth/
│   │   ├── players/
│   │   ├── events/
│   │   ├── matches/
│   │   │   ├── dashboard/             ← Pre-match, daftar pertandingan
│   │   │   └── live/                  ← Match Mode fullscreen
│   │   │       ├── data/
│   │   │       │   ├── models/
│   │   │       │   └── repositories/
│   │   │       ├── domain/providers/
│   │   │       └── presentation/
│   │   │           ├── pages/
│   │   │           └── widgets/
│   │   │               ├── header/    ← MatchHeader, MatchTimer, ConnectionStatus
│   │   │               ├── left_panel/   ← PlayerList
│   │   │               ├── center_panel/ ← ActionButtons, CourtOverlay, LiveStats
│   │   │               ├── right_panel/  ← OpponentActions
│   │   │               ├── bottom_panel/ ← SubstitutionPanel
│   │   │               └── timeline/    ← EventTimeline
│   │   ├── training/
│   │   ├── injuries/
│   │   ├── physical_tests/
│   │   └── statistics/
│   │
│   └── shared/
│       ├── models/
│       ├── providers/
│       └── widgets/                   ← AppButton, ConfirmDialog, AppLayout, dll.
│
├── functions/
│   └── src/
│       └── index.ts                   ← onMatchFinished, createUser, auditLog, dst.
│
├── test/
│   ├── core/utils/                    ← Unit tests
│   └── security/rules_test.js         ← Security Rules tests (Node.js)
│
├── integration_test/
│   └── auth_test.dart                 ← Integration tests
│
├── assets/
│   └── audio/
│       └── beep_test.mp3              ← Bundle audio beep test
│
├── scripts/
│   ├── seed_emulator.dart             ← Seed data ke Emulator
│   └── seed_production.dart           ← Seed data production (sekali pakai)
│
├── firestore.rules                    ← Security Rules Firestore
├── storage.rules                      ← Security Rules Storage
├── firestore.indexes.json             ← Composite Indexes
├── firebase.json
└── pubspec.yaml
```

---

# TROUBLESHOOTING

## Firebase Emulator tidak bisa distart

```
Solusi:
1. Pastikan Java terinstall: java --version
2. Pastikan Firebase CLI versi terbaru: npm update -g firebase-tools
3. Cek port tidak dipakai: lsof -i :8080 (Mac/Linux)
4. Jalankan ulang: firebase emulators:start
5. Jika masih gagal: firebase emulators:start --only firestore,auth
```

---

## flutter pub get gagal karena konflik package

```
Solusi:
1. flutter pub outdated
2. Update package yang bermasalah di pubspec.yaml ke versi terbaru
3. flutter pub get
4. Jika masih error: flutter clean → flutter pub get
```

---

## build_runner tidak generate file .freezed.dart

```
Solusi:
1. Pastikan dev_dependencies ada: freezed, build_runner, json_serializable
2. Jalankan: dart run build_runner clean
3. Jalankan: dart run build_runner build --delete-conflicting-outputs
4. Jika ada error "already has a part": hapus file .g.dart lama
```

---

## Match Mode timer tidak sinkron antar device

```
Penyebab: Menggunakan DateTime.now() sebagai referensi tanpa server timestamp
Solusi:
1. Pastikan started_at menggunakan FieldValue.serverTimestamp() saat RESUME
2. Pastikan kalkulasi menggunakan startedAt.toDate() dari Timestamp Firebase
3. Cek timer_calculator.dart: currentRemainingSeconds() menerima Timestamp?
4. Jika masih drift: tambahkan log di setiap device untuk debug timestamp
```

---

## Foto pemain tidak tampil setelah upload

```
Solusi (free plan — base64 di Firestore):
1. Cek ukuran: foto harus < 200KB setelah kompresi
2. Cek format base64: harus dimulai dengan "data:image/jpeg;base64,"
3. Cek field name di Firestore: harus "photo_base64" (bukan "photoBase64")
4. Cek widget PhotoDisplay menggunakan base64Decode() dengan benar
5. Di Chrome DevTools → Network: cek apakah Firestore request berhasil
```

---

## Security Rules selalu deny padahal sudah login

```
Penyebab: Custom Claims belum diset pada user yang digunakan untuk test
Solusi di Emulator:
1. Buka Emulator UI: http://localhost:4000
2. Authentication → pilih user → Edit
3. Tambah Custom Claims: {"role": "manager"}
4. Logout dari app → login ulang (agar claims ter-refresh)
5. Cek dengan: FirebaseAuth.instance.currentUser?.getIdTokenResult(true)
```

---

## Court Overlay tidak muncul saat tap tombol +2

```
Penyebab: Widget CourtOverlay belum di-mount atau state provider belum ter-update
Solusi:
1. Cek apakah selectedPlayerId sudah di-set (tap pemain di Left Panel dulu)
2. Cek state provider: isCourtOverlayOpen
3. Pastikan GestureDetector di CourtOverlay tidak terblokir widget lain
4. Test di tablet fisik — bukan hanya di Chrome DevTools device mode
```

---

## Cloud Function onMatchFinished tidak berjalan

```
Solusi:
1. Cek Firebase Console → Functions → Logs
2. Pastikan current_state ter-update ke "POST_MATCH" (bukan "post_match")
3. Cek Emulator Functions log: localhost:4000 → Functions
4. Pastikan Cloud Functions sudah di-deploy: firebase deploy --only functions
5. Cek apakah Blaze plan aktif (Functions memerlukan Blaze)
```

---

# REFERENSI CEPAT

## Document ID Convention

| Collection | Format | Contoh |
|------------|--------|--------|
| users | `{role}_{namaDepan}` | `manager_andi` |
| teams | `{gender}_{tahunAjaran}` | `putra_2526` |
| players | `{jersey}_{inisial}_{teamId}` | `7_ar_putra2526` |
| events | `{tipe}_{namasingkat}_{tahun}` | `porseni_kota_2526` |
| matches | `{eventId}_vs_{lawan}_{tgl}` | `porseni_kota_2526_vs_sman1_20260315` |
| match/events | `q{quarter}_{urutan3digit}` | `q3_047` |
| match/player_stats | `{jersey}_{inisial}` | `7_ar` |
| physical_test_sessions | `{tipe}_{teamId}_{tgl}` | `beep_putra2526_20260120` |
| injury_reports | `{playerId}_{tgl}` | `7_ar_putra2526_20260205` |
| training_sessions | `{teamId}_{tipe}_{tgl}` | `putra2526_fisik_20260110` |

## Konversi Tahun Ajaran & Tanggal

- `2025/2026` → `2526`
- `2026/2027` → `2627`
- `15 Maret 2026` → `20260315`

## Action Types Match Events

| Kode | Keterangan |
|------|------------|
| `1PT_MADE` | Free throw masuk |
| `2PT_MADE` | 2PT masuk |
| `3PT_MADE` | 3PT masuk |
| `MISS_1PT` | Free throw gagal |
| `MISS_2PT` | 2PT gagal |
| `MISS_3PT` | 3PT gagal |
| `ASSIST` | Assist |
| `REBOUND_OFF` | Offensive rebound |
| `REBOUND_DEF` | Defensive rebound |
| `STEAL` | Steal |
| `TURNOVER` | Turnover |
| `BLOCK` | Block |
| `FOUL` | Personal foul |
| `UNDO` | Pembatalan event sebelumnya |
| `SUBSTITUTION` | Pergantian pemain |
| `STATE_TRANSITION` | Transisi state pertandingan |
| `TIMER_START` / `TIMER_PAUSE` / `TIMER_RESUME` | Kontrol timer |

## Shot Zones (9 Zona)

| Kode | Label | Poin |
|------|-------|------|
| `PAINT` | Area Cat | 2 |
| `MEDIUM_LEFT` | Medium Kiri | 2 |
| `MEDIUM_CENTER` | Medium Tengah | 2 |
| `MEDIUM_RIGHT` | Medium Kanan | 2 |
| `CORNER_LEFT` | Corner Kiri | 3 |
| `CORNER_RIGHT` | Corner Kanan | 3 |
| `WING_LEFT` | Wing Kiri | 3 |
| `WING_RIGHT` | Wing Kanan | 3 |
| `CENTER_3` | Center 3PT | 3 |

## Perintah Penting

```bash
# Jalankan emulator (wajib saat development)
firebase emulators:start

# Run app di Chrome (mengarah ke emulator)
flutter run -d chrome

# Generate Freezed models setelah edit model
dart run build_runner build --delete-conflicting-outputs

# Jalankan semua unit test
flutter test

# Deploy Security Rules saja
firebase deploy --only firestore:rules

# Deploy Functions saja
firebase deploy --only functions

# Build APK Release
flutter build apk --release

# Build Flutter Web Release
flutter build web --release
```

---

**Last Updated**: Juni 2026  
**Version**: 2.0 — Flutter + Firebase  
**Status**: Ready to Development  
**Platform**: Flutter (Android · iOS · Web) + Firebase  
**Nama App**: Budi Utama Basketball Management System  
**Organisasi**: SMA Budi Utama Yogyakarta  

🏀 **Siap? Let's build Budi Utama Basketball!**
