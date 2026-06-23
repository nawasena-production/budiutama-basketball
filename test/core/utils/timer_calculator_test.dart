import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/core/utils/timer_calculator.dart';
import 'package:budiutama_basketball/features/matches/live/data/models/timer_state_model.dart';

void main() {
  group('currentRemainingSeconds', () {
    test('timer tidak berjalan — kembalikan secondsAtStart apa adanya', () {
      const state = TimerStateModel(
        isRunning: false,
        secondsAtStart: 384.0,
        startedAt: null,
        quarter: 3,
      );
      expect(currentRemainingSeconds(state), 384.0);
    });

    test('startedAt null walau isRunning true — fallback ke secondsAtStart', () {
      const state = TimerStateModel(
        isRunning: true,
        secondsAtStart: 200.0,
        startedAt: null,
      );
      expect(currentRemainingSeconds(state), 200.0);
    });

    test('timer berjalan — kurangi waktu yang sudah berlalu', () {
      final fixedNow = DateTime(2026, 3, 15, 19, 30, 0);
      final startedAt =
          Timestamp.fromDate(fixedNow.subtract(const Duration(seconds: 16)));
      final state = TimerStateModel(
        isRunning: true,
        secondsAtStart: 384.0,
        startedAt: startedAt,
        quarter: 3,
      );
      expect(
        currentRemainingSeconds(state, now: fixedNow),
        closeTo(368.0, 0.01),
      );
    });

    test('tidak pernah negatif — clamp ke 0 walau elapsed melebihi secondsAtStart', () {
      final fixedNow = DateTime(2026, 3, 15, 19, 30, 0);
      final startedAt =
          Timestamp.fromDate(fixedNow.subtract(const Duration(seconds: 999)));
      final state = TimerStateModel(
        isRunning: true,
        secondsAtStart: 60.0,
        startedAt: startedAt,
      );
      expect(currentRemainingSeconds(state, now: fixedNow), 0.0);
    });

    test('presisi milidetik tetap dihormati (bukan dibulatkan di sini)', () {
      final fixedNow = DateTime(2026, 1, 1, 12, 0, 0, 500); // +500ms
      final startedAt = Timestamp.fromDate(DateTime(2026, 1, 1, 12, 0, 0));
      final state = TimerStateModel(
        isRunning: true,
        secondsAtStart: 10.0,
        startedAt: startedAt,
      );
      expect(currentRemainingSeconds(state, now: fixedNow), closeTo(9.5, 0.01));
    });
  });

  group('formatSeconds', () {
    test('384 detik = 06:24 (sesuai contoh PRD Section 7.3)', () {
      expect(formatSeconds(384.0), '06:24');
    });

    test('600 detik (10 menit penuh) = 10:00', () {
      expect(formatSeconds(600.0), '10:00');
    });

    test('0 detik = 00:00', () {
      expect(formatSeconds(0.0), '00:00');
    });

    test('59.9 detik dibulatkan ke bawah = 00:59 (bukan 01:00)', () {
      expect(formatSeconds(59.9), '00:59');
    });

    test('nilai negatif (seharusnya tidak terjadi) tetap aman = 00:00', () {
      expect(formatSeconds(-5.0), '00:00');
    });
  });

  group('isTimeRunningLow', () {
    test('59 detik tersisa, threshold default 60 — true', () {
      expect(isTimeRunningLow(59.0), isTrue);
    });

    test('61 detik tersisa, threshold default 60 — false', () {
      expect(isTimeRunningLow(61.0), isFalse);
    });

    test('0 detik tersisa — false (sudah habis, bukan "menipis")', () {
      expect(isTimeRunningLow(0.0), isFalse);
    });

    test('threshold custom 10 detik', () {
      expect(isTimeRunningLow(8.0, thresholdSeconds: 10), isTrue);
      expect(isTimeRunningLow(15.0, thresholdSeconds: 10), isFalse);
    });
  });
}
