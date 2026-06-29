# Statistician Role Fix - Implementasi & Testing

## 📋 Summary Perubahan

Saya sudah mengidentifikasi dan memperbaiki root cause permission-denied error untuk role `statistician` (dan roles lain):

### Root Cause
- **Problem**: Security Rules membaca `request.auth.token.role` (Custom Claims di Auth), tapi Custom Claims tidak pernah di-set saat seeding
- **Symptom**: Login berhasil, tapi view/query collection ditolak permission-denied
- **Solution**: Auto-set Custom Claims saat seeding via Node.js helper + Admin SDK

### Files & Changes

#### ✅ Dibuat:
1. **`functions/lib/setCustomClaims.js`** - Node.js helper untuk set Custom Claims
2. **`scripts/set_custom_claims_batch.dart`** - Batch set claims untuk existing users
3. **`scripts/create_auth_users_from_firestore.dart`** - Create Auth users + set claims
4. **`EMULATOR_SEEDING_GUIDE.md`** - Complete step-by-step seeding guide + troubleshooting

#### ✅ Modified:
1. **`scripts/seed_test_match.dart`** - Auto-set Custom Claims untuk statistician
   - Import `dart:io`
   - Call Node.js helper setelah create user
   - Proper cross-platform path handling

#### ⚠️ NOT Modified:
- **Security Rules**: Sudah correct, hanya perlu Custom Claims di Auth
- **AuthRepository.getRole()**: Sudah correct, membaca dari token.claims
- **Firestore user documents**: Struktur field sudah correct

---

## 🧪 Testing Flow

### Prerequisites
```bash
# Pastikan sudah install Node.js
node --version

# Install dependencies di functions/
cd functions/
npm install
cd ..
```

### Step 1: Start Firebase Emulator
```bash
firebase emulators:start --import=./emulator-data --export-on-exit=./emulator-data
```
- Tunggu sampai semua emulator ready (Auth, Firestore, Functions)
- Output: `emulator running` di semua service

### Step 2: Seed Firestore Base Data
Terminal baru:
```bash
dart run scripts/seed_emulator.dart
```
**Expected Output:**
```
✅ Team ... dibuat
...
Seed data emulator selesai.
```

### Step 3: Create Auth Users + Set Custom Claims
```bash
dart run scripts/create_auth_users_from_firestore.dart
```
**Expected Output:**
```
📄 Reading users dari Firestore...
✅ User dibuat: manager_andi_uid (manager@...)
✅ Custom Claims set untuk manager_andi_uid: {"role":"manager"}
✅ User dibuat: coach_budi_uid (coach@...)
✅ Custom Claims set untuk coach_budi_uid: {"role":"coach"}

✅ Selesai!
   Users created: 2
   Custom Claims set: 2
   Skipped: 0
```

### Step 4: Seed Test Match (Creates Statistician)
```bash
dart run scripts/seed_test_match.dart
```
**Expected Output:**
```
✅ Akun Statistician dibuat: statistician_<uid>
✅ Custom Claims set untuk statistician_...: {"role":"statistician"}
✅ Fixture pertandingan 'friendly_sman1_...' berhasil di-seed!
   Status: scheduled, 5 starter siap, timer belum berjalan.
   Login sebagai: statistician@budiutama.sch.id / Test1234!
   Custom Claims sudah di-set otomatis untuk statistician role.
```

### Step 5: Test Login di App
```bash
flutter run -d chrome
# atau
flutter run -d windows
```

**Test Credentials:**
- **Manager**: manager@budiutama.sch.id / Test1234!
- **Coach**: coach@budiutama.sch.id / Test1234!
- **Statistician**: statistician@budiutama.sch.id / Test1234!

**Test Points untuk Statistician:**
- ✅ Login berhasil
- ✅ Dashboard statistician terbuka (jika accessible route)
- ✅ Bisa akses players list (matches rule read allowed)
- ✅ Buka match → statistician dashboard/match mode
- ✅ Tidak ada error `cloud_firestore/permission-denied`

---

## 🔧 Troubleshooting

### Error: Node.js helper gagal dijalankan

```
⚠️  Warning: Gagal run Node.js helper: ...
```

**Solusi:**
1. Pastikan Node.js ter-install: `node --version`
2. Pastikan di-run dari root project directory (bukan folder lain)
3. Verifikasi path: `functions/lib/setCustomClaims.js` harus exist

### Error: `spawn node ENOENT`

**Penyebab**: Node.js tidak ada di PATH

**Solusi Windows PowerShell:**
```powershell
# Cek Node.js installed
node --version

# Kalau error, install dari https://nodejs.org/

# Jika sudah install tapi masih error, gunakan full path
& "C:\Program Files\nodejs\node.exe" --version
```

### Error: GOOGLE_APPLICATION_CREDENTIALS not found

```
Unable to determine Project ID for Admin SDK
```

**Solusi:**
```bash
# Set variable (temporary, untuk session ini saja)

# PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS = "./serviceAccountKey.json"

# bash/zsh
export GOOGLE_APPLICATION_CREDENTIALS="./serviceAccountKey.json"

# Untuk emulator lokal, file ini bisa dummy JSON:
# { "type": "service_account", "project_id": "demo-project" }
```

### Error: Auth Emulator koneksi ditolak

```
Connection refused at localhost:9099
```

**Solusi:**
- Pastikan `firebase emulators:start` sudah running
- Check port 9099 tidak di-use aplikasi lain:
  ```bash
  # Windows: cari process di port 9099
  netstat -ano | findstr :9099
  ```

### Permission Denied masih muncul setelah seeding

**Kemungkinan Penyebab 1**: Custom Claims belum di-set (helper gagal silent)
```bash
# Batch set ulang
dart run scripts/set_custom_claims_batch.dart
```

**Kemungkinan Penyebab 2**: Token belum di-refresh
```
Solusi: Sign out, sign in ulang
```

**Kemungkinan Penyebab 3**: Firestore Rules still denying (verify rules)
```bash
# Buka Emulator UI
http://localhost:4000/firestore/
# Cek rule untuk statistician access
```

### Manual Set Custom Claims via Emulator UI

Jika script gagal, bisa set manual:

1. Buka **Emulator UI**: http://localhost:4000
2. Tab **Authentication**
3. Klik user yang akan diedit
4. **Edit Custom Claims** (ikon >)
5. Copy-paste:
   ```json
   {"role": "statistician"}
   ```
   atau
   ```json
   {"role": "coach", "team_id": "sma_putra_2526"}
   ```
6. **Update**
7. Sign out/in di app untuk refresh token

---

## 📊 Architecture Explanation

### Before Fix:
```
┌─────────────────────────────────────────────┐
│ User Login: statistician@budiutama.sch.id   │
└─────────────┬───────────────────────────────┘
              │
              ▼
         Firestore users doc:
         { uid: "...", role: "statistician" } ✅
              │
              ▼
    Firebase Auth Token:
    { aud, iss, ... }  ❌ NO ROLE CLAIM
              │
              ▼
    AuthRepository.getRole():
    token.claims?['role'] = null ❌
              │
              ▼
    App checks role → null → fallback/error
         AND
    Firestore Query:
    Security Rule: read if role() == "statistician"
    token.role = null ❌ PERMISSION DENIED ❌❌❌
```

### After Fix:
```
┌─────────────────────────────────────────────┐
│ User Creation in Seed Script                │
└─────────────┬───────────────────────────────┘
              │
    ┌─────────▼──────────┐
    │ Create Auth user   │ → Auth Emulator
    └────────────────────┘
              │
    ┌─────────▼────────────────────────────────┐
    │ Call Node.js Helper                      │
    │ setCustomClaims.js <uid> "statistician"  │
    │ ↓ Admin SDK ↓                            │
    │ auth.setCustomUserClaims()               │
    └────────────────────────────────────────┬─┘
                                             │
                                    ▼ Cached in Auth Emulator
    ┌──────────────────────────────────────────────┐
    │ Firestore users doc:                         │
    │ { uid: "...", role: "statistician" } ✅      │
    │                                              │
    │ Firebase Auth Token (after login):           │
    │ { aud, iss, ..., role: "statistician" } ✅   │
    └────────────────┬─────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
    AuthRepository:         Firestore:
    getRole() → "stat..."   Rule check:
    ✅ Returns role         role() == "stat..."
                            ✅ ALLOWED ✅
```

### Key Points:
1. **Node.js Helper** menggunakan Firebase Admin SDK (bisa server-side operation)
2. **Custom Claims** di-cache di Auth token setelah di-set
3. **Token refresh** otomatis terjadi saat `getIdTokenResult(true)`
4. **Security Rules** membaca dari `request.auth.token` (source of truth)

---

## ✅ Checklist Sebelum Production

- [ ] Test semua credentials berhasil login
- [ ] Test statistician role akses Match Management
- [ ] Verify tidak ada permission-denied di console
- [ ] Test coach role (jika applicable)
- [ ] Test player role dengan correct UID mapping
- [ ] Run integration_test `full_match_flow_test.dart`
- [ ] Check Firestore Rules test (jika ada)
- [ ] Backup dan reset emulator-data before production deploy

---

## 📝 Reference

- [EMULATOR_SEEDING_GUIDE.md](EMULATOR_SEEDING_GUIDE.md) - Complete guide dengan troubleshooting
- [firestore.rules](firestore.rules) - Security rules (already verified correct)
- [lib/features/auth/data/repositories/auth_repository.dart](lib/features/auth/data/repositories/auth_repository.dart) - getRole() implementation
- [functions/lib/setCustomClaims.js](functions/lib/setCustomClaims.js) - Node.js helper code

---

## 🎯 Next Phase (After Statistician Verified)

1. **Fix Coach Role** - Verify routes + access control
2. **Fix Player Role** - Fix UID vs DocID mismatch in security rules
3. **Integration Tests** - Test all roles dengan proper permission matrix
4. **Cloud Functions** - Verify createUser() setCustomUserClaims() works on production
