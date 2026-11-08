import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import 'session_controller.dart';

/// Resolves the signed-in Auth account to its `public.users` row.
///
/// The database trigger normally creates that row with the account. The
/// fallback insert covers projects created before the trigger and is still
/// constrained by Row Level Security to the caller's own profile.
final FutureProvider<RepositoryResult<AppUser>> currentProfileProvider =
    FutureProvider<RepositoryResult<AppUser>>((Ref ref) async {
      final SessionSnapshot session = ref.watch(sessionProvider);
      final ProfileRepository? repository = ref.watch(
        profileRepositoryProvider,
      );
      if (repository == null || session.userId == null) {
        return RepositoryFailure<AppUser>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }
      return repository.resolveOrCreate(
        authUserId: session.userId!,
        email: session.email,
        fallbackName: session.name,
      );
    });
