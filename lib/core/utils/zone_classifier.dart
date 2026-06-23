import 'dart:math';

/// Klasifikasi 9 zona half-court berdasarkan koordinat normalisasi
/// (0.0–1.0) hasil tap di [CourtOverlay] (PRD Section 7.7, SDD Section 3.4).
///
/// Sistem koordinat: origin (0,0) di pojok kiri-atas half-court,
/// ring basket berada di (x=0.5, y=0.08) — dekat baseline atas.
/// `y` membesar menjauhi ring (ke arah top of key / tengah lapangan).

const ringX = 0.5;
const ringY = 0.08;

const paintXMin = 0.35;
const paintXMax = 0.65;
const paintYMax = 0.30;

const threePtRadius = 0.43;
const cornerLineY = 0.18;

/// Sembilan kode zona valid (urutan sesuai PRD Section 7.7 / SDD 3.4).
const validZones = {
  'PAINT',
  'MEDIUM_LEFT',
  'MEDIUM_CENTER',
  'MEDIUM_RIGHT',
  'CORNER_LEFT',
  'CORNER_RIGHT',
  'WING_LEFT',
  'WING_RIGHT',
  'CENTER_3',
};

/// Zona yang bernilai 2 poin vs 3 poin — dipakai untuk validasi
/// konsistensi tombol aksi vs lokasi tap (SRS FR-LMS-14).
const zones2pt = {'PAINT', 'MEDIUM_LEFT', 'MEDIUM_CENTER', 'MEDIUM_RIGHT'};
const zones3pt = {
  'CORNER_LEFT',
  'CORNER_RIGHT',
  'WING_LEFT',
  'WING_RIGHT',
  'CENTER_3',
};

/// Klasifikasikan koordinat (x, y) normalisasi ke salah satu dari 9 zona.
///
/// `x` dan `y` HARUS sudah dalam rentang [0.0, 1.0] — clamp dilakukan
/// sebagai safety net jika ada floating point error kecil dari
/// `RenderBox.globalToLocal()`.
String classifyZone(double x, double y) {
  final clampedX = x.clamp(0.0, 1.0);
  final clampedY = y.clamp(0.0, 1.0);

  final dist = _distanceFromRing(clampedX, clampedY);

  // 1. Area cat (paint) — selalu 2 poin, prioritas tertinggi karena
  //    berada di dalam radius 3PT tapi harus tetap dikenali sebagai PAINT.
  if (clampedX >= paintXMin &&
      clampedX <= paintXMax &&
      clampedY <= paintYMax) {
    return 'PAINT';
  }

  // 2. Corner 3PT — dekat baseline DAN di luar arc.
  if (clampedY < cornerLineY && dist > threePtRadius) {
    return clampedX < 0.5 ? 'CORNER_LEFT' : 'CORNER_RIGHT';
  }

  // 3. Di luar arc 3PT, bukan corner → Wing atau Center 3PT.
  if (dist > threePtRadius) {
    if (clampedY > 0.55) return 'CENTER_3';
    return clampedX < 0.5 ? 'WING_LEFT' : 'WING_RIGHT';
  }

  // 4. Sisanya: medium range, di dalam arc 3PT, di luar paint.
  if (clampedX < 0.42) return 'MEDIUM_LEFT';
  if (clampedX > 0.58) return 'MEDIUM_RIGHT';
  return 'MEDIUM_CENTER';
}

/// Estimasi jarak tembakan dalam feet, dipakai untuk field
/// `shot_distance_ft` di dokumen event (PRD Section 7.3).
///
/// Konversi dari koordinat normalisasi ke ukuran half-court NBA standar
/// (lebar 49.2 ft, panjang half-court ~45.9 ft) lalu diagonalisasi.
int calculateDistanceFt(double x, double y) {
  const halfCourtFt = 45.9;
  const courtWidthFt = 49.2;

  final clampedX = x.clamp(0.0, 1.0);
  final clampedY = y.clamp(0.0, 1.0);

  final distNorm = _distanceFromRing(clampedX, clampedY);
  final diagonalFt = sqrt(pow(halfCourtFt, 2) + pow(courtWidthFt, 2));
  return (distNorm * diagonalFt / sqrt(2)).round();
}

double _distanceFromRing(double x, double y) {
  return sqrt(pow(x - ringX, 2) + pow(y - ringY, 2));
}

/// Validasi konsistensi antara tombol aksi yang ditekan Statistician
/// (misal "+2") dan zona hasil tap di court overlay.
///
/// Mengembalikan `true` jika konsisten (boleh lanjut tanpa konfirmasi),
/// `false` jika tidak konsisten (UI harus tampilkan dialog konfirmasi —
/// SRS FR-LMS-14: "Dialog konfirmasi jika zona tap tidak sesuai tombol").
bool validateZoneActionConsistency(String actionType, String zone) {
  final is2ptAction = actionType == '2PT_MADE' || actionType == 'MISS_2PT';
  final is3ptAction = actionType == '3PT_MADE' || actionType == 'MISS_3PT';

  if (is2ptAction && zones3pt.contains(zone)) return false;
  if (is3ptAction && zones2pt.contains(zone)) return false;

  // Free throw (1PT_MADE / MISS_1PT) tidak pernah memakai court overlay
  // sama sekali (SRS FR-LMS-03) — jika actionType bukan 2PT/3PT, anggap
  // selalu konsisten karena fungsi ini seharusnya tidak dipanggil untuk
  // free throw.
  return true;
}

/// Poin yang seharusnya didapat untuk zona tertentu — dipakai sebagai
/// referensi tampilan label zona di [CourtPainter] (PRD Section 7.7).
int pointsForZone(String zone) {
  return zones3pt.contains(zone) ? 3 : 2;
}
