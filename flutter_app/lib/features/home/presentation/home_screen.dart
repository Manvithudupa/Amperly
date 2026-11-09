import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../admin/presentation/admin_desk_screen.dart';
import '../../auth/application/profile_providers.dart';
import '../../auth/presentation/blocked_screen.dart';
import '../../consumer/presentation/discover_screen.dart';

/// The signed-in destination.
///
/// It resolves the real `public.users` profile before drawing anything. A
/// restricted profile never reaches discovery, and a failed resolution is a
/// plain retry instead of an empty catalogue that looks like missing data.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<AppUser>> profile = ref.watch(
      currentProfileProvider,
    );

    return profile.when(
      loading: () => const _ProfileLoading(),
      error: (Object error, StackTrace stack) => AmpScaffold(
        title: AmpStrings.appName,
        body: ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
      ),
      data: (RepositoryResult<AppUser> result) {
        final RepositoryFailure<AppUser>? failure = result.failureOrNull;
        if (failure != null) {
          return AmpScaffold(
            title: AmpStrings.appName,
            body: ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(currentProfileProvider),
            ),
          );
        }
        final AppUser user = result.valueOrNull!;
        if (user.isBlocked) {
          return BlockedScreen(profile: user);
        }
        if (user.canActAsAdmin) {
          return const AdminDeskScreen();
        }
        return const DiscoverScreen();
      },
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

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
          ChargerRowSkeleton(),
          ChargerRowSkeleton(),
          ChargerRowSkeleton(),
        ],
      ),
    );
  }
}
