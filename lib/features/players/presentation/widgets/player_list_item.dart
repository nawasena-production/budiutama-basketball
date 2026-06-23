import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/utils/physical_format.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'player_status_badge.dart';

/// Widget card untuk satu pemain di halaman daftar pemain.
/// Menampilkan foto (dari base64), jersey, nama, posisi, dan status.
class PlayerListItem extends StatelessWidget {
  final PlayerModel player;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PlayerListItem({
    super.key,
    required this.player,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Foto / Avatar pemain
              _buildAvatar(),
              const SizedBox(width: 12),
              // Info pemain
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${player.jerseyNumber}',
                          style: const TextStyle(
                            color: Color(0xFFE8420A),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            player.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...player.positions.map(
                          (pos) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: _buildPositionChip(pos),
                          ),
                        ),
                        if (player.heightCm != null) ...[
                          const SizedBox(width: 2),
                          Text(
                            '${formatPhysicalValue(player.heightCm!)}cm',
                            style: const TextStyle(
                              color: Color(0xFF6B7A8D),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              PlayerStatusBadge(status: player.status),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF6B7A8D),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (player.photoBase64 != null && player.photoBase64!.isNotEmpty) {
      try {
        final raw = player.photoBase64!;
        final bytes = base64Decode(
          raw.contains(',') ? raw.split(',').last : raw,
        );
        return ClipOval(
          child: Image.memory(
            bytes,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        // fallback ke inisial
      }
    }

    // Inisial dari nama pemain
    final initials = player.fullName
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFFE6F1FB),
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF0C447C),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildPositionChip(String position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEDFE),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        position,
        style: const TextStyle(
          color: Color(0xFF3C3489),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
