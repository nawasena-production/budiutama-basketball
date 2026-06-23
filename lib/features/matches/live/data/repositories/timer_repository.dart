import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';

/// Repository untuk dokumen tunggal `matches/{matchId}/timer_state/state`.
///
/// Timer pertandingan adalah "waktu bersih" (clean time) yang dikontrol
/// manual oleh Statistician — TIDAK ada shot clock (PRD Section 7.6).
/// Server Timestamp Firebase dipakai sebagai acuan bersama semua device
/// supaya tidak terjadi drift waktu antar tablet (SRS FR-LMS-05).
class TimerRepository {
  TimerRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _timerDocRef(String matchId) {
    return _db.doc(FirestorePaths.matchTimerStateDoc(matchId));
  }

  /// Stream state timer real-time — dipakai oleh MatchTimerWidget untuk
  /// menghitung sisa waktu secara lokal di setiap device.
  Stream<TimerStateModel> watchTimer(String matchId) {
    return _timerDocRef(matchId).snapshots().map((snap) {
      if (!snap.exists) return const TimerStateModel();
      return TimerStateModel.fromFirestore(snap);
    });
  }

  /// Ambil state timer sekali (non-stream) — dipakai saat akan menghitung
  /// `currentRemaining` sebelum menulis PAUSE, supaya nilai yang ditulis
  /// akurat berdasarkan snapshot terbaru, bukan state lokal yang mungkin
  /// sudah agak basi.
  Future<TimerStateModel> getTimer(String matchId) async {
    final snap = await _timerDocRef(matchId).get();
    if (!snap.exists) return const TimerStateModel();
    return TimerStateModel.fromFirestore(snap);
  }

  /// START atau RESUME timer.
  ///
  /// Menulis `started_at` dengan [FieldValue.serverTimestamp()] — bukan
  /// `DateTime.now()` lokal — agar semua device menghitung sisa waktu
  /// dari acuan yang identik (SDD Section 3.5).
  Future<void> startTimer({
    required String matchId,
    required double secondsAtStart,
    required int quarter,
  }) async {
    await _timerDocRef(matchId).set({
      'is_running': true,
      'seconds_at_start': secondsAtStart,
      'started_at': FieldValue.serverTimestamp(),
      'quarter': quarter,
    });
  }

  /// PAUSE timer — simpan sisa detik yang sudah dihitung di client
  /// (`currentRemaining`), dan kosongkan `started_at` agar
  /// `currentRemainingSeconds()` di client lain langsung berhenti
  /// menghitung mundur.
  Future<void> pauseTimer({
    required String matchId,
    required double currentRemaining,
  }) async {
    await _timerDocRef(matchId).update({
      'is_running': false,
      'seconds_at_start': currentRemaining,
      'started_at': null,
    });
  }

  /// RESUME adalah operasi yang sama dengan START — bedanya hanya
  /// konteks pemanggilan UI (tombol RESUME vs tombol START pertama kali
  /// di quarter). Disediakan sebagai alias agar kode pemanggil lebih
  /// jelas maksudnya.
  Future<void> resumeTimer({
    required String matchId,
    required double secondsAtStart,
    required int quarter,
  }) {
    return startTimer(
      matchId: matchId,
      secondsAtStart: secondsAtStart,
      quarter: quarter,
    );
  }

  /// Set ulang konfigurasi quarter (dipanggil saat transisi state, misal
  /// dari Q1_BREAK ke Q2_ACTIVE) — durasi penuh quarter baru, timer belum
  /// berjalan sampai Statistician menekan START/RESUME secara eksplisit.
  Future<void> resetForNewQuarter({
    required String matchId,
    required double fullDurationSeconds,
    required int quarter,
  }) async {
    await _timerDocRef(matchId).set({
      'is_running': false,
      'seconds_at_start': fullDurationSeconds,
      'started_at': null,
      'quarter': quarter,
    });
  }
}
