import 'package:budiutama_basketball/shared/models/team_model.dart';

/// Urutan tampilan tim: SMA Putra → SMA Putri → SMP Putra → SMP Putri.
int teamDisplayOrder(TeamModel team) {
  final id = team.id.toLowerCase();
  if (id.contains('sma') && team.gender == 'male') return 0;
  if (id.contains('sma') && team.gender == 'female') return 1;
  if (id.contains('smp') && team.gender == 'male') return 2;
  if (id.contains('smp') && team.gender == 'female') return 3;
  // Fallback untuk ID legacy (putra_2526 / putri_2526).
  return team.gender == 'male' ? 0 : 1;
}

List<TeamModel> sortTeamsForDisplay(List<TeamModel> teams) {
  final sorted = List<TeamModel>.from(teams);
  sorted.sort((a, b) {
    final order = teamDisplayOrder(a).compareTo(teamDisplayOrder(b));
    if (order != 0) return order;
    return a.name.compareTo(b.name);
  });
  return sorted;
}
