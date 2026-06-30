import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/features/audit_log/domain/providers/audit_log_provider.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/events/domain/providers/events_provider.dart';
import 'package:budiutama_basketball/features/injuries/domain/providers/injury_provider.dart';
import 'package:budiutama_basketball/features/physical_tests/domain/providers/physical_test_provider.dart';
import 'package:budiutama_basketball/features/players/domain/providers/players_provider.dart';
import 'package:budiutama_basketball/features/players/presentation/widgets/team_toggle_widget.dart';
import 'package:budiutama_basketball/features/training/domain/providers/training_provider.dart';
import 'package:budiutama_basketball/features/users/domain/providers/user_provider.dart';

/// Mendengarkan perubahan UID auth dan mereset cache provider session-scoped.
///
/// Tanpa ini, [userRoleProvider] bisa menampilkan role user lama saat reload,
/// dan StreamProvider Firestore tidak otomatis re-subscribe sehingga muncul
/// `permission-denied` sampai halaman di-refresh manual.
final authSessionCoordinatorProvider = Provider<void>((ref) {
  ref.listen<String?>(authUidProvider, (previous, next) {
    if (previous == next) return;
    _resetSessionScopedProviders(ref);
  });
});

void _resetSessionScopedProviders(Ref ref) {
  ref.read(activeTeamIdProvider.notifier).state = '';
  ref.read(selectedPlayerIdProvider.notifier).state = null;
  ref.read(playerStatusFilterProvider.notifier).state = null;
  ref.read(selectedEventProvider.notifier).state = null;
  ref.read(userRoleFilterProvider.notifier).state = null;
  ref.read(trainingTabIndexProvider.notifier).state = 0;
  ref.read(injuryTabIndexProvider.notifier).state = 0;
  ref.read(activeSessionIdProvider.notifier).state = null;
  ref.read(activeSessionTeamIdProvider.notifier).state = null;
  ref.read(selectedTestTypeProvider.notifier).state = 'beep_test';
  ref.read(pendingOtpProvider.notifier).state = null;

  ref.invalidate(userRoleProvider);
  ref.invalidate(currentUserDocIdProvider);
  ref.invalidate(currentUserProfileProvider);

  ref.invalidate(teamsStreamProvider);
  ref.invalidate(playersStreamProvider);
  ref.invalidate(activePLayersStreamProvider);
  ref.invalidate(eventsStreamProvider);
  ref.invalidate(activeEventsStreamProvider);
  ref.invalidate(trainingsStreamProvider);
  ref.invalidate(upcomingTrainingsProvider);
  ref.invalidate(pastTrainingsProvider);
  ref.invalidate(activeInjuriesProvider);
  ref.invalidate(allInjuriesProvider);
  ref.invalidate(physicalTestSessionsProvider);
  ref.invalidate(physicalTestResultsStreamProvider);
  ref.invalidate(physicalTestSessionProvider);
  ref.invalidate(allUsersProvider);
  ref.invalidate(usersByRoleProvider);
  ref.invalidate(linkedPlayerForUserProvider);
  ref.invalidate(auditLogListProvider);
  ref.invalidate(auditLogActionTypesProvider);
}

/// Set tim aktif otomatis untuk role Player berdasarkan profil pemain
/// yang terhubung ke akun — sesuai PRD (read-only data milik sendiri).
final playerTeamBootstrapProvider = Provider<void>((ref) {
  final role = ref.watch(userRoleProvider).valueOrNull;
  if (role != 'player') return;

  final userDocId = ref.watch(currentUserDocIdProvider).valueOrNull;
  if (userDocId == null) return;

  ref.listen(
    linkedPlayerForUserProvider(userDocId),
    (previous, next) {
      final teamId = next.valueOrNull?.teamId;
      if (teamId != null && teamId.isNotEmpty) {
        ref.read(activeTeamIdProvider.notifier).state = teamId;
      }
    },
    fireImmediately: true,
  );
});
