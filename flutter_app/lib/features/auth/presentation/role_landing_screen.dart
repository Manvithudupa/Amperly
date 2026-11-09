import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../application/app_role.dart';
import '../application/profile_providers.dart';
import '../application/role_providers.dart';
import 'blocked_screen.dart';

/// Resolves the account and remembered role once, then opens its home.
///
/// Keeping this outside the shells means a restored session and a fresh
/// sign-in follow the same path, and blocked accounts never see a navigation
/// bar they cannot use.
class RoleLandingScreen extends ConsumerStatefulWidget {
  const RoleLandingScreen({super.key});

  @override
  ConsumerState<RoleLandingScreen> createState() => _RoleLandingScreenState();
}

class _RoleLandingScreenState extends ConsumerState<RoleLandingScreen> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<AppUser>> profile = ref.watch(
      currentProfileProvider,
    );
    final AsyncValue<AppRole?> role = ref.watch(activeRoleProvider);

    final RepositoryResult<AppUser>? result = profile.asData?.value;
    if (profile.hasError && result == null) {
      return AmpScaffold(
        title: AmpStrings.appName,
        body: ErrorState(
          message: UserMessages.from(profile.error),
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      );
    }
    final RepositoryFailure<AppUser>? failure = result?.failureOrNull;
    if (failure != null) {
      return AmpScaffold(
        title: AmpStrings.appName,
        body: ErrorState(
          message: failure.message,
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      );
    }

    final AppUser? user = result?.valueOrNull;
    if (user == null || (!role.hasValue && role.isLoading)) {
      return const _RoleLoading();
    }
    if (user.isBlocked) {
      return BlockedScreen(profile: user);
    }

    final AppRole target = preferredRoleFor(user, role.asData?.value);
    if (!_opened) {
      _opened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(target.homePath);
        }
      });
    }
    return const _RoleLoading();
  }
}

class _RoleLoading extends StatelessWidget {
  const _RoleLoading();

  @override
  Widget build(BuildContext context) {
    return AmpScaffold(
      title: AmpStrings.appName,
      subtitle: AmpStrings.discoverSubtitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceM,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: const <Widget>[
          SkeletonLine(widthFactor: 0.55),
          SizedBox(height: AmpTheme.spaceL),
          SkeletonLine(widthFactor: 0.8),
          SizedBox(height: 10),
          SkeletonLine(widthFactor: 0.65),
          SizedBox(height: AmpTheme.spaceL),
          Hairline(),
          SizedBox(height: AmpTheme.spaceL),
          SkeletonLine(widthFactor: 0.45),
          SizedBox(height: 10),
          SkeletonLine(widthFactor: 0.7),
        ],
      ),
    );
  }
}
