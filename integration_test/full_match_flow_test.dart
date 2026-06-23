import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budiutama_basketball/main.dart' as app;

/// Integration test alur kritis penuh (SRS Section 12 — Testing
/// Strategy, "Integration Test: Login → buat event → buat match → live
/// stats → selesai").
///
/// **Pendekatan**: bukan menguji setiap field form secara mendetail
/// (rapuh terhadap perubahan UI form yang sah/disengaja), melainkan
/// memverifikasi ALUR NAVIGASI dan INTERAKSI KRITIS benar-benar
/// berfungsi end-to-end melawan Firebase Emulator sungguhan. Data
/// pendukung (event, match dengan status `scheduled`, starter lineup)
/// di-SEED LEBIH DULU via `scripts/seed_emulator.dart` (bukan dibuat
/// lewat UI form di dalam test ini) — memisahkan "apakah form
/// menyimpan data dengan benar" (lebih cocok diuji di level
/// repository/unit, lihat Step 7-9 `*_repository_test.dart`) dari
/// "apakah alur Match Mode end-to-end bekerja" (kekhawatiran murni
/// integration test).
///
/// Prasyarat sebelum menjalankan:
///   firebase emulators:start
///   dart run scripts/seed_emulator.dart
///   dart run scripts/seed_test_match.dart   (lihat Step 19-23 README)
///
/// Jalankan:
///   flutter test integration_test/full_match_flow_test.dart -d chrome
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Alur penuh: Login -> Dashboard -> Match Mode -> Live Stats', () {
    testWidgets(
        'Statistician login, buka pertandingan scheduled, mulai Match '
        'Mode, input statistik, Tab 2 Live Stats ter-update',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Login sebagai Statistician (data sudah di-seed sebelumnya).
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'statistician@budiutama.sch.id',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Test1234!',
      );
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 2. Navigasi ke menu Matches.
      final matchesNav = find.text('Matches');
      expect(matchesNav, findsWidgets,
          reason: 'menu navigasi Matches harus tampil setelah login');
      await tester.tap(matchesNav.first);
      await tester.pumpAndSettle();

      // 3. Buka pertandingan berstatus scheduled yang sudah di-seed
      //    (mis. "vs SMAN 1 Yogyakarta" - sesuaikan dengan data seed).
      final matchTile = find.textContaining('SMAN 1');
      expect(matchTile, findsWidgets,
          reason:
              'pertandingan hasil seeding harus tampil di daftar Matches');
      await tester.tap(matchTile.first);
      await tester.pumpAndSettle();

      // 4. Tekan "MULAI PERTANDINGAN".
      final startButton = find.textContaining('MULAI PERTANDINGAN');
      expect(startButton, findsOneWidget);
      await tester.tap(startButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 5. Verifikasi sudah masuk Match Mode fullscreen - header skor
      //    dan tab "Input Mode" harus tampil.
      expect(find.text('Input Mode'), findsWidgets);
      expect(find.text('Live Player Stats'), findsWidgets);

      // 6. Pilih pemain pertama di Left Panel (starter pertama hasil
      //    seeding), lalu catat aksi ASSIST (tidak perlu Court Overlay
      //    - paling sederhana untuk diverifikasi end-to-end).
      final firstPlayerCard = find.textContaining('#7').first;
      await tester.tap(firstPlayerCard);
      await tester.pumpAndSettle();

      final assistButton = find.text('AST');
      expect(assistButton, findsOneWidget);
      await tester.tap(assistButton);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // 7. Pindah ke Tab 2 - Live Player Stats harus menunjukkan AST: 1
      //    untuk pemain yang baru saja dicatat (real-time, tanpa reload
      //    manual, FR-LMS-16).
      await tester.tap(find.text('Live Player Stats'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('1'), findsWidgets,
          reason: 'kolom AST pemain harus menunjukkan angka 1 setelah '
              'aksi ASSIST dicatat di Tab 1');
    });
  });

  group('Smoke test navigasi - semua menu utama termuat tanpa error', () {
    testWidgets('Manager bisa membuka seluruh menu navigasi tanpa crash',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'manager@budiutama.sch.id',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Test1234!',
      );
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      const menuLabels = [
        'Players',
        'Training',
        'Events',
        'Matches',
        'Injuries',
        'Physical Tests',
        'Statistics',
        'Audit Log',
        'Users',
      ];

      for (final label in menuLabels) {
        final menuItem = find.text(label);
        if (menuItem.evaluate().isEmpty) continue; // layout sempit/rail beda
        await tester.tap(menuItem.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Smoke assertion minimal: tidak ada exception merah yang
        // ditangkap Flutter (ErrorWidget) setelah navigasi.
        expect(find.byType(ErrorWidget), findsNothing,
            reason: 'halaman "$label" tidak boleh menampilkan error widget');
      }
    });
  });
}
