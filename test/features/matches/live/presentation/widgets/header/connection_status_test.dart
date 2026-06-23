import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/features/matches/live/presentation/widgets/header/connection_status.dart';

/// Widget test untuk [ConnectionStatusIndicator] — mendukung
/// verifikasi otomatis sebagian dari Step 22.4 (Test Offline Mode):
/// memastikan indikator BENAR-BENAR berubah warna/label sesuai 3
/// kemungkinan state firestoreSyncStatusProvider, tanpa perlu
/// Firebase Emulator sungguhan atau memutus koneksi jaringan manual di
/// DevTools - cukup override provider dengan StreamController palsu.
///
/// Catatan: ini TIDAK menggantikan verifikasi manual Step 22.4
/// (mematikan jaringan sungguhan di Chrome DevTools dan memastikan
/// event yang diinput offline tersinkron otomatis saat online kembali)
/// - itu menguji perilaku Firestore SDK yang sesungguhnya, di luar
/// jangkauan widget test murni. Test ini HANYA memverifikasi bagian
/// "apakah UI bereaksi benar terhadap setiap kemungkinan state stream".
void main() {
  group('ConnectionStatusIndicator - render berdasarkan state stream', () {
    testWidgets('menampilkan label "Firestore" saat data (sinkron)',
        (tester) async {
      final controller = StreamController<void>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreSyncStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConnectionStatusIndicator()),
          ),
        ),
      );

      controller.add(null);
      await tester.pump();

      expect(find.text('Firestore'), findsOneWidget);
    });

    testWidgets(
        'menampilkan label "Menyambungkan..." sebelum event pertama diterima',
        (tester) async {
      final controller = StreamController<void>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreSyncStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConnectionStatusIndicator()),
          ),
        ),
      );

      await tester.pump();

      // Belum ada event dipancarkan sama sekali - state masih loading.
      expect(find.textContaining('Menyambungkan'), findsOneWidget);
    });

    testWidgets('menampilkan label "Offline" saat stream error',
        (tester) async {
      final controller = StreamController<void>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreSyncStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConnectionStatusIndicator()),
          ),
        ),
      );

      controller.addError(Exception('Koneksi terputus'));
      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('transisi data -> error (simulasi koneksi terputus) mengganti label',
        (tester) async {
      final controller = StreamController<void>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firestoreSyncStatusProvider.overrideWith((ref) => controller.stream),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ConnectionStatusIndicator()),
          ),
        ),
      );

      controller.add(null);
      await tester.pump();
      expect(find.text('Firestore'), findsOneWidget);

      // Simulasikan koneksi terputus (Step 22.4 - set Network Offline).
      controller.addError(Exception('Network unreachable'));
      await tester.pump();
      expect(find.text('Offline'), findsOneWidget);
      expect(find.text('Firestore'), findsNothing);
    });
  });
}
