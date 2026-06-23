import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:budiutama_basketball/core/theme/app_theme.dart';

// Auth
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/auth/presentation/pages/login_page.dart';
import 'package:budiutama_basketball/features/auth/presentation/pages/otp_verification_page.dart';

import 'package:budiutama_basketball/features/players/presentation/pages/players_root_page.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';

// Step 8 — Events
import 'package:budiutama_basketball/features/events/data/models/event_model.dart';
import 'package:budiutama_basketball/features/events/presentation/pages/events_page.dart';

// Step 10 — Injuries
import 'package:budiutama_basketball/features/injuries/presentation/pages/injury_page.dart';

// Step 11 — Physical Tests
import 'package:budiutama_basketball/features/physical_tests/presentation/pages/physical_test_page.dart';

// Step 12 — Users
import 'package:budiutama_basketball/features/users/presentation/pages/user_management_page.dart';

// Step 8 — Training
import 'package:budiutama_basketball/features/training/presentation/pages/training_page.dart';

// Step 9 — Matches
import 'package:budiutama_basketball/features/matches/dashboard/presentation/pages/matches_page.dart';

// Step 16 — Match Mode (Live Match Engine UI)
import 'package:budiutama_basketball/features/matches/live/presentation/pages/match_mode_page.dart';

// Step 18 — Statistics Dashboard
import 'package:budiutama_basketball/features/statistics/presentation/pages/statistics_dashboard_page.dart';

// Step 19 — Audit Log
import 'package:budiutama_basketball/features/audit_log/presentation/pages/audit_log_page.dart';

// Shared
import 'package:budiutama_basketball/shared/widgets/app_layout.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Budi Utama Basketball',
      debugShowCheckedModeBanner: false,
      // Wajib untuk showDatePicker/showTimePicker yang memakai
      // locale: const Locale('id', 'ID') (lihat add_event_bottom_sheet.dart,
      // add_injury_bottom_sheet.dart, add_training_bottom_sheet.dart, dst.)
      // — tanpa delegate ini Flutter melempar
      // "No MaterialLocalizations found" (Issue 3).
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      theme: AppTheme.light(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}

// ── ROUTER ────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final notifier = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateStream,
  );
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/otp';
      final pendingOtp = ref.read(pendingOtpProvider);

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && pendingOtp != null && location != '/otp') {
        return '/otp';
      }
      if (isLoggedIn && pendingOtp == null && isAuthRoute) return '/players';
      return null;
    },
    routes: [
      // ── AUTH ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? const {};
          return OtpVerificationPage(
            email: extra['email'] ?? '',
            userId: extra['userId'] ?? '',
            deviceHash: extra['deviceHash'] ?? '',
          );
        },
      ),

      // ── DASHBOARD (shell utama dengan navigasi) ───────────────────────
      // Setiap menu punya path sendiri agar URL browser mengikuti
      // halaman yang aktif (mis. /players, /events, /injuries) — bukan
      // selalu /dashboard untuk semua tab (Issue 5 / PRD Section 9,
      // SRS Section 5.1 daftar menu navigasi).
      GoRoute(
        path: '/dashboard',
        redirect: (context, state) => '/players',
      ),
      ..._dashboardSlugs.map(
        (slug) => GoRoute(
          path: '/$slug',
          builder: (context, state) => _DashboardPage(slug: slug),
        ),
      ),

      // ── MATCH MODE (fullscreen, tanpa nav) — Step 16 ──────────────────
      // MatchModePage menangani sendiri landscape lock, immersive mode,
      // dan exit confirmation — lihat SDD Section 5.1.
      GoRoute(
        path: '/match/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          return MatchModePage(matchId: matchId);
        },
      ),
    ],
  );
});

// ── DASHBOARD MENU SLUGS (URL clean paths) ────────────────────────────────
//
// Daftar lengkap slug menu dashboard — superset dari seluruh role, karena
// GoRoute didefinisikan sekali secara statis (bukan per-role). Akses tiap
// slug per role tetap ditentukan oleh AppLayout._destinationsForRole() dan
// _DashboardPage._indexForSlug() di bawah; membuka slug yang tidak relevan
// untuk role tertentu akan jatuh ke _ComingSoonPage (perilaku sama seperti
// index di luar rentang pada implementasi switch-index sebelumnya).
const _dashboardSlugs = [
  'players',
  'training',
  'events',
  'matches',
  'injuries',
  'physical-tests',
  'statistics',
  'audit-log',
  'users',
];

// ── REFRESH STREAM ────────────────────────────────────────────────────────

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ── DASHBOARD PAGE ────────────────────────────────────────────────────────

class _DashboardPage extends ConsumerWidget {
  final String slug;
  const _DashboardPage({required this.slug});

  /// Slug per role, urutannya WAJIB identik dengan
  /// `AppLayout._destinationsForRole()` dan dengan komentar index di
  /// `_buildBody()` / `_managerBody()` / dst. di bawah — ini adalah satu-
  /// satunya tempat yang menterjemahkan index navigasi menjadi path URL,
  /// supaya logika pemilihan halaman (`_buildBody` dkk.) tidak perlu
  /// diubah sama sekali.
  static const Map<String, List<String>> _slugsByRole = {
    'manager': [
      'players',
      'training',
      'events',
      'matches',
      'injuries',
      'physical-tests',
      'statistics',
      'audit-log',
      'users',
    ],
    'coach': [
      'training',
      'events',
      'matches',
      'injuries',
      'physical-tests',
      'statistics',
      'audit-log',
    ],
    'statistician': ['events', 'matches'],
    'player': ['training', 'events', 'matches', 'statistics'],
  };

  static List<String> _slugsFor(String role) => _slugsByRole[role] ?? const [];

  static int _indexForSlug(String role, String slug) {
    final index = _slugsFor(role).indexOf(slug);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(userRoleProvider);
    final userDocIdAsync = ref.watch(currentUserDocIdProvider);

    return roleAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const Scaffold(
        body: Center(child: Text('Gagal memuat role pengguna.')),
      ),
      data: (role) {
        final effectiveRole = role ?? 'player';
        final userDocId = userDocIdAsync.valueOrNull ?? '';
        final teamId = ref.watch(activeTeamIdProvider);
        final roleSlugs = _slugsFor(effectiveRole);
        final selectedIndex = _indexForSlug(effectiveRole, slug);

        return AppLayout(
          role: effectiveRole,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            if (index < 0 || index >= roleSlugs.length) return;
            context.go('/${roleSlugs[index]}');
          },
          body: _DashboardBody(
            index: selectedIndex,
            role: effectiveRole,
            teamId: teamId,
            userDocId: userDocId,
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final int index;
  final String role;
  final String teamId;
  final String userDocId;

  const _DashboardBody({
    required this.index,
    required this.role,
    required this.teamId,
    required this.userDocId,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBody(
      context: context,
      index: index,
      role: role,
      teamId: teamId,
      userDocId: userDocId,
    );
  }

  /// Menentukan halaman body berdasarkan index navigasi yang aktif.
  ///
  /// Index bergantung pada urutan destination di AppLayout._destinationsForRole().
  /// Karena destination berbeda per role, index dipetakan per role.
  Widget _buildBody({
    required BuildContext context,
    required int index,
    required String role,
    required String teamId,
    required String userDocId,
  }) {
    // Mapping index → halaman berdasarkan role.
    // Urutan harus SAMA dengan _destinationsForRole() di AppLayout.
    switch (role) {
      // ── MANAGER ─────────────────────────────────────────────────────
      // 0: Players, 1: Training, 2: Events, 3: Matches,
      // 4: Injuries, 5: Physical Tests, 6: Statistics, 7: Audit Log, 8: Users
      case 'manager':
        return _managerBody(context, index, teamId, userDocId);

      // ── COACH ───────────────────────────────────────────────────────
      // 0: Training, 1: Events, 2: Matches,
      // 3: Injuries, 4: Physical Tests, 5: Statistics, 6: Audit Log
      case 'coach':
        return _coachBody(context, index, teamId, userDocId);

      // ── STATISTICIAN ─────────────────────────────────────────────────
      // 0: Events, 1: Matches
      case 'statistician':
        return _statisticianBody(context, index, teamId, userDocId);

      // ── PLAYER ──────────────────────────────────────────────────────
      // 0: Training, 1: Events, 2: Matches, 3: Statistics
      case 'player':
        return _playerBody(context, index, teamId, userDocId);

      default:
        return const _ComingSoonPage(label: 'Dashboard');
    }
  }

  // ── BODY PER ROLE ─────────────────────────────────────────────────────

  Widget _managerBody(
      BuildContext context, int index, String teamId, String userDocId) {
    switch (index) {
      case 0: // Players
        return const PlayersRootPage(role: 'manager');
      case 1: // Training
        return TrainingPage(
          teamId: teamId,
          role: 'manager',
          createdBy: userDocId,
        );
      case 2: // Events
        return EventsPage(
          teamId: teamId,
          role: 'manager',
          academicYear: '2025/2026',
          onEventSelected: (event) =>
              _pushMatchesPage(context, event, 'manager', teamId, userDocId),
        );
      case 3: // Matches — tampilkan events dulu untuk pilih context
        return EventsPage(
          teamId: teamId,
          role: 'manager',
          academicYear: '2025/2026',
          onEventSelected: (event) =>
              _pushMatchesPage(context, event, 'manager', teamId, userDocId),
        );
      case 4: // Injuries — placeholder Step 10
        return InjuryPage(
          teamId: teamId,
          role: 'manager',
          createdBy: userDocId,
        );
      case 5: // Physical Tests — placeholder Step 11
        return PhysicalTestPage(
          teamId: teamId,
          role: 'manager',
          createdBy: userDocId,
          academicYear: '2025/2026',
        );
      case 6: // Statistics — Step 18
        return const StatisticsDashboardPage();
      case 7: // Audit Log — Step 19
        return const AuditLogPage();
      case 8: // Users — placeholder Step 12
        return const UserManagementPage();
      default:
        return const _ComingSoonPage(label: 'Dashboard');
    }
  }

  Widget _coachBody(
      BuildContext context, int index, String teamId, String userDocId) {
    switch (index) {
      case 0: // Training (read-only)
        return TrainingPage(
          teamId: teamId,
          role: 'coach',
          createdBy: userDocId,
        );
      case 1: // Events
        return EventsPage(
          teamId: teamId,
          role: 'coach',
          academicYear: '2025/2026',
          onEventSelected: (event) =>
              _pushMatchesPage(context, event, 'coach', teamId, userDocId),
        );
      case 2: // Matches
        return EventsPage(
          teamId: teamId,
          role: 'coach',
          academicYear: '2025/2026',
          onEventSelected: (event) =>
              _pushMatchesPage(context, event, 'coach', teamId, userDocId),
        );
      case 3: // Injuries — placeholder Step 10
        return InjuryPage(
          teamId: teamId,
          role: 'coach',
          createdBy: userDocId,
        );
      case 4: // Physical Tests — placeholder Step 11
        return PhysicalTestPage(
          teamId: teamId,
          role: 'coach',
          createdBy: userDocId,
          academicYear: '2025/2026',
        );
      case 5: // Statistics — Step 18
        return const StatisticsDashboardPage();
      case 6: // Audit Log — Step 19
        return const AuditLogPage();
      default:
        return const _ComingSoonPage(label: 'Dashboard');
    }
  }

  Widget _statisticianBody(
      BuildContext context, int index, String teamId, String userDocId) {
    switch (index) {
      case 0: // Events
        return EventsPage(
          teamId: teamId,
          role: 'statistician',
          academicYear: '2025/2026',
          onEventSelected: (event) => _pushMatchesPage(
              context, event, 'statistician', teamId, userDocId),
        );
      case 1: // Matches
        return EventsPage(
          teamId: teamId,
          role: 'statistician',
          academicYear: '2025/2026',
          onEventSelected: (event) => _pushMatchesPage(
              context, event, 'statistician', teamId, userDocId),
        );
      default:
        return const _ComingSoonPage(label: 'Dashboard');
    }
  }

  Widget _playerBody(
      BuildContext context, int index, String teamId, String userDocId) {
    switch (index) {
      case 0: // Training (read-only)
        return TrainingPage(
          teamId: teamId,
          role: 'player',
          createdBy: userDocId,
        );
      case 1: // Events (read-only)
        return EventsPage(
          teamId: teamId,
          role: 'player',
          academicYear: '2025/2026',
          onEventSelected: (event) =>
              _pushMatchesPage(context, event, 'player', teamId, userDocId),
        );
      case 2: // Matches (read-only)
        return EventsPage(
          teamId: teamId,
          role: 'player',
          academicYear: '2025/2026',
          onEventSelected: (event) =>
              _pushMatchesPage(context, event, 'player', teamId, userDocId),
        );
      case 3: // Statistics — Step 18
        return const StatisticsDashboardPage();
      default:
        return const _ComingSoonPage(label: 'Dashboard');
    }
  }

  // ── NAVIGASI HELPER ───────────────────────────────────────────────────

  void _pushMatchesPage(
    BuildContext context,
    EventModel event,
    String role,
    String teamId,
    String userDocId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchesPage(
          event: event,
          role: role,
          homeTeamId: teamId,
          createdBy: userDocId,
        ),
      ),
    );
  }
}

// ── PLACEHOLDER PAGES ─────────────────────────────────────────────────────

/// Placeholder untuk fitur yang belum diimplementasikan (Step 10+).
class _ComingSoonPage extends StatelessWidget {
  final String label;
  const _ComingSoonPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_outlined,
                size: 56, color: Color(0xFF6B7A8D)),
            const SizedBox(height: 16),
            Text(
              label,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Fitur ini akan tersedia di step berikutnya.',
              style: TextStyle(color: Color(0xFF6B7A8D)),
            ),
          ],
        ),
      ),
    );
  }
}
