import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';

/// The live catalogue row for one charger. The detail screen reads ports and
/// published hours from here instead of trusting a card that may be stale.
final stationDetailProvider =
    FutureProvider.family<RepositoryResult<StationCatalogueEntry>, String>((
      Ref ref,
      String stationId,
    ) async {
      final StationRepository? repository = ref.watch(
        stationRepositoryProvider,
      );
      if (repository == null) {
        return RepositoryFailure<StationCatalogueEntry>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }
      return repository.detail(stationId);
    });
