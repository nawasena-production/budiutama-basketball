import 'package:flutter_test/flutter_test.dart';
import 'package:budiutama_basketball/core/utils/stats_calculator.dart';

void main() {
  group('StatsCalculator.ftPercentage', () {
    test('3 made dari 4 attempted = 75%', () {
      expect(StatsCalculator.ftPercentage(3, 4), closeTo(75.0, 0.01));
    });

    test('0 attempted = 0% (hindari pembagian nol)', () {
      expect(StatsCalculator.ftPercentage(0, 0), 0.0);
    });

    test('made == attempted = 100%', () {
      expect(StatsCalculator.ftPercentage(5, 5), 100.0);
    });

    test('0 made dari beberapa attempted = 0%', () {
      expect(StatsCalculator.ftPercentage(0, 6), 0.0);
    });
  });

  group('StatsCalculator.fg2Percentage', () {
    test('4 made dari 8 attempted = 50%', () {
      expect(StatsCalculator.fg2Percentage(4, 8), closeTo(50.0, 0.01));
    });

    test('0 attempted = 0%', () {
      expect(StatsCalculator.fg2Percentage(0, 0), 0.0);
    });
  });

  group('StatsCalculator.fg3Percentage', () {
    test('1 made dari 3 attempted ≈ 33.3%', () {
      expect(StatsCalculator.fg3Percentage(1, 3), closeTo(33.33, 0.1));
    });

    test('0 attempted = 0%', () {
      expect(StatsCalculator.fg3Percentage(0, 0), 0.0);
    });
  });

  group('StatsCalculator.fgPercentage (gabungan FG2 + FG3)', () {
    test('combined FG = (4+1)/(8+3) ≈ 45.5%', () {
      expect(
        StatsCalculator.fgPercentage(4, 8, 1, 3),
        closeTo(45.45, 0.1),
      );
    });

    test('hanya FG2, FG3 nol attempted — tetap dihitung benar', () {
      expect(StatsCalculator.fgPercentage(4, 8, 0, 0), closeTo(50.0, 0.01));
    });

    test('hanya FG3, FG2 nol attempted — tetap dihitung benar', () {
      expect(StatsCalculator.fgPercentage(0, 0, 2, 4), closeTo(50.0, 0.01));
    });

    test('semua nol attempted = 0%', () {
      expect(StatsCalculator.fgPercentage(0, 0, 0, 0), 0.0);
    });

    test('FG 100% — semua tembakan masuk', () {
      expect(StatsCalculator.fgPercentage(3, 3, 2, 2), 100.0);
    });
  });

  group('StatsCalculator.zonePercentage', () {
    test('zona dengan made dan attempted normal', () {
      final zone = {'made': 3, 'attempted': 4};
      expect(StatsCalculator.zonePercentage(zone), 75.0);
    });

    test('zona kosong (belum ada tembakan) = 0%', () {
      final zone = <String, dynamic>{};
      expect(StatsCalculator.zonePercentage(zone), 0.0);
    });

    test('zona dengan attempted 0 eksplisit = 0%', () {
      final zone = {'made': 0, 'attempted': 0};
      expect(StatsCalculator.zonePercentage(zone), 0.0);
    });

    test('nilai berupa num (bukan int murni, mis. dari Firestore) tetap valid', () {
      // Firestore kadang mengembalikan field numerik sebagai num/double,
      // bukan int murni — pastikan cast (num?)?.toInt() tidak meledak.
      final zone = {'made': 3.0, 'attempted': 4.0};
      expect(StatsCalculator.zonePercentage(zone), 75.0);
    });
  });

  group('StatsCalculator.efficiency', () {
    test('menghitung EF sesuai rumus FIBA', () {
      final ef = StatsCalculator.efficiency(
        points: 12,
        offensiveRebounds: 2,
        defensiveRebounds: 5,
        assists: 4,
        steals: 1,
        blocks: 1,
        fg2Made: 4,
        fg2Attempted: 8,
        fg3Made: 1,
        fg3Attempted: 3,
        ftMade: 1,
        ftAttempted: 2,
        turnovers: 3,
      );

      expect(ef, 15);
    });

    test('attempted lebih kecil dari made tidak menghasilkan penalti negatif',
        () {
      final ef = StatsCalculator.efficiency(
        points: 5,
        offensiveRebounds: 0,
        defensiveRebounds: 0,
        assists: 0,
        steals: 0,
        blocks: 0,
        fg2Made: 2,
        fg2Attempted: 1,
        fg3Made: 0,
        fg3Attempted: 0,
        ftMade: 1,
        ftAttempted: 0,
        turnovers: 0,
      );

      expect(ef, 5);
    });
  });

  group('StatsCalculator.formatMinutes', () {
    test('format detik menjadi m:ss', () {
      expect(StatsCalculator.formatMinutes(605), '10:05');
    });
  });
}
