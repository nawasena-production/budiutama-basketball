import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';
import 'package:budiutama_basketball/core/utils/physical_format.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/add_edit_player_bottom_sheet.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/player_status_badge.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';

class PlayerDetailPage extends ConsumerWidget {
  final String playerId;
  final String teamId;
  final String role;

  const PlayerDetailPage({
    super.key,
    required this.playerId,
    required this.teamId,
    required this.role,
  });

  bool get _canEdit => role == 'manager';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(playersStreamProvider(teamId));

    return playersAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Detail Pemain')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (players) {
        final player = players.where((p) => p.id == playerId).firstOrNull;

        if (player == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Pemain')),
            body: const Center(child: Text('Pemain tidak ditemukan.')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, ref, player),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(player),
                      if (player.heightCm != null || player.weightKg != null) ...[
                        const SizedBox(height: 12),
                        _buildPhysicalCard(player),
                      ],
                      if (_canEdit) ...[
                        const SizedBox(height: 12),
                        _buildActionsCard(context, ref, player),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, WidgetRef ref, PlayerModel player) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      actions: _canEdit
          ? [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Pemain',
                onPressed: () => _showEditSheet(context, player),
              ),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A3A5C), Color(0xFF2E75B6)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                _buildAvatar(player, radius: 40),
                const SizedBox(height: 10),
                Text(
                  player.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: [
                    _buildJerseyChip(player.jerseyNumber),
                    ...player.positions.map((pos) => _buildPositionChip(pos)),
                    PlayerStatusBadge(status: player.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(PlayerModel player) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pemain',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF1A3A5C),
              ),
            ),
            const SizedBox(height: 14),
            // Nomor Jersey
            _infoTile(
              icon: Icons.tag,
              label: 'Nomor Jersey',
              value: '#${player.jerseyNumber}',
            ),
            const Divider(height: 1),
            // Posisi
            _infoTile(
              icon: Icons.sports_basketball_outlined,
              label: 'Posisi',
              value: player.positions.map(_positionLabel).join(' · '),
            ),
            const Divider(height: 1),
            // Tim - Fix #4: formatted team name
            _infoTile(
              icon: Icons.group_outlined,
              label: 'Tim',
              value: _formatTeamName(player.teamId),
            ),
            const Divider(height: 1),
            // Tanggal lahir
            if (player.dateOfBirth != null) ...[
              _infoTile(
                icon: Icons.cake_outlined,
                label: 'Tanggal Lahir',
                value:
                    '${DateFormat('dd MMM yyyy').format(player.dateOfBirth!)} '
                    '(${calculateAge(player.dateOfBirth!)} tahun)',
              ),
              const Divider(height: 1),
            ],
            // Status
            _infoTile(
              icon: Icons.circle_outlined,
              label: 'Status',
              value: _statusLabel(player.status),
              valueColor: _statusColor(player.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7A8D)),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7A8D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? const Color(0xFF1C2B3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalCard(PlayerModel player) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Fisik',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF1A3A5C),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (player.heightCm != null)
                  _physicalStatBox(
                    label: 'Tinggi',
                    value: '${formatPhysicalValue(player.heightCm!)}',
                    unit: 'cm',
                    icon: Icons.height,
                  ),
                if (player.weightKg != null)
                  _physicalStatBox(
                    label: 'Berat',
                    value: '${formatPhysicalValue(player.weightKg!)}',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                  ),
                if (player.heightCm != null && player.weightKg != null)
                  _physicalStatBox(
                    label: 'BMI',
                    value: calculateBmi(player.heightCm!, player.weightKg!)!
                        .toStringAsFixed(1),
                    unit: 'kg/m²',
                    icon: Icons.accessibility_new,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _physicalStatBox({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.navySoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.navy),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A3A5C),
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7A8D)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7A8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
      BuildContext context, WidgetRef ref, PlayerModel player) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC8D6E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Aksi Manajemen',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF1A3A5C),
              ),
            ),
          ),
          const Divider(height: 1),
          if (player.status == 'active')
            ListTile(
              leading: const Icon(Icons.healing_outlined,
                  color: Color(0xFFBA7517)),
              title: const Text('Tandai Cedera'),
              subtitle: const Text('Ubah status pemain menjadi cedera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _updateStatus(context, ref, player, 'injured'),
            ),
          if (player.status == 'injured') ...[
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: Color(0xFF3B6D11)),
              title: const Text('Tandai Pulih'),
              subtitle: const Text('Kembalikan status pemain menjadi aktif'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _updateStatus(context, ref, player, 'active'),
            ),
          ],
          if (player.status != 'inactive') ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_off_outlined,
                  color: Color(0xFFA32D2D)),
              title: const Text(
                'Nonaktifkan Pemain',
                style: TextStyle(color: Color(0xFFA32D2D)),
              ),
              subtitle:
                  const Text('Pemain tidak akan muncul di roster aktif'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _confirmDeactivate(context, ref, player),
            ),
          ],
          if (player.status == 'inactive') ...[
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.person_outline, color: Color(0xFF3B6D11)),
              title: const Text(
                'Aktifkan Kembali',
                style: TextStyle(color: Color(0xFF3B6D11)),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _updateStatus(context, ref, player, 'active'),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, PlayerModel player) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddEditPlayerBottomSheet(
        teamId: teamId,
        existingPlayer: player,
        existingPlayerId: playerId,
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref,
      PlayerModel player, String newStatus) async {
    await ref
        .read(playerActionsProvider.notifier)
        .updateStatus(player.id, newStatus);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Status pemain diubah menjadi ${_statusLabel(newStatus)}.',
          ),
          backgroundColor: const Color(0xFF3B6D11),
        ),
      );
    }
  }

  Future<void> _confirmDeactivate(
      BuildContext context, WidgetRef ref, PlayerModel player) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Nonaktifkan Pemain',
      content: 'Pemain ${player.fullName} akan dinonaktifkan dan tidak akan '
          'muncul di roster aktif. Data statistik tetap tersimpan.',
      confirmLabel: 'Nonaktifkan',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(playerActionsProvider.notifier)
          .deactivatePlayer(player.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pemain berhasil dinonaktifkan.')),
        );
      }
    }
  }

  Widget _buildAvatar(PlayerModel player, {required double radius}) {
    if (player.photoBase64 != null && player.photoBase64!.isNotEmpty) {
      try {
        final raw = player.photoBase64!;
        final base64Str = raw.contains(',') ? raw.split(',').last : raw;
        final bytes = base64Decode(base64Str);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsAvatar(player, radius),
          ),
        );
      } catch (_) {}
    }
    return _initialsAvatar(player, radius);
  }

  Widget _initialsAvatar(PlayerModel player, double radius) {
    final initials = player.fullName
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.55,
        ),
      ),
    );
  }

  Widget _buildJerseyChip(int jersey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8420A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '#$jersey',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPositionChip(String position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        position,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _positionLabel(String pos) {
    switch (pos) {
      case 'PG': return 'Point Guard (PG)';
      case 'SG': return 'Shooting Guard (SG)';
      case 'SF': return 'Small Forward (SF)';
      case 'PF': return 'Power Forward (PF)';
      case 'C':  return 'Center (C)';
      default:   return pos;
    }
  }

  /// Fix #4: Format team ID to readable name
  /// e.g. "sma_putra_2526" → "SMA Putra"
  /// e.g. "putra_2526" → "SMA Putra"
  String _formatTeamName(String teamId) {
    final id = teamId.toLowerCase();

    String level = 'SMA';
    if (id.contains('smp')) level = 'SMP';

    String gender = 'Putra';
    if (id.contains('putri') || id.contains('female')) gender = 'Putri';

    // Extract academic year
    final yearMatch = RegExp(r'(\d{2})(\d{2})').firstMatch(id);
    if (yearMatch != null) {
      final yearStr = '20${yearMatch.group(1)}/20${yearMatch.group(2)}';
      return '$level $gender $yearStr';
    }

    return '$level $gender';
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':   return 'Aktif';
      case 'injured':  return 'Cedera';
      case 'inactive': return 'Non-Aktif';
      default:         return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':   return const Color(0xFF27500A);
      case 'injured':  return const Color(0xFF633806);
      case 'inactive': return const Color(0xFF444441);
      default:         return const Color(0xFF1C2B3A);
    }
  }
}