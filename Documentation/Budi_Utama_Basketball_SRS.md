# SOFTWARE REQUIREMENTS SPECIFICATION (SRS)
## BUDI UTAMA BASKETBALL MANAGEMENT SYSTEM
### SMA Budi Utama Yogyakarta

---

| | |
|---|---|
| **Dokumen** | Software Requirements Specification |
| **Versi** | 2.0 — Revised (Flutter + Firebase) |
| **Tanggal** | Juni 2026 |
| **Status** | Final — Approved for Development |
| **Referensi** | PRD v2.0 Revised |
| **Klasifikasi** | CONFIDENTIAL — INTERNAL USE ONLY |

---

## DAFTAR ISI

1. [Pendahuluan](#1-pendahuluan)
2. [Deskripsi Umum Sistem](#2-deskripsi-umum-sistem)
3. [Kebutuhan Fungsional](#3-kebutuhan-fungsional)
4. [Kebutuhan Non-Fungsional](#4-kebutuhan-non-fungsional)
5. [Kebutuhan Antarmuka Eksternal](#5-kebutuhan-antarmuka-eksternal)
6. [Kebutuhan Keamanan](#6-kebutuhan-keamanan)
7. [Kebutuhan Sistem & Infrastruktur](#7-kebutuhan-sistem--infrastruktur)
8. [Use Case Diagram & Spesifikasi](#8-use-case-diagram--spesifikasi)
9. [Batasan & Asumsi](#9-batasan--asumsi)
10. [Matriks Keterlacakan Kebutuhan](#10-matriks-keterlacakan-kebutuhan)

---

## 1. Pendahuluan

### 1.1 Tujuan Dokumen

Dokumen SRS ini menjabarkan seluruh kebutuhan fungsional dan non-fungsional dari sistem Budi Utama Basketball Management System versi 2.0 yang dibangun menggunakan Flutter dan Firebase. Dokumen ini menjadi kontrak teknis antara tim pengembang, stakeholder, dan tim QA.

### 1.2 Ruang Lingkup Sistem

Sistem mencakup dua modul utama:

1. **Basketball Club Management System** — pengelolaan data pemain, jadwal latihan, pertandingan, cedera, tes fisik, dan statistik
2. **Live Match Statistics Engine** — pencatatan statistik pertandingan secara real-time dengan sinkronisasi multi-perangkat via Firestore

Sistem **tidak mencakup**:
- Manajemen keuangan atau anggaran tim
- Sistem pendaftaran liga eksternal
- Streaming video pertandingan
- Shot clock (tidak diperlukan untuk kebutuhan internal)
- Analitik AI (dijadwalkan di Fase 3)

### 1.3 Definisi & Akronim

| Istilah | Definisi |
|---|---|
| **SRS** | Software Requirements Specification |
| **PRD** | Product Requirements Document |
| **RBAC** | Role-Based Access Control |
| **Firestore** | Cloud Firestore — database NoSQL real-time dari Google Firebase |
| **Custom Claims** | Metadata tambahan pada Firebase Auth token untuk menyimpan role pengguna |
| **Security Rules** | Aturan akses data Firestore yang dievaluasi di server Firebase |
| **Listener** | Firestore real-time listener — menerima update data secara otomatis tanpa polling |
| **Materialized Stats** | Dokumen statistik teragregasi yang diperbarui incremental via `FieldValue.increment()` |
| **Cloud Functions** | Serverless function yang berjalan di server Google, trigger oleh event Firestore |
| **Event Log** | Subcollection `events` dalam dokumen match — bersifat immutable |
| **FG%** | Field Goal Percentage |
| **PPG** | Points Per Game |
| **OT** | Overtime |
| **MFA** | Multi-Factor Authentication |
| **reCAPTCHA v3** | Anti-bot verification Google yang berjalan invisible di background |
| **Email OTP** | One-Time Password yang dikirim ke email untuk verifikasi device baru |
| **Beep Test** | Tes daya tahan aerobik dengan level dan shuttle |
| **T-Test** | Tes kelincahan berbentuk pola huruf T |
| **Sprint 20 Meter** | Tes kecepatan lari jarak 20 meter |

### 1.4 Referensi Dokumen

- PRD v2.0 Revised — Budi Utama Basketball Management System
- Firebase Documentation — Cloud Firestore, Authentication, Security Rules
- OWASP Mobile Top 10
- Flutter Documentation

---

## 2. Deskripsi Umum Sistem

### 2.1 Perspektif Sistem

Budi Utama Basketball Management System adalah aplikasi Flutter lintas platform yang berkomunikasi langsung dengan layanan Firebase:

```
[Pengguna] ←→ [Flutter App: Android/iOS/Web] ←→ [Firebase Platform]
                                                  ├── Firebase Auth
                                                  ├── Cloud Firestore
                                                  ├── Firebase Storage
                                                  └── Cloud Functions
```

Tidak ada backend server custom — seluruh logika bisnis sederhana dijalankan di Flutter client, sedangkan logika yang membutuhkan kepercayaan server (audit log, statistik final) dijalankan di Cloud Functions.

### 2.2 Fungsi Utama Sistem

- **F-01** Manajemen data pemain dan roster tim
- **F-02** Penjadwalan dan pencatatan sesi latihan
- **F-03** Manajemen pertandingan dan histori hasil
- **F-04** Pencatatan statistik pertandingan real-time
- **F-05** Manajemen laporan cedera pemain
- **F-06** Dashboard statistik dan analitik performa
- **F-07** Autentikasi dan otorisasi berbasis peran (Firebase Auth + Custom Claims)
- **F-08** Audit log otomatis via Cloud Functions
- **F-09** Manajemen tes fisik pemain

### 2.3 Karakteristik Pengguna

| Pengguna | Literasi Teknis | Frekuensi | Perangkat Utama |
|---|---|---|---|
| Coach | Menengah | Harian | Android/iOS tablet atau laptop |
| Team Manager | Menengah | Harian | Android/iOS tablet atau laptop |
| Statistician | Menengah–Tinggi | Saat pertandingan | Android/iOS tablet landscape (10"+) |
| Player | Dasar–Menengah | Mingguan | Android/iOS smartphone |

### 2.4 Batasan Umum

- Sistem memerlukan koneksi internet untuk operasi penuh; mode offline tersedia untuk input Match Mode
- Match Mode dioptimalkan untuk tablet landscape minimum 10 inch
- Bahasa antarmuka: Indonesia
- Platform: Android 8.0+, iOS 14+, browser modern (Chrome, Safari, Firefox, Edge)
- Shot clock tidak tersedia — sistem ini untuk penggunaan internal bukan kompetisi resmi

---

## 3. Kebutuhan Fungsional

Format kode: `FR-[MODUL]-[NOMOR]`

---

### 3.1 Modul Autentikasi & Otorisasi (AUTH)

#### FR-AUTH-01: Login Pengguna
- **Deskripsi:** Sistem menyediakan layar login dengan field email dan password menggunakan Firebase Authentication
- **Input:** Email (format valid), Password (min 8 karakter)
- **Output:** Firebase Auth session (dikelola otomatis oleh SDK)
- **Perlindungan:** reCAPTCHA v3 invisible aktif di background setiap percobaan login
- **Kondisi Sukses:** Pengguna diarahkan ke halaman sesuai role (Custom Claims)
- **Kondisi Gagal:** Pesan error generik ditampilkan
- **Prioritas:** P0

#### FR-AUTH-02: Verifikasi Device Baru (Email OTP)
- **Deskripsi:** Saat Coach atau Manager login dari device yang belum pernah digunakan, sistem mengirimkan Email OTP via Firebase Auth untuk verifikasi tambahan
- **Trigger:** Login berhasil dari device_id yang tidak ada di daftar trusted devices pengguna
- **Mekanisme:** Email link atau 6-digit OTP dikirim ke email terdaftar
- **Catatan:** Tidak diperlukan di setiap login — hanya saat device baru
- **Prioritas:** P0

#### FR-AUTH-03: Logout Pengguna
- **Deskripsi:** Sistem menyediakan fungsi logout yang mengakhiri Firebase Auth session
- **Aksi:** `FirebaseAuth.instance.signOut()` — semua listener Firestore berhenti otomatis
- **Prioritas:** P0

#### FR-AUTH-04: Role-Based Access Control via Custom Claims
- **Deskripsi:** Role pengguna disimpan dalam Firebase Auth Custom Claims dan diverifikasi di Firebase Security Rules untuk setiap operasi database
- **Peran:** `coach`, `manager`, `statistician`, `player`
- **Validasi:** Dilakukan di Security Rules (server-side) — bukan hanya di Flutter UI
- **Prioritas:** P0

#### FR-AUTH-05: Session Persistence
- **Deskripsi:** Firebase SDK mempertahankan session pengguna secara otomatis antar sesi aplikasi — pengguna tidak perlu login ulang setiap membuka aplikasi
- **Prioritas:** P0

#### FR-AUTH-06: Manajemen Akun (oleh Manager)
- **Deskripsi:** Manager dapat membuat akun pengguna baru via Cloud Functions (karena pembuatan akun Firebase dengan Custom Claims harus dilakukan via Admin SDK)
- **Prioritas:** P1

---

### 3.2 Modul Player Management (PLY)

#### FR-PLY-01: Tambah Pemain
- **Deskripsi:** Manager dapat menambahkan data pemain baru
- **Input:** Nama lengkap, nomor jersey (unik per tim), posisi, tinggi (cm), berat (kg), tim (putra/putri), foto profil (opsional, max 2MB, JPG/PNG)
- **Document ID:** `{jersey}_{inisial}_{teamId}` — contoh: `7_ar_putra2526`
- **Validasi:** Nomor jersey tidak boleh duplikat dalam satu tim
- **Prioritas:** P0

#### FR-PLY-02: Edit Data Pemain
- **Deskripsi:** Manager dapat mengubah data pemain yang sudah ada
- **Catatan:** Cloud Functions mencatat perubahan di audit log
- **Prioritas:** P0

#### FR-PLY-03: Nonaktifkan Pemain
- **Deskripsi:** Manager dapat mengubah status pemain (soft delete — dokumen tidak dihapus)
- **Status field:** `active` / `injured` / `inactive`
- **Prioritas:** P0

#### FR-PLY-04: Lihat Profil Pemain
- **Deskripsi:** Coach, Manager, dan Player (data sendiri) dapat melihat profil lengkap pemain termasuk statistik dan riwayat tes fisik
- **Prioritas:** P0

#### FR-PLY-05: Upload Foto Pemain
- **Deskripsi:** Manager dapat mengunggah foto profil pemain
- **Implementasi Free Plan:** Foto dikompres di Flutter menggunakan package `flutter_image_compress`, dikonversi ke base64, dan disimpan sebagai string di field `photo_base64` dokumen player di Firestore. Maksimal ukuran foto setelah kompresi: **200KB** (agar dokumen Firestore tetap jauh di bawah batas 1MB)
- **Implementasi Blaze Plan:** Foto diupload ke Firebase Storage path `players/{playerId}/profile.jpg`; field `photo_url` di dokumen player menyimpan URL download
- **Validasi:** Max 2MB input dari user; dikompres otomatis sebelum disimpan
- **Prioritas:** P1

#### FR-PLY-06: Filter & Pencarian Pemain
- **Deskripsi:** Pencarian berdasarkan nama, nomor jersey, posisi, dan status
- **Implementasi:** Firestore query dengan compound index atau client-side filter untuk dataset kecil
- **Prioritas:** P1

---

### 3.3 Modul Training Management (TRN)

#### FR-TRN-01: Buat Jadwal Latihan
- **Deskripsi:** Manager dapat membuat sesi latihan baru
- **Input:** Tanggal, waktu mulai/selesai, lokasi, tipe sesi, deskripsi program
- **Document ID:** `{teamId}_{tipe}_{tanggal}` — contoh: `putra2526_fisik_20260110`
- **Prioritas:** P1

#### FR-TRN-02: Edit & Batalkan Jadwal Latihan
- **Deskripsi:** Manager dapat mengubah atau membatalkan sesi yang belum berlangsung
- **Prioritas:** P1

#### FR-TRN-03: Lihat Jadwal Latihan
- **Deskripsi:** Semua pengguna dapat melihat jadwal latihan mendatang dan histori
- **Prioritas:** P1

#### FR-TRN-04: Notifikasi Jadwal
- **Deskripsi:** Sistem mengirimkan push notification via Firebase Cloud Messaging (FCM) saat jadwal latihan baru dibuat atau diubah
- **Tampilan:** Notifikasi muncul di notification bar HP untuk Android dan iOS; browser notification untuk Flutter Web
- **Prioritas:** P2

---

### 3.4 Modul Match Management (MCH)

#### FR-MCH-01: Buat Pertandingan
- **Deskripsi:** Manager dapat membuat entri pertandingan baru yang terikat pada event
- **Input:** Event (wajib), tanggal, waktu, nama lawan, venue, tipe (home/away/neutral), fase
- **Document ID:** `{eventId}_vs_{lawan}_{tgl}` — contoh: `porseni_kota_2526_vs_sman1_20260315`
- **Prioritas:** P0

#### FR-MCH-02: Konfigurasi Timer Pertandingan
- **Deskripsi:** Manager mengatur parameter timer sebelum pertandingan dimulai
- **Parameter:** Durasi per quarter (1–20 menit), jumlah periode (4 quarter/2 babak), durasi OT (1–10 menit)
- **Catatan:** Shot clock tidak tersedia
- **Kunci:** Konfigurasi dikunci otomatis setelah START MATCH ditekan (`timer_config_locked: true`)
- **Prioritas:** P0

#### FR-MCH-03: Edit & Batalkan Pertandingan
- **Deskripsi:** Manager dapat mengubah detail atau membatalkan pertandingan berstatus `scheduled`
- **Prioritas:** P0

#### FR-MCH-04: Rekap Statistik Pertandingan
- **Deskripsi:** Setelah `POST_MATCH`, Cloud Functions menghasilkan rekap statistik final yang tersimpan di dokumen match
- **Prioritas:** P0

#### FR-MCH-05: Mulai Match Mode
- **Deskripsi:** Statistician memulai Match Mode dari halaman detail pertandingan
- **Aksi:** Update `status: ongoing`, `current_state: PRE_MATCH`; navigasi ke Match Mode fullscreen
- **Prioritas:** P0

---

### 3.5 Modul Live Match Statistics Engine (LMS)

#### FR-LMS-01: Tampilan Header Real-Time
- **Deskripsi:** Header Match Mode menampilkan score, quarter aktif, timer, sisa timeout, foul count, dan status koneksi Firestore
- **Update timer:** Dihitung lokal setiap frame menggunakan `server_timestamp` sebagai acuan bersama
- **Status koneksi:** Monitor via `FirebaseFirestore.instance.snapshotsInSync()`
- **Prioritas:** P0

#### FR-LMS-02: Pilih Pemain Aktif
- **Deskripsi:** Left Panel menampilkan 5 pemain di lapangan; Statistician memilih pemain sebelum mencatat aksi
- **Data sumber:** Firestore listener pada `matches/{matchId}/lineups` dimana `is_on_court == true`
- **Prioritas:** P0

#### FR-LMS-03: Input Aksi Pemain Tim Sendiri
- **Deskripsi:** Statistician mencatat aksi: +1, +2, +3, MISS 1, MISS 2, MISS 3, AST, TO, STL, BLK, OREB, DREB, FOUL
- **Alur Shot Input (+2, +3, MISS 2, MISS 3):**
  1. Tap tombol aksi
  2. Court overlay muncul (Flutter CustomPainter half-court)
  3. Tap lokasi di court overlay
  4. Sistem deteksi zona otomatis dari koordinat
  5. Event disimpan ke `matches/{matchId}/events/{q{n}_{seq}}`
  6. `player_stats` diperbarui via `FieldValue.increment()`
  7. Firestore listener broadcast ke semua device
- **Free Throw (+1, MISS 1):** Court overlay tidak muncul; event langsung disimpan tanpa koordinat
- **Timeout overlay:** 15 detik tanpa tap → overlay tutup otomatis, aksi dibatalkan
- **Prioritas:** P0

#### FR-LMS-04: Input Aksi Tim Lawan
- **Deskripsi:** Right Panel untuk aksi lawan: +1, +2, +3, FOUL (agregat tim, tanpa breakdown pemain). Tembakan gagal tim lawan tidak dicatat — hanya skor masuk dan foul
- **Prioritas:** P0

#### FR-LMS-05: Kontrol Timer
- **Deskripsi:** Statistician mengontrol timer dengan tombol START, PAUSE, dan RESUME. Timer sepenuhnya dalam kendali manual Statistician
- **Implementasi Firestore:**
  - START/RESUME: tulis `{is_running: true, started_at: FieldValue.serverTimestamp(), seconds_at_start: X}`
  - PAUSE: hitung elapsed lokal, tulis `{is_running: false, seconds_at_start: remaining, started_at: null}`
- **Tampilan client:** Setiap device menghitung waktu tersisa dari `started_at` Server Timestamp Firebase — semua device sinkron tanpa drift
- **Mode waktu campuran:** Karena timer sepenuhnya dikendalikan manual, sistem mendukung format pertandingan campuran. Contoh: Q1–Q3 menggunakan waktu kotor (Statistician tidak menjalankan timer, hanya mencatat skor), kemudian beralih ke waktu bersih di Q4 2 menit terakhir (Statistician mulai RESUME timer). Tidak diperlukan pengaturan khusus — fleksibilitas penuh ada di tangan Statistician
- **Shot clock:** Tidak tersedia
- **Prioritas:** P0

#### FR-LMS-06: Transisi State Pertandingan
- **Deskripsi:** Statistician melakukan transisi state sesuai urutan valid dengan dialog konfirmasi
- **Urutan:** PRE_MATCH → Q1_ACTIVE → Q1_BREAK → Q2_ACTIVE → HALFTIME → Q3_ACTIVE → Q3_BREAK → Q4_ACTIVE → CHECK_SCORE → [OT_ACTIVE] → POST_MATCH
- **Implementasi:** Update field `current_state` di dokumen match
- **Prioritas:** P0

#### FR-LMS-07: Sistem Substitusi
- **Deskripsi:** Statistician melakukan substitusi pemain melalui Bottom Panel
- **Alur:** Pilih OUT → pilih IN → konfirmasi
- **Implementasi:** Update `is_on_court` di dokumen lineups; catat event `SUBSTITUTION`
- **Prioritas:** P0

#### FR-LMS-08: Undo Last Action
- **Deskripsi:** Statistician membatalkan aksi statistik terakhir
- **Mekanisme:**
  1. Ambil event terakhir dengan `is_undone == false`
  2. Update event tersebut: `is_undone: true`
  3. Tambah event baru `UNDO` yang mereferensi event asli
  4. Decrement `player_stats` menggunakan `FieldValue.increment(-1)` atau nilai negatif
- **Catatan:** Security Rules mengizinkan update `is_undone` field saja — field lain immutable
- **Prioritas:** P0

#### FR-LMS-09: Event Timeline
- **Deskripsi:** Log real-time seluruh event dalam urutan kronologis terbalik
- **Implementasi:** Firestore listener dengan `orderBy('created_at', descending: true)`
- **Format:** `Q3 06:24 #7 3PT MADE`
- **Prioritas:** P0

#### FR-LMS-10: Timeout Management
- **Deskripsi:** Statistician mencatat timeout untuk kedua tim; timer berhenti saat timeout aktif
- **Prioritas:** P1

#### FR-LMS-11: Multi-Device Sync via Firestore
- **Deskripsi:** Semua data pertandingan tersinkron ke semua device yang menjalankan listener dalam waktu < 1 detik
- **Mekanisme:** Firestore real-time listeners — tidak memerlukan WebSocket server atau Socket.io
- **Prioritas:** P0

#### FR-LMS-12: Offline Mode
- **Deskripsi:** Jika koneksi terputus, Firestore cache lokal memungkinkan input tetap berjalan; sync otomatis saat koneksi pulih
- **Implementasi:** `persistenceEnabled: true` pada Firestore settings
- **Indikator:** Status koneksi ditampilkan di header Match Mode
- **Prioritas:** P1

#### FR-LMS-13: Kunci Data Post-Match
- **Deskripsi:** Setelah `POST_MATCH`, Security Rules menolak semua write ke subcollection events dan lineups
- **Implementasi:** Security Rules cek `resource.data.current_state != 'POST_MATCH'`
- **Prioritas:** P0

#### FR-LMS-14: Court Overlay — Pemilihan Lokasi Tembakan
- **Deskripsi:** Overlay interaktif half-court untuk input lokasi tembakan +2, +3, MISS 2, MISS 3
- **Implementasi:** Flutter `CustomPainter` dengan `GestureDetector` untuk tap detection
- **Zona:** 9 zona (PAINT, MEDIUM_LEFT/CENTER/RIGHT, CORNER_LEFT/RIGHT, WING_LEFT/RIGHT, CENTER_3)
- **Output:** `zone`, `shot_x` (0.0–1.0), `shot_y` (0.0–1.0), `shot_distance_ft`
- **Free throw:** Tidak menggunakan court overlay
- **Validasi konsistensi:** Dialog konfirmasi jika zona tap tidak sesuai tombol (misal: tap zona 3PT tapi tombol +2)
- **Prioritas:** P0

#### FR-LMS-15: Pemisahan MISS per Jenis Tembakan
- **Deskripsi:** Tembakan gagal dipisah menjadi MISS 1, MISS 2, MISS 3 untuk akurasi statistik
- **Formula:**
  - `FT%`  = ft_made / (ft_made + miss_1)
  - `FG2%` = fg2_made / (fg2_made + miss_2)
  - `FG3%` = fg3_made / (fg3_made + miss_3)
  - `FG%`  = (fg2_made + fg3_made) / (fg2_made + miss_2 + fg3_made + miss_3)
- **Prioritas:** P0

#### FR-LMS-16: Live Player Stats Tab
- **Deskripsi:** Tab 2 di Center Panel menampilkan statistik real-time semua pemain via Firestore listener pada `matches/{matchId}/player_stats`
- **Update:** Otomatis setiap kali `player_stats` dokumen berubah — tanpa polling
- **Prioritas:** P0

#### FR-LMS-17: Waktu Bermain Pemain (Minutes Played)
- **Deskripsi:** Sistem mencatat durasi bermain setiap pemain
- **Implementasi:** Field `entered_at_clock` dan `total_seconds_played` di dokumen lineup; dihitung dan diperbarui saat substitusi
- **Prioritas:** P1

---

### 3.6 Modul Injury Management (INJ)

#### FR-INJ-01: Buat Laporan Cedera
- **Input:** ID pemain, tanggal, jenis cedera, deskripsi, bagian tubuh, tingkat keparahan, estimasi pemulihan, foto dokumentasi (opsional)
- **Document ID:** `{playerId}_{tanggal}` — contoh: `7_ar_putra2526_20260205`
- **Foto (Free Plan):** Dikompres dan disimpan sebagai base64 string di field `photo_base64` dokumen injury. Maksimal ukuran setelah kompresi: **300KB**
- **Foto (Blaze Plan):** Upload ke Firebase Storage path `injuries/{injuryId}/photo.jpg`
- **Prioritas:** P1

#### FR-INJ-02: Update Status Pemulihan
- **Status:** `active` → `recovery` → `cleared`
- **Saat cleared:** Update `player.status` ke `active` secara otomatis
- **Prioritas:** P1

#### FR-INJ-03: Histori Cedera Pemain
- **Query:** Firestore query `injury_reports` dimana `player_id == playerId`
- **Prioritas:** P1

#### FR-INJ-04: Laporan Cedera Tim
- **Deskripsi:** Ringkasan kondisi cedera seluruh tim dalam satu tampilan
- **Query:** Firestore query `injury_reports` dimana `status != cleared` dan `team_id == teamId`
- **Prioritas:** P1

---

### 3.7 Modul Physical Test Management (PHY)

#### FR-PHY-01: Jadwalkan Sesi Tes Fisik
- **Input:** Jenis tes, tanggal, tim yang diuji
- **Document ID:** `{tipe}_{teamId}_{tgl}` — contoh: `beep_putra2526_20260120`
- **Prioritas:** P1

#### FR-PHY-02: Beep Test — Batch 5 Pemain
- **Alur:**
  1. Operator memilih 5 pemain dari roster
  2. UI menampilkan 5 kartu besar dengan tombol PASS/FAIL tanpa scroll
  3. Sistem memutar audio beep test otomatis (bundle di dalam app menggunakan package `audioplayers`) — operator tidak memerlukan speaker eksternal
  4. Audio mengumumkan level dan shuttle secara otomatis sesuai standar beep test
  5. Saat pemain gagal, operator mengetuk FAIL — sistem mencatat level dan shuttle terakhir secara otomatis dari audio yang sedang berjalan, operator bisa konfirmasi atau koreksi manual
  6. Setelah batch selesai, pilih 5 pemain berikutnya
  7. Stop Sesi kapan saja — `is_stopped_early: true`; audio berhenti otomatis
- **Simpan ke:** `physical_test_sessions/{sessionId}/results/{jersey_inisial}`
- **Data:** `beep_level`, `beep_shuttle`, `created_at`
- **Prioritas:** P1

#### FR-PHY-03: T-Test — Individual Stopwatch
- **Alur:** Pilih pemain → Mulai (stopwatch) → Selesai → Pilih berikutnya / Stop Sesi
- **Data:** `time_seconds` (presisi milidetik), `created_at`
- **Prioritas:** P1

#### FR-PHY-04: Sprint 20 Meter — Individual Stopwatch
- **Alur:** Identik dengan FR-PHY-03
- **Prioritas:** P1

#### FR-PHY-05: Hasil Per Sesi
- **Query:** Semua dokumen di `physical_test_sessions/{sessionId}/results`
- **Prioritas:** P1

#### FR-PHY-06: Hasil Per Semester (Tren)
- **Query:** Firestore query `physical_test_sessions` dimana `team_id == X AND academic_year == Y AND semester == Z AND test_type == T`
- **Tampilan:** Tren perkembangan per pemain antar sesi dalam satu semester
- **Prioritas:** P1

#### FR-PHY-07: Riwayat Tes Fisik Pemain
- **Query:** Semua results dimana `player_id == playerId` di seluruh sesi
- **Prioritas:** P1

---

### 3.8 Modul Statistics Dashboard (STT)

#### FR-STT-01: Leaderboard Statistik Tim
- **Sumber data:** `matches/.../player_stats` teragregasi per event
- **Filter:** Per event/turnamen, per tim
- **Prioritas:** P1

#### FR-STT-02: Statistik Individu Pemain
- **Konten:** PPG, RPG, APG, SPG, BPG, FG%, FG2%, FG3%, FT%, FG% per zona
- **Prioritas:** P1

#### FR-STT-03: Shot Chart & Heatmap
- **Implementasi:** Flutter `CustomPainter` render titik tembakan di atas gambar half-court
- **Data:** Query events dimana `shot_x != null AND is_undone == false`
- **Visual:** Titik hijau (made), merah (miss); overlay warna per zona berdasarkan FG%
- **Free throw:** Tidak ditampilkan di heatmap
- **Prioritas:** P1

#### FR-STT-04: Grafik Tren Performa
- **Implementasi:** Package `fl_chart`
- **Tipe:** Line chart (tren), bar chart (perbandingan)
- **Prioritas:** P1

#### FR-STT-05: Komparasi Pemain
- **Konten:** Statistik dua pemain side-by-side
- **Prioritas:** P1

---

### 3.9 Modul Audit Log (AUD)

#### FR-AUD-01: Pencatatan Otomatis via Cloud Functions
- **Trigger:** Firestore `onWrite` trigger pada collection utama
- **Data:** `{timestamp, user_id, role, action_type, entity_type, entity_id, old_value, new_value}`
- **Simpan ke:** Collection `audit_logs` dengan ID auto-generated
- **Prioritas:** P1

#### FR-AUD-02: Tampilan Log
- **Akses:** Coach dan Manager
- **Filter:** Tanggal, pengguna, tipe aksi
- **Prioritas:** P1

#### FR-AUD-03: Immutability
- **Implementasi:** Security Rules melarang semua write ke `audit_logs` dari client
- **Hanya:** Cloud Functions Admin SDK yang bisa menulis ke collection ini
- **Retention:** Minimum 1 tahun
- **Prioritas:** P1

---

## 4. Kebutuhan Non-Fungsional

### 4.1 Performa

| ID | Kebutuhan | Target |
|---|---|---|
| NFR-PRF-01 | Real-time sync latency | < 1 detik (Firestore listener) |
| NFR-PRF-02 | Firestore read — dokumen tunggal | < 300ms |
| NFR-PRF-03 | App launch time | < 3 detik cold start |
| NFR-PRF-04 | Touch response Match Mode | < 100ms |
| NFR-PRF-05 | Court overlay response | < 50ms |
| NFR-PRF-06 | Offline write (ke cache) | Instan — tidak tergantung network |

### 4.2 Ketersediaan & Keandalan

| ID | Kebutuhan | Target |
|---|---|---|
| NFR-AVL-01 | Firebase uptime SLA | 99.95% |
| NFR-AVL-02 | Offline data persistence | Unlimited via Firestore cache |
| NFR-AVL-03 | Sync setelah offline | Otomatis saat koneksi pulih |

### 4.3 Usabilitas

- **NFR-USB-01:** Semua aksi kritis Match Mode dapat dilakukan dengan maksimal 2 tap
- **NFR-USB-02:** Touch target minimum 44×44 dp di Match Mode
- **NFR-USB-03:** Visual feedback < 100ms setelah setiap interaksi
- **NFR-USB-04:** Pesan error dalam bahasa Indonesia yang jelas
- **NFR-USB-05:** Mendukung landscape dan portrait di tablet
- **NFR-USB-06:** Beep Test UI menampilkan 5 kartu pemain tanpa scroll

### 4.4 Pemeliharaan

- **NFR-MNT-01:** Semua perubahan Firestore Security Rules melalui version control
- **NFR-MNT-02:** Cloud Functions menggunakan TypeScript dengan strict mode
- **NFR-MNT-03:** Unit test coverage minimal 70% untuk logika statistik dan state machine
- **NFR-MNT-04:** Firebase Emulator Suite digunakan untuk testing lokal

---

## 5. Kebutuhan Antarmuka Eksternal

### 5.1 Antarmuka Pengguna

#### Dashboard Mode (mobile & web)
- Bottom navigation di smartphone; sidebar di tablet dan web
- Tema warna konsisten dengan design system Flutter

#### Match Mode (tablet)
- Fullscreen tanpa navigasi standar
- Layout: Left (pemain) | Center (aksi/stats 2 tab) | Right (lawan) | Bottom (substitusi)
- Semua tombol berukuran besar, touch-optimized

#### Physical Test Mode
- Beep Test: 5 kartu besar tanpa scroll
- T-Test & Sprint: Stopwatch besar dengan nama pemain aktif

### 5.2 Antarmuka Firebase SDK

| Komunikasi | SDK | Keterangan |
|---|---|---|
| Auth | `firebase_auth` Flutter package | Login, session, OTP |
| Database read | Firestore `snapshots()` | Real-time listener |
| Database write | Firestore `set()`, `update()`, `FieldValue.increment()` | Write operations |
| File upload | `firebase_storage` | Foto profil, foto cedera |
| Push notification | `firebase_messaging` | Notifikasi jadwal |
| Functions call | `cloud_functions` | Trigger manual functions |

---

## 6. Kebutuhan Keamanan

### 6.1 Autentikasi

- **SEC-01:** Password di-hash oleh Firebase Auth (bcrypt managed by Google) — tidak ada hash manual
- **SEC-02:** reCAPTCHA v3 aktif invisible di semua form login
- **SEC-03:** Email OTP wajib untuk Coach dan Manager saat login dari device baru
- **SEC-04:** Session dikelola otomatis Firebase SDK; tidak ada JWT manual atau refresh token logic
- **SEC-05:** Maksimal 5 percobaan login gagal → Firebase Auth automatic lockout

### 6.2 Otorisasi

- **SEC-06:** Role disimpan di Firebase Custom Claims — tidak bisa dimodifikasi dari client
- **SEC-07:** Setiap operasi Firestore divalidasi oleh Security Rules di server Firebase
- **SEC-08:** Flutter UI hanya menyembunyikan tampilan — Security Rules tetap memvalidasi
- **SEC-09:** Firebase App Check mencegah akses dari aplikasi tidak sah (non-Flutter resmi)

### 6.3 Perlindungan Data

- **SEC-10:** Semua komunikasi menggunakan HTTPS (managed by Firebase)
- **SEC-11:** `google-services.json` dan `GoogleService-Info.plist` tidak boleh di-commit ke repository
- **SEC-12:** Firebase Storage Security Rules membatasi akses foto berdasarkan role
- **SEC-13:** Audit log hanya bisa ditulis oleh Cloud Functions Admin SDK — client tidak bisa write

---

## 7. Kebutuhan Sistem & Infrastruktur

### 7.1 Kebutuhan Device Client

| Platform | Minimum |
|---|---|
| Android | Android 8.0 (API 26) |
| iOS | iOS 14.0 |
| Flutter Web | Chrome 100+, Safari 15+, Firefox 100+, Edge 100+ |
| Layar Tablet Match Mode | Minimum 10 inch, 1280×800 px |
| Koneksi internet | Minimum 5 Mbps untuk Match Mode multi-tablet |

### 7.2 Firebase Project Setup

| Layanan | Tier Minimum |
|---|---|
| Firebase Authentication | Spark (free) |
| Cloud Firestore | Spark (free) untuk MVP; Blaze (pay-as-you-go) untuk produksi |
| Firebase Storage | Spark 5GB |
| Cloud Functions | Blaze (wajib untuk Cloud Functions) |
| Firebase Hosting | Spark |

### 7.3 Development Environment

- Flutter SDK 3.x stable
- Dart SDK 3.x
- Firebase CLI untuk deploy Functions, Hosting, Security Rules
- Firebase Emulator Suite untuk testing lokal
- Android Studio / VS Code dengan Flutter extension

---

## 8. Use Case Diagram & Spesifikasi

### 8.1 Daftar Use Case

| ID | Use Case | Aktor |
|---|---|---|
| UC-01 | Login ke Sistem | Semua pengguna |
| UC-02 | Kelola Data Pemain | Manager |
| UC-03 | Buat Jadwal Latihan | Manager |
| UC-04 | Buat & Kelola Pertandingan | Manager |
| UC-05 | Mulai Match Mode | Statistician |
| UC-06 | Input Statistik Live | Statistician |
| UC-07 | Substitusi Pemain | Statistician |
| UC-08 | Undo Aksi Statistik | Statistician |
| UC-09 | Transisi State Pertandingan | Statistician |
| UC-10 | Buat Laporan Cedera | Coach / Manager |
| UC-11 | Lihat Dashboard Statistik | Coach / Manager / Player |
| UC-12 | Jalankan Sesi Tes Fisik | Manager / Coach |
| UC-13 | Monitor Live Player Stats | Coach / Manager |

---

### 8.2 Spesifikasi Use Case Detail

#### UC-05: Mulai Match Mode

| | |
|---|---|
| **Aktor** | Statistician |
| **Prasyarat** | Login berhasil; pertandingan berstatus `scheduled` |
| **Trigger** | Statistician tap "Mulai Pertandingan" |
| **Alur Normal** | 1. Statistician buka halaman detail pertandingan<br>2. Tap "Mulai Pertandingan"<br>3. Dialog konfirmasi lineup pemain awal<br>4. Pilih 5 pemain starter<br>5. Konfirmasi<br>6. Firestore: update `status: ongoing`, `current_state: PRE_MATCH`<br>7. Update lineups: `is_starter: true`, `is_on_court: true` untuk 5 pemain<br>8. Navigasi ke Match Mode fullscreen<br>9. Semua device yang listening otomatis menerima perubahan state |
| **Pasca Kondisi** | Pertandingan PRE_MATCH aktif; semua Firestore listeners pada match ini menerima state terbaru |
| **Prioritas** | P0 |

---

#### UC-06: Input Statistik Live

| | |
|---|---|
| **Aktor** | Statistician |
| **Prasyarat** | Match Mode aktif; state salah satu dari Q_ACTIVE atau OT_ACTIVE |
| **Trigger** | Aksi terjadi di lapangan |
| **Alur Normal** | 1. Tap pemain di Left Panel<br>2. Tap tombol aksi (contoh: +2)<br>3. Court overlay muncul (Flutter CustomPainter)<br>4. Tap lokasi tembakan<br>5. Sistem klasifikasi zona otomatis<br>6. **Batch write Firestore:**<br>&nbsp;&nbsp;- Tambah dokumen baru di `events/q3_047`<br>&nbsp;&nbsp;- Increment `player_stats/7_ar`: `{fg2_made: +1, fg2_attempted: +1, points: +2}`<br>&nbsp;&nbsp;- Increment `player_stats/7_ar` zona: `{shot_zones.MEDIUM_LEFT.made: +1}`<br>7. Firestore push update ke semua listeners<br>8. Tab 2 Live Player Stats diperbarui otomatis di semua device |
| **Pasca Kondisi** | Event tersimpan immutable; player_stats terupdate; semua device sinkron |
| **Prioritas** | P0 |

---

#### UC-08: Undo Aksi Statistik

| | |
|---|---|
| **Aktor** | Statistician |
| **Prasyarat** | Minimal satu event statistik sudah diinput |
| **Trigger** | Tap tombol UNDO |
| **Alur Normal** | 1. Tap UNDO<br>2. Dialog: "Batalkan Q3 06:24 #7 3PT MADE?"<br>3. Konfirmasi<br>4. **Batch write Firestore:**<br>&nbsp;&nbsp;- Update event terakhir: `is_undone: true`<br>&nbsp;&nbsp;- Tambah event baru: `{action_type: UNDO, undo_ref_id: eventId}`<br>&nbsp;&nbsp;- Decrement `player_stats`: `{fg2_made: -1, fg2_attempted: -1, points: -2}`<br>5. Firestore push ke semua listeners |
| **Pasca Kondisi** | Event asli tetap ada dengan `is_undone: true`; statistik terkoreksi |
| **Prioritas** | P0 |

---

## 9. Batasan & Asumsi

### 9.1 Batasan Sistem

- Tidak ada penghapusan permanen data statistik pertandingan yang sudah selesai
- Shot clock tidak tersedia — sistem untuk keperluan internal
- Maksimal satu pertandingan aktif per tim pada waktu yang sama
- Firestore document size maksimal 1 MB — diatasi dengan subcollection events
- Foto disimpan di Firebase Storage — bukan inline di Firestore
- Beep Test hanya menampilkan 5 pemain per batch

### 9.2 Asumsi

- Semua Statistician mendapat pelatihan sebelum pertandingan pertama
- Venue pertandingan memiliki Wi-Fi minimum 10 Mbps
- Tablet Match Mode: minimum 10 inch landscape
- Timer menggunakan Server Timestamp Firebase untuk konsistensi antar device
- Semester: Semester 1 (Juli–Desember), Semester 2 (Januari–Juni)
- Tim Budi Utama memiliki akun Google/Firebase aktif

---

## 10. Matriks Keterlacakan Kebutuhan

| Kode FR | Nama Kebutuhan | Tujuan PRD | Prioritas |
|---|---|---|---|
| FR-AUTH-01 s.d 06 | Autentikasi Firebase + reCAPTCHA + Email OTP | Keamanan data | P0/P1 |
| FR-PLY-01 s.d 06 | Player Management | Pengelolaan data pemain | P0/P1 |
| FR-TRN-01 s.d 04 | Training Management | Jadwal latihan + notifikasi FCM | P1/P2 |
| FR-MCH-01 s.d 05 | Match Management | Manajemen pertandingan | P0 |
| FR-LMS-01 s.d 17 | Live Match Engine | Statistik real-time, Live Player Stats | P0/P1 |
| FR-INJ-01 s.d 04 | Injury Management | Riwayat cedera pemain | P1 |
| FR-PHY-01 s.d 07 | Physical Test Management | Tes fisik pemain | P1 |
| FR-STT-01 s.d 05 | Statistics Dashboard | Dashboard analitik + shot chart | P1 |
| FR-AUD-01 s.d 03 | Audit Log via Cloud Functions | Akuntabilitas sistem | P1 |

---

*— End of Document —*

*SRS v2.0 Revised · Flutter + Firebase · Budi Utama Basketball Management System · SMA Budi Utama Yogyakarta*
