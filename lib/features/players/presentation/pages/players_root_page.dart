import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'players_page.dart';

/// Halaman root Players yang menggabungkan TeamToggle + PlayersPage.
/// Ini adalah entry point dari navigasi utama (bottom nav / sidebar).
///
/// Layout:
/// - AppBar dengan judul "Pemain"
/// - TeamToggle (pilih Tim Putra / Putri)
/// - PlayersPage (list + search + filter)
class PlayersRootPage extends ConsumerWidget {
  /// Role pengguna yang sedang login.
  final String role;

  const PlayersRootPage({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsStreamProvider);
    final activeTeamId = ref.watch(activeTeamIdProvider);

    return AppPageScaffold(
      title: 'Pemain',
      subtitle: 'Roster, status, dan data atlet aktif',
      icon: Icons.people_outline,
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.navySoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: Text(
            _academicYear(activeTeamId),
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
      child: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error memuat tim: $e')),
        data: (teams) {
          if (teams.isEmpty) {
            return const Center(
              child: Text('Belum ada tim yang terdaftar.'),
            );
          }

          return Column(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderSoft),
                  ),
                ),
                child: TeamToggleWidget(teams: teams),
              ),
              Expanded(
                child: PlayersPage(
                  teamId: activeTeamId,
                  role: role,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Derivasi label tahun ajaran dari teamId.
  /// Contoh: "putra_2526" → "2025/2026"
  String _academicYear(String teamId) {
    final parts = teamId.split('_');
    if (parts.length < 2) return '';
    final code = parts.last; // "2526"
    if (code.length != 4) return code;
    return '20${code.substring(0, 2)}/20${code.substring(2)}';
  }
}
