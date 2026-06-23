import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';

/// Widget untuk memilih tepat 5 pemain starter sebelum START MATCH.
///
/// Ditampilkan di MatchDetailPage sebagai bottom sheet atau inline section.
/// Sesuai SRS UC-05 alur: "Dialog konfirmasi lineup pemain awal → Pilih 5 pemain starter".
///
/// Logic:
/// - Hanya pemain dengan status 'active' yang muncul
/// - Maksimal 5 pemain bisa dipilih
/// - Tombol konfirmasi baru aktif jika tepat 5 pemain dipilih
class StarterPickerWidget extends ConsumerWidget {
  final String teamId;
  final VoidCallback? onConfirmed;

  const StarterPickerWidget({
    super.key,
    required this.teamId,
    this.onConfirmed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlayers = ref.watch(activePLayersStreamProvider(teamId));
    final selectedStarters = ref.watch(selectedStartersProvider);

    return activePlayers.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (players) {
        if (players.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Tidak ada pemain aktif di roster.\n'
                'Tambahkan pemain terlebih dahulu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B7A8D)),
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Pilih 5 Pemain Starter',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A3A5C),
                    ),
                  ),
                  const Spacer(),
                  // Counter badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: selectedStarters.length == 5
                          ? const Color(0xFFEAF3DE)
                          : const Color(0xFFE6F1FB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedStarters.length}/5',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: selectedStarters.length == 5
                            ? const Color(0xFF27500A)
                            : const Color(0xFF0C447C),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List pemain
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: players.length,
                itemBuilder: (context, i) {
                  final player = players[i];
                  final isSelected = selectedStarters
                      .any((p) => p.id == player.id);
                  final isDisabled =
                      !isSelected && selectedStarters.length >= 5;

                  return _StarterPlayerTile(
                    player: player,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    onTap: () => _togglePlayer(ref, player, isSelected),
                  );
                },
              ),
            ),

            // Footer: tombol konfirmasi
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (selectedStarters.length != 5)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        selectedStarters.length < 5
                            ? 'Pilih ${5 - selectedStarters.length} pemain lagi'
                            : 'Batalkan pilihan ${selectedStarters.length - 5} pemain',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7A8D),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: selectedStarters.length == 5
                          ? () {
                              onConfirmed?.call();
                            }
                          : null,
                      icon: const Icon(Icons.sports_basketball, size: 18),
                      label: const Text(
                        'Konfirmasi Lineup',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8420A),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        disabledBackgroundColor:
                            const Color(0xFFE8420A).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePlayer(
      WidgetRef ref, PlayerModel player, bool isCurrentlySelected) {
    final notifier = ref.read(selectedStartersProvider.notifier);
    final current = ref.read(selectedStartersProvider);

    if (isCurrentlySelected) {
      // Deselect
      notifier.state = current.where((p) => p.id != player.id).toList();
    } else if (current.length < 5) {
      // Select
      notifier.state = [...current, player];
    }
    // Jika sudah 5 dan belum dipilih → ignore (tombol disabled)
  }
}

class _StarterPlayerTile extends StatelessWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _StarterPlayerTile({
    required this.player,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF1A3A5C).withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF1A3A5C)
              : const Color(0xFFC8D6E5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        onTap: isDisabled ? null : onTap,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: isSelected
              ? const Color(0xFF1A3A5C)
              : const Color(0xFFE6F1FB),
          child: Text(
            '#${player.jerseyNumber}',
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0C447C),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
        title: Text(
          player.fullName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDisabled
                ? const Color(0xFF6B7A8D)
                : const Color(0xFF1C2B3A),
          ),
        ),
        subtitle: Text(
          player.positionsDisplay,
          style: const TextStyle(
              fontSize: 11, color: Color(0xFF6B7A8D)),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle,
                color: Color(0xFF1A3A5C), size: 20)
            : isDisabled
                ? const Icon(Icons.circle_outlined,
                    color: Color(0xFFC8D6E5), size: 20)
                : const Icon(Icons.radio_button_unchecked,
                    color: Color(0xFFC8D6E5), size: 20),
      ),
    );
  }
}
