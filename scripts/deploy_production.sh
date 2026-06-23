#!/usr/bin/env bash
#
# deploy_production.sh - Otomasi Step 23.3 (Build & Deploy) dengan
# pagar konfirmasi eksplisit di setiap tahap berisiko tinggi, supaya
# tidak ada langkah yang "kebablasan" dijalankan tanpa sengaja terhadap
# project production.
#
# Jalankan dari root project Flutter:
#   bash scripts/deploy_production.sh
#
# Catatan: script ini TIDAK menggantikan review manual checklist
# Step 22 (hardening_check.sh) dan Step 23.1-23.2 (clear data + seed) -
# jalankan itu semua TERLEBIH DAHULU sebelum script ini.

set -euo pipefail

PROJECT_ID="bu-basketball-test"

confirm() {
  local prompt="$1"
  read -r -p "$prompt (ketik 'yes' untuk lanjut): " response
  if [ "$response" != "yes" ]; then
    echo "Dibatalkan oleh pengguna. Berhenti."
    exit 1
  fi
}

echo "================================================================"
echo " DEPLOY PRODUCTION - Budi Utama Basketball Management System"
echo " Target project Firebase: $PROJECT_ID"
echo "================================================================"
echo ""

confirm "Apakah hardening_check.sh sudah dijalankan dan SEMUA lolos?"
confirm "Apakah Firestore production sudah di-clear & seed sesuai Step 23.1-23.2?"
confirm "Yakin ingin melanjutkan deploy ke PRODUCTION ($PROJECT_ID)?"
echo ""

# ── 1. Build Flutter Web Release ──────────────────────────────────
echo "-- 1. Build Flutter Web Release --"
flutter build web --release
echo "OK Build web selesai: build/web/"
echo ""

# ── 2. Deploy Security Rules (DULUAN, sebelum hosting/functions) ───
# Urutan ini SENGAJA diubah dari skeleton dev guide asli (yang men-
# deploy hosting terlebih dahulu) - rules harus aktif LEBIH DULU
# sebelum kode aplikasi baru yang mungkin bergantung pada field/aturan
# baru benar-benar bisa diakses pengguna, menghindari jendela waktu di
# mana app baru berjalan melawan rules lama yang lebih longgar/ketat.
echo "-- 2. Deploy Security Rules --"
confirm "Lanjutkan deploy firestore:rules ke production?"
firebase deploy --only firestore:rules --project "$PROJECT_ID"
echo "OK Security Rules ter-deploy"
echo ""

# ── 3. Deploy Firestore Indexes ───────────────────────────────────
echo "-- 3. Deploy Firestore Indexes --"
firebase deploy --only firestore:indexes --project "$PROJECT_ID"
echo "OK Indexes ter-deploy"
echo ""

# ── 4. Deploy Cloud Functions ─────────────────────────────────────
echo "-- 4. Deploy Cloud Functions --"
confirm "Lanjutkan deploy Cloud Functions ke production?"
firebase deploy --only functions --project "$PROJECT_ID"
echo "OK Cloud Functions ter-deploy"
echo ""

# ── 5. Deploy Flutter Web ke Hosting (live channel) ───────────────
echo "-- 5. Deploy Flutter Web ke Hosting --"
confirm "Lanjutkan deploy Hosting (live channel, akan langsung publik)?"
firebase deploy --only hosting --project "$PROJECT_ID"
echo "OK Hosting ter-deploy ke live channel"
echo ""

# ── 6. Build Android APK Release ──────────────────────────────────
echo "-- 6. Build Android APK Release --"
read -r -p "Build APK Android sekarang juga? (yes/skip): " build_apk
if [ "$build_apk" = "yes" ]; then
  flutter build apk --release
  echo "OK APK ter-build: build/app/outputs/flutter-apk/app-release.apk"
else
  echo "Build APK dilewati - jalankan manual nanti dengan:"
  echo "   flutter build apk --release"
fi
echo ""

echo "================================================================"
echo " DEPLOY SELESAI"
echo "================================================================"
echo "Langkah selanjutnya: jalankan Smoke Test Production (Step 23.4)"
echo "sesuai checklist di README_step19_23.md sebelum mengumumkan"
echo "go-live ke seluruh pengguna."
