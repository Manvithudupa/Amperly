import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/amp_colors.dart';
import '../app/theme/amp_theme.dart';
import '../core/errors/user_messages.dart';
import '../core/ui/strings.dart';
import '../core/widgets/amp_bottom_bar.dart';
import '../core/widgets/amp_icon.dart';
import '../core/widgets/amp_scaffold.dart';
import '../core/widgets/error_state.dart';
import '../core/widgets/skeleton.dart';
import '../data/models/models.dart';
import '../data/repositories/repository_result.dart';
import '../features/auth/application/app_role.dart';
import '../features/auth/application/profile_providers.dart';
import '../features/auth/presentation/blocked_screen.dart';
import '../features/consumer/presentation/widgets/active_journey_banner.dart';

/// Resolves the profile once for a role shell, keeping blocked and unentitled
/// accounts away from the working surfaces.
class RoleShell extends ConsumerWidget {
  const RoleShell({
    required this.navigationShell,
    required this.role,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final AppRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<AppUser>> profile = ref.watch(
      currentProfileProvider,
    );
    final RepositoryResult<AppUser>? result = profile.asData?.value;

    if (profile.hasError && result == null) {
      return _ShellStatus(
        message: UserMessages.from(profile.error),
        onRetry: () => ref.invalidate(currentProfileProvider),
      );
    }
    final RepositoryFailure<AppUser>? failure = result?.failureOrNull;
    if (failure != null) {
      return _ShellStatus(
        message: failure.message,
        onRetry: () => ref.invalidate(currentProfileProvider),
      );
    }
    final AppUser? user = result?.valueOrNull;
    if (user == null) {
      return const _ShellLoading();
    }
    if (user.isBlocked) {
      return BlockedScreen(profile: user);
    }
    if (!role.isEntitledBy(user)) {
      return const _ShellStatus(
        title: AmpStrings.roleNotAllowedTitle,
        message: AmpStrings.roleNotAllowedBody,
      );
    }

    return AmpShellFrame(
      navigationShell: navigationShell,
      role: role,
      showActiveJourney: role == AppRole.consumer,
    );
  }
}

/// One instance of the bottom navigation for a shell.
///
/// Branch switching uses `goBranch` without resetting the destination, which
/// is what keeps each tab's navigator, scroll position and field state alive.
class AmpShellFrame extends StatelessWidget {
  const AmpShellFrame({
    required this.navigationShell,
    required this.role,
    super.key,
    this.showActiveJourney = false,
  });

  final StatefulNavigationShell navigationShell;
  final AppRole role;
  final bool showActiveJourney;

  @override
  Widget build(BuildContext context) {
    final List<AmpBottomDestination> destinations = switch (role) {
      AppRole.consumer => _consumerDestinations,
      AppRole.host => _hostDestinations,
      AppRole.admin => _adminDestinations,
    };

    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        backgroundColor: context.amp.background,
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showActiveJourney) const ConsumerActiveJourneyBanner(),
            AmpBottomBar(
              destinations: destinations,
              currentIndex: navigationShell.currentIndex,
              onSelected: (int index) {
                if (index == navigationShell.currentIndex) {
                  return;
                }
                navigationShell.goBranch(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}

const List<AmpBottomDestination> _consumerDestinations = <AmpBottomDestination>[
  AmpBottomDestination(
    label: AmpStrings.navDiscover,
    icon: AmpIconName.compass,
  ),
  AmpBottomDestination(label: AmpStrings.navTrips, icon: AmpIconName.route),
  AmpBottomDestination(label: AmpStrings.navBookings, icon: AmpIconName.ticket),
  AmpBottomDestination(label: AmpStrings.navMessages, icon: AmpIconName.chat),
  AmpBottomDestination(label: AmpStrings.navProfile, icon: AmpIconName.user),
];

const List<AmpBottomDestination> _hostDestinations = <AmpBottomDestination>[
  AmpBottomDestination(
    label: AmpStrings.hostTabDashboard,
    icon: AmpIconName.bolt,
  ),
  AmpBottomDestination(
    label: AmpStrings.hostTabStations,
    icon: AmpIconName.plug,
  ),
  AmpBottomDestination(
    label: AmpStrings.hostTabBookings,
    icon: AmpIconName.ticket,
  ),
  AmpBottomDestination(label: AmpStrings.navProfile, icon: AmpIconName.user),
];

const List<AmpBottomDestination> _adminDestinations = <AmpBottomDestination>[
  AmpBottomDestination(label: AmpStrings.adminTabQueue, icon: AmpIconName.list),
  AmpBottomDestination(
    label: AmpStrings.adminTabReports,
    icon: AmpIconName.flag,
  ),
  AmpBottomDestination(label: AmpStrings.navProfile, icon: AmpIconName.user),
];

class _ShellLoading extends StatelessWidget {
  const _ShellLoading();

  @override
  Widget build(BuildContext context) {
    return AmpScaffold(
      title: AmpStrings.appName,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceM,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: const <Widget>[
          SkeletonLine(widthFactor: 0.5),
          SizedBox(height: AmpTheme.spaceL),
          SkeletonLine(widthFactor: 0.74),
          SizedBox(height: 10),
          SkeletonLine(widthFactor: 0.62),
        ],
      ),
    );
  }
}

class _ShellStatus extends StatelessWidget {
  const _ShellStatus({
    required this.message,
    this.title = AmpStrings.appName,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AmpScaffold(
      title: title,
      body: ErrorState(message: message, onRetry: onRetry),
    );
  }
}
