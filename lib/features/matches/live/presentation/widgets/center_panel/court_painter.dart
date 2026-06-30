import 'dart:math';
import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/utils/zone_classifier.dart';

/// Satu titik tembakan untuk heatmap (FR-STT-03) — `x`,`y` dalam
/// koordinat normalisasi [0.0, 1.0], sama seperti yang dipakai
/// [classifyZone].
class ShotPoint {
  final double x;
  final double y;
  final bool isMade;

  const ShotPoint({required this.x, required this.y, required this.isMade});
}

/// Rect half-court dengan rasio lapangan basket regulasi.
///
/// Ukuran half-court FIBA/NBA secara visual mendekati 50ft x 47ft
/// (lebar x panjang). Overlay Match Mode sering jauh lebih wide dari
/// rasio ini, jadi lapangan harus di-center-fit agar tidak gepeng.
Rect courtRectForSize(Size size) {
  const courtAspectRatio = 50 / 47;
  const padding = 12.0;
  final availableWidth = max(0.0, size.width - padding * 2);
  final availableHeight = max(0.0, size.height - padding * 2);

  var courtWidth = availableWidth;
  var courtHeight = courtWidth / courtAspectRatio;
  if (courtHeight > availableHeight) {
    courtHeight = availableHeight;
    courtWidth = courtHeight * courtAspectRatio;
  }

  final left = (size.width - courtWidth) / 2;
  final top = (size.height - courtHeight) / 2;
  return Rect.fromLTWH(left, top, courtWidth, courtHeight);
}

/// Menggambar garis lapangan half-court standar (boundary, paint, free
/// throw circle, arc 3PT, garis baseline corner, ring + backboard) ke
/// atas [canvas] berukuran [size].
///
/// Fungsi TOP-LEVEL ini sengaja dipisah dari [CourtPainter] supaya bisa
/// di-reuse 1:1 oleh `ShotChartPainter` di Statistics Dashboard
/// (FR-STT-03) — kedua tempat menggambar lapangan yang SAMA PERSIS
/// secara geometris, jadi tidak ada alasan untuk duplikasi logika
/// (yang berisiko kedua gambar diam-diam berbeda seiring waktu kalau
/// salah satu diubah tanpa mengubah yang lain).
///
/// Geometri (paint, free-throw circle, arc 3PT, ring) memakai proporsi
/// relatif terhadap ukuran canvas, identik dengan constants di
/// [zone_classifier] supaya highlight zona BENAR-BENAR selaras visual
/// dengan logika klasifikasi — bukan dua sumber kebenaran yang bisa
/// divergen.
void drawHalfCourtLines(Canvas canvas, Size size) {
  final courtRect = courtRectForSize(size);
  final w = courtRect.width;
  final h = courtRect.height;

  canvas.save();
  canvas.translate(courtRect.left, courtRect.top);

  final boundaryPaint = Paint()
    ..color = const Color(0xFFCBD5E1)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  final mainLinePaint = Paint()
    ..color = const Color(0xFFCBD5E1)
    ..strokeWidth = 1.35
    ..style = PaintingStyle.stroke;
  final secondaryLinePaint = Paint()
    ..color = const Color(0xFF94A3B8)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;
  final paintFill = Paint()
    ..color = const Color(0xFF1E3A5F).withValues(alpha: 0.32)
    ..style = PaintingStyle.fill;

  canvas.drawRect(
    Rect.fromLTWH(0, 0, w, h),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h)),
  );
  canvas.drawRect(Rect.fromLTWH(0, 0, w, h), boundaryPaint);

  // Half-court line detail: bagian bawah rect adalah garis tengah
  // lapangan, dengan setengah lingkaran center circle yang terlihat
  // masuk ke area half-court.
  canvas.drawArc(
    Rect.fromCenter(
      center: Offset(w * 0.5, h),
      width: w * 0.24,
      height: w * 0.24,
    ),
    pi,
    pi,
    false,
    secondaryLinePaint,
  );

  // Area cat (paint) — sesuai paintXMin/paintXMax/paintYMax dari
  // zone_classifier.dart (0.35–0.65 horizontal, 0–0.30 vertikal).
  final paintRect = Rect.fromLTWH(
    w * paintXMin,
    0,
    w * (paintXMax - paintXMin),
    h * paintYMax,
  );
  canvas.drawRect(paintRect, paintFill);
  canvas.drawRect(paintRect, mainLinePaint);

  // Free throw circle — di tengah garis bawah area cat.
  final freeThrowCircle = Rect.fromCircle(
    center: Offset(w * 0.5, h * paintYMax),
    radius: w * 0.12,
  );
  canvas.drawArc(freeThrowCircle, 0, pi, false, mainLinePaint);
  canvas.drawArc(freeThrowCircle, pi, pi, false, secondaryLinePaint);

  // Restricted area di bawah ring.
  final ringCenter = Offset(w * ringX, h * ringY);
  canvas.drawArc(
    Rect.fromCircle(center: ringCenter, radius: w * 0.08),
    0,
    pi,
    false,
    secondaryLinePaint,
  );

  // Garis 3PT: straight corner lines paralel sideline, lalu arc besar
  // menghadap ke half-court. Ini lebih dekat ke lapangan asli daripada
  // menggambar lingkaran penuh yang terpotong boundary.
  final cornerYPx = h * cornerLineY;
  final cornerLeftX = xAtArcIntersection(cornerLineY, isLeft: true) * w;
  final cornerRightX = xAtArcIntersection(cornerLineY, isLeft: false) * w;
  final threePointPaint = Paint()
    ..color = const Color(0xFFA78BFA)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  canvas.save();
  canvas.clipRect(Rect.fromLTWH(0, 0, w, h));
  canvas.drawLine(
    Offset(cornerLeftX, 0),
    Offset(cornerLeftX, cornerYPx),
    threePointPaint,
  );
  canvas.drawLine(
    Offset(cornerRightX, 0),
    Offset(cornerRightX, cornerYPx),
    threePointPaint,
  );

  final radius = w * threePtRadius;
  final leftAngle = atan2(
    cornerYPx - ringCenter.dy,
    cornerLeftX - ringCenter.dx,
  );
  final rightAngle =
      atan2(cornerYPx - ringCenter.dy, cornerRightX - ringCenter.dx);
  canvas.drawArc(
    Rect.fromCircle(center: ringCenter, radius: radius),
    leftAngle,
    (2 * pi) + rightAngle - leftAngle,
    false,
    threePointPaint,
  );
  canvas.restore();

  // Ring + backboard
  canvas.drawCircle(
    ringCenter,
    6,
    Paint()
      ..color = const Color(0xFFE8420A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2,
  );
  canvas.drawCircle(ringCenter, 2, Paint()..color = const Color(0xFFE8420A));
  canvas.drawRect(
    Rect.fromCenter(
      center: Offset(w * 0.5, h * (ringY - 0.02)),
      width: w * 0.16,
      height: h * 0.012,
    ),
    Paint()..color = const Color(0xFF475569),
  );
  canvas.restore();
}

/// Titik potong antara garis `y = yNorm` dan lingkaran arc 3PT
/// (radius [threePtRadius] dari ring) — dipakai untuk menentukan x
/// straight corner line sebelum menyambung ke arc.
///
/// Diselesaikan dari persamaan lingkaran:
/// `(x - ringX)^2 + (yNorm - ringY)^2 = threePtRadius^2`
double xAtArcIntersection(double yNorm, {required bool isLeft}) {
  final dySq = pow(yNorm - ringY, 2);
  final dxSq = pow(threePtRadius, 2) - dySq;
  if (dxSq < 0) return isLeft ? 0.0 : 1.0;
  final dx = sqrt(dxSq);
  return isLeft ? ringX - dx : ringX + dx;
}

/// Membangun [Path] kasar yang merepresentasikan area satu zona di atas
/// kanvas berukuran [size] — dipakai BERSAMA oleh [CourtPainter] (untuk
/// highlight saat hover) dan `ShotChartPainter` di Statistics Dashboard
/// (untuk overlay warna FG% per zona, FR-STT-03), supaya kedua tempat
/// selalu sinkron secara visual tanpa duplikasi logika geometri.
///
/// Path ini adalah APROKSIMASI kotak/sektor sederhana untuk tujuan
/// visual highlight — bukan replikasi pixel-perfect dari
/// `classifyZone()` (yang bekerja di ranah matematis jarak-dari-ring,
/// bukan path tertutup). Untuk 9 zona yang ada, aproksimasi kotak/pie
/// ini cukup akurat secara visual karena batas-batasnya lurus atau
/// mendekati lurus pada rentang ukuran lapangan yang dipakai.
Path? buildCourtZonePath(String zone, Size size) {
  final courtRect = courtRectForSize(size);
  final l = courtRect.left;
  final t = courtRect.top;
  final w = courtRect.width;
  final h = courtRect.height;

  switch (zone) {
    case 'PAINT':
      return Path()
        ..addRect(Rect.fromLTWH(
          l + w * paintXMin,
          t,
          w * (paintXMax - paintXMin),
          h * paintYMax,
        ));
    case 'MEDIUM_LEFT':
      return Path()..addRect(Rect.fromLTWH(l, t, w * paintXMin, h * 0.55));
    case 'MEDIUM_RIGHT':
      return Path()
        ..addRect(Rect.fromLTWH(
          l + w * paintXMax,
          t,
          w * (1 - paintXMax),
          h * 0.55,
        ));
    case 'MEDIUM_CENTER':
      return Path()
        ..addRect(Rect.fromLTWH(
          l + w * paintXMin,
          t + h * paintYMax,
          w * (paintXMax - paintXMin),
          h * 0.25,
        ));
    case 'CORNER_LEFT':
      return Path()..addRect(Rect.fromLTWH(l, t, w * 0.18, h * cornerLineY));
    case 'CORNER_RIGHT':
      return Path()
        ..addRect(Rect.fromLTWH(
          l + w * 0.82,
          t,
          w * 0.18,
          h * cornerLineY,
        ));
    case 'WING_LEFT':
      return Path()
        ..addRect(Rect.fromLTWH(
          l,
          t + h * cornerLineY,
          w * 0.30,
          h * 0.45,
        ));
    case 'WING_RIGHT':
      return Path()
        ..addRect(Rect.fromLTWH(
          l + w * 0.70,
          t + h * cornerLineY,
          w * 0.30,
          h * 0.45,
        ));
    case 'CENTER_3':
      return Path()
        ..addRect(Rect.fromLTWH(
          l + w * 0.30,
          t + h * 0.55,
          w * 0.40,
          h * 0.35,
        ));
    default:
      return null;
  }
}

/// Menggambar half-court lengkap dengan highlight zona opsional dan
/// titik-titik tembakan — dipakai di Match Mode (Court Overlay, input
/// langsung) untuk memilih lokasi tembakan secara interaktif.
class CourtPainter extends CustomPainter {
  final List<ShotPoint> shots;
  final String? hoveredZone;

  CourtPainter({this.shots = const [], this.hoveredZone});

  @override
  void paint(Canvas canvas, Size size) {
    drawHalfCourtLines(canvas, size);
    if (hoveredZone != null) {
      _drawZoneHighlight(canvas, size, hoveredZone!);
    }
    _drawShotPoints(canvas, size);
  }

  /// Highlight area yang merepresentasikan satu [zone] secara spesifik
  /// (bukan generic full-canvas tint) — dipakai saat Statistician
  /// menggeser jari di atas Court Overlay sebelum melepas tap, supaya ia
  /// melihat dengan jelas zona mana yang akan tercatat.
  void _drawZoneHighlight(Canvas canvas, Size size, String zone) {
    final path = buildCourtZonePath(zone, size);
    if (path == null) return;
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFE8420A).withValues(alpha: 0.22),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFE8420A).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawShotPoints(Canvas canvas, Size size) {
    final courtRect = courtRectForSize(size);
    for (final shot in shots) {
      canvas.drawCircle(
        Offset(
          courtRect.left + shot.x * courtRect.width,
          courtRect.top + shot.y * courtRect.height,
        ),
        5,
        Paint()
          ..color = shot.isMade
              ? const Color(0xFF22C55E).withValues(alpha: 0.9)
              : const Color(0xFFEF4444).withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(CourtPainter oldDelegate) =>
      !_listEquals(oldDelegate.shots, shots) ||
      oldDelegate.hoveredZone != hoveredZone;

  bool _listEquals(List<ShotPoint> a, List<ShotPoint> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].x != b[i].x || a[i].y != b[i].y || a[i].isMade != b[i].isMade) {
        return false;
      }
    }
    return true;
  }
}
