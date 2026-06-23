import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/constants/firestore_paths.dart';
import 'package:budiutama_basketball/core/utils/team_sort.dart';
import 'package:budiutama_basketball/shared/models/team_model.dart';

/// Provider untuk stream semua tim aktif.
final teamsStreamProvider = StreamProvider<List<TeamModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirestorePaths.teams)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => TeamModel.fromFirestore(doc))
          .where((team) => team.isActive)
          .toList());
});

/// Provider untuk team ID yang sedang aktif.
/// Tetap String (non-nullable) — default ke string kosong '',
/// diselesaikan menjadi tim pertama di level widget/page.
final activeTeamIdProvider = StateProvider<String>((ref) => '');

/// Widget toggle untuk memilih salah satu dari empat tim.
class TeamToggleWidget extends ConsumerWidget {
  final List<TeamModel>? teams;

  const TeamToggleWidget({super.key, this.teams});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providedTeams = teams;

    if (providedTeams == null) {
      final teamsAsync = ref.watch(teamsStreamProvider);
      return teamsAsync.maybeWhen(
        data: (loadedTeams) => _buildBody(ref, loadedTeams),
        orElse: () => const SizedBox.shrink(),
      );
    }

    return _buildBody(ref, providedTeams);
  }

  Widget _buildBody(WidgetRef ref, List<TeamModel> teamList) {
    if (teamList.isEmpty) return const SizedBox.shrink();

    final sorted = sortTeamsForDisplay(teamList);
    final activeTeamId = ref.watch(activeTeamIdProvider);

    // Resolve effective ID — use first team when nothing selected yet
    final effectiveId =
        activeTeamId.isEmpty ? sorted.first.id : activeTeamId;

    // Sync provider to first team if still empty
    if (activeTeamId.isEmpty) {
      Future.microtask(() {
        ref.read(activeTeamIdProvider.notifier).state = sorted.first.id;
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC8D6E5)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < sorted.length; i++) ...[
            if (i > 0)
              Container(
                  width: 1, height: 28, color: const Color(0xFFC8D6E5)),
            Expanded(
              child: _TeamTab(
                label: sorted[i].name,
                teamId: sorted[i].id,
                isActive: effectiveId == sorted[i].id,
                onTap: () =>
                    ref.read(activeTeamIdProvider.notifier).state =
                        sorted[i].id,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamTab extends StatelessWidget {
  final String label;
  final String teamId;
  final bool isActive;
  final VoidCallback onTap;

  const _TeamTab({
    required this.label,
    required this.teamId,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A3A5C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF6B7A8D),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}