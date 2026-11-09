import '../../../core/ids.dart';
import '../../../data/models/models.dart';
import '../../../domain/engines/route_planner_engine.dart';
import '../../../domain/policy.dart';

/// Converts the shared route engine result into the rows both surfaces read.
///
/// The column names and value shapes mirror the Java RoutePlan and RouteStop
/// entities, so the native car layer can read a plan planned in Flutter.
abstract final class JourneyMapper {
  static const String routeProvider = 'GEOAPIFY';

  static RoutePlan toRoutePlan({
    required RoutePlanResult result,
    required String consumerId,
    required String? vehicleId,
    required String? destinationPlaceId,
    int? nowMs,
  }) {
    final int timestamp = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return RoutePlan(
      id: newId(),
      consumerId: consumerId,
      vehicleId: vehicleId,
      origin: result.origin,
      destination: result.destination,
      originLat: result.originLat,
      originLng: result.originLng,
      destinationLat: result.destinationLat,
      destinationLng: result.destinationLng,
      corridorKm: result.corridorKm,
      preference: result.preference,
      totalDistanceKm: result.totalDistanceKm,
      driveMinutes: result.driveMinutes,
      detourMinutes: result.detourMinutes,
      chargingMinutes: result.chargingMinutes,
      totalJourneyMinutes: result.totalJourneyMinutes,
      plannedStartSoc: result.startSoc,
      arrivalSocTarget: result.arrivalTargetSoc,
      isSocAuthoritative: true,
      assumptions: result.assumptions.join('\n'),
      confidence: result.confidence,
      status: AmpPolicy.routePlanActive,
      routeProvider: routeProvider,
      googlePlaceId: destinationPlaceId,
      createdAtMs: timestamp,
      updatedAtMs: timestamp,
    );
  }

  static List<RouteStop> toRouteStops({
    required String planId,
    required RoutePlanResult result,
  }) {
    return <RouteStop>[
      for (final PlannedStop stop in <PlannedStop>[
        ...result.plannedStops,
        ...result.backups,
      ])
        RouteStop(
          id: stop.id,
          planId: planId,
          sequence: stop.sequence,
          stationId: stop.station.id,
          stationName: stop.station.name,
          isBackup: stop.backup,
          isReachable: stop.reachable,
          distanceAlongRouteKm: stop.distanceAlongRouteKm,
          detourKm: stop.detourKm,
          detourMinutes: stop.detourMinutes,
          arrivalSoc: stop.arrivalSoc,
          departureSoc: stop.departureSoc,
          energyAddedKwh: stop.energyAddedKwh,
          chargingMinutes: stop.chargingMinutes,
          estimatedCost: stop.estimatedCost,
          recommendationReason: stop.recommendationReason,
        ),
    ];
  }
}
