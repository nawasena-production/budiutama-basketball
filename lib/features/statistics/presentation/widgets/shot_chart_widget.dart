import 'package:flutter/material.dart';

import 'package:budiutama_basketball/features/matches/live/presentation/widgets/center_panel/court_painter.dart';
import 'package:budiutama_basketball/features/statistics/data/repositories/stats_repository.dart';

/// Shot chart heatmap (FR-STT-03) — menampilkan titik tembakan
/// individual (hijau = made, merah = miss) DAN overlay warna per zona
/// berdasarkan FG% zona tersebut (hijau pekat = FG% tinggi, merah
/// pekat = FG% rendah), persis seperti spesifikasi PRD Section 7
/// "Shot Chart Heatmap".
///
/// Menggambar lapangan via `drawHalfCourtLines()` yang SAMA PERSIS
/// dipakai [CourtPainter] di Match Mode — supaya shot chart yang
/// ditampilkan di sini selalu match secara visual dengan apa yang
/// dilihat Statistician saat menginput data, tanpa risiko drift
/// geometri antara dua tempat.
class ShotChartWidget extends StatelessWidget {
  final List<ShotChartEntry> shotEntries;
  final String? playerIdFilter;

  const ShotChartWidget({
    super.key,
    required this.shotEntries,
    this.playerIdFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = playerIdFilter == null
        ? shotEntries.where((e) => !e.isOpponent).toList()
        : shotEntries
            .where((e) => !e.isOpponent && e.playerId == playerIdFilter)
            .toList();

    return AspectRatio(
      aspectRatio: 300 / 280,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomPaint(
          painter: ShotChartPainter(entries: filtered),
          child: Container(),
        ),
      ),
    );
  }
}

/// CustomPainter shot chart — menggambar lapangan, overlay FG% per
/// zona, lalu titik-titik tembakan individual di lapisan paling atas
/// supaya tetap terbaca jelas di atas overlay warna.
class ShotChartPainter extends CustomPainter {
  final List<ShotChartEntry> entries;

  ShotChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    drawHalfCourtLines(canvas, size);
    _drawZoneOverlays(canvas, size);
    _drawShotPoints(canvas, size);
  }

  /// Hitung FG% per zona dari [entries] (groupBy zone → made/attempted),
  /// lalu gambar overlay warna gradasi merah (FG% rendah) → hijau
  /// (FG% tinggi) di atas area masing-masing zona via
  /// `buildCourtZonePath()` — sumber geometri yang SAMA dengan highlight
  /// zona interaktif di Court Overlay (Match Mode).
  void _drawZoneOverlays(Canvas canvas, Size size) {
    final Map<String, _ZoneTally> tallyByZone = {};
    for (final e in entries) {
      final tally = tallyByZone.putIfAbsent(e.zone, () => _ZoneTally());
      tally.attempted += 1;
      if (e.isMade) tally.made += 1;
    }

    for (final entry in tallyByZone.entries) {
      final zone = entry.key;
      final tally = entry.value;
      if (tally.attempted == 0) continue;

      final path = buildCourtZonePath(zone, size);
      if (path == null) continue;

      final fgPct = tally.made / tally.attempted;
      final color = _colorForFgPercentage(fgPct);

      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.28));

      // Label persentase di tengah area zona.
      final bounds = path.getBounds();
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(fgPct * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          bounds.center.dx - textPainter.width / 2,
          bounds.center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  void _drawShotPoints(Canvas canvas, Size size) {
    for (final e in entries) {
      canvas.drawCircle(
        Offset(e.x * size.width, e.y * size.height),
        5,
        Paint()
          ..color = e.isMade
              ? const Color(0xFF22C55E).withValues(alpha: 0.9)
              : const Color(0xFFEF4444).withValues(alpha: 0.9),
      );
    }
  }

  Color _colorForFgPercentage(double fgPct) {
    if (fgPct >= 0.60) return const Color(0xFF86EFAC); // hijau — tinggi
    if (fgPct >= 0.40) return const Color(0xFFFCD34D); // kuning — sedang
    return const Color(0xFFEF4444); // merah — rendah
  }

  @override
  bool shouldRepaint(ShotChartPainter oldDelegate) =>
      !_listEquals(oldDelegate.entries, entries);

  bool _listEquals(List<ShotChartEntry> a, List<ShotChartEntry> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].x != b[i].x ||
          a[i].y != b[i].y ||
          a[i].isMade != b[i].isMade ||
          a[i].zone != b[i].zone ||
          a[i].playerId != b[i].playerId) {
        return false;
      }
    }
    return true;
  }
}

class _ZoneTally {
  int made = 0;
  int attempted = 0;
}
