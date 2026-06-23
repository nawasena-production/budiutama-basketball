import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';

/// Menghitung sisa detik timer pertandingan dari [TimerStateModel].
///
/// Prinsip kunci (SDD Section 3.5, PRD Section 7.6): timer adalah
/// "waktu bersih" yang sepenuhnya manual — TIDAK ada shot clock — dan
/// SEMUA device menghitung mundur dari acuan yang sama, yaitu
/// `started_at` (Firebase Server Timestamp), bukan jam lokal masing-
/// masing device. Ini mencegah drift waktu antar tablet meskipun jam
/// sistem operasi device berbeda beberapa detik.
///
/// - Jika timer tidak berjalan (`isRunning == false`) atau `startedAt`
///   null (baru di-PAUSE atau belum pernah di-START), sisa waktu sama
///   dengan `secondsAtStart` apa adanya — tidak ada pengurangan.
/// - Jika timer berjalan, sisa waktu = `secondsAtStart` dikurangi waktu
///   yang sudah berlalu sejak `startedAt`, dan tidak akan pernah negatif
///   (`clamp(0.0, ...)`).
///
/// Parameter [now] disediakan terutama untuk keperluan unit test
/// (supaya hasil deterministik tanpa bergantung pada jam sistem saat
/// test dijalankan). Di kode produksi, biarkan default (`DateTime.now()`).
double currentRemainingSeconds(
  TimerStateModel state, {
  DateTime? now,
}) {
  if (!state.isRunning || state.startedAt == null) {
    return state.secondsAtStart.clamp(0.0, double.infinity);
  }

  final referenceNow = now ?? DateTime.now();
  final startedAtDate = state.startedAt!.toDate();
  final elapsedSeconds =
      referenceNow.difference(startedAtDate).inMilliseconds / 1000.0;

  return (state.secondsAtStart - elapsedSeconds).clamp(0.0, double.infinity);
}

/// Format detik (double) menjadi tampilan `mm:ss`, contoh: `9:87` detik
/// → tidak relevan untuk timer pertandingan (selalu bilangan utuh detik
/// saat ditampilkan), sehingga bagian desimal dibuang via `.floor()`.
///
/// Contoh: `formatSeconds(384.7)` → `'06:24'`
String formatSeconds(double seconds) {
  final clamped = seconds.clamp(0.0, double.infinity);
  final totalSeconds = clamped.floor();
  final minutes = totalSeconds ~/ 60;
  final remainingSeconds = totalSeconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}

/// Indikator visual apakah timer sudah masuk fase "genting" (kurang dari
/// [thresholdSeconds] detik tersisa) — dipakai MatchTimerWidget untuk
/// mengubah warna teks timer (misal jadi merah) saat akhir quarter
/// mendekat. Default threshold 60 detik (1 menit terakhir).
bool isTimeRunningLow(double remainingSeconds, {double thresholdSeconds = 60}) {
  return remainingSeconds > 0 && remainingSeconds <= thresholdSeconds;
}

/// Helper konversi `Timestamp?` Firestore ke `DateTime?` biasa — dipakai
/// di tempat yang membutuhkan perbandingan waktu tanpa melalui
/// [TimerStateModel] secara penuh (misal saat menghitung durasi bermain
/// pemain langsung dari field `entered_at_clock` di lineup, yang memakai
/// representasi detik-tersisa, bukan Timestamp — disertakan di sini
/// sebagai utilitas umum agar tidak perlu import `cloud_firestore`
/// langsung di banyak widget).
DateTime? timestampToDateTime(Timestamp? timestamp) => timestamp?.toDate();
