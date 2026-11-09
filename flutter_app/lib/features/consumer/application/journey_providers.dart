import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/journey_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../auth/application/profile_providers.dart';

/// The Supabase-backed store for route plans and battery confirmations.
final Provider<JourneyRepository?> journeyRepositoryProvider =
    Provider<JourneyRepository?>((Ref ref) {
      final SupabaseClient? client = ref.watch(supabaseClientProvider);
      return client == null ? null : JourneyRepository(client);
    });

/// The latest active plan and its stops for the signed-in consumer.
///
/// The Java car layer reads the same rows after its own sync. Trips watches
/// this provider to offer the saved trip after a restart.
final FutureProvider<RepositoryResult<SavedJourney?>> savedJourneyProvider =
    FutureProvider<RepositoryResult<SavedJourney?>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<SavedJourney?>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }

      final JourneyRepository? repository = ref.watch(
        journeyRepositoryProvider,
      );
      if (repository == null) {
        return RepositoryFailure<SavedJourney?>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }
      return repository.activeForConsumer(profile.valueOrNull!.id);
    });
