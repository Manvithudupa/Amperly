import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/host_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../auth/application/profile_providers.dart';

RepositoryFailure<T> _failure<T>(UserMessageKind kind, String message) =>
    RepositoryFailure<T>(kind: kind, message: message);

/// Everything the host workspace draws, read once per refresh.
final FutureProvider<RepositoryResult<HostWorkspaceData>>
hostWorkspaceProvider = FutureProvider<RepositoryResult<HostWorkspaceData>>((
  Ref ref,
) async {
  final RepositoryResult<AppUser> profile = await ref.watch(
    currentProfileProvider.future,
  );
  final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
  if (profileFailure != null) {
    return RepositoryFailure<HostWorkspaceData>(
      kind: profileFailure.kind,
      message: profileFailure.message,
      cause: profileFailure.cause,
    );
  }

  final AppUser user = profile.valueOrNull!;
  if (!user.canActAsHost) {
    return _failure<HostWorkspaceData>(
      UserMessageKind.permission,
      AmpStrings.blockedBody,
    );
  }
  final HostRepository? repository = ref.watch(hostRepositoryProvider);
  if (repository == null) {
    return _failure<HostWorkspaceData>(
      UserMessageKind.sessionExpired,
      UserMessages.messageFor(UserMessageKind.sessionExpired),
    );
  }
  return repository.workspace(user.id);
});
