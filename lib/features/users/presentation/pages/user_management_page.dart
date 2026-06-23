import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/users/domain/providers/user_provider.dart';
import 'package:budiutama_basketball/features/users/presentation/widgets/add_user_bottom_sheet.dart';
import 'package:budiutama_basketball/shared/models/user_model.dart';
import 'package:budiutama_basketball/shared/widgets/app_page_scaffold.dart';
import 'package:budiutama_basketball/shared/widgets/confirm_dialog.dart';
import 'package:budiutama_basketball/shared/widgets/empty_state_widget.dart';

/// Halaman Account Management — khusus Manager (SRS FR-AUTH-06).
///
/// Menampilkan semua akun pengguna, filter per role, dan aksi:
/// buat akun baru, ubah role, nonaktifkan/aktifkan akun.
///
/// Semua aksi yang mengubah Firebase Auth (Custom Claims, disable user)
/// dilakukan via Cloud Functions callable — TIDAK langsung dari client.
class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  static const _roleFilters = [
    (value: null, label: 'Semua'),
    (value: 'manager', label: 'Manager'),
    (value: 'coach', label: 'Coach'),
    (value: 'statistician', label: 'Statistician'),
    (value: 'player', label: 'Player'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(filteredUsersProvider);
    final activeFilter = ref.watch(userRoleFilterProvider);

    return AppPageScaffold(
      title: 'Manajemen Pengguna',
      subtitle: 'Kelola akun, role, dan status akses pengguna',
      icon: Icons.manage_accounts_outlined,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserSheet(context),
        tooltip: 'Buat Akun Baru',
        child: const Icon(Icons.person_add_alt_1),
      ),
      child: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _roleFilters.map((f) {
                  final isSelected = activeFilter == f.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f.label),
                      selected: isSelected,
                      onSelected: (_) => ref
                          .read(userRoleFilterProvider.notifier)
                          .state = f.value,
                      selectedColor: const Color(0xFF1A3A5C),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF1C2B3A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: const Color(0xFFF4F6F8),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Daftar user
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (users) {
                if (users.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.people_outline,
                    message: 'Belum ada pengguna untuk filter ini.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: users.length,
                  itemBuilder: (ctx, i) => _UserCard(user: users[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddUserBottomSheet(),
    );
  }
}

// ── USER CARD ─────────────────────────────────────────────────────────────

class _UserCard extends ConsumerWidget {
  final UserModel user;
  const _UserCard({required this.user});

  static const _roleColors = {
    'manager': Color(0xFF1A3A5C),
    'coach': Color(0xFF534AB7),
    'statistician': Color(0xFFE8420A),
    'player': Color(0xFF0F6E56),
  };

  static const _roleLabels = {
    'manager': 'Manager',
    'coach': 'Coach',
    'statistician': 'Statistician',
    'player': 'Player',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleColor = _roleColors[user.role] ?? const Color(0xFF6B7A8D);
    final roleLabel = _roleLabels[user.role] ?? user.role;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              user.isActive ? const Color(0xFFC8D6E5) : const Color(0xFFE24B4A),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.12),
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
            style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(user.fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            if (!user.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEBEB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Nonaktif',
                    style: TextStyle(
                        fontSize: 9,
                        color: Color(0xFF791F1F),
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7A8D))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(roleLabel,
                  style: TextStyle(
                      fontSize: 10,
                      color: roleColor,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF6B7A8D)),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'change_role',
              child: Row(children: [
                Icon(Icons.swap_horiz, size: 16),
                SizedBox(width: 8),
                Text('Ubah Role'),
              ]),
            ),
            if (user.isActive)
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(children: [
                  Icon(Icons.block, size: 16, color: Color(0xFFA32D2D)),
                  SizedBox(width: 8),
                  Text('Nonaktifkan',
                      style: TextStyle(color: Color(0xFFA32D2D))),
                ]),
              )
            else
              const PopupMenuItem(
                value: 'reactivate',
                child: Row(children: [
                  Icon(Icons.check_circle_outline,
                      size: 16, color: Color(0xFF3B6D11)),
                  SizedBox(width: 8),
                  Text('Aktifkan Kembali',
                      style: TextStyle(color: Color(0xFF3B6D11))),
                ]),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(children: [
                Icon(Icons.delete_forever, size: 16, color: Color(0xFFA32D2D)),
                SizedBox(width: 8),
                Text('Hapus Akun',
                    style: TextStyle(color: Color(0xFFA32D2D))),
              ]),
            ),
          ],
          onSelected: (action) => _handleAction(context, ref, action),
        ),
      ),
    );
  }

  Future<void> _handleAction(
      BuildContext context, WidgetRef ref, String action) async {
    switch (action) {
      case 'change_role':
        await _showChangeRoleDialog(context, ref);
        break;
      case 'deactivate':
        await _confirmAndRun(
          context,
          title: 'Nonaktifkan Akun?',
          content:
              '${user.fullName} tidak akan bisa login sampai diaktifkan kembali.',
          confirmLabel: 'Nonaktifkan',
          isDestructive: true,
          action: () => ref
              .read(userActionsProvider.notifier)
              .deactivateUser(docId: user.id, uid: user.uid),
        );
        break;
      case 'reactivate':
        await _confirmAndRun(
          context,
          title: 'Aktifkan Kembali?',
          content: '${user.fullName} akan bisa login kembali.',
          confirmLabel: 'Aktifkan',
          action: () => ref
              .read(userActionsProvider.notifier)
              .reactivateUser(docId: user.id, uid: user.uid),
        );
        break;
      case 'delete':
        await _confirmAndRun(
          context,
          title: 'Hapus Akun Permanen?',
          content:
              'Akun ${user.fullName} akan dihapus dari Firebase Auth dan daftar pengguna. Data roster/statistik pemain tidak ikut dihapus.',
          confirmLabel: 'Hapus Akun',
          isDestructive: true,
          successMessage: 'Akun berhasil dihapus permanen.',
          failureMessage: 'Gagal menghapus akun.',
          action: () => ref
              .read(userActionsProvider.notifier)
              .deleteUser(docId: user.id, uid: user.uid),
        );
        break;
    }
  }

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmLabel,
    required Future<bool> Function() action,
    bool isDestructive = false,
    String successMessage = 'Berhasil diperbarui.',
    String failureMessage = 'Gagal memperbarui akun.',
  }) async {
    final confirmed = await showConfirmDialog(
      context,
      title: title,
      content: content,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
    );
    if (confirmed != true) return;

    final success = await action();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? successMessage : failureMessage),
        backgroundColor:
            success ? const Color(0xFF3B6D11) : Colors.red.shade700,
      ),
    );
  }

  Future<void> _showChangeRoleDialog(
      BuildContext context, WidgetRef ref) async {
    String selectedRole = user.role;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ubah Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role baru untuk ${user.fullName}:'),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                items: _roleLabels.entries
                    .map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedRole = v);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selectedRole != user.role) {
      final success =
          await ref.read(userActionsProvider.notifier).updateUserRole(
                docId: user.id,
                uid: user.uid,
                newRole: selectedRole,
              );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Role berhasil diubah. Pengguna perlu login ulang.'
              : 'Gagal mengubah role.'),
          backgroundColor:
              success ? const Color(0xFF3B6D11) : Colors.red.shade700,
        ),
      );
    }
  }
}
