import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/utils/team_sort.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/position_selector.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/features/users/domain/providers/user_provider.dart';
import 'package:budiutama_basketball/shared/models/team_model.dart';

/// Bottom sheet untuk membuat akun pengguna baru (Manager-only).
///
/// Memanggil Cloud Function `createUser` via UserActionsNotifier — proses
/// pembuatan Firebase Auth user + Custom Claims + dokumen Firestore
/// dilakukan sepenuhnya di server (Admin SDK), sesuai SRS FR-AUTH-06.
class AddUserBottomSheet extends ConsumerStatefulWidget {
  const AddUserBottomSheet({super.key});

  @override
  ConsumerState<AddUserBottomSheet> createState() =>
      _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends ConsumerState<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _role = 'player';
  String? _teamId;
  Set<String> _selectedPositions = {'PG'};
  DateTime? _dateOfBirth;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  static const _roles = [
    (value: 'manager', label: 'Manager', icon: Icons.manage_accounts),
    (value: 'coach', label: 'Coach', icon: Icons.sports),
    (value: 'statistician', label: 'Statistician', icon: Icons.touch_app),
    (value: 'player', label: 'Player', icon: Icons.person),
  ];

  static final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$'));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _jerseyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get _needsTeam => _role == 'player' || _role == 'statistician';
  bool get _needsPlayerProfile => _role == 'player';

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamsStreamProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8D6E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Nama Lengkap *'),
              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration('Contoh: Budi Santoso'),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildLabel('Email *'),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration('nama@budiutama.sch.id'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final email = v?.trim() ?? '';
                  return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)
                      ? null
                      : 'Email tidak valid';
                },
              ),
              const SizedBox(height: 14),
              _buildLabel('Password Sementara *'),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Minimal 8 karakter').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) => (v?.length ?? 0) >= 8
                    ? null
                    : 'Password minimal 8 karakter',
              ),
              const SizedBox(height: 14),
              _buildLabel('Role *'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _roles.map((r) {
                  final isSelected = _role == r.value;
                  return GestureDetector(
                    onTap: () => setState(() => _role = r.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A3A5C)
                            : const Color(0xFFF4F6F8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1A3A5C)
                              : const Color(0xFFC8D6E5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            r.icon,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7A8D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            r.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF6B7A8D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              if (_needsTeam) ...[
                _buildLabel('Tim *'),
                _buildTeamDropdown(teamsAsync),
                const SizedBox(height: 14),
              ],
              if (_needsPlayerProfile) ...[
                _buildLabel('No. Jersey *'),
                TextFormField(
                  controller: _jerseyController,
                  decoration: _inputDecoration('Contoh: 7'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  validator: (v) {
                    if (!_needsPlayerProfile) return null;
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    final number = int.tryParse(v);
                    if (number == null || number < 0 || number > 99) {
                      return '0-99';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildLabel('Posisi * (pilih satu atau lebih)'),
                PositionSelector(
                  selected: _selectedPositions,
                  onChanged: (next) =>
                      setState(() => _selectedPositions = next),
                ),
                if (_selectedPositions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      'Pilih minimal 1 posisi',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 14),
                _buildLabel('Tanggal Lahir'),
                InkWell(
                  onTap: _pickDateOfBirth,
                  borderRadius: BorderRadius.circular(10),
                  child: InputDecorator(
                    decoration: _inputDecoration('Pilih tanggal lahir'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dateOfBirth == null
                                ? 'Belum diisi'
                                : DateFormat('dd MMMM yyyy', 'id_ID')
                                    .format(_dateOfBirth!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _dateOfBirth == null
                                  ? const Color(0xFF6B7A8D)
                                  : const Color(0xFF1C2B3A),
                            ),
                          ),
                        ),
                        const Icon(Icons.calendar_today,
                            size: 18, color: Color(0xFF6B7A8D)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Tinggi (cm)'),
                          TextFormField(
                            controller: _heightController,
                            decoration: _inputDecoration('Contoh: 175.5'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [_decimalFormatter],
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              final n = double.tryParse(v);
                              if (n == null || n < 100 || n > 230) {
                                return '100-230';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Berat (kg)'),
                          TextFormField(
                            controller: _weightController,
                            decoration: _inputDecoration('Contoh: 75.2'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [_decimalFormatter],
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              final n = double.tryParse(v);
                              if (n == null || n < 30 || n > 150) {
                                return '30-150';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE8420A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Buat Akun',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2008, 6, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_needsPlayerProfile && _selectedPositions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal 1 posisi.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final heightCm = _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text.trim())
          : null;
      final weightKg = _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text.trim())
          : null;
      final positions = _needsPlayerProfile
          ? PositionSelector.sortedPositions(_selectedPositions)
          : null;

      final error = await ref.read(userActionsProvider.notifier).createUser(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
            role: _role,
            teamId: _needsTeam ? _teamId : null,
            jerseyNumber: _needsPlayerProfile
                ? int.parse(_jerseyController.text.trim())
                : null,
            positions: positions,
            heightCm: heightCm,
            weightKg: weightKg,
            dateOfBirth: _dateOfBirth,
          );

      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Akun ${_fullNameController.text.trim()} berhasil dibuat.',
            ),
            backgroundColor: const Color(0xFF3B6D11),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTeamDropdown(AsyncValue<List<TeamModel>> teamsAsync) {
    return teamsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Text(
        'Gagal memuat daftar tim: $e',
        style: TextStyle(color: Colors.red.shade700, fontSize: 12),
      ),
      data: (teams) {
        final sortedTeams = sortTeamsForDisplay(teams);
        if (sortedTeams.isEmpty) {
          return const Text(
            'Belum ada tim terdaftar di Firestore. Hubungi admin untuk menambahkan tim.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7A8D)),
          );
        }

        final selectedId =
            sortedTeams.any((t) => t.id == _teamId) ? _teamId : null;

        return DropdownButtonFormField<String>(
          value: selectedId,
          decoration: _inputDecoration('Pilih tim'),
          items: sortedTeams
              .map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _teamId = v),
          validator: (_) => _needsTeam && _teamId == null
              ? 'Pilih tim terlebih dahulu'
              : null,
        );
      },
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1C2B3A),
          ),
        ),
      );

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC8D6E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFC8D6E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A3A5C), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      );
}
