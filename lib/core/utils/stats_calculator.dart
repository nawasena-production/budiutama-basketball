class StatsCalculator {
  const StatsCalculator._();

  static double ftPercentage(int made, int attempted) =>
      attempted > 0 ? made / attempted * 100 : 0.0;

  static double fg2Percentage(int made, int attempted) =>
      attempted > 0 ? made / attempted * 100 : 0.0;

  static double fg3Percentage(int made, int attempted) =>
      attempted > 0 ? made / attempted * 100 : 0.0;

  static double fgPercentage(
    int fg2Made,
    int fg2Attempted,
    int fg3Made,
    int fg3Attempted,
  ) {
    final totalMade = fg2Made + fg3Made;
    final totalAttempted = fg2Attempted + fg3Attempted;
    return totalAttempted > 0 ? totalMade / totalAttempted * 100 : 0.0;
  }

  static double zonePercentage(Map<String, dynamic> zone) {
    final made = (zone['made'] as num?)?.toInt() ?? 0;
    final attempted = (zone['attempted'] as num?)?.toInt() ?? 0;
    return attempted > 0 ? made / attempted * 100 : 0.0;
  }
}
