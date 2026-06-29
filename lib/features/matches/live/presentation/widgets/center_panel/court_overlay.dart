import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/utils/zone_classifier.dart';
import 'court_painter.dart';

/// Hasil yang dikembalikan saat Statistician menyelesaikan pemilihan
/// lokasi tembakan di [CourtOverlay] (FR-LMS-14).
class ShotLocationResult {
  final double x;
  final double y;
  final String zone;
  final int distanceFt;

  const ShotLocationResult({
    required this.x,
    required this.y,
    required this.zone,
    required this.distanceFt,
  });
}

/// Overlay half-court interaktif untuk memilih lokasi tembakan +2, +3,
/// MISS 2, MISS 3 (SRS FR-LMS-14). TIDAK dipakai untuk free throw
/// (+1 / MISS 1) — pemanggil (CenterPanelTabs) bertanggung jawab untuk
/// tidak menampilkan widget ini sama sekali pada kasus tersebut.
///
/// Widget ini SENGAJA dirancang "dumb" / tanpa pengetahuan tentang
/// Firestore — ia hanya melaporkan koordinat & zona terpilih lewat
/// [onLocationSelected]. Pemanggang (parent) yang memutuskan kapan dan
/// bagaimana memanggil `MatchActionNotifier.recordAction()`, menjaga
/// pemisahan tanggung jawab presentasi vs domain logic (SDD Section 1.2
/// — Separation of Concerns).
///
/// Auto-dismiss setelah 15 detik tanpa interaksi sesuai SRS FR-LMS-03
/// ("Timeout overlay: 15 detik tanpa tap → overlay tutup otomatis, aksi
/// dibatalkan").
class CourtOverlay extends StatefulWidget {
  final String actionType; // '2PT_MADE', 'MISS_3PT', dst.
  final List<ShotPoint> shots;
  final ValueChanged<ShotLocationResult> onLocationSelected;
  final VoidCallback onDismiss;

  const CourtOverlay({
    super.key,
    required this.actionType,
    this.shots = const [],
    required this.onLocationSelected,
    required this.onDismiss,
  });

  @override
  State<CourtOverlay> createState() => _CourtOverlayState();
}

class _CourtOverlayState extends State<CourtOverlay> {
  String? _hoveredZone;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && !_resolved) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTapUp: _handleTapUp,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: (_) => setState(() => _hoveredZone = null),
            child: CustomPaint(
              painter: CourtPainter(
                shots: widget.shots,
                hoveredZone: _hoveredZone,
              ),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Batal',
            onPressed: () {
              _resolved = true;
              widget.onDismiss();
            },
          ),
        ),
      ],
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final (x, y) = _normalizedCourtPosition(
      renderBox.globalToLocal(details.globalPosition),
      renderBox.size,
    );
    final zone = classifyZone(x, y);
    if (zone != _hoveredZone) {
      setState(() => _hoveredZone = zone);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final (x, y) = _normalizedCourtPosition(
      renderBox.globalToLocal(details.globalPosition),
      renderBox.size,
    );

    final zone = classifyZone(x, y);
    final distanceFt = calculateDistanceFt(x, y);

    if (!validateZoneActionConsistency(widget.actionType, zone)) {
      _showConsistencyDialog(x: x, y: y, zone: zone, distanceFt: distanceFt);
      return;
    }

    _confirmAndClose(x: x, y: y, zone: zone, distanceFt: distanceFt);
  }

  void _confirmAndClose({
    required double x,
    required double y,
    required String zone,
    required int distanceFt,
  }) {
    _resolved = true;
    widget.onLocationSelected(
      ShotLocationResult(x: x, y: y, zone: zone, distanceFt: distanceFt),
    );
  }

  Future<void> _showConsistencyDialog({
    required double x,
    required double y,
    required String zone,
    required int distanceFt,
  }) async {
    final zoneIsThreePoint = zones3pt.contains(zone);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Zona Tembakan'),
        content: Text(
          'Lokasi yang Anda tap berada di zona $zone '
          '(${zoneIsThreePoint ? "3 poin" : "2 poin"}), tetapi tombol aksi '
          'yang ditekan adalah ${_actionLabel(widget.actionType)}. '
          'Tetap lanjutkan dengan lokasi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal — Pilih Ulang'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tetap Lanjutkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _confirmAndClose(x: x, y: y, zone: zone, distanceFt: distanceFt);
    }
  }

  (double, double) _normalizedCourtPosition(Offset localPos, Size size) {
    final courtRect = courtRectForSize(size);
    final x = ((localPos.dx - courtRect.left) / courtRect.width).clamp(
      0.0,
      1.0,
    );
    final y = ((localPos.dy - courtRect.top) / courtRect.height).clamp(
      0.0,
      1.0,
    );
    return (x, y);
  }

  String _actionLabel(String actionType) {
    switch (actionType) {
      case '2PT_MADE':
        return '+2 (2PT Made)';
      case '3PT_MADE':
        return '+3 (3PT Made)';
      case 'MISS_2PT':
        return 'MISS 2 (Miss 2PT)';
      case 'MISS_3PT':
        return 'MISS 3 (Miss 3PT)';
      default:
        return actionType;
    }
  }
}
