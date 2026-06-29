import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/injuries/data/models/injury_report_model.dart';
import 'package:budiutama_basketball/features/injuries/data/repositories/injury_repository.dart';
import 'package:budiutama_basketball/features/injuries/domain/providers/injury_provider.dart';
import 'package:budiutama_basketball/features/players/data/models/player_model.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';

/// Bottom sheet untuk membuat laporan cedera pemain baru.
/// Hanya Coach dan Manager yang bisa mengakses (SRS FR-INJ-01).
///
/// Sekaligus mengubah status pemain menjadi 'injured' secara atomic.
class AddInjuryBottomSheet extends ConsumerStatefulWidget {
  final String teamId;
  final String createdBy;
  /// Jika sudah diketahui pemainnya (dari halaman profil pemain).
  final PlayerModel? preSelectedPlayer;

  const AddInjuryBottomSheet({
    super.key,
    required this.teamId,
    required this.createdBy,
    this.preSelectedPlayer,
  });

  @override
  ConsumerState<AddInjuryBottomSheet> createState() =>
      _AddInjuryBottomSheetState();
}

class _AddInjuryBottomSheetState extends ConsumerState<AddInjuryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _bodyPartController = TextEditingController();
  final _notesController = TextEditingController();
  final _recoveryDaysController = TextEditingController();
  final _playerSearchController = TextEditingController();

  PlayerModel? _selectedPlayer;
  DateTime _injuryDate = DateTime.now();
  String _severity = 'moderate';
  bool _isSubmitting = false;

  static const _severities = [
    (value: 'mild', label: 'Ringan', color: Color(0xFF3B6D11)),
    (value: 'moderate', label: 'Sedang', color: Color(0xFFBA7517)),
    (value: 'severe', label: 'Berat', color: Color(0xFFA32D2D)),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPlayer = widget.preSelectedPlayer;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _bodyPartController.dispose();
    _notesController.dispose();
    _recoveryDaysController.dispose();
    _playerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final playersAsync = ref.watch(activePLayersStreamProvider(widget.teamId));

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
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8D6E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Laporan Cedera',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                    color: Color(0xFF1A3A5C)),
              ),
              const SizedBox(height: 20),

              // Pilih Pemain
              _buildLabel('Pemain *'),
              playersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (players) {
                  // Filter: hanya pemain yang belum berstatus injured
                  final eligible = players
                      .where((p) => p.status != 'injured')
                      .toList();
                  return _buildSearchablePlayerPicker(eligible);
                },
              ),
              const SizedBox(height: 14),

              // Tanggal cedera + estimasi pulih
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal Cedera *'),
                        _buildDateField(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Est. Pulih (hari)'),
                        TextFormField(
                          controller: _recoveryDaysController,
                          decoration: _inputDecoration('Contoh: 14'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bagian tubuh
              _buildLabel('Bagian Tubuh yang Cedera *'),
              TextFormField(
                controller: _bodyPartController,
                decoration:
                    _inputDecoration('Contoh: Pergelangan kaki kanan'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              // Tingkat keparahan
              _buildLabel('Tingkat Keparahan *'),
              Row(
                children: _severities.map((s) {
                  final isSelected = _severity == s.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _severity = s.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(
                            right: s.value != 'severe' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? s.color.withValues(alpha: 0.15)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? s.color
                                : const Color(0xFFC8D6E5),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          s.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? s.color
                                : const Color(0xFF6B7A8D),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Deskripsi
              _buildLabel('Deskripsi Cedera *'),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    _inputDecoration('Contoh: Terkilir saat mendarat setelah lay-up'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                minLines: 2,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 14),

              // Catatan medis (opsional)
              _buildLabel('Catatan Medis'),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('Opsional — catatan dokter, penanganan, dsb.'),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
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
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Simpan Laporan Cedera',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _injuryDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
          locale: const Locale('id', 'ID'),
        );
        if (picked != null) setState(() => _injuryDate = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC8D6E5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF6B7A8D)),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy', 'id_ID').format(_injuryDate),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1C2B3A)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchablePlayerPicker(List<PlayerModel> players) {
    final query = _playerSearchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? players
        : players.where((player) {
            return player.fullName.toLowerCase().contains(query) ||
                player.jerseyNumber.toString().contains(query) ||
                player.positionsDisplay.toLowerCase().contains(query);
          }).toList();

    return FormField<PlayerModel>(
      validator: (_) =>
          _selectedPlayer == null ? 'Pilih pemain terlebih dahulu' : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _playerSearchController,
              decoration: _inputDecoration('Cari nama / nomor jersey'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 190),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: field.hasError
                      ? Colors.red
                      : const Color(0xFFC8D6E5),
                ),
              ),
              child: filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Pemain tidak ditemukan.',
                        style:
                            TextStyle(fontSize: 12, color: Color(0xFF6B7A8D)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final player = filtered[index];
                        return RadioListTile<PlayerModel>(
                          dense: true,
                          value: player,
                          groupValue: _selectedPlayer,
                          title: Text(
                            '#${player.jerseyNumber} ${player.fullName}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: player.positionsDisplay.isEmpty
                              ? null
                              : Text(
                                  player.positionsDisplay,
                                  style: const TextStyle(fontSize: 11),
                                ),
                          onChanged: (value) {
                            setState(() => _selectedPlayer = value);
                            field.didChange(value);
                          },
                        );
                      },
                    ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlayer == null) return;

    setState(() => _isSubmitting = true);

    try {
      final player = _selectedPlayer!;
      final reportId = InjuryRepository.generateReportId(
        playerId: player.id,
        injuryDate: _injuryDate,
      );

      final report = InjuryReportModel(
        id: reportId,
        playerId: player.id,
        teamId: widget.teamId,
        injuryDate: _injuryDate,
        bodyPart: _bodyPartController.text.trim(),
        severity: _severity,
        description: _descriptionController.text.trim(),
        estimatedRecoveryDays:
            int.tryParse(_recoveryDaysController.text.trim()),
        status: 'active',
        notes: _notesController.text.trim(),
        createdBy: widget.createdBy,
      );

      final success = await ref
          .read(injuryActionsProvider.notifier)
          .createReport(reportId: reportId, report: report);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Laporan cedera ${player.fullName} berhasil disimpan.'),
            backgroundColor: const Color(0xFF3B6D11),
          ),
        );
      } else if (mounted) {
        _showError('Gagal menyimpan laporan cedera.');
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
          content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C2B3A))),
      );

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC8D6E5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFC8D6E5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF1A3A5C), width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      );
}
