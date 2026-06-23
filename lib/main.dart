import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:budiutama_basketball/app/app.dart';
import 'package:budiutama_basketball/firebase_options.dart';

const _debugRecaptchaSiteKey = 'debug-recaptcha-site-key';
const _releaseRecaptchaSiteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');

// ── EMULATOR TOGGLE ──────────────────────────────────────────────
// Set ke `true` kalau mau pakai Firebase Local Emulator Suite
// (butuh `firebase emulators:start` jalan duluan di terminal).
// Set ke `false` supaya app langsung konek ke Firebase project
// production — paling gampang untuk testing cepat / solo development.
const bool useEmulator = false;
// ──────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hilangkan hash (/#/) dari URL Flutter Web — gunakan path URL strategy
  // standar (mis. /players, /events) sesuai kebutuhan routing (Issue 5).
  // Tidak berpengaruh di Android/iOS (no-op di luar web).
  usePathUrlStrategy();

  // Inisialisasi data locale untuk package:intl SEBELUM widget apa pun
  // memanggil DateFormat(..., 'id_ID') — tanpa ini, semua DateFormat
  // dengan locale Indonesia melempar LocaleDataException (Issue 4).
  // Bahasa Inggris (default) selalu tersedia secara built-in, jadi tetap
  // aman walau initializeDateFormatting gagal untuk locale lain.
  await initializeDateFormatting('id_ID');
  await initializeDateFormatting('en_US');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  if (useEmulator && kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
    await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  }

  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    webProvider: kDebugMode
        ? ReCaptchaV3Provider(_debugRecaptchaSiteKey)
        : ReCaptchaV3Provider(_releaseRecaptchaSiteKey),
  );

  runApp(const ProviderScope(child: App()));
}