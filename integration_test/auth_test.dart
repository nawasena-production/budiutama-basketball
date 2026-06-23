import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:budiutama_basketball/main.dart' as app;

/// Integration test alur Autentikasi (SRS Section 3.1, FR-AUTH-01 s.d
/// 05). Dijalankan melawan Firebase Emulator — pastikan emulator sudah
/// berjalan (`firebase emulators:start`) dan user uji berikut sudah
/// di-seed ke Auth Emulator + Firestore `users` collection SEBELUM
/// menjalankan test ini:
///
///   manager@budiutama.sch.id / Test1234!  → role: manager
///   coach@budiutama.sch.id   / Test1234!  → role: coach
///   (lihat scripts/seed_emulator.dart Step 6.5 untuk referensi seeding)
///
/// Jalankan:
///   flutter test integration_test/auth_test.dart -d chrome
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth — login flow', () {
    testWidgets(
        'Login dengan credentials valid (Manager) → redirect ke /dashboard',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      await tester.enterText(emailField, 'manager@budiutama.sch.id');
      await tester.enterText(passwordField, 'Test1234!');
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Manager tanpa device baru (sudah trusted) langsung ke dashboard.
      expect(find.byIcon(Icons.sports_basketball), findsWidgets);
    });

    testWidgets('Login dengan password salah menampilkan pesan error generik',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'manager@budiutama.sch.id',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'PasswordSalahTotal!',
      );
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // SEC-01: pesan error harus generik, TIDAK membocorkan apakah
      // email terdaftar atau password yang salah (mencegah user
      // enumeration).
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email atau password tidak valid.'), findsOneWidget);
    });

    testWidgets('Validasi client-side menolak email tanpa format valid',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'bukan-email-valid',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'Test1234!',
      );
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('Validasi client-side menolak password kurang dari 8 karakter',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'manager@budiutama.sch.id',
      );
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.text('Masuk'));
      await tester.pump();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });
  });
}
