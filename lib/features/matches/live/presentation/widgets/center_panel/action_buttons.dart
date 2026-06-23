import 'package:flutter/material.dart';

/// Deskripsi satu tombol aksi statistik.
class ActionButtonSpec {
  final String actionType;
  final String shortLabel;
  final String longLabel;
  final _ActionButtonStyle style;
  final bool needsCourtOverlay;

  const ActionButtonSpec({
    required this.actionType,
    required this.shortLabel,
    required this.longLabel,
    required this.style,
    this.needsCourtOverlay = false,
  });
}

enum _ActionButtonStyle { scoring3pt, scoring, miss, stat, foul }

/// 13 tombol aksi sesuai SRS FR-LMS-03 / PRD Section 7.2 (tabel "Tim
/// Budi Utama — Detail per Pemain").
///
/// Free throw (+1 / MISS 1) TIDAK memerlukan Court Overlay — dicatat
/// langsung tanpa koordinat (PRD: "Tidak masuk heatmap").
const List<ActionButtonSpec> kPlayerActionButtons = [
  ActionButtonSpec(
    actionType: '1PT_MADE',
    shortLabel: '+1',
    longLabel: 'Free Throw',
    style: _ActionButtonStyle.scoring,
  ),
  ActionButtonSpec(
    actionType: '2PT_MADE',
    shortLabel: '+2',
    longLabel: '2PT Made',
    style: _ActionButtonStyle.scoring,
    needsCourtOverlay: true,
  ),
  ActionButtonSpec(
    actionType: '3PT_MADE',
    shortLabel: '+3',
    longLabel: '3PT Made',
    style: _ActionButtonStyle.scoring3pt,
    needsCourtOverlay: true,
  ),
  ActionButtonSpec(
    actionType: 'MISS_1PT',
    shortLabel: 'M1',
    longLabel: 'Miss FT',
    style: _ActionButtonStyle.miss,
  ),
  ActionButtonSpec(
    actionType: 'MISS_2PT',
    shortLabel: 'M2',
    longLabel: 'Miss 2PT',
    style: _ActionButtonStyle.miss,
    needsCourtOverlay: true,
  ),
  ActionButtonSpec(
    actionType: 'MISS_3PT',
    shortLabel: 'M3',
    longLabel: 'Miss 3PT',
    style: _ActionButtonStyle.miss,
    needsCourtOverlay: true,
  ),
  ActionButtonSpec(
    actionType: 'ASSIST',
    shortLabel: 'AST',
    longLabel: 'Assist',
    style: _ActionButtonStyle.stat,
  ),
  ActionButtonSpec(
    actionType: 'REBOUND_OFF',
    shortLabel: 'OREB',
    longLabel: 'Off Reb',
    style: _ActionButtonStyle.stat,
  ),
  ActionButtonSpec(
    actionType: 'REBOUND_DEF',
    shortLabel: 'DREB',
    longLabel: 'Def Reb',
    style: _ActionButtonStyle.stat,
  ),
  ActionButtonSpec(
    actionType: 'STEAL',
    shortLabel: 'STL',
    longLabel: 'Steal',
    style: _ActionButtonStyle.stat,
  ),
  ActionButtonSpec(
    actionType: 'TURNOVER',
    shortLabel: 'TO',
    longLabel: 'Turnover',
    style: _ActionButtonStyle.stat,
  ),
  ActionButtonSpec(
    actionType: 'BLOCK',
    shortLabel: 'BLK',
    longLabel: 'Block',
    style: _ActionButtonStyle.stat,
  ),
  ActionButtonSpec(
    actionType: 'FOUL',
    shortLabel: 'FOUL',
    longLabel: 'Personal',
    style: _ActionButtonStyle.foul,
  ),
];

/// Grid 13 tombol aksi (FR-LMS-03) — dinonaktifkan total bila belum ada
/// pemain dipilih ([enabled] = false), karena setiap aksi statistik
/// individu wajib terikat pada satu pemain (kecuali aksi tim lawan, yang
/// ditangani [OpponentActionsPanel] terpisah).
class ActionButtons extends StatelessWidget {
  final bool enabled;
  final void Function(ActionButtonSpec spec) onActionTap;

  const ActionButtons({
    super.key,
    required this.enabled,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.3,
      ),
      itemCount: kPlayerActionButtons.length,
      itemBuilder: (context, i) {
        final spec = kPlayerActionButtons[i];
        return _ActionButton(
          spec: spec,
          enabled: enabled,
          onTap: () => onActionTap(spec),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final ActionButtonSpec spec;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.spec,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = _colorsFor(spec.style);

    return Material(
      color: enabled ? bg : bg.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? border : border.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                spec.shortLabel,
                style: TextStyle(
                  color: enabled ? fg : fg.withValues(alpha: 0.45),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                spec.longLabel,
                style: TextStyle(
                  color: enabled
                      ? fg.withValues(alpha: 0.85)
                      : fg.withValues(alpha: 0.35),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, Color, Color) _colorsFor(_ActionButtonStyle style) {
    switch (style) {
      case _ActionButtonStyle.scoring3pt:
        return (
          const Color(0xFF14532D),
          const Color(0xFF166534),
          const Color(0xFF86EFAC),
        );
      case _ActionButtonStyle.scoring:
        return (
          const Color(0xFF1B4332),
          const Color(0xFF2D6A4F),
          const Color(0xFF95D5B2),
        );
      case _ActionButtonStyle.miss:
        return (
          const Color(0xFF450A0A),
          const Color(0xFF7F1D1D),
          const Color(0xFFFCA5A5),
        );
      case _ActionButtonStyle.stat:
        return (
          const Color(0xFF1E3A5F),
          const Color(0xFF2563EB),
          const Color(0xFF93C5FD),
        );
      case _ActionButtonStyle.foul:
        return (
          const Color(0xFF451A03),
          const Color(0xFF92400E),
          const Color(0xFFFCD34D),
        );
    }
  }
}
