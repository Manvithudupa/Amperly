import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../domain/engines/route_planner_engine.dart';
import '../../../domain/policy.dart';
import '../../auth/application/profile_providers.dart';
import 'vehicle_providers.dart';

enum DiscoveryFilter { all, compatible, dc, metered }

final class DiscoveryData {
  const DiscoveryData({required this.entries, required this.vehicle});

  final List<StationCatalogueEntry> entries;
  final Vehicle? vehicle;
}

/// Loads the public catalogue and the active vehicle together.
///
/// The repository owns the network; this provider only decides what the screen
/// needs and keeps the active vehicle beside the stations so the compatibility
/// filter cannot drift from the saved profile.
final FutureProvider<RepositoryResult<DiscoveryData>> discoveryProvider =
    FutureProvider<RepositoryResult<DiscoveryData>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return RepositoryFailure<DiscoveryData>(
          kind: profileFailure.kind,
          message: profileFailure.message,
          cause: profileFailure.cause,
        );
      }

      final RepositoryResult<Vehicle?> vehicleResult = await ref.watch(
        activeVehicleProvider.future,
      );
      final RepositoryFailure<Vehicle?>? vehicleFailure =
          vehicleResult.failureOrNull;
      if (vehicleFailure != null) {
        return RepositoryFailure<DiscoveryData>(
          kind: vehicleFailure.kind,
          message: vehicleFailure.message,
          cause: vehicleFailure.cause,
        );
      }

      final StationRepository? repository = ref.watch(
        stationRepositoryProvider,
      );
      if (repository == null) {
        return RepositoryFailure<DiscoveryData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      final RepositoryResult<StationCatalogue> catalogue = await repository
          .catalogue();
      final RepositoryFailure<StationCatalogue>? failure =
          catalogue.failureOrNull;
      if (failure != null) {
        return RepositoryFailure<DiscoveryData>(
          kind: failure.kind,
          message: failure.message,
          cause: failure.cause,
        );
      }

      return RepositorySuccess<DiscoveryData>(
        DiscoveryData(
          entries: catalogue.valueOrNull!.entries,
          vehicle: vehicleResult.valueOrNull,
        ),
      );
    });

/// The chosen filter survives a reload but starts on the complete catalogue.
class DiscoveryFilterController extends Notifier<DiscoveryFilter> {
  @override
  DiscoveryFilter build() => DiscoveryFilter.all;

  void select(DiscoveryFilter filter) => state = filter;
}

final NotifierProvider<DiscoveryFilterController, DiscoveryFilter>
discoveryFilterProvider =
    NotifierProvider<DiscoveryFilterController, DiscoveryFilter>(
      DiscoveryFilterController.new,
    );

List<StationCatalogueEntry> filterStationEntries({
  required List<StationCatalogueEntry> entries,
  required DiscoveryFilter filter,
  required Vehicle? vehicle,
}) {
  return switch (filter) {
    DiscoveryFilter.all => entries,
    DiscoveryFilter.compatible =>
      entries
          .where(
            (StationCatalogueEntry entry) =>
                vehicle != null &&
                RoutePlannerEngine.isConnectorCompatible(
                  entry.station,
                  vehicle,
                ),
          )
          .toList(growable: false),
    DiscoveryFilter.dc =>
      entries
          .where((StationCatalogueEntry entry) => entry.station.isDcCapable)
          .toList(growable: false),
    DiscoveryFilter.metered =>
      entries
          .where(
            (StationCatalogueEntry entry) =>
                entry.station.supportsPaidEnergyBilling,
          )
          .toList(growable: false),
  };
}

int availablePortCount(StationCatalogueEntry entry) {
  return entry.ports
      .where(
        (ChargerPort port) =>
            (port.status ?? '').toUpperCase() == AmpPolicy.portAvailable,
      )
      .length;
}

String availabilityLabel(StationCatalogueEntry entry) {
  if (entry.ports.isEmpty) {
    return AmpStrings.portsNotPublished;
  }
  final int available = availablePortCount(entry);
  if (available == 0) {
    return AmpStrings.noPortsAvailable;
  }
  return AmpStrings.portsAvailable(available, entry.ports.length);
}
