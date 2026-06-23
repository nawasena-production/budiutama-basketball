import 'package:flutter_test/flutter_test.dart';

import 'package:budiutama_basketball/core/utils/stats_calculator.dart';

void main() {
  test('StatsCalculator returns zero when attempts are zero', () {
    expect(StatsCalculator.ftPercentage(0, 0), 0.0);
    expect(StatsCalculator.fg2Percentage(0, 0), 0.0);
    expect(StatsCalculator.fg3Percentage(0, 0), 0.0);
    expect(StatsCalculator.fgPercentage(0, 0, 0, 0), 0.0);
    expect(StatsCalculator.zonePercentage(const {}), 0.0);
  });

  test('StatsCalculator computes basketball percentages', () {
    expect(StatsCalculator.ftPercentage(3, 4), 75.0);
    expect(StatsCalculator.fg2Percentage(5, 10), 50.0);
    expect(StatsCalculator.fg3Percentage(2, 5), 40.0);
    expect(StatsCalculator.fgPercentage(5, 10, 2, 5), closeTo(46.67, 0.01));
    expect(
      StatsCalculator.zonePercentage(const {'made': 3, 'attempted': 6}),
      50.0,
    );
  });
}
