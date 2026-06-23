import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/utils/physical_format.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/add_edit_player_bottom_sheet.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/player_status_badge.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';

/// Halaman detail pemain — menampilkan profil lengkap, statistik ringkasan,
/// dan aksi manajemen (edit, ubah status, nonaktifkan).
///
/// Accessible oleh Coach (read-only), Manager (full access),
/// dan Player sendiri (read-only data milik sendiri).
class PlayerDetailPage extends ConsumerWidget {
  final String playerId;
  final String teamId;
  final String role; // role pengguna yang sedang login

  const PlayerDetailPage({
    super.key,
    required this.playerId,
    required this.teamId,
    required this.role,
  });

  bool get _canEdit => role == 'manager';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ambil data pemain dari stream real-time (selalu segar dari Firestore)
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
          backgroundColor: const Color(0xFFF4F6F8),
          body: CustomScrollView(
            slivers: [
              _buildAppBar(context, ref, player),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoCard(player),
                      const SizedBox(height: 12),
                      _buildPhysicalCard(player),
                      if (_canEdit) ...[
                        const SizedBox(height: 12),
                        _buildActionsCard(context, ref, player),
                      ],
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
      expandedHeight: 240,
      pinned: true,
      backgroundColor: const Color(0xFF1A3A5C),
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
                _buildAvatar(player, radius: 44),
                const SizedBox(height: 12),
                Text(
                  player.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildJerseyChip(player.jerseyNumber),
                    const SizedBox(width: 8),
                    ...player.positions.map(
                      (pos) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildPositionChip(pos),
                      ),
                    ),
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
            const SizedBox(height: 12),
            _infoRow('Nomor Jersey', '#${player.jerseyNumber}'),
            _infoRow(
              'Posisi',
              player.positions
                  .map(_positionLabel)
                  .join(' · '),
            ),
            if (player.dateOfBirth != null)
              _infoRow(
                'Tanggal Lahir',
                '${DateFormat('dd MMM yyyy').format(player.dateOfBirth!)} '
                '(${calculateAge(player.dateOfBirth!)} th)',
              ),
            _infoRow('Tim', player.teamId),
            _infoRow('Status', _statusLabel(player.status)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalCard(PlayerModel player) {
    if (player.heightCm == null &&
        player.weightKg == null &&
        player.dateOfBirth == null) {
      return const SizedBox.shrink();
    }

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
            const SizedBox(height: 12),
            Row(
              children: [
                if (player.heightCm != null)
                  Expanded(
                    child: _physicalStat(
                      'Tinggi',
                      '${formatPhysicalValue(player.heightCm!)} cm',
                    ),
                  ),
                if (player.weightKg != null)
                  Expanded(
                    child: _physicalStat(
                      'Berat',
                      '${formatPhysicalValue(player.weightKg!)} kg',
                    ),
                  ),
                if (player.heightCm != null && player.weightKg != null)
                  Expanded(
                    child: _physicalStat(
                      'BMI',
                      calculateBmi(player.heightCm!, player.weightKg!)!
                          .toStringAsFixed(1),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            // Ubah status
            if (player.status == 'active')
              ListTile(
                leading: const Icon(Icons.healing_outlined,
                    color: Color(0xFFBA7517)),
                title: const Text('Tandai Cedera'),
                subtitle: const Text('Ubah status pemain menjadi cedera'),
                onTap: () => _updateStatus(context, ref, player, 'injured'),
              ),
            if (player.status == 'injured')
              ListTile(
                leading: const Icon(Icons.check_circle_outline,
                    color: Color(0xFF3B6D11)),
                title: const Text('Tandai Pulih'),
                subtitle: const Text('Kembalikan status pemain menjadi aktif'),
                onTap: () => _updateStatus(context, ref, player, 'active'),
              ),
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
                onTap: () => _updateStatus(context, ref, player, 'active'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────────

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
          const SnackBar(
            content: Text('Pemain berhasil dinonaktifkan.'),
          ),
        );
      }
    }
  }

  // ── HELPER WIDGETS ────────────────────────────────────────────────────────

  Widget _buildAvatar(PlayerModel player, {required double radius}) {
    if (player.photoBase64 != null && player.photoBase64!.isNotEmpty) {
      try {
        final raw = player.photoBase64!;
        final bytes =
            base64Decode(raw.contains(',') ? raw.split(',').last : raw);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }
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
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPositionChip(String position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        position,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6B7A8D), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _physicalStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A3A5C),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A8D)),
        ),
      ],
    );
  }

  String _positionLabel(String pos) {
    switch (pos) {
      case 'PG':
        return 'Point Guard (PG)';
      case 'SG':
        return 'Shooting Guard (SG)';
      case 'SF':
        return 'Small Forward (SF)';
      case 'PF':
        return 'Power Forward (PF)';
      case 'C':
        return 'Center (C)';
      default:
        return pos;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'injured':
        return 'Cedera';
      case 'inactive':
        return 'Non-Aktif';
      default:
        return status;
    }
  }
}
