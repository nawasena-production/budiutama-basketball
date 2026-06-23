# PRODUCT REQUIREMENTS DOCUMENT
## BUDI UTAMA BASKETBALL MANAGEMENT SYSTEM
### SMA Budi Utama Yogyakarta

---

| | |
|---|---|
| **Versi** | 2.0 — Revised (Flutter + Firebase) |
| **Tanggal** | Juni 2026 |
| **Status** | Final — Approved for Development |
| **Organisasi** | SMA Budi Utama Yogyakarta |
| **Klasifikasi** | CONFIDENTIAL — INTERNAL USE ONLY |

---

## DAFTAR ISI

1. [Executive Summary](#1-executive-summary)
2. [Project Goals](#2-project-goals)
3. [Target Users & Role Matrix](#3-target-users--role-matrix)
4. [System Architecture](#4-system-architecture)
5. [Cybersecurity Architecture](#5-cybersecurity-architecture)
6. [Core Features](#6-core-features)
7. [Live Match Statistics Engine](#7-live-match-statistics-engine)
8. [Statistics Dashboard](#8-statistics-dashboard)
9. [Responsive & Device Requirements](#9-responsive--device-requirements)
10. [Tech Stack](#10-tech-stack)
11. [Performance Targets](#11-performance-targets)
12. [Testing Strategy](#12-testing-strategy)
13. [MVP Scope & Roadmap](#13-mvp-scope--roadmap)
14. [Firestore Data Structure & Document ID Convention](#14-firestore-data-structure--document-id-convention)
15. [Penutup](#15-penutup)

---

## 1. Executive Summary

Budi Utama Basketball Management System adalah platform manajemen olahraga berbasis **Flutter** yang berjalan di Android, iOS, dan Web, dirancang untuk mendukung operasional tim basket SMA Budi Utama Yogyakarta secara modern, terpusat, dan real-time.

Sistem ini dibangun di atas **Firebase Platform** yang terdiri dari:

- **Flutter App** — antarmuka pengguna lintas platform (Android, iOS, Flutter Web)
- **Firebase Authentication** — autentikasi pengguna dengan reCAPTCHA v3 dan Email OTP
- **Cloud Firestore** — database NoSQL real-time dengan offline persistence bawaan
- **Firebase Storage** — penyimpanan foto profil dan dokumentasi cedera
- **Cloud Functions (TypeScript)** — logika kalkulasi statistik final dan audit log otomatis

**Dua modul utama sistem:**

1. **Basketball Club Management System** — pengelolaan pemain, jadwal latihan, pertandingan, dan riwayat cedera
2. **Live Match Statistics Engine** — input dan sinkronisasi statistik real-time saat pertandingan berlangsung

**Satu codebase Flutter untuk Android, iOS, dan Web.**

---

## 2. Project Goals

### 2.1 Primary Goals

- Mengelola data pemain basket putra dan putri secara terpusat dalam satu platform
- Mencatat statistik pertandingan secara real-time dengan sinkronisasi multi-perangkat
- Menyimpan histori pertandingan lengkap dan riwayat cedera pemain
- Menyediakan dashboard statistik modern untuk evaluasi dan analitik performa per event/turnamen
- Mendukung pengalaman multi-device yang responsif di desktop, tablet, dan smartphone (Android, iOS, Web)
- Memastikan keamanan data dengan Firebase Security Rules di seluruh lapisan sistem

---

## 3. Target Users & Role Matrix

Sistem menggunakan **Role-Based Access Control (RBAC)** yang diimplementasikan melalui **Firebase Custom Claims** dan **Firebase Security Rules**. Setiap peran memiliki hak akses yang terdefinisi dengan ketat.

| Role | Tanggung Jawab | Akses Utama | Batasan |
|---|---|---|---|
| **Coach** | Evaluasi performa dan strategi tim | Statistik pemain, histori injury, laporan performa, Live Player Stats real-time | Tidak dapat input live stats atau mengubah data pemain |
| **Team Manager** | Pengelolaan roster, jadwal, dan pertandingan | CRUD pemain, jadwal latihan, manajemen pertandingan, Live Player Stats real-time | Tidak dapat mengakses live match engine input |
| **Statistician** | Input statistik real-time saat pertandingan | Live match panel, timer, substitusi, undo aksi | Tidak dapat mengubah data master pemain |
| **Player** | Melihat data dan jadwal pribadi | Statistik pribadi, jadwal latihan | Read-only, hanya data milik sendiri |

---

## 4. System Architecture

### 4.1 Firebase-First Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APPLICATION                       │
│          Android · iOS · Flutter Web (Tablet)               │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Dashboard    │  │  Match Mode  │  │  Physical Test   │  │
│  │ (Coach/Mgr)  │  │ (Statistician│  │  (Manager/Coach) │  │
│  │              │  │  /Coach/Mgr) │  │                  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │ Firebase SDK
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE PLATFORM                         │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  Firebase    │  │   Cloud      │  │    Firebase      │  │
│  │    Auth      │  │  Firestore   │  │    Storage       │  │
│  │              │  │  (Real-time  │  │  (Foto pemain,   │  │
│  │ reCAPTCHA v3 │  │   + Offline) │  │   foto cedera)   │  │
│  │ Email OTP    │  │              │  │                  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│                                                             │
│  ┌──────────────┐  ┌──────────────────────────────────────┐ │
│  │    Cloud     │  │         Firebase Security Rules      │ │
│  │  Functions   │  │   (RBAC enforcement di semua         │ │
│  │ (TypeScript) │  │    collection dan dokumen)           │ │
│  │              │  │                                      │ │
│  │ Stats final  │  └──────────────────────────────────────┘ │
│  │ Audit log    │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Pola Komunikasi Data

| Dari | Ke | Mekanisme | Keterangan |
|---|---|---|---|
| Flutter App | Firestore | SDK real-time listeners | Update otomatis ke semua device |
| Flutter App | Firestore | SDK write operations | Create/update dokumen |
| Flutter App | Firebase Auth | SDK sign-in methods | Login, logout, token refresh |
| Flutter App | Firebase Storage | SDK upload/download | Foto profil, foto cedera |
| Firestore | Cloud Functions | Trigger onWrite/onCreate | Kalkulasi stats final, audit log |
| Cloud Functions | Firestore | Admin SDK write | Update dokumen hasil kalkulasi |

### 4.3 Application Work Modes

#### Mode 1: Dashboard Mode
- Digunakan untuk operasional harian tim di luar jam pertandingan
- Fitur: player management, injury reports, training schedule, match management, analytics
- Layout: bottom navigation (mobile) / sidebar navigasi (tablet & web)
- Aksesibel oleh: Coach, Manager, Player

#### Mode 2: Match Mode (Live Statistics Engine)
- Aktif secara otomatis saat tombol **START MATCH** ditekan oleh Statistician
- Tampilan fullscreen tanpa navigasi standar, dioptimalkan untuk sentuh (touch-optimized)
- Real-time synchronization via Firestore listeners antar semua perangkat yang terhubung
- Aksesibel oleh: Statistician (input penuh), Coach dan Manager (Live Player Stats — read-only)

### 4.4 Match State Machine

> ⚠️ Transisi state pertandingan hanya bisa dilakukan secara eksplisit oleh Statistician yang berwenang.

```
PRE_MATCH → Q1_ACTIVE → Q1_BREAK → Q2_ACTIVE → HALFTIME
          → Q3_ACTIVE → Q3_BREAK → Q4_ACTIVE → CHECK_SCORE → [OT_ACTIVE] → POST_MATCH
```

### 4.5 Statistik — Strategi Kalkulasi

Sistem menggunakan **dua mekanisme kalkulasi** yang berjalan bersama:

**Live Match (Materialized Stats):**
Setiap kali Statistician mencatat event, dokumen `player_stats` di Firestore diperbarui secara instan menggunakan `FieldValue.increment()` langsung dari Flutter client. Hasilnya statistik tampil real-time di semua perangkat tanpa jeda — cocok untuk Tab 2 Live Player Stats yang dimonitor Coach dan Manager selama pertandingan berlangsung.

**Rekap Final (Cloud Functions):**
Saat pertandingan berakhir (state `POST_MATCH`), Cloud Functions berjalan otomatis dan melakukan kalkulasi ulang dari seluruh event log dari awal. Ini berfungsi sebagai verifikasi — memastikan tidak ada inkonsistensi akibat write yang gagal sebagian selama pertandingan, dan menghasilkan statistik final yang akurat untuk disimpan permanen.

---

## 5. Cybersecurity Architecture

### 5.1 Authentication & Authorization

- **Firebase Authentication** mengelola seluruh siklus autentikasi
- **reCAPTCHA v3** (invisible) aktif di semua form login sebagai perlindungan anti-bot
- **Email OTP** (via Firebase Auth) wajib untuk Coach dan Manager saat login dari **device baru** — tidak diperlukan setiap login
- **Firebase Custom Claims** menyimpan informasi role (`coach`, `manager`, `statistician`, `player`) yang diverifikasi di Security Rules
- Session dikelola otomatis oleh Firebase SDK

### 5.2 Firebase Security Rules

Seluruh akses data dilindungi oleh Firebase Security Rules yang dievaluasi di server Firebase sebelum data dikembalikan ke client.

```javascript
// Contoh prinsip Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    function getRole() {
      return request.auth.token.role;
    }
    function isManager() { return getRole() == 'manager'; }
    function isCoach()   { return getRole() == 'coach'; }
    function isStatistician() { return getRole() == 'statistician'; }
    function isPlayer()  { return getRole() == 'player'; }

    // Players collection
    match /players/{playerId} {
      allow read: if isAuthenticated() && (isCoach() || isManager() || isStatistician()
                    || (isPlayer() && request.auth.uid == resource.data.user_id));
      allow write: if isAuthenticated() && isManager();
    }

    // Match events — hanya Statistician yang bisa write saat pertandingan aktif
    match /matches/{matchId}/events/{eventId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && isStatistician();
      allow update: if false; // events bersifat immutable
      allow delete: if false;
    }
  }
}
```

### 5.3 Data Security

- **Firebase App Check** aktif untuk memastikan hanya aplikasi Flutter resmi yang bisa mengakses Firebase
- **HTTPS** otomatis untuk semua komunikasi Firebase
- Secrets dan konfigurasi Firebase dikelola via `google-services.json` / `GoogleService-Info.plist` yang tidak di-commit ke repository
- Foto disimpan di Firebase Storage dengan Security Rules yang membatasi akses berdasarkan role

---

## 6. Core Features

### 6.1 Player Management

| Fitur | Detail | Role yang Dapat Akses |
|---|---|---|
| **CRUD Pemain** | Tambah, edit, hapus data pemain; upload foto profil (disimpan base64 di Firestore pada free plan; Firebase Storage saat Blaze) | Manager |
| **Profil Pemain** | Nomor jersey, posisi, tinggi badan, berat badan, tim (putra/putri) | Manager, Coach, Player (milik sendiri) |
| **Statistik Pemain** | Points, rebound, assist, steal, block, FG%, FG2%, FG3%, FT% per event/turnamen | Coach, Manager, Player (milik sendiri) |
| **Roster Management** | Daftar tim aktif, status: Aktif / Cedera / Non-Aktif | Manager |

---

### 6.2 Event / Tournament Management

> ℹ️ Setiap pertandingan di SMA Budi Utama selalu terikat pada sebuah **event atau turnamen**. Tidak ada pertandingan yang berdiri sendiri di luar konteks event.

| Fitur | Detail | Role yang Dapat Akses |
|---|---|---|
| **Buat Event/Turnamen** | Nama event, penyelenggara, lokasi, tanggal, tahun ajaran, tipe event | Manager |
| **Daftar Pertandingan per Event** | Semua pertandingan dalam satu event beserta status dan hasilnya | Semua role |
| **Rekap Statistik per Event** | Win/loss, top scorer, team averages dalam event | Coach, Manager |
| **Arsip Event** | Histori event per tahun ajaran | Coach, Manager |

### 6.3 Training Management

- Pembuatan dan pengelolaan jadwal latihan: tanggal, waktu, lokasi, tipe sesi
- Program latihan terstruktur dengan deskripsi dan tujuan
- Histori sesi latihan yang telah selesai
- Notifikasi push notification jadwal untuk pemain dan pelatih via Firebase Cloud Messaging (muncul di notification bar Android/iOS dan browser notification di Flutter Web)

### 6.4 Match Management

- Setiap pertandingan wajib terikat pada satu Event/Turnamen
- Pembuatan jadwal: home/away/neutral, nama lawan, venue, tanggal, fase (grup/semifinal/final)
- Histori hasil pertandingan dan rekap statistik per event/turnamen
- Status: `scheduled` / `ongoing` / `finished` / `cancelled`

### 6.5 Injury Management

- Pencatatan laporan cedera dengan deskripsi detail dan foto dokumentasi
- Tracking status: `active` / `recovery` / `cleared`
- Histori lengkap cedera per pemain
- Estimasi waktu pemulihan dan catatan medis

### 6.6 Physical Test Management

Modul pencatatan dan analitik tes fisik pemain. Tersedia tiga jenis tes yang dapat dijadwalkan beberapa kali dalam satu semester.

#### Jenis Tes Fisik

| Jenis Tes | Mekanisme Input | Jumlah Pemain Bersamaan |
|---|---|---|
| **Beep Test** | Batch — kelompok 5 pemain, tombol PASS/FAIL per pemain | 5 pemain per batch |
| **T-Test** | Individual — stopwatch satu per satu | 1 pemain |
| **Sprint 20 Meter** | Individual — stopwatch satu per satu | 1 pemain |

#### Beep Test — Alur Detail

1. Manager/Coach menjadwalkan sesi dan memilih pemain dari roster aktif
2. Operator memilih maksimal **5 pemain** dari roster untuk batch pertama
3. UI menampilkan 5 kartu pemain dengan tombol **PASS** dan **FAIL** besar tanpa scroll
4. Saat pemain gagal, operator mengetuk **FAIL** → input level dan shuttle
5. Pemain yang FAIL ditandai visual (badge "Selesai") agar status jelas
6. Setelah batch selesai, operator memilih 5 pemain berikutnya
7. Operator dapat menekan **Stop Sesi** kapan saja — data tersimpan parsial

#### T-Test & Sprint 20 Meter — Alur Detail

1. Operator memilih satu pemain dari daftar roster
2. Operator menekan **Mulai** → stopwatch berjalan
3. Saat pemain selesai, operator menekan **Selesai** → waktu dicatat otomatis
4. Operator memilih pemain berikutnya atau Stop Sesi

### 6.7 Audit Log System

- Cloud Functions mencatat otomatis setiap aksi CRUD: identitas pengguna, waktu, data yang diubah
- Audit trail live match events bersifat immutable (Security Rules: `allow update: if false`)
- Log dapat diakses Coach dan Manager
- Retention: minimum 1 tahun

---

## 7. Live Match Statistics Engine

### 7.1 UI Layout Match Mode — Dua Tab di Center Panel

```
[TAB 1: INPUT MODE]  [TAB 2: LIVE PLAYER STATS]
```

| Tab | Konten | Pengguna |
|---|---|---|
| **Tab 1: Input Mode** | Tombol aksi statistik (+1, +2, +3, MISS 1/2/3, AST, TO, STL, BLK, OREB, DREB, FOUL) | Statistician |
| **Tab 2: Live Player Stats** | Tabel statistik real-time seluruh pemain yang sudah bermain | Coach, Manager, Statistician |

| Panel | Posisi | Konten | Interaksi |
|---|---|---|---|
| **Header** | Top — Full Width | Score, quarter, timer (waktu bersih), timeout, foul, status koneksi Firestore | START/PAUSE/RESUME timer |
| **Left Panel** | Kiri | 5 pemain aktif di lapangan: jersey, nama, posisi | Tap pilih pemain |
| **Center Panel** | Tengah | Tab 1: tombol aksi; Tab 2: Live Player Stats | Beralih tab; tap aksi → court overlay |
| **Right Panel** | Kanan | Tim lawan: +1, +2, +3, MISS, FOUL | Tap aksi lawan |
| **Bottom Panel** | Bawah | Substitusi: pilih OUT dan IN dengan konfirmasi | Two-step + confirm dialog |
| **Event Timeline** | Sidebar | Log real-time semua aksi | Scroll; tap untuk undo |

### 7.2 Statistik yang Dicatat

#### Tim Budi Utama — Detail per Pemain

| Tombol | Jenis Aksi | Keterangan |
|---|---|---|
| **+1** | Free Throw Made | Tidak masuk heatmap |
| **+2** | 2PT Made | Zona + koordinat (x,y) + jarak |
| **+3** | 3PT Made | Zona + koordinat (x,y) + jarak |
| **MISS 1** | Missed Free Throw | Tidak masuk heatmap |
| **MISS 2** | Missed 2PT | Zona + koordinat (x,y) + jarak |
| **MISS 3** | Missed 3PT | Zona + koordinat (x,y) + jarak |
| **AST** | Assist | — |
| **OREB** | Offensive Rebound | — |
| **DREB** | Defensive Rebound | — |
| **STL** | Steal | — |
| **TO** | Turnover | — |
| **BLK** | Block | — |
| **FOUL** | Personal Foul | — |

#### Tim Lawan — Agregat Tim

| Tombol | Keterangan |
|---|---|
| **+1** | Free throw masuk (agregat tim) |
| **+2** | 2PT masuk (agregat tim) |
| **+3** | 3PT masuk (agregat tim) |
| **FOUL** | Foul tim lawan (agregat tim) |

> Tim lawan tidak memiliki pencatatan tembakan gagal — hanya skor masuk dan foul yang dicatat.

### 7.3 Event-Driven Architecture (Firestore)

Seluruh aksi disimpan sebagai **immutable event** di subcollection Firestore:

```
matches/{matchId}/events/{q3_047}
{
  "quarter": 3,
  "time_remaining": 384.0,
  "player_id": "7_ar_putra2526",
  "action_type": "2PT_MADE",
  "value": 2,
  "zone": "MEDIUM_LEFT",
  "shot_x": 0.31,
  "shot_y": 0.58,
  "shot_distance_ft": 16,
  "is_opponent": false,
  "is_undone": false,
  "created_by": "statistician_reza",
  "created_at": Timestamp
}
```

**Prinsip:**
- Security Rules memastikan event tidak bisa di-update atau dihapus setelah dibuat
- Undo bekerja dengan menambahkan event `UNDO` baru yang mereferensi event asli
- Statistik dihitung dari materialized `player_stats` dokumen (diperbarui via `FieldValue.increment()`)

### 7.4 Multi-Device Real-Time Sync (Firestore Listeners)

```
TABLET A (Statistician)
    │ write event ke Firestore
    ▼
FIRESTORE
    │ real-time push ke semua listener
    ├──► TABLET B (Coach — Tab 2 Live Stats)
    ├──► TABLET C (Manager — Tab 2 Live Stats)
    └──► TABLET A (konfirmasi write)
```

- Sinkronisasi ke semua perangkat dalam waktu **< 1 detik** via Firestore real-time listeners
- Fallback otomatis ke Firestore offline cache jika koneksi terputus

### 7.5 Offline Safety (Firestore Built-in)

```dart
// Aktifkan sekali saat inisialisasi app
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

- Data yang belum tersinkron disimpan otomatis di cache lokal Firestore
- Indikator koneksi: monitor `FirebaseFirestore.instance.snapshotsInSync()`
- Auto-sync otomatis saat koneksi pulih — tanpa logika tambahan
- **Menggantikan seluruh IndexedDB logic manual** dari arsitektur sebelumnya

### 7.6 Konfigurasi & Kontrol Timer (Waktu Bersih)

Timer pertandingan berjalan sebagai **waktu bersih (clean time)** — hanya bergerak saat Statistician mengaktifkannya secara eksplisit. **Shot clock tidak digunakan** — sistem ini untuk keperluan internal latihan dan pertandingan persahabatan Budi Utama.

#### Struktur Data Timer di Firestore

```
matches/{matchId}/timer_state   ← dokumen tunggal, bukan subcollection
{
  "is_running": false,
  "seconds_at_start": 600.0,    // sisa detik saat timer terakhir distart/pause
  "started_at": null,           // Server Timestamp Firebase, diisi saat RESUME
  "quarter": 1
}
```

#### Parameter Konfigurasi (diset Manager sebelum START MATCH)

| Parameter | Default | Range |
|---|---|---|
| Durasi per quarter | 10 menit | 1–20 menit |
| Jumlah periode | 4 quarter | 4 quarter atau 2 babak |
| Durasi OT | 5 menit | 1–10 menit |

> Semua konfigurasi **dikunci otomatis** setelah START MATCH ditekan.

#### Perilaku Timer

- Timer **hanya berjalan** saat Statistician menekan **RESUME / START**
- Timer **berhenti** saat Statistician menekan **PAUSE** — waktu tersisa disimpan ke Firestore
- Waktu ditampilkan secara lokal di setiap client menggunakan `started_at` Server Timestamp Firebase sebagai acuan bersama — semua device menampilkan waktu yang identik tanpa drift
- Setiap aksi timer (start, pause, resume) dicatat di event log
- **Mode waktu campuran didukung:** karena timer sepenuhnya dalam kendali Statistician, sistem ini fleksibel untuk berbagai format pertandingan. Contoh: Q1–Q3 menggunakan waktu kotor (Statistician tidak menjalankan timer, skor tetap dicatat), kemudian Q4 2 menit terakhir beralih ke waktu bersih (Statistician mulai menjalankan timer). Tidak ada pengaturan khusus — cukup gunakan tombol PAUSE dan RESUME sesuai kebutuhan pertandingan.

```dart
// Kalkulasi waktu tersisa di client — konsisten antar semua device
double currentRemaining(TimerState state) {
  if (!state.isRunning) return state.secondsAtStart;
  final elapsed = DateTime.now()
    .difference(state.startedAt.toDate())
    .inMilliseconds / 1000.0;
  return (state.secondsAtStart - elapsed).clamp(0, double.infinity);
}
```

### 7.7 Shot Zone Map

Sistem menggunakan **9 zona lapangan** dikombinasikan dengan koordinat (x,y). Free throw tidak masuk heatmap.

| Kode Zona | Label | Poin | Keterangan |
|---|---|---|---|
| `PAINT` | Area Cat | 2 | Seluruh area dalam kotak paint |
| `MEDIUM_LEFT` | Medium Kiri | 2 | Di luar paint, dalam arc 3PT, kiri |
| `MEDIUM_CENTER` | Medium Tengah | 2 | Di luar paint, dalam arc 3PT, tengah |
| `MEDIUM_RIGHT` | Medium Kanan | 2 | Di luar paint, dalam arc 3PT, kanan |
| `CORNER_LEFT` | Corner Kiri | 3 | Sudut kiri baseline |
| `CORNER_RIGHT` | Corner Kanan | 3 | Sudut kanan baseline |
| `WING_LEFT` | Wing Kiri | 3 | Sisi kiri, luar arc 3PT |
| `WING_RIGHT` | Wing Kanan | 3 | Sisi kanan, luar arc 3PT |
| `CENTER_3` | Center 3PT | 3 | Atas arc 3PT, top of key |

---

## 8. Statistics Dashboard

Dashboard statistik selalu menampilkan data dalam konteks **event/turnamen** tertentu:

- Top Scorer, Assist Leader, Rebound Leader, Steal Leader, Block Leader
- **FG% breakdown per jenis:** FT%, FG2%, FG3%, FG% keseluruhan
- **Statistik per zona:** persentase tembakan per zona lapangan
- **Shot chart heatmap:** visualisasi titik tembakan di half-court (Flutter CustomPainter)
- Player averages per game: PPG, RPG, APG, SPG, BPG
- Head-to-head comparison antar dua pemain
- Grafik tren performa per pertandingan (menggunakan `fl_chart`)
- Filter: event/turnamen, tahun ajaran, tim (putra/putri), quarter
- **Hasil tes fisik:** tampilan Beep Test, T-Test, Sprint 20m per sesi dan per semester

---

## 9. Responsive & Device Requirements

| Perangkat | Platform | Dashboard Mode | Match Mode | Orientasi |
|---|---|---|---|---|
| **Desktop/Laptop** | Flutter Web | Full feature | Full feature | Landscape |
| **Tablet 10"+** | Android / iOS / Web | Adaptive layout | **Perangkat utama** | Landscape |
| **Smartphone** | Android / iOS | Mobile layout | Read-only (Coach/Mgr) | Portrait |

> Tablet landscape minimum 10 inch adalah **perangkat yang direkomendasikan** untuk Match Mode input.

---

## 10. Tech Stack

### 10.1 Flutter Application

| Teknologi | Versi | Fungsi |
|---|---|---|
| Flutter | 3.x (stable) | Framework lintas platform (Android, iOS, Web) |
| Dart | 3.x | Bahasa pemrograman |
| flutter_riverpod / riverpod | Latest | State management |
| go_router | Latest | Routing dan navigasi |
| freezed + json_serializable | Latest | Data models dan serialization |

### 10.2 Firebase Services

| Layanan | Fungsi |
|---|---|
| **Firebase Authentication** | Login, session management, Email OTP, reCAPTCHA v3 |
| **Cloud Firestore** | Database real-time + offline persistence |
| **Firebase Storage** | Foto profil pemain, foto dokumentasi cedera *(aktif saat Blaze plan; free plan menggunakan base64 di Firestore)* |
| **Cloud Functions (TypeScript)** | Kalkulasi statistik final, audit log otomatis |
| **Firebase App Check** | Proteksi API dari akses tidak sah |
| **Firebase Cloud Messaging** | Push notification jadwal latihan — muncul di notification bar HP (Android/iOS) dan browser notification (Flutter Web) |
| **Firebase Hosting** | Hosting Flutter Web build |

### 10.3 Flutter Firebase Packages

| Package | Fungsi |
|---|---|
| `firebase_core` | Inisialisasi Firebase |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database operations |
| `firebase_storage` | File upload/download |
| `cloud_functions` | Call Cloud Functions |
| `firebase_app_check` | App Check |
| `firebase_messaging` | Push notifications |

### 10.4 Flutter UI & Utility Packages

| Package | Fungsi |
|---|---|
| `fl_chart` | Grafik statistik dan tren |
| `cached_network_image` | Cache foto profil |
| `image_picker` | Upload foto dari kamera/galeri |
| `intl` | Formatting tanggal dan angka |
| `flutter_svg` | Render court overlay SVG |

### 10.5 Cloud Functions (TypeScript)

| Trigger | Fungsi |
|---|---|
| `onMatchFinished` | Hitung statistik final dari seluruh event log |
| `onEventCreated` | Catat audit log otomatis |
| `onPlayerStatusChanged` | Update status pemain terkait injury |

---

## 11. Performance Targets

| Metrik | Target | Keterangan |
|---|---|---|
| **Real-time sync latency** | < 1 detik | Dari write Statistician ke semua device |
| **Firestore read time** | < 300ms | Untuk query dokumen tunggal |
| **App launch time** | < 3 detik | Cold start pada device mid-range |
| **Touch response — Match Mode** | < 100ms | Dari tap ke visual feedback |
| **Court overlay response** | < 50ms | Dari tap tombol ke overlay muncul |
| **Offline cache** | Unlimited | Firestore offline persistence |
| **Uptime Firebase** | 99.95% | SLA Firebase |

---

## 12. Testing Strategy

| Tipe Test | Cakupan | Tools |
|---|---|---|
| **Unit Test** | StatsCalculator, StateMachine, classify_zone(), timer calculation | Flutter test, dart test |
| **Widget Test** | Match Mode panels, Court Overlay, Beep Test panel | flutter_test |
| **Integration Test** | Login → buat event → buat match → live stats → selesai | integration_test package |
| **Firebase Emulator Test** | Firestore rules, Auth, Cloud Functions | Firebase Emulator Suite |
| **Security Rules Test** | Verifikasi RBAC per collection per role | `@firebase/rules-unit-testing` |
| **Load Test** | 5 device bersamaan, 10 events/menit, 40 menit | Firebase performance monitoring |

---

## 13. MVP Scope & Roadmap

### 13.1 MVP — Deliverable Fase Pertama

| Fitur | Keterangan | Prioritas |
|---|---|---|
| ✅ Firebase Auth + RBAC | Login, Email OTP device baru, reCAPTCHA v3, Custom Claims | P0 |
| ✅ Player Management | CRUD pemain putra/putri, foto profil, statistik individu | P0 |
| ✅ Event/Tournament Management | Buat & kelola event, arsip per tahun ajaran | P0 |
| ✅ Match Management | Jadwal, histori, pertandingan terikat event | P0 |
| ✅ Live Match Engine | Fullscreen, real-time Firestore, multi-tablet, undo | P0 |
| ✅ Live Player Stats Tab | Tab real-time di Match Mode untuk Coach & Manager | P0 |
| ✅ Court Overlay & Shot Heatmap | CustomPainter Flutter, 9 zona, koordinat x/y | P0 |
| ✅ MISS 1/2/3 Terpisah | Statistik FT%, FG2%, FG3% akurat | P0 |
| ✅ Timer Waktu Bersih | Server Timestamp Firebase, START/PAUSE/RESUME | P0 |
| ✅ Firestore Real-time | Sinkronisasi < 1 detik antar perangkat | P0 |
| ✅ Offline Persistence | Firestore built-in cache | P0 |
| ✅ Firebase Security Rules | RBAC enforcement di database layer | P0 |
| ✅ Training Schedule | Jadwal dan program latihan | P1 |
| ✅ Injury Management | Laporan cedera, status pemulihan, histori | P1 |
| ✅ Physical Test Management | Beep Test (batch 5), T-Test, Sprint 20m | P1 |
| ✅ Statistics Dashboard | FG% breakdown, shot chart heatmap, event stats | P1 |
| ✅ Audit Log | Cloud Functions trigger otomatis | P1 |
| ✅ Push Notification | Firebase Cloud Messaging untuk jadwal | P2 |

### 13.2 Roadmap Pengembangan Lanjutan

| Fase | Nama | Fitur |
|---|---|---|
| **Fase 2** | Advanced Analytics | Shot heatmap clustering, lineup analytics, performa per quarter |
| **Fase 3** | AI-Powered Insights | Prediksi formasi, rekomendasi strategi, player development tracking |
| **Fase 4** | League Ecosystem | Multi-tim, sistem turnamen, bracket otomatis |

---

## 14. Firestore Data Structure & Document ID Convention

### 14.1 Konvensi Penamaan ID

Semua document ID menggunakan format **lowercase dengan underscore** — tidak boleh mengandung spasi, slash, atau karakter khusus.

| Collection | Format ID | Contoh |
|---|---|---|
| `users` | `{role}_{namaDepan}` | `coach_budi`, `manager_andi` |
| `teams` | `{gender}_{tahunAjaran}` | `putra_2526`, `putri_2526` |
| `players` | `{jersey}_{inisial}_{teamId}` | `7_ar_putra2526`, `3_rn_putri2526` |
| `events` | `{tipe}_{namasingkat}_{tahun}` | `porseni_kota_2526`, `friendly_sman1_2526` |
| `matches` | `{eventId}_vs_{lawan}_{tgl}` | `porseni_kota_2526_vs_sman1_20260315` |
| `matches/.../events` | `q{quarter}_{urutan3digit}` | `q1_001`, `q3_047` |
| `matches/.../player_stats` | `{jersey}_{inisial}` | `7_ar`, `4_dp` |
| `matches/.../lineups` | `{jersey}_{inisial}` | `7_ar`, `11_bs` |
| `physical_test_sessions` | `{tipe}_{teamId}_{tgl}` | `beep_putra2526_20260120` |
| `physical_test_sessions/.../results` | `{jersey}_{inisial}` | `7_ar`, `4_dp` |
| `injury_reports` | `{playerId}_{tgl}` | `7_ar_putra2526_20260205` |
| `training_sessions` | `{teamId}_{tipe}_{tgl}` | `putra2526_fisik_20260110` |

### 14.2 Struktur Collection Utama

```
users/
  coach_budi/
  manager_andi/
  statistician_reza/
  player_7_ar/

teams/
  putra_2526/
  putri_2526/

players/
  7_ar_putra2526/
  4_dp_putra2526/
  3_rn_putri2526/

events/
  porseni_kota_2526/
  friendly_sman1_2526/

matches/
  porseni_kota_2526_vs_sman1_20260315/
    timer_state             ← dokumen tunggal
    events/
      q1_001/
      q1_002/
      q3_047/
    player_stats/
      7_ar/
      4_dp/
    lineups/
      7_ar/
      4_dp/

physical_test_sessions/
  beep_putra2526_20260120/
    results/
      7_ar/
      4_dp/

injury_reports/
  7_ar_putra2526_20260205/

training_sessions/
  putra2526_fisik_20260110/

audit_logs/
  (auto-generated ID oleh Cloud Functions)
```

### 14.3 Format Tahun Ajaran

Tahun ajaran disingkat menjadi 4 digit:
- `2025/2026` → `2526`
- `2026/2027` → `2627`

Format tanggal dalam ID: `YYYYMMDD`
- `15 Maret 2026` → `20260315`

---

## 15. Penutup

Budi Utama Basketball Management System versi 2.0 adalah platform manajemen tim basket berbasis Flutter dan Firebase yang dibangun untuk mendukung seluruh kebutuhan operasional tim basket SMA Budi Utama Yogyakarta.

Sistem ini dirancang dengan fokus pada:

- **Satu codebase** — Flutter untuk Android, iOS, dan Web
- **Real-time** — Firestore listeners menjamin sinkronisasi antar perangkat < 1 detik
- **Offline-first** — Firestore offline persistence bawaan
- **Keamanan berbasis rules** — Firebase Security Rules di seluruh lapisan data
- **ID yang readable** — semua document ID menggunakan format deskriptif untuk kemudahan debugging langsung dari Firestore console
- **Timer bersih** — waktu bersih tanpa shot clock, sesuai kebutuhan internal
- **Statistik akurat** — dual-write strategy (materialized untuk live, Cloud Functions untuk final)

> Dokumen ini adalah **living document** dan harus diperbarui setiap kali ada perubahan keputusan arsitektur, penambahan fitur, atau perubahan scope yang signifikan.

---

*— End of Document —*

*PRD v2.0 Revised · Flutter + Firebase · Budi Utama Basketball Management System · SMA Budi Utama Yogyakarta*
