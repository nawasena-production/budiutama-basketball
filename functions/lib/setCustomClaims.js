/**
 * Helper untuk set Custom Claims ke Auth Emulator atau Firebase Auth
 * Dipanggil dari seed scripts untuk assign role via Custom Claims
 * 
 * Penggunaan:
 *   node functions/lib/setCustomClaims.js <uid> <role> [team_id]
 * 
 * Contoh:
 *   node functions/lib/setCustomClaims.js statistician_reza_uid statistician
 *   node functions/lib/setCustomClaims.js player_7_uid player sma_putra_2526
 * 
 * Environment Variables (optional):
 *   GOOGLE_APPLICATION_CREDENTIALS: Path ke service account key JSON
 *   FIREBASE_DATABASE_EMULATOR_HOST: untuk Emulator (auto-detected jika localhost:9099 berjalan)
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
// Auto-detect emulator atau production setup

let app;
try {
  // Cek if emulator is running (biasanya projectId akan di-set oleh Firebase CLI)
  // Atau explicitly set environment variable USE_EMULATOR=true
  const isEmulator = 
    process.env.FIREBASE_EMULATOR_HOST || 
    process.env.USE_EMULATOR === 'true' ||
    !process.env.GOOGLE_APPLICATION_CREDENTIALS; // Jika tidak ada cred file, assume emulator

  let initOptions = {};

  if (isEmulator) {
    // Emulator mode: credential bisa dummy, Admin SDK connect via emulator host
    console.log('ℹ️  Menggunakan Firebase Emulator');
    initOptions = {
      projectId: process.env.GCLOUD_PROJECT || 'budiutama-basketball',
    };
  } else {
    // Production mode: gunakan service account key
    const credentialPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    console.log(`ℹ️  Menggunakan service account: ${credentialPath}`);
    
    const serviceAccount = require(path.resolve(credentialPath));
    initOptions = {
      credential: admin.credential.cert(serviceAccount),
    };
  }

  app = admin.initializeApp(initOptions);
} catch (error) {
  console.error(`❌ Failed to initialize Firebase Admin SDK: ${error.message}`);
  console.error('   Pastikan:');
  console.error('   1. Firebase Emulator berjalan (firebase emulators:start)');
  console.error('   2. Atau set GOOGLE_APPLICATION_CREDENTIALS=./serviceAccountKey.json');
  process.exit(1);
}

const auth = admin.auth();

async function setCustomClaims(uid, role, teamId = null) {
  try {
    const claims = {
      role,
      ...(teamId && { team_id: teamId }),
    };

    await auth.setCustomUserClaims(uid, claims);
    console.log(`✅ Custom Claims set untuk ${uid}: ${JSON.stringify(claims)}`);
    process.exit(0);
  } catch (error) {
    console.error(`❌ Gagal set Custom Claims: ${error.message}`);
    process.exit(1);
  }
}

// Parse arguments: node script.js <uid> <role> [team_id]
const args = process.argv.slice(2);
if (args.length < 2) {
  console.error('Usage: node setCustomClaims.js <uid> <role> [team_id]');
  process.exit(1);
}

const [uid, role, teamId] = args;
setCustomClaims(uid, role, teamId);
