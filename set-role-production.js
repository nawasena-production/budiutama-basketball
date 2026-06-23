/**
 * set-role-production.js
 *
 * Script sekali-jalan untuk men-set role (Custom Claims) Firebase Auth
 * di PRODUCTION project. Jalankan lewat: node set-role-production.js
 *
 * Persiapan sebelum jalan:
 * 1. Download Service Account Key:
 *    Firebase Console → Project Settings → Service Accounts →
 *    "Generate new private key" → simpan sebagai serviceAccountKey.json
 *    di folder yang sama dengan file ini.
 * 2. Install dependency (sekali saja):
 *    npm install firebase-admin
 */

const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const auth = getAuth();

// ── DAFTAR USER YANG MAU DI-SET ROLE-NYA ────────────────────────────
// Tambah/kurangi baris di array ini sesuai kebutuhan.
// uid          : ambil dari Firebase Console → Authentication
// role         : 'coach' | 'manager' | 'statistician' | 'player'
// teamId       : opsional, isi null kalau tidak perlu di-scope ke tim tertentu
const usersToUpdate = [
  {
    uid: 'ZNwuueJ3ihZ3fOKQ64AILgSBDFf1',
    role: 'manager',
    teamId: null,
  },
  // Contoh tambahan, hapus comment & sesuaikan kalau perlu:
  // { uid: 'UID_COACH_DI_SINI', role: 'coach', teamId: 'putra_2526' },
  // { uid: 'UID_STATISTICIAN_DI_SINI', role: 'statistician', teamId: 'putra_2526' },
  // { uid: 'UID_PLAYER_DI_SINI', role: 'player', teamId: 'putra_2526' },
];
// ─────────────────────────────────────────────────────────────────────

async function setRole({ uid, role, teamId }) {
  const claims = teamId ? { role, team_id: teamId } : { role };
  await auth.setCustomUserClaims(uid, claims);
  console.log(`✅ Role '${role}' berhasil di-set untuk UID ${uid}`);
}

async function main() {
  for (const user of usersToUpdate) {
    try {
      await setRole(user);
    } catch (err) {
      console.error(`❌ Gagal set role untuk UID ${user.uid}:`, err.message);
    }
  }
  console.log('\nSelesai. Jangan lupa logout & login ulang di app supaya token baru terbaca.');
  process.exit(0);
}

main();