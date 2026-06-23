import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';
import 'package:budiutama_basketball/core/utils/team_sort.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'players_page.dart';

class PlayersRootPage extends ConsumerWidget {
  final String role;

  const PlayersRootPage({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsAsync = ref.watch(teamsStreamProvider);
    final activeTeamId = ref.watch(activeTeamIdProvider); // String

    return AppPageScaffold(
      title: 'Pemain',
      subtitle: 'Roster, status, dan data atlet aktif',
      icon: Icons.people_outline,
      child: teamsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error memuat tim: $e')),
        data: (teams) {
          if (teams.isEmpty) {
            return const Center(
              child: Text('Belum ada tim yang terdaftar.'),
            );
          }

          final sorted = sortTeamsForDisplay(teams);
          // Resolve: empty string means "not selected yet" → use first team
          final effectiveTeamId =
              activeTeamId.isEmpty ? sorted.first.id : activeTeamId;

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
                  teamId: effectiveTeamId,
                  role: role,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}