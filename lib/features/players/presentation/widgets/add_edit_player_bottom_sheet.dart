import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/core/utils/physical_format.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/data/repositories/player_repository.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/position_selector.dart';
import 'photo_upload_widget.dart';

/// Bottom sheet untuk tambah pemain baru atau edit pemain yang sudah ada.
/// Accessible oleh Manager saja (enforcement di Security Rules).
///
/// Sesuai SRS FR-PLY-01 (tambah) dan FR-PLY-02 (edit).
class AddEditPlayerBottomSheet extends ConsumerStatefulWidget {
  /// ID tim yang sedang aktif.
  final String teamId;

  /// Jika tidak null, mode edit dengan data pemain yang akan diubah.
  final PlayerModel? existingPlayer;

  /// Document ID pemain yang sudah ada (untuk mode edit).
  final String? existingPlayerId;

  const AddEditPlayerBottomSheet({
    super.key,
    required this.teamId,
    this.existingPlayer,
    this.existingPlayerId,
  });

  bool get isEditMode => existingPlayer != null;

  @override
  ConsumerState<AddEditPlayerBottomSheet> createState() =>
      _AddEditPlayerBottomSheetState();
}

class _AddEditPlayerBottomSheetState
    extends ConsumerState<AddEditPlayerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  Set<String> _selectedPositions = {'PG'};
  DateTime? _dateOfBirth;
  String? _photoBase64;
  bool _isSubmitting = false;

  static final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$'));

  @override
  void initState() {
    super.initState();
    if (widget.existingPlayer != null) {
      final p = widget.existingPlayer!;
      _nameController.text = p.fullName;
      _jerseyController.text = p.jerseyNumber.toString();
      _heightController.text =
          p.heightCm != null ? formatPhysicalValue(p.heightCm!) : '';
      _weightController.text =
          p.weightKg != null ? formatPhysicalValue(p.weightKg!) : '';
      _selectedPositions = p.positions.isNotEmpty
          ? Set<String>.from(p.positions)
          : {'PG'};
      _dateOfBirth = p.dateOfBirth;
      _photoBase64 = p.photoBase64;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                widget.isEditMode ? 'Edit Data Pemain' : 'Tambah Pemain Baru',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: PhotoUploadWidget(
                  currentBase64: _photoBase64,
                  onPhotoChanged: (base64) =>
                      setState(() => _photoBase64 = base64),
                ),
              ),
              const SizedBox(height: 20),
              _buildLabel('Nama Lengkap *'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Contoh: Ahmad Rizki'),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (v.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
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
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  final num = int.tryParse(v);
                  if (num == null || num < 0 || num > 99) return '0–99';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildLabel('Posisi * (pilih satu atau lebih)'),
              PositionSelector(
                selected: _selectedPositions,
                onChanged: (next) => setState(() => _selectedPositions = next),
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
                              return '100–230';
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
                              return '30–150';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                      : Text(
                          widget.isEditMode
                              ? 'Simpan Perubahan'
                              : 'Tambah Pemain',
                          style: const TextStyle(
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
    if (_selectedPositions.isEmpty) {
      _showError('Pilih minimal 1 posisi.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final fullName = _nameController.text.trim();
      final jerseyNumber = int.parse(_jerseyController.text.trim());
      final heightCm = _heightController.text.isNotEmpty
          ? double.tryParse(_heightController.text.trim())
          : null;
      final weightKg = _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text.trim())
          : null;
      final positions =
          PositionSelector.sortedPositions(_selectedPositions);

      final repo = ref.read(playerRepositoryProvider);

      if (widget.isEditMode && widget.existingPlayerId != null) {
        final jerseyTaken = await repo.isJerseyNumberTaken(
          widget.teamId,
          jerseyNumber,
          excludePlayerId: widget.existingPlayerId,
        );
        if (jerseyTaken) {
          _showError(
              'Nomor jersey #$jerseyNumber sudah digunakan pemain lain.');
          return;
        }

        await ref.read(playerActionsProvider.notifier).updatePlayer(
          widget.existingPlayerId!,
          {
            'full_name': fullName,
            'jersey_number': jerseyNumber,
            'positions': positions,
            'height_cm': heightCm,
            'weight_kg': weightKg,
            'date_of_birth': _dateOfBirth != null
                ? Timestamp.fromDate(_dateOfBirth!)
                : null,
            if (_photoBase64 != null) 'photo_base64': _photoBase64,
          },
        );
      } else {
        final playerId = PlayerRepository.generatePlayerId(
          jerseyNumber: jerseyNumber,
          fullName: fullName,
          teamId: widget.teamId,
        );

        final newPlayer = PlayerModel(
          id: playerId,
          teamId: widget.teamId,
          fullName: fullName,
          jerseyNumber: jerseyNumber,
          positions: positions,
          heightCm: heightCm,
          weightKg: weightKg,
          dateOfBirth: _dateOfBirth,
          photoBase64: _photoBase64,
          status: 'active',
          createdAt: DateTime.now(),
        );

        final success = await ref
            .read(playerActionsProvider.notifier)
            .addPlayer(player: newPlayer, playerId: playerId);

        if (!success) {
          final error = ref.read(playerActionsProvider).error;
          _showError(error?.toString() ?? 'Gagal menambahkan pemain.');
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Data pemain berhasil diperbarui.'
                  : 'Pemain berhasil ditambahkan.',
            ),
            backgroundColor: const Color(0xFF3B6D11),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
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
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}
