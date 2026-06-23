#!/usr/bin/env bash
#
# hardening_check.sh — Verifikasi otomatis Step 22 (Performance,
# Hardening & Bug Fix) sebelum go-live. Menggabungkan checklist manual
# dev guide Step 22.1-22.2 menjadi satu script yang bisa dijalankan
# berulang kali di CI atau lokal, plus beberapa pemeriksaan tambahan
# yang tidak disinggung skeleton asli tapi krusial untuk produksi.
#
# Jalankan dari root project Flutter:
#   bash scripts/hardening_check.sh
#
# Exit code 0 jika semua pemeriksaan lolos, 1 jika ada yang gagal.

set -uo pipefail

PASS=0
FAIL=0

pass() { echo "✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "❌ $1"; FAIL=$((FAIL + 1)); }

echo "════════════════════════════════════════════════════════════"
echo " HARDENING CHECK — Budi Utama Basketball Management System"
echo "════════════════════════════════════════════════════════════"
echo ""

# ── 1. Secrets TIDAK boleh ter-track git (Step 22.1) ─────────────────
echo "── 1. Verifikasi secrets tidak di-commit ──"

check_not_tracked() {
  local file="$1"
  if git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    fail "$file MASIH TER-TRACK git — HAPUS dari repo dan tambahkan ke .gitignore segera"
  else
    pass "$file tidak ter-track git"
  fi
}

check_not_tracked "android/app/google-services.json"
check_not_tracked "ios/Runner/GoogleService-Info.plist"
check_not_tracked "lib/firebase_options.dart"
echo ""

# ── 2. .gitignore memuat seluruh pola secrets yang relevan ──────────
echo "── 2. Verifikasi .gitignore lengkap ──"

check_gitignore_pattern() {
  local pattern="$1"
  if grep -qF "$pattern" .gitignore 2>/dev/null; then
    pass "Pola \"$pattern\" ada di .gitignore"
  else
    fail "Pola \"$pattern\" TIDAK ditemukan di .gitignore"
  fi
}

check_gitignore_pattern "android/app/google-services.json"
check_gitignore_pattern "ios/Runner/GoogleService-Info.plist"
check_gitignore_pattern "lib/firebase_options.dart"
echo ""

# ── 3. App Check memakai kDebugMode, bukan hardcode debug (Step 22.2) ─
echo "── 3. Verifikasi App Check provider berbasis kDebugMode ──"

if grep -q "kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity" lib/main.dart 2>/dev/null; then
  pass "AndroidProvider memakai kDebugMode sebagai kondisi"
else
  fail "AndroidProvider TIDAK ditemukan memakai pola kDebugMode yang benar di lib/main.dart"
fi

if grep -q "kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck" lib/main.dart 2>/dev/null; then
  pass "AppleProvider memakai kDebugMode sebagai kondisi"
else
  fail "AppleProvider TIDAK ditemukan memakai pola kDebugMode yang benar di lib/main.dart"
fi

if grep -qE "ReCaptchaV3Provider\('[a-zA-Z0-9_-]{10,}'\)" lib/main.dart 2>/dev/null \
   && ! grep -q "YOUR_RECAPTCHA_SITE_KEY" lib/main.dart 2>/dev/null; then
  pass "Web reCAPTCHA site key sudah diisi (bukan placeholder)"
else
  fail "Web reCAPTCHA site key TAMPAKNYA masih placeholder — cek lib/main.dart"
fi
echo ""

# ── 4. Tidak ada print()/debugPrint() tertinggal di kode produksi ────
echo "── 4. Cek sisa print()/debugPrint() debug ──"

PRINT_COUNT=$(grep -rn "print(" lib/ --include="*.dart" 2>/dev/null | grep -v "// ignore" | wc -l | tr -d ' ')
if [ "$PRINT_COUNT" -eq 0 ]; then
  pass "Tidak ada print() tersisa di lib/"
else
  fail "$PRINT_COUNT pemanggilan print() ditemukan di lib/ — review manual, mungkin sisa debug:"
  grep -rn "print(" lib/ --include="*.dart" 2>/dev/null | grep -v "// ignore" | head -10
fi
echo ""

# ── 5. Tidak ada TODO/FIXME kritis tersisa ───────────────────────────
echo "── 5. Cek TODO/FIXME tersisa (informational, bukan blocker) ──"

TODO_COUNT=$(grep -rn "TODO\|FIXME" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TODO_COUNT" -eq 0 ]; then
  pass "Tidak ada TODO/FIXME tersisa"
else
  echo "ℹ️  $TODO_COUNT TODO/FIXME ditemukan (tidak otomatis menggagalkan check, review manual):"
  grep -rn "TODO\|FIXME" lib/ --include="*.dart" 2>/dev/null | head -10
fi
echo ""

# ── 6. flutter analyze tanpa error ────────────────────────────────────
echo "── 6. flutter analyze ──"

if command -v flutter >/dev/null 2>&1; then
  if flutter analyze --no-fatal-infos 2>&1 | tee /tmp/flutter_analyze_output.txt | grep -q "No issues found"; then
    pass "flutter analyze: tidak ada issue"
  else
    ERROR_COUNT=$(grep -c "error •" /tmp/flutter_analyze_output.txt 2>/dev/null || echo 0)
    if [ "$ERROR_COUNT" -eq 0 ]; then
      pass "flutter analyze: tidak ada ERROR (mungkin ada warning/info, lihat detail di atas)"
    else
      fail "flutter analyze: $ERROR_COUNT error ditemukan — WAJIB diperbaiki sebelum deploy"
    fi
  fi
else
  echo "⚠️  Flutter SDK tidak ditemukan di PATH, lewati pemeriksaan ini"
fi
echo ""

# ── 7. firestore.rules TIDAK dalam mode deny-all/allow-all placeholder ─
echo "── 7. Verifikasi firestore.rules bukan placeholder ──"

if [ -f firestore.rules ]; then
  if grep -q "allow read, write: if false;" firestore.rules && [ "$(wc -l < firestore.rules)" -lt 10 ]; then
    fail "firestore.rules TAMPAKNYA masih placeholder deny-all dari Step 1.11 — deploy rules final dari Step 6"
  elif grep -q "allow read, write: if true;" firestore.rules; then
    fail "firestore.rules mengandung 'allow read, write: if true' — KEBOCORAN KEAMANAN SERIUS"
  else
    pass "firestore.rules tampak sudah berisi rules production (bukan placeholder)"
  fi
else
  fail "firestore.rules TIDAK ditemukan di root project"
fi
echo ""

# ── RINGKASAN ──────────────────────────────────────────────────────
echo "════════════════════════════════════════════════════════════"
echo " RINGKASAN: $PASS lolos, $FAIL gagal"
echo "════════════════════════════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
  echo "❌ Ada pemeriksaan yang GAGAL — JANGAN deploy ke production sebelum diperbaiki."
  exit 1
else
  echo "✅ Semua pemeriksaan otomatis lolos. Lanjutkan ke verifikasi manual:"
  echo "   - Step 22.3: Performance Test Multi-Device Sync (manual, lihat README)"
  echo "   - Step 22.4: Test Offline Mode (manual, lihat README)"
  exit 0
fi
