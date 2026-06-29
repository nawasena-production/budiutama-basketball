/// Utilitas untuk konversi ID tim SMP → SMA (naik tingkat).
String? smaTeamIdFromSmp(String smpTeamId) {
  final normalized = smpTeamId.toLowerCase();
  if (!normalized.contains('smp')) return null;
  return smpTeamId.replaceFirst(
    RegExp('smp', caseSensitive: false),
    'sma',
  );
}

bool isSmpTeam(String teamId) => teamId.toLowerCase().contains('smp');

bool isSmaTeam(String teamId) => teamId.toLowerCase().contains('sma');
