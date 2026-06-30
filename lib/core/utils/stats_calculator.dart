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

  /// FIBA-style efficiency:
  /// PTS + REB + AST + STL + BLK - missed FG - missed FT - TO.
  static int efficiency({
    required int points,
    required int offensiveRebounds,
    required int defensiveRebounds,
    required int assists,
    required int steals,
    required int blocks,
    required int fg2Made,
    required int fg2Attempted,
    required int fg3Made,
    required int fg3Attempted,
    required int ftMade,
    required int ftAttempted,
    required int turnovers,
  }) {
    int missed(int attempted, int made) {
      return attempted > made ? attempted - made : 0;
    }

    final rebounds = offensiveRebounds + defensiveRebounds;
    final missedFg =
        missed(fg2Attempted, fg2Made) + missed(fg3Attempted, fg3Made);
    final missedFt = missed(ftAttempted, ftMade);

    return points +
        rebounds +
        assists +
        steals +
        blocks -
        missedFg -
        missedFt -
        turnovers;
  }

  static String formatMinutes(int totalSeconds) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = safeSeconds ~/ 60;
    final seconds = safeSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
