import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../auth/application/profile_providers.dart';

final FutureProvider<RepositoryResult<SafetyData>> safetyDataProvider =
    FutureProvider<RepositoryResult<SafetyData>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<SafetyData>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }
      final SafetyRepository? repository = ref.watch(safetyRepositoryProvider);
      if (repository == null) {
        return RepositoryFailure<SafetyData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }
      return repository.load(profile.valueOrNull!.id);
    });
