import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:budiutama_basketball/core/theme/app_breakpoints.dart';
import 'package:budiutama_basketball/core/theme/app_colors.dart';
import 'package:budiutama_basketball/features/auth/domain/providers/auth_provider.dart';
import 'package:budiutama_basketball/features/users/domain/providers/user_provider.dart';
import 'package:budiutama_basketball/shared/models/user_model.dart';

class AppLayout extends ConsumerStatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String role;

  const AppLayout({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.role,
  });

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout> {
  static bool _persistedExpanded = false;
  late bool _isExpanded = _persistedExpanded;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinationsForRole(widget.role);
    final currentUser = ref.watch(currentUserProfileProvider).valueOrNull;
    final safeIndex = destinations.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, destinations.length - 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (AppBreakpoints.isDesktop(width)) {
          return Scaffold(
            body: Row(
              children: [
                _DesktopSidebar(
                  destinations: destinations,
                  selectedIndex: safeIndex,
                  expanded: _isExpanded,
                  role: widget.role,
                  user: currentUser,
                  onLogout: _logout,
                  onToggleExpanded: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      _persistedExpanded = _isExpanded;
                    });
                  },
                  onDestinationSelected: widget.onDestinationSelected,
                ),
                Expanded(child: widget.body),
              ],
            ),
          );
        }

        return Scaffold(
          drawer: _NavigationDrawerContent(
            destinations: destinations,
            selectedIndex: safeIndex,
            role: widget.role,
            user: currentUser,
            onLogout: _logout,
            onDestinationSelected: (index) {
              Navigator.of(context).pop();
              widget.onDestinationSelected(index);
            },
          ),
          body: Stack(
            children: [
              Positioned.fill(child: widget.body),
              _FloatingMenuButton(
                isTablet: AppBreakpoints.isTablet(width),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    ref.read(pendingOtpProvider.notifier).state = null;
    await ref.read(authRepositoryProvider).signOut();
    ref.invalidate(userRoleProvider);
    ref.invalidate(currentUserDocIdProvider);
    ref.invalidate(currentUserUidProvider);
    ref.invalidate(currentUserProfileProvider);
  }

  List<_AppDestination> _destinationsForRole(String role) {
    return [
      if (role == 'coach' || role == 'manager')
        const _AppDestination(
          label: 'Players',
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
        ),
      if (role == 'coach' || role == 'manager' || role == 'player')
        const _AppDestination(
          label: 'Training',
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
        ),
      const _AppDestination(
        label: 'Events',
        icon: Icons.emoji_events_outlined,
        selectedIcon: Icons.emoji_events,
      ),
      if (role == 'coach' || role == 'manager')
        const _AppDestination(
          label: 'Injuries',
          icon: Icons.healing_outlined,
          selectedIcon: Icons.healing,
        ),
      if (role == 'coach' || role == 'manager')
        const _AppDestination(
          label: 'Physical Tests',
          icon: Icons.directions_run_outlined,
          selectedIcon: Icons.directions_run,
        ),
      if (role == 'coach' || role == 'manager' || role == 'player')
        const _AppDestination(
          label: 'Statistics',
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
        ),
      if (role == 'coach' || role == 'manager')
        const _AppDestination(
          label: 'Audit Log',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
        ),
      if (role == 'manager')
        const _AppDestination(
          label: 'Users',
          icon: Icons.manage_accounts_outlined,
          selectedIcon: Icons.manage_accounts,
        ),
    ];
  }
}

class _DesktopSidebar extends StatelessWidget {
  final List<_AppDestination> destinations;
  final int selectedIndex;
  final bool expanded;
  final String role;
  final UserModel? user;
  final VoidCallback onLogout;
  final VoidCallback onToggleExpanded;
  final ValueChanged<int> onDestinationSelected;

  const _DesktopSidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.expanded,
    required this.role,
    required this.user,
    required this.onLogout,
    required this.onToggleExpanded,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: expanded ? 248 : 76,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.borderSoft)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: expanded
                  ? Row(
                      children: [
                        const _BrandMark(),
                        const SizedBox(width: 10),
                        const Expanded(child: _BrandText()),
                        _SidebarIconButton(
                          icon: Icons.keyboard_double_arrow_left,
                          tooltip: 'Collapse menu',
                          onPressed: onToggleExpanded,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const _BrandMark(),
                        const SizedBox(height: 10),
                        _SidebarIconButton(
                          icon: Icons.keyboard_double_arrow_right,
                          tooltip: 'Expand menu',
                          onPressed: onToggleExpanded,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return _NavItem(
                    destination: destination,
                    selected: index == selectedIndex,
                    expanded: expanded,
                    onTap: () => onDestinationSelected(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _AccountCard(
                role: role,
                user: user,
                expanded: expanded,
                onLogout: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDrawerContent extends StatelessWidget {
  final List<_AppDestination> destinations;
  final int selectedIndex;
  final String role;
  final UserModel? user;
  final VoidCallback onLogout;
  final ValueChanged<int> onDestinationSelected;

  const _NavigationDrawerContent({
    required this.destinations,
    required this.selectedIndex,
    required this.role,
    required this.user,
    required this.onLogout,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Row(
                children: [
                  _BrandMark(),
                  SizedBox(width: 12),
                  Expanded(child: _BrandText()),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  return _NavItem(
                    destination: destinations[index],
                    selected: index == selectedIndex,
                    expanded: true,
                    onTap: () => onDestinationSelected(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _AccountCard(
                role: role,
                user: user,
                expanded: true,
                onLogout: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMenuButton extends StatelessWidget {
  final bool isTablet;

  const _FloatingMenuButton({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 10,
      left: isTablet ? 18 : 12,
      child: Builder(
        builder: (buttonContext) => Material(
          color: AppColors.surface,
          elevation: 3,
          shadowColor: AppColors.ink.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          child: IconButton(
            tooltip: 'Open navigation',
            icon: const Icon(Icons.menu_rounded),
            color: AppColors.navy,
            onPressed: () => Scaffold.of(buttonContext).openDrawer(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _AppDestination destination;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  const _NavItem({
    required this.destination,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppColors.navySoft : Colors.transparent;
    final foreground = selected ? AppColors.navy : AppColors.muted;

    return Tooltip(
      message: expanded ? '' : destination.label,
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: expanded ? 12 : 0,
              vertical: 11,
            ),
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: selected ? AppColors.orange : foreground,
                  size: 22,
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.sports_basketball,
        color: AppColors.orange,
        size: 22,
      ),
    );
  }
}

class _BrandText extends StatelessWidget {
  const _BrandText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budi Utama',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Basketball Academy',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SidebarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _SidebarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        iconSize: 18,
        color: AppColors.muted,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final String role;
  final UserModel? user;
  final bool expanded;
  final VoidCallback onLogout;

  const _AccountCard({
    required this.role,
    required this.user,
    required this.expanded,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final roleLabel =
        role.isEmpty ? 'User' : '${role[0].toUpperCase()}${role.substring(1)}';
    final name = user?.fullName.trim();
    final email = user?.email.trim();
    final initials = (name == null || name.isEmpty)
        ? '?'
        : name
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    if (!expanded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.navySoft,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 30,
              height: 30,
              child: IconButton(
                tooltip: 'Logout',
                onPressed: onLogout,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.logout,
                  size: 16,
                  color: AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? 12 : 0,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.navySoft,
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name?.isNotEmpty == true ? name! : roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email?.isNotEmpty == true ? email! : roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout,
              size: 18,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
