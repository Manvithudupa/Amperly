import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../../auth/application/profile_providers.dart';

/// Every saved vehicle for the signed-in account.
final FutureProvider<RepositoryResult<List<Vehicle>>> vehicleGarageProvider =
    FutureProvider<RepositoryResult<List<Vehicle>>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<List<Vehicle>>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }

      final VehicleRepository? repository = ref.watch(
        vehicleRepositoryProvider,
      );
      if (repository == null) {
        return RepositoryFailure<List<Vehicle>>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      return repository.forUser(profile.valueOrNull!.id);
    });

/// The one vehicle every compatibility check follows, or null when the
/// account has not saved one yet.
final FutureProvider<RepositoryResult<Vehicle?>> activeVehicleProvider =
    FutureProvider<RepositoryResult<Vehicle?>>((Ref ref) async {
      final RepositoryResult<List<Vehicle>> garage = await ref.watch(
        vehicleGarageProvider.future,
      );
      final RepositoryFailure<List<Vehicle>>? failure = garage.failureOrNull;
      if (failure != null) {
        return RepositoryFailure<Vehicle?>(
          kind: failure.kind,
          message: failure.message,
          cause: failure.cause,
        );
      }

      final List<Vehicle> vehicles = garage.valueOrNull!;
      for (final Vehicle vehicle in vehicles) {
        if (vehicle.isActive) {
          return RepositorySuccess<Vehicle?>(vehicle);
        }
      }
      return RepositorySuccess<Vehicle?>(
        vehicles.isEmpty ? null : vehicles.first,
      );
    });
