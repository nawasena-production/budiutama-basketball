/// Konfigurasi navigasi dashboard per role — selaras dengan
/// Documentation/Budi_Utama_Basketball_UIUX_Flow.html (Menu Navigasi).
class RoleNavigation {
  RoleNavigation._();

  static const Map<String, List<String>> slugsByRole = {
    'manager': [
      'players',
      'training',
      'events',
      'injuries',
      'physical-tests',
      'statistics',
      'audit-log',
      'users',
    ],
    'coach': [
      'players',
      'training',
      'events',
      'injuries',
      'physical-tests',
      'statistics',
      'audit-log',
    ],
    'statistician': [
      'players',
      'events',
    ],
    'player': [
      'training',
      'events',
      'statistics',
    ],
  };

  static List<String> slugsFor(String? role) =>
      slugsByRole[role ?? 'player'] ?? slugsByRole['player']!;

  static String defaultPath(String? role) {
    final slugs = slugsFor(role);
    return slugs.isEmpty ? '/training' : '/${slugs.first}';
  }

  static int indexForSlug(String? role, String slug) {
    final index = slugsFor(role).indexOf(slug);
    return index == -1 ? 0 : index;
  }

  static bool slugAllowed(String? role, String slug) =>
      slugsFor(role).contains(slug);
}
