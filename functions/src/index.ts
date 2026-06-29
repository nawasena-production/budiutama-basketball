import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

// ── createUser: Manager buat akun baru ───────────────────────────────
// Sesuai Dev Guide Step 12.2 / SRS FR-AUTH-06.
export const createUser = functions.https.onCall(async (data, context) => {
  // Hanya Manager yang bisa membuat akun baru
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Hanya Manager yang bisa membuat akun baru'
    );
  }

  const {
    email,
    password,
    fullName,
    role: rawRole,
    teamId,
    jerseyNumber,
    positions,
    position,
    heightCm,
    weightKg,
    dateOfBirth,
  } = data;

  const validPositions = ['PG', 'SG', 'SF', 'PF', 'C'];
  const playerPositions: string[] = Array.isArray(positions)
    ? positions
    : position
      ? [position]
      : [];

  const role = normalizeRole(rawRole);

  if (!email || !password || !fullName || !role) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Email, password, nama lengkap, dan role valid wajib diisi'
    );
  }

  const needsTeam = role === 'player';
  if (needsTeam && !teamId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Player wajib memilih tim'
    );
  }

  if (role === 'player') {
    if (typeof jerseyNumber !== 'number' || jerseyNumber < 0 || jerseyNumber > 99) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Player wajib mengisi nomor jersey 0-99'
      );
    }
    if (playerPositions.length === 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Player wajib memilih minimal 1 posisi'
      );
    }
    if (!playerPositions.every((p: string) => validPositions.includes(p))) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Posisi tidak valid'
      );
    }
  }

  if (teamId) {
    const teamSnap = await db.collection('teams').doc(teamId).get();
    if (!teamSnap.exists) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        `Tim "${teamId}" tidak ditemukan di Firestore`
      );
    }
  }

  if (role === 'player') {
    const jerseySnap = await db
      .collection('players')
      .where('team_id', '==', teamId)
      .where('jersey_number', '==', jerseyNumber)
      .limit(1)
      .get();
    if (!jerseySnap.empty) {
      throw new functions.https.HttpsError(
        'already-exists',
        `Nomor jersey #${jerseyNumber} sudah digunakan pemain lain di tim ini.`
      );
    }
  }

  let userRecord: admin.auth.UserRecord;
  try {
    userRecord = await auth.createUser({ email, password });
  } catch (err: unknown) {
    const code = (err as { code?: string }).code;
    if (code === 'auth/email-already-exists') {
      throw new functions.https.HttpsError(
        'already-exists',
        'Email sudah terdaftar. Gunakan email lain.'
      );
    }
    throw new functions.https.HttpsError(
      'internal',
      'Gagal membuat akun Firebase Auth'
    );
  }

  try {
    // Document ID unik — hindari overwrite jika nama depan sama
    const baseDocId = `${role}_${String(fullName).split(' ')[0].toLowerCase()}`;
    let docId = baseDocId;
    let counter = 1;
    while ((await db.collection('users').doc(docId).get()).exists) {
      docId = `${baseDocId}_${counter++}`;
    }

    // Set Custom Claims (role + team_id)
    await auth.setCustomUserClaims(userRecord.uid, {
      role,
      team_id: teamId ?? null,
    });

    let playerId: string | null = null;
    if (role === 'player') {
      playerId = generatePlayerId(jerseyNumber, fullName, teamId);
    }

    const batch = db.batch();
    batch.set(db.collection('users').doc(docId), {
      uid: userRecord.uid,
      email,
      full_name: fullName,
      role,
      team_id: teamId ?? null,
      player_id: playerId,
      jersey_number: role === 'player' ? jerseyNumber : null,
      positions: role === 'player' ? playerPositions : null,
      is_active: true,
      trusted_device_ids: [],
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      created_by: context.auth?.uid,
    });

    if (role === 'player' && playerId) {
      batch.set(db.collection('players').doc(playerId), {
        user_id: docId,
        team_id: teamId,
        full_name: fullName,
        jersey_number: jerseyNumber,
        positions: playerPositions,
        height_cm: typeof heightCm === 'number' ? heightCm : null,
        weight_kg: typeof weightKg === 'number' ? weightKg : null,
        date_of_birth: dateOfBirth
          ? admin.firestore.Timestamp.fromDate(new Date(dateOfBirth))
          : null,
        photo_url: null,
        photo_base64: null,
        status: 'active',
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    return { success: true, uid: userRecord.uid, docId, playerId };
  } catch (err) {
    // Rollback Auth user jika penulisan Firestore gagal
    await auth.deleteUser(userRecord.uid).catch(() => undefined);
    throw new functions.https.HttpsError(
      'internal',
      'Gagal menyimpan data pengguna'
    );
  }
});

// ── updateUserRole: ubah role pengguna ───────────────────────────────
// Sesuai Dev Guide Step 12.2.
export const updateUserRole = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'Permission denied');
  }
  const { docId, uid, newRole } = data;
  const normalizedRole = normalizeRole(newRole);
  if (!normalizedRole) {
    throw new functions.https.HttpsError('invalid-argument', 'Role tidak valid');
  }
  const userDoc = docId ? await db.collection('users').doc(docId).get() : null;
  const teamId = userDoc?.data()?.team_id ?? null;
  await auth.setCustomUserClaims(uid, { role: normalizedRole, team_id: teamId });
  if (docId) {
    await db.collection('users').doc(docId).update({
      role: normalizedRole,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  // Force token refresh pada next login
  return { success: true };
});

// ── deactivateUser: nonaktifkan user ─────────────────────────────────
// Sesuai Dev Guide Step 12.2.
export const deactivateUser = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'Permission denied');
  }
  const { docId, uid } = data;
  if (!docId || !uid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'docId dan uid wajib diisi'
    );
  }
  await updateAuthDisabled(uid, true);
  if (docId) {
    await db.collection('users').doc(docId).update({
      is_active: false,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  return { success: true };
});

// ── reactivateUser: aktifkan kembali user ────────────────────────────
// TIDAK didokumentasikan secara eksplisit di PRD/SRS/SDD/Dev Guide,
// namun dipanggil oleh client (lib/features/users/.../user_repository.dart
// via httpsCallable('reactivateUser'), dipicu dari UserManagementPage
// aksi "Aktifkan Kembali"). Diimplementasikan sebagai kebalikan logis
// persis dari deactivateUser yang terdokumentasi di atas — bukan
// business logic baru, hanya invers dari operasi yang sudah ada.
export const reactivateUser = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'Permission denied');
  }
  const { docId, uid } = data;
  if (!docId || !uid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'docId dan uid wajib diisi'
    );
  }
  await updateAuthDisabled(uid, false);
  if (docId) {
    await db.collection('users').doc(docId).update({
      is_active: true,
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
  return { success: true };
});

// ── transferPlayerTeam: pindahkan pemain SMP → SMA ──────────────────
export const transferPlayerTeam = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Hanya Manager yang bisa memindahkan pemain antar tim'
    );
  }

  const { playerId, targetTeamId } = data;
  if (!playerId || !targetTeamId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'playerId dan targetTeamId wajib diisi'
    );
  }

  const playerSnap = await db.collection('players').doc(playerId).get();
  if (!playerSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Pemain tidak ditemukan');
  }

  const player = playerSnap.data()!;
  const currentTeamId = player.team_id as string;

  if (!currentTeamId.toLowerCase().includes('smp')) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Hanya pemain tim SMP yang bisa dipindahkan ke SMA'
    );
  }

  if (!targetTeamId.toLowerCase().includes('sma')) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Tim tujuan harus tim SMA'
    );
  }

  const currentGender = currentTeamId.toLowerCase().includes('putri')
    ? 'putri'
    : 'putra';
  const targetGender = targetTeamId.toLowerCase().includes('putri')
    ? 'putri'
    : 'putra';
  if (currentGender !== targetGender) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Tim tujuan harus sesuai gender pemain (Putra/Putri)'
    );
  }

  const targetTeamSnap = await db.collection('teams').doc(targetTeamId).get();
  if (!targetTeamSnap.exists) {
    throw new functions.https.HttpsError(
      'not-found',
      `Tim tujuan "${targetTeamId}" tidak ditemukan`
    );
  }

  const jerseyNumber = player.jersey_number as number;
  const fullName = player.full_name as string;
  const userDocId = player.user_id as string | undefined;

  const jerseySnap = await db
    .collection('players')
    .where('team_id', '==', targetTeamId)
    .where('jersey_number', '==', jerseyNumber)
    .limit(1)
    .get();
  if (!jerseySnap.empty) {
    throw new functions.https.HttpsError(
      'already-exists',
      `Nomor jersey #${jerseyNumber} sudah digunakan di tim SMA`
    );
  }

  const newPlayerId = generatePlayerId(jerseyNumber, fullName, targetTeamId);
  const newPlayerSnap = await db.collection('players').doc(newPlayerId).get();
  if (newPlayerSnap.exists) {
    throw new functions.https.HttpsError(
      'already-exists',
      'Pemain dengan ID yang sama sudah ada di tim SMA'
    );
  }

  const batch = db.batch();

  batch.set(db.collection('players').doc(newPlayerId), {
    user_id: userDocId ?? null,
    team_id: targetTeamId,
    full_name: fullName,
    jersey_number: jerseyNumber,
    positions: player.positions ?? [],
    height_cm: player.height_cm ?? null,
    weight_kg: player.weight_kg ?? null,
    date_of_birth: player.date_of_birth ?? null,
    photo_url: player.photo_url ?? null,
    photo_base64: player.photo_base64 ?? null,
    status: 'active',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  batch.update(db.collection('players').doc(playerId), {
    status: 'inactive',
    user_id: admin.firestore.FieldValue.delete(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  if (userDocId) {
    const userSnap = await db.collection('users').doc(userDocId).get();
    if (userSnap.exists) {
      const uid = userSnap.data()?.uid as string | undefined;
      batch.update(db.collection('users').doc(userDocId), {
        team_id: targetTeamId,
        player_id: newPlayerId,
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      if (uid) {
        await auth.setCustomUserClaims(uid, {
          role: 'player',
          team_id: targetTeamId,
        });
      }
    }
  }

  await batch.commit();

  return { success: true, newPlayerId, targetTeamId };
});

// ── deleteUser: hapus akun permanen dari Auth + Firestore ───────────
export const deleteUser = functions.https.onCall(async (data, context) => {
  if (context.auth?.token?.role !== 'manager') {
    throw new functions.https.HttpsError('permission-denied', 'Permission denied');
  }

  const { docId, uid } = data;
  if (!docId || !uid) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'docId dan uid wajib diisi'
    );
  }

  const batch = db.batch();
  batch.delete(db.collection('users').doc(docId));

  const linkedPlayers = await db
    .collection('players')
    .where('user_id', '==', docId)
    .get();
  linkedPlayers.docs.forEach((doc) => {
    batch.update(doc.ref, {
      user_id: admin.firestore.FieldValue.delete(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  await deleteAuthUserIfExists(uid);
  return { success: true };
});

// ── onMatchFinished: Hitung statistik final saat POST_MATCH ──────────
// Sesuai Dev Guide Step 15.1 (versi final, termasuk update status match).
export const onMatchFinished = functions.firestore
  .document('matches/{matchId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const matchId = context.params.matchId;

    if (before.current_state === after.current_state) return;
    if (after.current_state !== 'POST_MATCH') return;

    // Ambil semua events yang valid (belum di-undo)
    const eventsSnap = await db
      .collection(`matches/${matchId}/events`)
      .where('is_undone', '==', false)
      .get();

    // Hitung ulang stats dari event log (verifikasi vs materialized stats)
    const finalStats = calculateFinalStats(eventsSnap.docs);

    // Update player_stats dengan nilai final yang terverifikasi
    const batch = db.batch();
    for (const [playerId, stats] of Object.entries(finalStats)) {
      batch.update(
        db.collection(`matches/${matchId}/player_stats`).doc(playerId),
        { ...(stats as object), final_calculated: true }
      );
    }
    await batch.commit();

    // Update status match menjadi finished
    await db.collection('matches').doc(matchId).update({
      status: 'finished',
      finished_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// ── onMatchEventCreated: Audit log otomatis ────────────────────────
// Sesuai Dev Guide Step 15.1 / SRS FR-AUD-01.
export const onMatchEventCreated = functions.firestore
  .document('matches/{matchId}/events/{eventId}')
  .onCreate(async (snap, context) => {
    const event = snap.data();
    if (!event || event.action_type === 'UNDO') return; // jangan audit UNDO event
    await db.collection('audit_logs').add({
      user_id: event.created_by,
      action_type: 'MATCH_EVENT_CREATED',
      entity_type: 'match_event',
      entity_id: context.params.eventId,
      new_value: {
        match_id: context.params.matchId,
        action_type: event.action_type,
        player_id: event.player_id,
        quarter: event.quarter,
      },
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// ── onInjuryStatusChanged: Update player status saat cedera cleared ─
// Sesuai Dev Guide Step 15.1 / SRS FR-INJ-02.
export const onInjuryStatusChanged = functions.firestore
  .document('injury_reports/{reportId}')
  .onUpdate(async (change) => {
    const after = change.after.data();
    if (!after || after.status !== 'cleared') return;
    await db.collection('players').doc(after.player_id).update({
      status: 'active',
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

// ── Helper: Kalkulasi statistik final dari event log ────────────────
function generatePlayerId(
  jerseyNumber: number,
  fullName: string,
  teamId: string
): string {
  const initials = fullName
    .trim()
    .split(/\s+/)
    .slice(0, 2)
    .map((word) => word.charAt(0).toLowerCase())
    .join('');
  const teamShort = teamId.replace(/_/g, '');
  return `${jerseyNumber}_${initials}_${teamShort}`;
}

function normalizeRole(role: unknown): string | null {
  if (typeof role !== 'string') return null;
  const normalized = role.trim().toLowerCase();
  if (normalized === 'statistican') return 'statistician';
  return ['manager', 'coach', 'statistician', 'player'].includes(normalized)
    ? normalized
    : null;
}

async function updateAuthDisabled(uid: string, disabled: boolean): Promise<void> {
  try {
    await auth.updateUser(uid, { disabled });
  } catch (err: unknown) {
    const code = (err as { code?: string }).code;
    if (code === 'auth/user-not-found') return;
    throw err;
  }
}

async function deleteAuthUserIfExists(uid: string): Promise<void> {
  try {
    await auth.deleteUser(uid);
  } catch (err: unknown) {
    const code = (err as { code?: string }).code;
    if (code === 'auth/user-not-found') return;
    throw err;
  }
}

function calculateFinalStats(
  eventDocs: admin.firestore.QueryDocumentSnapshot[]
): Record<string, Record<string, number>> {
  const stats: Record<string, Record<string, number>> = {};

  const initStats = () => ({
    points: 0, ft_made: 0, ft_attempted: 0,
    fg2_made: 0, fg2_attempted: 0, fg3_made: 0, fg3_attempted: 0,
    assists: 0, offensive_rebounds: 0, defensive_rebounds: 0,
    steals: 0, turnovers: 0, blocks: 0, fouls: 0,
  });

  for (const doc of eventDocs) {
    const e = doc.data();
    if (e.is_opponent || !e.player_id) continue;

    // Derive stats doc ID dari player_id
    const key = e.player_id.replace(/_putra.*/, '').replace(/_putri.*/, '');
    if (!stats[key]) stats[key] = initStats();

    switch (e.action_type) {
      case '1PT_MADE': stats[key].ft_made++; stats[key].ft_attempted++; stats[key].points++; break;
      case '2PT_MADE': stats[key].fg2_made++; stats[key].fg2_attempted++; stats[key].points += 2; break;
      case '3PT_MADE': stats[key].fg3_made++; stats[key].fg3_attempted++; stats[key].points += 3; break;
      case 'MISS_1PT': stats[key].ft_attempted++; break;
      case 'MISS_2PT': stats[key].fg2_attempted++; break;
      case 'MISS_3PT': stats[key].fg3_attempted++; break;
      case 'ASSIST': stats[key].assists++; break;
      case 'REBOUND_OFF': stats[key].offensive_rebounds++; break;
      case 'REBOUND_DEF': stats[key].defensive_rebounds++; break;
      case 'STEAL': stats[key].steals++; break;
      case 'TURNOVER': stats[key].turnovers++; break;
      case 'BLOCK': stats[key].blocks++; break;
      case 'FOUL': stats[key].fouls++; break;
    }
  }
  return stats;
}
