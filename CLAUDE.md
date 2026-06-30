# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Budi Utama Basketball** — a Flutter web/mobile app for managing a basketball team. It covers player roster management, training sessions, events/competitions, injuries, physical tests, live match scoring (with real-time Firestore), and statistics. The app is primarily web-targeted (desktop layout with sidebar nav) and targets Flutter SDK `>=3.0.0`.

## Commands

### Flutter (app)
```bash
# Run the app (web)
flutter run -d chrome

# Run the app with Firebase emulators (set useEmulator = true in lib/main.dart first)
flutter run -d chrome

# Run all tests
flutter test

# Run a single test file
flutter test test/core/utils/stats_calculator_test.dart

# Run code generation (after modifying .dart files with @freezed / @riverpod annotations)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Lint
flutter analyze
```

### Firebase Functions (`functions/`)
```bash
cd functions

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy functions
firebase deploy --only functions

# Start local emulators (requires Firebase CLI)
firebase emulators:start
```

### Firebase Emulator Toggle
In `lib/main.dart`, set `const bool useEmulator = true;` to route all Firebase traffic to local emulators on `localhost`.

## Architecture

### Layer structure (Clean Architecture, per feature)
```
lib/
  core/           # Shared utilities, theme, constants, error types
  features/       # Feature modules (see below)
  shared/         # Cross-feature models (UserModel, TeamModel) and widgets
  app/            # App root, router, DashboardPage
  main.dart       # Firebase init, emulator config, ProviderScope
```

Each feature under `lib/features/<name>/` follows:
```
data/
  models/      # Freezed + JsonSerializable data classes (+ .freezed.dart, .g.dart)
  repositories/ # Firestore CRUD — no business logic
domain/
  providers/   # Riverpod providers (FutureProvider, StreamProvider, Notifier)
presentation/
  pages/       # Full pages
  widgets/     # Reusable widgets within the feature
```

### Features
| Feature | Path | Notes |
|---|---|---|
| Auth | `features/auth/` | Email+OTP login; custom claims for role |
| Players | `features/players/` | Roster management, photo upload |
| Training | `features/training/` | Session scheduling |
| Events | `features/events/` | Competitions/events; entry point to matches |
| Matches (dashboard) | `features/matches/dashboard/` | Match list per event |
| Matches (live) | `features/matches/live/` | Real-time live scoring engine |
| Injuries | `features/injuries/` | Injury reports |
| Physical Tests | `features/physical_tests/` | Physical fitness test sessions |
| Statistics | `features/statistics/` | Aggregated stats dashboard, shot chart |
| Audit Log | `features/audit_log/` | Change history |
| Users | `features/users/` | Manager-only user account management |

### State management: Riverpod
- Providers are defined in `domain/providers/` files within each feature.
- `authSessionCoordinatorProvider` (`lib/features/auth/domain/providers/auth_session_provider.dart`) — watches auth UID changes and invalidates all session-scoped providers to prevent stale cache on logout/switch.
- `activeTeamIdProvider` and `playerTeamBootstrapProvider` handle team context globally.

### Routing: go_router
- Defined in `lib/app/app.dart` as `routerProvider`.
- Auth guard redirects unauthenticated users to `/login` and handles OTP flow.
- Dashboard routes use clean URL slugs (e.g. `/players`, `/training`, `/events`).
- Live match is a fullscreen route at `/match/:matchId` — no sidebar nav.
- `RoleNavigation` (`lib/core/constants/role_navigation.dart`) controls which slugs each role (`manager`, `coach`, `statistician`, `player`) can access and their default landing page.

### Firestore schema
All collection/path constants are in `lib/core/constants/firestore_paths.dart`. Key top-level collections: `users`, `teams`, `players`, `events`, `matches`, `training_sessions`, `injury_reports`, `physical_test_sessions`, `audit_logs`. Matches have subcollections: `events`, `player_stats`, `lineups`, `timer_state`.

### Live Match Engine (`features/matches/live/`)
The most complex feature. Key design decisions:
- **Dual-write strategy**: Every action writes an immutable event to `matches/{id}/events` AND increments materialized stats in `matches/{id}/player_stats` in a single Firestore batch (all-or-nothing).
- **Undo**: Marks the original event `is_undone: true` and writes a new `UNDO` event, then decrements stats — never deletes events.
- **Match state machine** (`lib/core/utils/match_state_machine.dart`): States are `PRE_MATCH → Q1_ACTIVE → Q1_BREAK → Q2_ACTIVE → HALFTIME → Q3_ACTIVE → Q3_BREAK → Q4_ACTIVE → CHECK_SCORE → (OT_ACTIVE →) POST_MATCH`.
- **Action types** (`match_action_provider.dart`): Self-team actions include all shot types, assists, rebounds, steals, turnovers, blocks, fouls. Opponent actions are limited to made shots and fouls only.
- **Zone classification** (`lib/core/utils/zone_classifier.dart`): Court zones used for shot chart.

### Code generation
Models use `freezed` + `json_serializable`. Providers use `riverpod_generator`. Generated files (`.freezed.dart`, `.g.dart`) are committed to the repo. Regenerate with `build_runner` after editing annotated source files.

### Firebase Functions (`functions/src/index.ts`)
Single TypeScript file with callable HTTPS functions and Firestore triggers:
- `createUser` — Manager-only: creates Firebase Auth user + Firestore user/player docs in one batch.
- `updateUserRole`, `deactivateUser`, `reactivateUser`, `deleteUser` — Manager-only user management.
- `transferPlayerTeam` — Manager-only: SMP→SMA team transfer with jersey conflict check.
- `onMatchFinished` — Firestore trigger on `matches/{id}` update: re-computes final stats from the immutable event log when state transitions to `POST_MATCH` (authoritative re-verification of on-device dual-writes).
- `onInjuryStatusChanged` — Firestore trigger: updates player `status` to `active` when an injury report is cleared.
- Role is stored as a Firebase Auth custom claim; the app reads it via `IdTokenResult`.
- `audit_logs` writes are blocked from the client — only the Admin SDK (Cloud Functions) can write them.

### Firestore IDs
IDs are deterministic and human-readable rather than auto-generated UUIDs (e.g. `7_ar_smaputra2526`, `porseni_kota_yogyakarta_2526`). This enables ID-based routing without extra lookups.

### Scripts (`scripts/`)
- `deploy_production.sh` — Full production deploy: `flutter build web` → Firestore rules → indexes → functions → hosting → optional APK build.
- `hardening_check.sh` — Pre-deploy checklist: verifies no secrets in git, App Check uses `kDebugMode`, no stray `print()` calls, no allow-all Firestore rules, runs `flutter analyze`.
- `seed_emulator.dart`, `create_auth_users_from_firestore.dart`, `seed_test_match.dart` — Emulator data seeding scripts.

### Integration tests
Require `firebase emulators:start` running first:
```bash
flutter test integration_test/auth_test.dart -d chrome
```

### Responsive layout
`AppLayout` (`lib/shared/widgets/app_layout.dart`) uses `AppBreakpoints` to switch between a desktop sidebar layout and a mobile bottom-nav layout. The match mode page is fullscreen/landscape-locked and bypasses `AppLayout`.

### Localization
App locale is `id_ID` (Indonesian). `initializeDateFormatting('id_ID')` is called in `main()` before any widgets render. `GlobalMaterialLocalizations.delegate` is required for date/time pickers.
