import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../auth/application/profile_providers.dart';

final FutureProvider<RepositoryResult<List<AppNotification>>>
notificationsProvider = FutureProvider<RepositoryResult<List<AppNotification>>>(
  (Ref ref) async {
    final RepositoryResult<AppUser> profile = await ref.watch(
      currentProfileProvider.future,
    );
    final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
    if (profileFailure != null) {
      return RepositoryFailure<List<AppNotification>>(
        kind: profileFailure.kind,
        message: profileFailure.message,
        cause: profileFailure.cause,
      );
    }
    final NotificationRepository? repository = ref.watch(
      notificationRepositoryProvider,
    );
    if (repository == null) {
      return RepositoryFailure<List<AppNotification>>(
        kind: UserMessageKind.sessionExpired,
        message: UserMessages.messageFor(UserMessageKind.sessionExpired),
      );
    }
    return repository.forUser(profile.valueOrNull!.id);
  },
);
