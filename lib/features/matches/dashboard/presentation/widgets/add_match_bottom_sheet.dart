import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:budiutama_basketball/features/events/data/models/event_model.dart';
import 'package:budiutama_basketball/features/matches/dashboard/data/models/match_model.dart';
import 'package:budiutama_basketball/features/matches/dashboard/data/repositories/match_repository.dart';
import 'package:budiutama_basketball/features/matches/dashboard/domain/providers/match_provider.dart';

/// Bottom sheet untuk membuat pertandingan baru yang terikat pada sebuah event.
///
/// Setiap pertandingan di Budi Utama WAJIB terikat pada event/turnamen.
/// Sesuai PRD Section 6.4 dan SRS FR-MCH-01.
///
/// Document ID: {eventId}_vs_{lawanShort}_{YYYYMMDD}
class AddMatchBottomSheet extends ConsumerStatefulWidget {
  /// Event yang menjadi konteks pertandingan ini — wajib ada.
  final EventModel event;

  /// Team ID tim Budi Utama (home team).
  final String homeTeamId;

  /// User doc ID Manager yang membuat.
  final String createdBy;

  const AddMatchBottomSheet({
    super.key,
    required this.event,
    required this.homeTeamId,
    required this.createdBy,
  });

  @override
  ConsumerState<AddMatchBottomSheet> createState() =>
      _AddMatchBottomSheetState();
}

class _AddMatchBottomSheetState
    extends ConsumerState<AddMatchBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _opponentController = TextEditingController();
  final _venueController = TextEditingController();
  final _notesController = TextEditingController();

  String _matchType = 'neutral'; // home | away | neutral
  String _phase = 'penyisihan';  // penyisihan | semifinal | final | friendly
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  // Konfigurasi timer — bisa diubah Manager sebelum START MATCH
  int _quarterDuration = 10; // menit
  int _numPeriods = 4;       // 4 quarter atau 2 babak
  int _otDuration = 5;       // menit

  bool _isSubmitting = false;

  static const _matchTypes = [
    (value: 'home', label: 'Home', icon: Icons.home_outlined),
    (value: 'away', label: 'Away', icon: Icons.flight_takeoff_outlined),
    (value: 'neutral', label: 'Netral', icon: Icons.location_on_outlined),
  ];

  static const _phases = [
    'penyisihan',
    'perempat_final',
    'semifinal',
    'final',
    'friendly',
  ];

  @override
  void dispose() {
    _opponentController.dispose();
    _venueController.dispose();
    _notesController.dispose();
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
              // Handle bar
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

              // Judul + event context
              const Text(
                'Buat Pertandingan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A3A5C),
                ),
              ),
              const SizedBox(height: 4),

              // Event badge — mengingatkan bahwa pertandingan terikat event ini
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events_outlined,
                        size: 13, color: Color(0xFF3C3489)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.event.name,
                        style: const TextStyle(
                          color: Color(0xFF3C3489),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nama lawan
              _buildLabel('Nama Tim Lawan *'),
              TextFormField(
                controller: _opponentController,
                decoration:
                    _inputDecoration('Contoh: SMAN 1 Yogyakarta'),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama lawan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Match type selector
              _buildLabel('Tipe Pertandingan *'),
              Row(
                children: _matchTypes.map((t) {
                  final isSelected = _matchType == t.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _matchType = t.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: EdgeInsets.only(
                          right: t.value != 'neutral' ? 8 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A3A5C)
                              : const Color(0xFFF4F6F8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1A3A5C)
                                : const Color(0xFFC8D6E5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(t.icon,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7A8D)),
                            const SizedBox(height: 4),
                            Text(
                              t.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1C2B3A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Fase pertandingan dan venue
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Fase'),
                        DropdownButtonFormField<String>(
                          value: _phase,
                          decoration: _inputDecoration(null),
                          items: _phases
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      _phaseLabel(p),
                                      style:
                                          const TextStyle(fontSize: 13),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _phase = v);
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
                        _buildLabel('Venue'),
                        TextFormField(
                          controller: _venueController,
                          decoration:
                              _inputDecoration('Contoh: GOR Amongraga'),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Tanggal dan waktu
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Tanggal *'),
                        _buildDateField(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Waktu'),
                        _buildTimeField(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Divider konfigurasi timer
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: Color(0xFF6B7A8D)),
                    const SizedBox(width: 6),
                    const Text(
                      'Konfigurasi Timer',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Color(0xFF1A3A5C),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '(dapat diubah sampai START MATCH)',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7A8D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  // Durasi per quarter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Durasi/Quarter'),
                        DropdownButtonFormField<int>(
                          value: _quarterDuration,
                          decoration: _inputDecoration(null),
                          items: [
                            for (int i = 1; i <= 20; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text('$i menit',
                                    style: const TextStyle(fontSize: 13)),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _quarterDuration = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Jumlah periode
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Periode'),
                        DropdownButtonFormField<int>(
                          value: _numPeriods,
                          decoration: _inputDecoration(null),
                          items: const [
                            DropdownMenuItem(
                              value: 4,
                              child: Text('4 Quarter',
                                  style: TextStyle(fontSize: 13)),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text('2 Babak',
                                  style: TextStyle(fontSize: 13)),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _numPeriods = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Durasi OT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Durasi OT'),
                        DropdownButtonFormField<int>(
                          value: _otDuration,
                          decoration: _inputDecoration(null),
                          items: [
                            for (int i = 1; i <= 10; i++)
                              DropdownMenuItem(
                                value: i,
                                child: Text('$i menit',
                                    style: const TextStyle(fontSize: 13)),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _otDuration = v);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Catatan
              _buildLabel('Catatan'),
              TextFormField(
                controller: _notesController,
                decoration: _inputDecoration('Opsional'),
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
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Buat Pertandingan',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
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
          initialDate: _scheduledDate ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          locale: const Locale('id', 'ID'),
        );
        if (picked != null) setState(() => _scheduledDate = picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              _scheduledDate != null
                  ? DateFormat('dd MMM yyyy', 'id_ID')
                      .format(_scheduledDate!)
                  : 'Pilih tanggal',
              style: TextStyle(
                fontSize: 13,
                color: _scheduledDate != null
                    ? const Color(0xFF1C2B3A)
                    : const Color(0xFF6B7A8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime:
              _scheduledTime ?? const TimeOfDay(hour: 8, minute: 0),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) setState(() => _scheduledTime = picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC8D6E5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time,
                size: 16, color: Color(0xFF6B7A8D)),
            const SizedBox(width: 8),
            Text(
              _scheduledTime != null
                  ? _scheduledTime!.format(context)
                  : 'Waktu',
              style: TextStyle(
                fontSize: 13,
                color: _scheduledTime != null
                    ? const Color(0xFF1C2B3A)
                    : const Color(0xFF6B7A8D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_scheduledDate == null) {
      _showError('Tanggal pertandingan wajib diisi.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final time = _scheduledTime ?? const TimeOfDay(hour: 8, minute: 0);
      final scheduledAt = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        time.hour,
        time.minute,
      );

      final matchId = MatchRepository.generateMatchId(
        eventId: widget.event.id,
        opponentName: _opponentController.text.trim(),
        scheduledAt: scheduledAt,
      );

      final match = MatchModel(
        id: matchId,
        homeTeamId: widget.homeTeamId,
        eventId: widget.event.id,
        opponentName: _opponentController.text.trim(),
        venue: _venueController.text.trim(),
        matchType: _matchType,
        phase: _phase,
        scheduledAt: scheduledAt,
        quarterDurationMinutes: _quarterDuration,
        numPeriods: _numPeriods,
        otDurationMinutes: _otDuration,
        notes: _notesController.text.trim(),
        createdBy: widget.createdBy,
      );

      final success = await ref
          .read(matchActionsProvider.notifier)
          .createMatch(matchId: matchId, match: match);

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertandingan berhasil dibuat.'),
            backgroundColor: Color(0xFF3B6D11),
          ),
        );
      } else if (mounted) {
        _showError('Gagal membuat pertandingan. Coba lagi.');
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
        borderSide:
            const BorderSide(color: Color(0xFF1A3A5C), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }

  String _phaseLabel(String phase) {
    switch (phase) {
      case 'penyisihan':
        return 'Penyisihan';
      case 'perempat_final':
        return 'Perempat Final';
      case 'semifinal':
        return 'Semifinal';
      case 'final':
        return 'Final';
      case 'friendly':
        return 'Friendly / Uji Coba';
      default:
        return phase;
    }
  }
}
