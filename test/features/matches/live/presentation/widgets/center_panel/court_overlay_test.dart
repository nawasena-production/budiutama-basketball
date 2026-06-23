import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/features/matches/live/presentation/widgets/center_panel/court_overlay.dart';

/// Widget test untuk [CourtOverlay] (Step 17, FR-LMS-14).
///
/// Karena [CourtOverlay] sengaja dirancang "dumb" (tidak bergantung pada
/// Firestore/Riverpod sama sekali — lihat docstring di court_overlay.dart),
/// widget ini bisa diuji murni dengan `WidgetTester`, tanpa perlu
/// `ProviderScope` atau mock Firebase apa pun.
void main() {
  Widget wrapInApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: 300, height: 280, child: child),
      ),
    );
  }

  group('CourtOverlay — tap lokasi konsisten', () {
    testWidgets(
        'tap di area PAINT untuk aksi 2PT_MADE langsung memanggil '
        'onLocationSelected tanpa dialog konfirmasi', (tester) async {
      ShotLocationResult? result;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '2PT_MADE',
            onLocationSelected: (r) => result = r,
            onDismiss: () {},
          ),
        ),
      );

      // Tap di tengah-atas widget (area PAINT secara proporsional).
      final center = tester.getTopLeft(find.byType(CourtOverlay)) +
          const Offset(150, 50);
      await tester.tapAt(center);
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.zone, 'PAINT');
      // Tidak ada dialog yang muncul untuk kasus konsisten.
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('CourtOverlay — tap lokasi tidak konsisten', () {
    testWidgets(
        'tap di area luar arc 3PT untuk aksi 2PT_MADE memunculkan '
        'dialog konfirmasi "Tetap Lanjutkan"', (tester) async {
      ShotLocationResult? result;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '2PT_MADE',
            onLocationSelected: (r) => result = r,
            onDismiss: () {},
          ),
        ),
      );

      // Tap jauh di sudut bawah-kiri widget — secara matematis jatuh ke
      // zona CENTER_3 (luar arc 3PT, y tinggi) — tetap merupakan zona
      // 3 poin sehingga inkonsisten dengan tombol 2PT_MADE, memicu
      // dialog konfirmasi yang sama.
      final topLeft = tester.getTopLeft(find.byType(CourtOverlay));
      await tester.tapAt(topLeft + const Offset(20, 230));
      await tester.pumpAndSettle();

      // Belum terpanggil — masih menunggu konfirmasi dialog.
      expect(result, isNull);
      expect(find.text('Konfirmasi Zona Tembakan'), findsOneWidget);
      expect(find.text('Tetap Lanjutkan'), findsOneWidget);
      expect(find.text('Batal — Pilih Ulang'), findsOneWidget);
    });

    testWidgets('menekan "Tetap Lanjutkan" pada dialog memanggil onLocationSelected',
        (tester) async {
      ShotLocationResult? result;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '2PT_MADE',
            onLocationSelected: (r) => result = r,
            onDismiss: () {},
          ),
        ),
      );

      final topLeft = tester.getTopLeft(find.byType(CourtOverlay));
      await tester.tapAt(topLeft + const Offset(20, 230));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tetap Lanjutkan'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('menekan "Batal — Pilih Ulang" TIDAK memanggil onLocationSelected',
        (tester) async {
      ShotLocationResult? result;
      bool dismissed = false;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '2PT_MADE',
            onLocationSelected: (r) => result = r,
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      final topLeft = tester.getTopLeft(find.byType(CourtOverlay));
      await tester.tapAt(topLeft + const Offset(20, 230));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal — Pilih Ulang'));
      await tester.pumpAndSettle();

      expect(result, isNull);
      // Membatalkan dialog TIDAK sama dengan onDismiss keseluruhan
      // overlay — overlay tetap terbuka supaya Statistician bisa tap
      // ulang lokasi yang benar.
      expect(dismissed, isFalse);
      expect(find.byType(CourtOverlay), findsOneWidget);
    });
  });

  group('CourtOverlay — tombol batal eksplisit', () {
    testWidgets('tombol close (X) di pojok kanan atas memanggil onDismiss',
        (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '2PT_MADE',
            onLocationSelected: (_) {},
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });
  });

  group('CourtOverlay — auto-dismiss setelah 15 detik', () {
    testWidgets('overlay memanggil onDismiss otomatis setelah 15 detik tanpa interaksi',
        (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '3PT_MADE',
            onLocationSelected: (_) {},
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      expect(dismissed, isFalse);

      await tester.pump(const Duration(seconds: 14));
      expect(dismissed, isFalse, reason: 'belum 15 detik, belum boleh dismiss');

      await tester.pump(const Duration(seconds: 2));
      expect(dismissed, isTrue, reason: 'setelah 15 detik harus auto-dismiss');
    });

    testWidgets('auto-dismiss TIDAK terpicu jika lokasi sudah dipilih lebih dulu',
        (tester) async {
      bool dismissed = false;
      ShotLocationResult? result;

      await tester.pumpWidget(
        wrapInApp(
          CourtOverlay(
            actionType: '2PT_MADE',
            onLocationSelected: (r) => result = r,
            onDismiss: () => dismissed = true,
          ),
        ),
      );

      final center = tester.getTopLeft(find.byType(CourtOverlay)) +
          const Offset(150, 50);
      await tester.tapAt(center);
      await tester.pumpAndSettle();

      expect(result, isNotNull);

      // Widget kemungkinan sudah di-unmount oleh parent setelah
      // onLocationSelected terpanggil (skenario nyata) — tapi bahkan
      // jika instance ini masih ada, _resolved sudah true sehingga
      // timer 15 detik tidak akan memanggil onDismiss lagi.
      await tester.pump(const Duration(seconds: 16));
      expect(dismissed, isFalse);
    });
  });
}
