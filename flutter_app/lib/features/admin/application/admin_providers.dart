import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../auth/application/profile_providers.dart';

final FutureProvider<RepositoryResult<AdminDeskData>> adminDeskProvider =
    FutureProvider<RepositoryResult<AdminDeskData>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<AdminDeskData>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }

      final AppUser user = profile.valueOrNull!;
      if (!user.canActAsAdmin) {
        return RepositoryFailure<AdminDeskData>(
          kind: UserMessageKind.permission,
          message: AmpStrings.adminNotAllowed,
        );
      }
      final AdminRepository? repository = ref.watch(adminRepositoryProvider);
      if (repository == null) {
        return RepositoryFailure<AdminDeskData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }
      return repository.load();
    });
