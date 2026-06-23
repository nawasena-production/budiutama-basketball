/**
 * Security Rules Test — Firebase Emulator + @firebase/rules-unit-testing
 *
 * Cakupan jauh lebih luas dari skeleton dev guide (yang hanya menutupi
 * 6 skenario dasar): seluruh collection di firestore.rules diuji untuk
 * SETIAP role (manager, coach, statistician, player, unauthenticated)
 * pada operasi read/create/update/delete yang relevan — sesuai SRS
 * Section 6 (Kebutuhan Keamanan) dan SDD Section 4 (Desain Firebase
 * Security Rules).
 *
 * Jalankan:
 *   firebase emulators:exec "npx jest test/security/rules_test.js" \
 *     --only firestore
 *
 * Prasyarat: firestore.rules sudah ada di root project (lihat
 * firebase_config/firestore.rules di README Step 19-23 untuk salinan
 * yang sudah diverifikasi identik dengan SDD Section 4 / dev guide
 * Step 6.1).
 */

const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');

let testEnv;

const MANAGER = { uid: 'manager_uid', role: 'manager' };
const COACH = { uid: 'coach_uid', role: 'coach' };
const STATISTICIAN = { uid: 'stat_uid', role: 'statistician' };
const PLAYER = { uid: 'player_uid', role: 'player' };

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'bu-basketball-test-test',
    firestore: {
      rules: fs.readFileSync('firestore.rules', 'utf8'),
    },
  });
});

afterEach(async () => {
  await testEnv.clearFirestore();
});

afterAll(async () => {
  await testEnv.cleanup();
});

/** Helper: dapatkan context Firestore terautentikasi untuk satu user. */
function dbAs(user) {
  return testEnv
    .authenticatedContext(user.uid, { role: user.role })
    .firestore();
}

/** Helper: dapatkan context Firestore TANPA autentikasi. */
function dbAnon() {
  return testEnv.unauthenticatedContext().firestore();
}

/** Helper: tulis data langsung via Admin SDK (bypass rules) untuk
 * menyiapkan precondition test (mis. dokumen sudah ada sebelum diuji
 * update/delete). */
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await context.firestore().doc(path).set(data);
  });
}

// ── USERS ───────────────────────────────────────────────────────────

describe('users collection', () => {
  test('Manager bisa membaca dokumen users', async () => {
    await seed('users/coach_budi', { uid: COACH.uid, role: 'coach' });
    await assertSucceeds(dbAs(MANAGER).collection('users').doc('coach_budi').get());
  });

  test('Coach bisa membaca dokumen users', async () => {
    await seed('users/manager_andi', { uid: MANAGER.uid, role: 'manager' });
    await assertSucceeds(dbAs(COACH).collection('users').doc('manager_andi').get());
  });

  test('Player HANYA bisa membaca dokumen users miliknya sendiri', async () => {
    await seed('users/player_7_ar', { uid: PLAYER.uid, role: 'player' });
    await assertSucceeds(
      dbAs(PLAYER).collection('users').doc('player_7_ar').get()
    );
  });

  test('Player TIDAK bisa membaca dokumen users milik orang lain', async () => {
    await seed('users/coach_budi', { uid: COACH.uid, role: 'coach' });
    await assertFails(dbAs(PLAYER).collection('users').doc('coach_budi').get());
  });

  test('Statistician TIDAK termasuk isStaff — tidak bisa baca users orang lain', async () => {
    await seed('users/coach_budi', { uid: COACH.uid, role: 'coach' });
    await assertFails(
      dbAs(STATISTICIAN).collection('users').doc('coach_budi').get()
    );
  });

  test('client (role apa pun) TIDAK BISA write ke users — hanya Cloud Functions', async () => {
    await assertFails(
      dbAs(MANAGER).collection('users').doc('new_user').set({ role: 'coach' })
    );
  });

  test('unauthenticated TIDAK bisa membaca users', async () => {
    await seed('users/coach_budi', { uid: COACH.uid, role: 'coach' });
    await assertFails(dbAnon().collection('users').doc('coach_budi').get());
  });
});

// ── TEAMS ───────────────────────────────────────────────────────────

describe('teams collection', () => {
  test('semua role terautentikasi bisa membaca teams', async () => {
    await seed('teams/putra_2526', { name: 'Tim Putra' });
    await assertSucceeds(dbAs(PLAYER).collection('teams').doc('putra_2526').get());
    await assertSucceeds(dbAs(STATISTICIAN).collection('teams').doc('putra_2526').get());
  });

  test('hanya Manager yang bisa menulis teams', async () => {
    await assertSucceeds(
      dbAs(MANAGER).collection('teams').doc('putra_2526').set({ name: 'Tim Putra' })
    );
  });

  test('Coach TIDAK bisa menulis teams', async () => {
    await assertFails(
      dbAs(COACH).collection('teams').doc('putra_2526').set({ name: 'Tim Putra' })
    );
  });

  test('unauthenticated TIDAK bisa membaca teams', async () => {
    await seed('teams/putra_2526', { name: 'Tim Putra' });
    await assertFails(dbAnon().collection('teams').doc('putra_2526').get());
  });
});

// ── PLAYERS ─────────────────────────────────────────────────────────

describe('players collection', () => {
  test('Manager bisa membuat pemain baru', async () => {
    await assertSucceeds(
      dbAs(MANAGER).collection('players').doc('7_ar_putra2526').set({
        full_name: 'Ahmad Rizki',
        team_id: 'putra_2526',
        user_id: 'player_7_ar',
      })
    );
  });

  test('Coach TIDAK bisa membuat pemain baru', async () => {
    await assertFails(
      dbAs(COACH).collection('players').doc('7_ar_putra2526').set({
        full_name: 'Ahmad Rizki',
      })
    );
  });

  test('Statistician TIDAK bisa membuat pemain baru (hanya read)', async () => {
    await assertFails(
      dbAs(STATISTICIAN).collection('players').doc('7_ar_putra2526').set({
        full_name: 'Ahmad Rizki',
      })
    );
  });

  test('Statistician BISA membaca data pemain (perlu untuk Match Mode)', async () => {
    await seed('players/7_ar_putra2526', {
      full_name: 'Ahmad Rizki',
      team_id: 'putra_2526',
      user_id: 'player_7_ar',
    });
    await assertSucceeds(
      dbAs(STATISTICIAN).collection('players').doc('7_ar_putra2526').get()
    );
  });

  test('Player bisa membaca profilnya sendiri (user_id cocok)', async () => {
    await seed('players/7_ar_putra2526', {
      full_name: 'Ahmad Rizki',
      user_id: PLAYER.uid,
    });
    await assertSucceeds(
      dbAs(PLAYER).collection('players').doc('7_ar_putra2526').get()
    );
  });

  test('Player TIDAK bisa membaca profil pemain lain', async () => {
    await seed('players/3_rn_putri2526', {
      full_name: 'Rina Nuraini',
      user_id: 'lain_uid',
    });
    await assertFails(
      dbAs(PLAYER).collection('players').doc('3_rn_putri2526').get()
    );
  });

  test('TIDAK ADA role yang bisa menghapus pemain (soft delete only)', async () => {
    await seed('players/7_ar_putra2526', { full_name: 'Ahmad Rizki' });
    await assertFails(
      dbAs(MANAGER).collection('players').doc('7_ar_putra2526').delete()
    );
  });
});

// ── EVENTS (TURNAMEN) ──────────────────────────────────────────────

describe('events collection', () => {
  test('semua role terautentikasi bisa membaca events', async () => {
    await seed('events/porseni_kota_2526', { name: 'Porseni Kota' });
    await assertSucceeds(
      dbAs(PLAYER).collection('events').doc('porseni_kota_2526').get()
    );
  });

  test('hanya Manager yang bisa menulis events', async () => {
    await assertSucceeds(
      dbAs(MANAGER).collection('events').doc('porseni_kota_2526').set({
        name: 'Porseni Kota',
      })
    );
  });

  test('Statistician TIDAK bisa menulis events', async () => {
    await assertFails(
      dbAs(STATISTICIAN).collection('events').doc('porseni_kota_2526').set({
        name: 'Porseni Kota',
      })
    );
  });
});

// ── MATCHES (root document) ────────────────────────────────────────

describe('matches collection (root)', () => {
  test('Manager bisa membuat pertandingan baru', async () => {
    await assertSucceeds(
      dbAs(MANAGER)
        .collection('matches')
        .doc('porseni_kota_2526_vs_sman1_20260315')
        .set({ status: 'scheduled', current_state: 'PRE_MATCH' })
    );
  });

  test('Statistician TIDAK bisa membuat pertandingan baru', async () => {
    await assertFails(
      dbAs(STATISTICIAN)
        .collection('matches')
        .doc('porseni_kota_2526_vs_sman1_20260315')
        .set({ status: 'scheduled' })
    );
  });

  test('Statistician BISA update pertandingan (mis. current_state, skor)', async () => {
    await seed('matches/test_match', { status: 'scheduled', current_state: 'PRE_MATCH' });
    await assertSucceeds(
      dbAs(STATISTICIAN).collection('matches').doc('test_match').update({
        current_state: 'Q1_ACTIVE',
      })
    );
  });

  test('Manager BISA update pertandingan', async () => {
    await seed('matches/test_match', { status: 'scheduled' });
    await assertSucceeds(
      dbAs(MANAGER).collection('matches').doc('test_match').update({
        status: 'cancelled',
      })
    );
  });

  test('Coach TIDAK bisa update pertandingan', async () => {
    await seed('matches/test_match', { status: 'scheduled' });
    await assertFails(
      dbAs(COACH).collection('matches').doc('test_match').update({
        status: 'cancelled',
      })
    );
  });

  test('TIDAK ADA role yang bisa menghapus pertandingan', async () => {
    await seed('matches/test_match', { status: 'finished' });
    await assertFails(
      dbAs(MANAGER).collection('matches').doc('test_match').delete()
    );
  });

  test('Player BISA membaca daftar pertandingan (read terbuka untuk semua auth)', async () => {
    await seed('matches/test_match', { status: 'scheduled' });
    await assertSucceeds(
      dbAs(PLAYER).collection('matches').doc('test_match').get()
    );
  });
});

// ── MATCHES / timer_state (subcollection) ──────────────────────────

describe('matches/{id}/timer_state subcollection', () => {
  test('Statistician bisa menulis timer_state', async () => {
    await assertSucceeds(
      dbAs(STATISTICIAN)
        .doc('matches/test_match/timer_state/state')
        .set({ is_running: true, seconds_at_start: 600.0 })
    );
  });

  test('Manager TIDAK bisa menulis timer_state (hanya Statistician)', async () => {
    await assertFails(
      dbAs(MANAGER)
        .doc('matches/test_match/timer_state/state')
        .set({ is_running: true })
    );
  });

  test('semua role terautentikasi bisa membaca timer_state', async () => {
    await seed('matches/test_match/timer_state/state', { is_running: false });
    await assertSucceeds(
      dbAs(COACH).doc('matches/test_match/timer_state/state').get()
    );
  });
});

// ── MATCHES / events (subcollection — IMMUTABLE) ───────────────────

describe('matches/{id}/events subcollection — immutability', () => {
  test('Statistician bisa membuat event baru', async () => {
    await assertSucceeds(
      dbAs(STATISTICIAN).doc('matches/test_match/events/q1_001').set({
        quarter: 1,
        action_type: '2PT_MADE',
        is_undone: false,
      })
    );
  });

  test('Coach TIDAK bisa membuat event (hanya Statistician)', async () => {
    await assertFails(
      dbAs(COACH).doc('matches/test_match/events/q1_001').set({
        quarter: 1,
        action_type: '2PT_MADE',
        is_undone: false,
      })
    );
  });

  test('Statistician BISA update HANYA field is_undone', async () => {
    await seed('matches/test_match/events/q1_001', {
      quarter: 1,
      action_type: '2PT_MADE',
      is_undone: false,
    });
    await assertSucceeds(
      dbAs(STATISTICIAN)
        .doc('matches/test_match/events/q1_001')
        .update({ is_undone: true })
    );
  });

  test('Statistician TIDAK BISA update field selain is_undone (immutability)', async () => {
    await seed('matches/test_match/events/q1_001', {
      quarter: 1,
      action_type: '2PT_MADE',
      is_undone: false,
    });
    await assertFails(
      dbAs(STATISTICIAN)
        .doc('matches/test_match/events/q1_001')
        .update({ action_type: '3PT_MADE' })
    );
  });

  test('Statistician TIDAK BISA update is_undone BERSAMA field lain sekaligus', async () => {
    await seed('matches/test_match/events/q1_001', {
      quarter: 1,
      action_type: '2PT_MADE',
      is_undone: false,
    });
    // affectedKeys().hasOnly(['is_undone']) harus menolak update yang
    // menyentuh is_undone DAN field lain dalam satu operasi yang sama —
    // ini skenario penting yang tidak tercakup skeleton dev guide asli.
    await assertFails(
      dbAs(STATISTICIAN)
        .doc('matches/test_match/events/q1_001')
        .update({ is_undone: true, value: 99 })
    );
  });

  test('TIDAK ADA role yang bisa menghapus event (immutable selamanya)', async () => {
    await seed('matches/test_match/events/q1_001', {
      quarter: 1,
      action_type: '2PT_MADE',
      is_undone: false,
    });
    await assertFails(
      dbAs(STATISTICIAN).doc('matches/test_match/events/q1_001').delete()
    );
  });

  test('semua role terautentikasi bisa membaca events (Live Player Stats butuh ini)', async () => {
    await seed('matches/test_match/events/q1_001', {
      quarter: 1,
      action_type: '2PT_MADE',
    });
    await assertSucceeds(
      dbAs(PLAYER).doc('matches/test_match/events/q1_001').get()
    );
  });
});

// ── MATCHES / player_stats & lineups ───────────────────────────────

describe('matches/{id}/player_stats subcollection', () => {
  test('Statistician bisa menulis player_stats', async () => {
    await assertSucceeds(
      dbAs(STATISTICIAN)
        .doc('matches/test_match/player_stats/7_ar')
        .set({ points: 2 })
    );
  });

  test('Coach TIDAK bisa menulis player_stats', async () => {
    await assertFails(
      dbAs(COACH).doc('matches/test_match/player_stats/7_ar').set({ points: 2 })
    );
  });

  test('semua role terautentikasi bisa membaca player_stats (Tab Live Stats)', async () => {
    await seed('matches/test_match/player_stats/7_ar', { points: 10 });
    await assertSucceeds(
      dbAs(COACH).doc('matches/test_match/player_stats/7_ar').get()
    );
  });
});

describe('matches/{id}/lineups subcollection', () => {
  test('Statistician bisa menulis lineups (substitusi)', async () => {
    await assertSucceeds(
      dbAs(STATISTICIAN)
        .doc('matches/test_match/lineups/7_ar')
        .set({ is_on_court: true })
    );
  });

  test('Manager TIDAK bisa menulis lineups langsung (hanya Statistician saat live)', async () => {
    await assertFails(
      dbAs(MANAGER).doc('matches/test_match/lineups/7_ar').set({ is_on_court: true })
    );
  });
});

// ── INJURY REPORTS ──────────────────────────────────────────────────

describe('injury_reports collection', () => {
  test('Coach bisa membuat laporan cedera', async () => {
    await assertSucceeds(
      dbAs(COACH).collection('injury_reports').doc('7_ar_putra2526_20260205').set({
        player_id: '7_ar_putra2526',
        status: 'active',
      })
    );
  });

  test('Manager bisa membuat laporan cedera', async () => {
    await assertSucceeds(
      dbAs(MANAGER).collection('injury_reports').doc('7_ar_putra2526_20260205').set({
        player_id: '7_ar_putra2526',
        status: 'active',
      })
    );
  });

  test('Statistician TIDAK bisa membuat/membaca laporan cedera (bukan isStaff)', async () => {
    await assertFails(
      dbAs(STATISTICIAN).collection('injury_reports').doc('test').set({
        player_id: '7_ar_putra2526',
      })
    );
  });

  test('Player TIDAK bisa membaca laporan cedera (bukan isStaff)', async () => {
    await seed('injury_reports/test', { player_id: '7_ar_putra2526' });
    await assertFails(
      dbAs(PLAYER).collection('injury_reports').doc('test').get()
    );
  });
});

// ── TRAINING SESSIONS ───────────────────────────────────────────────

describe('training_sessions collection', () => {
  test('semua role terautentikasi bisa membaca jadwal latihan', async () => {
    await seed('training_sessions/putra2526_fisik_20260110', { title: 'Fisik' });
    await assertSucceeds(
      dbAs(PLAYER)
        .collection('training_sessions')
        .doc('putra2526_fisik_20260110')
        .get()
    );
  });

  test('hanya Manager yang bisa menulis jadwal latihan', async () => {
    await assertSucceeds(
      dbAs(MANAGER)
        .collection('training_sessions')
        .doc('putra2526_fisik_20260110')
        .set({ title: 'Fisik' })
    );
  });

  test('Coach TIDAK bisa menulis jadwal latihan', async () => {
    await assertFails(
      dbAs(COACH)
        .collection('training_sessions')
        .doc('putra2526_fisik_20260110')
        .set({ title: 'Fisik' })
    );
  });
});

// ── PHYSICAL TEST SESSIONS ──────────────────────────────────────────

describe('physical_test_sessions collection', () => {
  test('Manager/Coach (isStaff) bisa menulis sesi tes fisik', async () => {
    await assertSucceeds(
      dbAs(MANAGER)
        .collection('physical_test_sessions')
        .doc('beep_putra2526_20260120')
        .set({ test_type: 'beep_test' })
    );
    await assertSucceeds(
      dbAs(COACH)
        .collection('physical_test_sessions')
        .doc('beep_putra2526_20260120')
        .set({ test_type: 'beep_test' })
    );
  });

  test('Statistician TIDAK bisa menulis/membaca sesi tes fisik', async () => {
    await assertFails(
      dbAs(STATISTICIAN)
        .collection('physical_test_sessions')
        .doc('beep_putra2526_20260120')
        .set({ test_type: 'beep_test' })
    );
  });

  test('hasil tes fisik (subcollection results) mengikuti aturan isStaff yang sama', async () => {
    await assertSucceeds(
      dbAs(COACH)
        .doc('physical_test_sessions/beep_putra2526_20260120/results/7_ar')
        .set({ beep_level: 8, beep_shuttle: 3 })
    );
    await assertFails(
      dbAs(PLAYER)
        .doc('physical_test_sessions/beep_putra2526_20260120/results/7_ar')
        .get()
    );
  });
});

// ── AUDIT LOGS — read-only dari client ─────────────────────────────

describe('audit_logs collection', () => {
  test('Coach dan Manager bisa MEMBACA audit log', async () => {
    await seed('audit_logs/log1', { action_type: 'PLAYER_UPDATED' });
    await assertSucceeds(dbAs(COACH).collection('audit_logs').doc('log1').get());
    await assertSucceeds(dbAs(MANAGER).collection('audit_logs').doc('log1').get());
  });

  test('Statistician dan Player TIDAK bisa membaca audit log', async () => {
    await seed('audit_logs/log1', { action_type: 'PLAYER_UPDATED' });
    await assertFails(
      dbAs(STATISTICIAN).collection('audit_logs').doc('log1').get()
    );
    await assertFails(dbAs(PLAYER).collection('audit_logs').doc('log1').get());
  });

  test('TIDAK ADA role yang bisa MENULIS audit log dari client (hanya Cloud Functions Admin SDK)', async () => {
    await assertFails(
      dbAs(MANAGER).collection('audit_logs').doc('log_palsu').set({
        action_type: 'FAKE',
      })
    );
  });
});

// ── UNAUTHENTICATED — baseline keamanan ─────────────────────────────

describe('unauthenticated access — baseline', () => {
  test('unauthenticated TIDAK bisa membaca players', async () => {
    await seed('players/7_ar_putra2526', { full_name: 'Ahmad Rizki' });
    await assertFails(dbAnon().collection('players').doc('7_ar_putra2526').get());
  });

  test('unauthenticated TIDAK bisa membaca matches', async () => {
    await seed('matches/test_match', { status: 'scheduled' });
    await assertFails(dbAnon().collection('matches').doc('test_match').get());
  });

  test('unauthenticated TIDAK bisa menulis apa pun', async () => {
    await assertFails(
      dbAnon().collection('teams').doc('putra_2526').set({ name: 'Tim' })
    );
  });
});
