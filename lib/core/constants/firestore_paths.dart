class FirestorePaths {
  const FirestorePaths._();

  static const users = 'users';
  static const teams = 'teams';
  static const players = 'players';
  static const events = 'events';
  static const matches = 'matches';
  static const injuryReports = 'injury_reports';
  static const trainingSessions = 'training_sessions';
  static const physicalTestSessions = 'physical_test_sessions';
  static const auditLogs = 'audit_logs';

  static String user(String userId) => '$users/$userId';
  static String team(String teamId) => '$teams/$teamId';
  static String player(String playerId) => '$players/$playerId';
  static String event(String eventId) => '$events/$eventId';
  static String match(String matchId) => '$matches/$matchId';
  static String injuryReport(String reportId) => '$injuryReports/$reportId';
  static String trainingSession(String sessionId) =>
      '$trainingSessions/$sessionId';
  static String physicalTestSession(String sessionId) =>
      '$physicalTestSessions/$sessionId';

  static String matchTimerState(String matchId) =>
      '$matches/$matchId/timer_state';
  static String matchTimerStateDoc(String matchId) =>
      '${matchTimerState(matchId)}/state';
  static String matchEvents(String matchId) => '$matches/$matchId/events';
  static String matchEvent(String matchId, String eventId) =>
      '${matchEvents(matchId)}/$eventId';
  static String matchPlayerStats(String matchId) =>
      '$matches/$matchId/player_stats';
  static String matchPlayerStat(String matchId, String playerStatId) =>
      '${matchPlayerStats(matchId)}/$playerStatId';
  static String matchLineups(String matchId) => '$matches/$matchId/lineups';
  static String matchLineup(String matchId, String lineupId) =>
      '${matchLineups(matchId)}/$lineupId';

  static String physicalTestResults(String sessionId) =>
      '$physicalTestSessions/$sessionId/results';
  static String physicalTestResult(String sessionId, String resultId) =>
      '${physicalTestResults(sessionId)}/$resultId';
}
