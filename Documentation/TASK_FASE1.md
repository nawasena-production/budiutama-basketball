Sebelum mengerjakan apapun, baca semua file dokumentasi proyek ini terlebih dahulu:

- Documentation/Budi_Utama_Basketball_PRD_FINAL.md
- Documentation/Budi_Utama_Basketball_SRS.md
- Documentation/Budi_Utama_Basketball_SDD.md
- Documentation/Budi_Utama_Basketball_UIUX_Flow.html
- Documentation/Budi_Utama_Basketball_DEV_GUIDE.md

Baca seluruh isi setiap file sampai selesai. Jangan mulai coding sebelum semua file selesai dibaca. Setelah selesai membaca, konfirmasi bahwa kamu sudah memahami:
- Arsitektur sistem (Firebase-first, Flutter multi-platform)
- Role pengguna dan RBAC via Custom Claims
- Struktur Firestore dan konvensi Document ID
- Dua mode aplikasi: Dashboard Mode dan Match Mode
- Strategi dual-write untuk statistik (materialized + Cloud Functions)
- Konvensi penamaan file dan folder di proyek ini

Baru setelah konfirmasi tersebut, kerjakan tugas berikut.

---

# TUGAS: FASE 1 — FOUNDATION (Part 4, 5, 6)

Status proyek saat ini: Fase 0 (Part 1–3) sudah selesai. Firebase project sudah dibuat, Flutter project sudah di-init dan dihubungkan ke Firebase via FlutterFire CLI, struktur folder sudah dibuat, CI/CD GitHub Actions sudah dikonfigurasi, Firebase Emulator Suite sudah bisa berjalan.

Kerjakan secara berurutan Part 4 → Part 5 → Part 6. Untuk setiap file, tulis kode lengkap dan siap pakai. Jangan tulis placeholder kosong kecuali untuk bagian yang secara eksplisit diminta ditunda. Setiap Part selesai, tunjukkan perintah verifikasi yang perlu dijalankan.

---

## PART 4: Flutter Skeleton & Firebase Init (estimasi 90 menit)

**Step 4.1 — pubspec.yaml**

Tulis isi lengkap pubspec.yaml. Semua package sesuai yang tercantum di DEV_GUIDE Part 4, Step 4.1. Sertakan flutter assets: assets/audio/

**Step 4.2 — lib/core/constants/firestore_paths.dart**

Semua path Firestore sebagai konstanta dan static methods. Tidak boleh ada string path Firestore yang ditulis manual di file manapun selain file ini.

**Step 4.3 — lib/core/errors/app_exceptions.dart**

Sealed class AppException dengan subclass sesuai SDD.

**Step 4.4 — lib/core/utils/match_state_machine.dart**

Konstanta validTransitions dan fungsi isValidTransition(), isActiveState(). State machine harus persis sesuai dengan yang ada di PRD Section 4.4 dan SDD Section 10.2.

**Step 4.5 — lib/core/utils/timer_calculator.dart**

Fungsi currentRemainingSeconds() menggunakan Firebase Server Timestamp sebagai acuan — bukan DateTime.now() murni. Hasilnya di-clamp ke minimum 0.0. Sertakan formatSeconds() format MM:SS.

**Step 4.6 — lib/core/utils/stats_calculator.dart**

Class StatsCalculator dengan static methods untuk FT%, FG2%, FG3%, FG% keseluruhan, dan zonePercentage(). Formula sesuai SRS Section FR-LMS-15.

**Step 4.7 — lib/main.dart**

Firebase.initializeApp(), Firestore offline persistence, redirect ke Emulator hanya saat kDebugMode, FirebaseAppCheck dengan provider berbeda untuk debug vs release, runApp dengan ProviderScope.

**Step 4.8 — lib/app/app.dart**

MaterialApp.router dengan theme sesuai design system di UIUX_Flow (primary color #1A3A5C, accent #E8420A), routerProvider sementara dengan route /login placeholder.

Setelah Part 4 selesai: jalankan `flutter pub get` dan `flutter run -d chrome` untuk verifikasi app bisa berjalan.

---

## PART 5: Firebase Auth — Login & OTP (estimasi 120 menit)

**Step 5.1 — Semua Dart Models (Freezed)**

Buat semua model berikut dengan implementasi Freezed lengkap — termasuk fromJson, toJson, dan fromFirestore(DocumentSnapshot):

1. lib/shared/models/user_model.dart — fields sesuai SDD Section 3.2 schema users
2. lib/shared/models/team_model.dart — fields sesuai SDD schema teams
3. lib/features/players/data/models/player_model.dart — fields sesuai SDD schema players. Sertakan field photoUrl DAN photoBase64 karena sistem mendukung dua mode penyimpanan foto (free plan = base64 di Firestore; Blaze plan = Firebase Storage)
4. lib/features/events/data/models/event_model.dart — fields sesuai SDD schema events
5. lib/features/matches/dashboard/data/models/match_model.dart — fields sesuai SDD schema matches termasuk semua field konfigurasi timer
6. lib/features/matches/live/data/models/match_event_model.dart — fields sesuai SDD schema matches/.../events. Sertakan semua action_type yang valid sebagai komentar referensi
7. lib/features/matches/live/data/models/player_stats_model.dart — fields sesuai SDD schema matches/.../player_stats. Field shotZones adalah Map<String, dynamic> untuk menyimpan made/attempted per zona
8. lib/features/matches/live/data/models/lineup_model.dart — fields sesuai SDD schema matches/.../lineups termasuk enteredAtClock dan totalSecondsPlayed untuk tracking minutes played
9. lib/features/matches/live/data/models/timer_state_model.dart — PENTING: field startedAt harus bertipe Timestamp? (dari cloud_firestore), bukan DateTime?, agar bisa langsung digunakan di timer_calculator.dart
10. lib/features/injuries/data/models/injury_report_model.dart — fields sesuai SDD schema injury_reports. Sertakan photoUrl DAN photoBase64
11. lib/features/training/data/models/training_session_model.dart — fields sesuai SDD schema training_sessions
12. lib/features/physical_tests/data/models/physical_test_session_model.dart — fields sesuai SDD schema physical_test_sessions
13. lib/features/physical_tests/data/models/physical_test_result_model.dart — fields sesuai SDD schema physical_test_sessions/.../results. Sertakan beepLevel, beepShuttle DAN timeSeconds karena satu model digunakan untuk tiga jenis tes

Setelah semua file dibuat, jalankan: `dart run build_runner build --delete-conflicting-outputs`

**Step 5.2 — lib/features/auth/data/repositories/auth_repository.dart**

Methods: authStateStream, signIn (lempar AuthException jika gagal — pesan generik, bukan pesan asli Firebase), signOut, getRole (baca Custom Claims via getIdTokenResult), isDeviceTrusted, addTrustedDevice. Logika device trust sesuai SRS FR-AUTH-02 dan UIUX_Flow Section 2.

**Step 5.3 — lib/features/auth/domain/providers/auth_provider.dart**

authRepositoryProvider, authStateProvider, userRoleProvider menggunakan Riverpod.

**Step 5.4 — lib/features/auth/presentation/pages/login_page.dart**

Tampilan sesuai UIUX_Flow Section 2. Background #1A3A5C, form maksimal lebar 400px, validator email dan password, loading state, error via SnackBar dengan pesan generik. Key 'email_field' dan 'password_field' untuk keperluan integration test nanti. Panggil AuthRepository.signIn() — redirect ditangani GoRouter via authStateProvider.

**Step 5.5 — lib/features/auth/presentation/pages/otp_verification_page.dart**

Halaman verifikasi OTP untuk Coach dan Manager yang login dari device baru (sesuai SRS FR-AUTH-02). Tampilkan email tujuan OTP, input kode, tombol verifikasi, tombol kirim ulang dengan cooldown 60 detik. Setelah berhasil: panggil addTrustedDevice() lalu navigate ke /dashboard.

**Step 5.6 — Update lib/app/app.dart**

GoRouter lengkap dengan redirect logic auth guard. Routes: /login, /dashboard (placeholder), /match/:matchId (placeholder untuk Fase 3). Gunakan authStateProvider untuk mendeteksi status login.

Setelah Part 5 selesai: jalankan emulator, tambah user test di Emulator UI Authentication, login dari app untuk verifikasi redirect bekerja.

---

## PART 6: Security Rules, Indexes & Shared Components (estimasi 180 menit)

**Step 6.1 — firestore.rules**

Security Rules lengkap sesuai SDD Section 4. Pastikan:
- Helper functions: isAuth(), role(), isManager(), isCoach(), isStatistician(), isPlayer(), isStaff()
- Events subcollection: update hanya diizinkan untuk field is_undone saja (gunakan affectedKeys().hasOnly(['is_undone']))
- audit_logs: write = false dari client (hanya Cloud Functions Admin SDK)
- Tidak ada akses yang lebih longgar dari yang didefinisikan di Role Matrix PRD Section 3

**Step 6.2 — firestore.indexes.json**

Composite indexes untuk 4 query yang membutuhkannya: matches, events (collection group), physical_test_sessions, injury_reports — sesuai DEV_GUIDE Step 6.3.

**Step 6.3 — storage.rules**

Storage Security Rules: foto profil pemain hanya bisa di-write Manager, foto cedera hanya bisa diakses Staff. Semua path lain deny.

**Step 6.4 — lib/shared/widgets/app_button.dart**

AppButton dengan props: label, onPressed, isLoading, isDestructive, icon. Loading state menampilkan CircularProgressIndicator di dalam tombol.

**Step 6.5 — lib/shared/widgets/confirm_dialog.dart**

Fungsi showConfirmDialog() → Future<bool?> dengan parameter title, content, confirmLabel, isDestructive.

**Step 6.6 — lib/shared/widgets/app_layout.dart**

Layout adaptif sesuai UIUX_Flow Section 4: NavigationBar di bawah untuk smartphone (< 768px), NavigationRail di kiri untuk tablet dan web (≥ 768px). Menu yang tampil disesuaikan dengan role — mengacu pada tabel navigasi di UIUX_Flow Section 4.

**Step 6.7 — lib/shared/widgets/empty_state_widget.dart**

Widget empty state: icon besar + teks pesan + tombol CTA opsional. Digunakan di semua halaman list yang mungkin kosong.

**Step 6.8 — lib/shared/widgets/loading_overlay.dart**

Widget yang membungkus child dengan overlay semi-transparan + CircularProgressIndicator, hanya muncul saat isLoading = true.

**Step 6.9 — scripts/seed_emulator.dart**

Script seed data untuk Emulator (bukan production). Isi data:
- 2 teams: putra_2526, putri_2526
- 2 users di Firestore: manager_andi, coach_budi (lengkap semua field)
- 3 players: 7_ar_putra2526 (Ahmad Rizki, PG, active), 11_bs_putra2526 (Budi Santoso, SF, injured), 3_rn_putri2526 (Rina Nuraini, PG, active)
- 1 event: porseni_kota_2526

Document ID semua data harus mengikuti konvensi yang ada di SDD Section 3.1 dan PRD Section 14.1.

Setelah Part 6 selesai: jalankan security rules test manual via Emulator UI — coba akses data dengan berbagai role untuk verifikasi rules bekerja benar.

---

## ATURAN DALAM MENGERJAKAN

1. Selalu rujuk ke file dokumentasi untuk setiap keputusan desain — jangan berasumsi sendiri.
2. Semua Firestore path wajib menggunakan FirestorePaths — tidak boleh hardcode string path di file lain.
3. Document ID harus mengikuti konvensi dari SDD Section 3.1 dan PRD Section 14.1 — tidak boleh menggunakan auto-generated ID kecuali untuk audit_logs.
4. Kode lengkap dan siap pakai — tidak ada TODO kosong.
5. Semua import menggunakan package name: budiutama_basketball.
6. Jika menemukan ambiguitas antara dokumen yang satu dengan yang lain, tanyakan sebelum memutuskan.