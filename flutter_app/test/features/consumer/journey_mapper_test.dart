import 'package:amperly/data/models/models.dart';
import 'package:amperly/domain/engines/route_planner_engine.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/journey_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a route result maps to the shared active-plan row and its stops', () {
    const ChargerStation station = ChargerStation(
      id: 'station-1',
      name: 'Udupi City',
      latitude: 13.34,
      longitude: 74.75,
      connectorTypes: 'CCS2',
      maxPowerKw: 60,
    );
    final PlannedStop primary = PlannedStop(
      id: 'stop-primary',
      station: station,
      sequence: 1,
      backup: false,
      reachable: true,
      distanceAlongRouteKm: 80,
      detourKm: 2,
      detourMinutes: 4,
      arrivalSoc: 22,
      departureSoc: 70,
      energyAddedKwh: 24,
      chargingMinutes: 30,
      estimatedCost: 320,
      recommendationReason: 'On the route',
    );
    final PlannedStop backup = PlannedStop(
      id: 'stop-backup',
      station: station,
      sequence: 0,
      backup: true,
      reachable: true,
      distanceAlongRouteKm: 42,
      detourKm: 5,
      detourMinutes: 8,
      arrivalSoc: 45,
      departureSoc: 65,
      energyAddedKwh: 12,
      chargingMinutes: 15,
      estimatedCost: 180,
      recommendationReason: 'Before the recommended stop',
    );
    final RoutePlanResult result = RoutePlanResult(
      origin: 'Mysore',
      destination: 'Mangalore',
      originLat: 12.2958,
      originLng: 76.6394,
      destinationLat: 12.9141,
      destinationLng: 74.856,
      totalDistanceKm: 140,
      corridorKm: 10,
      driveMinutes: 90,
      detourMinutes: 4,
      chargingMinutes: 30,
      totalJourneyMinutes: 124,
      startSoc: 55,
      arrivalTargetSoc: 20,
      preference: RoutePlannerEngine.prefFastest,
      recommendedStop: null,
      candidates: const <CandidateEvaluation>[],
      plannedStops: <PlannedStop>[primary],
      backups: <PlannedStop>[backup],
      excluded: const <ExcludedStation>[],
      assumptions: const <String>['Assumption one', 'Assumption two'],
      confidence: RoutePlannerEngine.confidenceHigh,
      noStopWarning: null,
    );

    final RoutePlan plan = JourneyMapper.toRoutePlan(
      result: result,
      consumerId: 'consumer-1',
      vehicleId: 'vehicle-1',
      destinationPlaceId: 'place-1',
      nowMs: 1730000000000,
    );
    final List<RouteStop> stops = JourneyMapper.toRouteStops(
      planId: plan.id,
      result: result,
    );

    expect(plan.consumerId, 'consumer-1');
    expect(plan.vehicleId, 'vehicle-1');
    expect(plan.origin, 'Mysore');
    expect(plan.destination, 'Mangalore');
    expect(plan.status, AmpPolicy.routePlanActive);
    expect(plan.isSocAuthoritative, isTrue);
    expect(plan.routeProvider, JourneyMapper.routeProvider);
    expect(plan.googlePlaceId, 'place-1');
    expect(plan.assumptions, 'Assumption one\nAssumption two');
    expect(plan.createdAtMs, 1730000000000);
    expect(plan.updatedAtMs, 1730000000000);

    expect(stops, hasLength(2));
    expect(stops.every((RouteStop stop) => stop.planId == plan.id), isTrue);
    expect(stops.first.id, 'stop-primary');
    expect(stops.first.sequence, 1);
    expect(stops.first.stationId, 'station-1');
    expect(stops.first.isBackup, isFalse);
    expect(stops.first.isReachable, isTrue);
    expect(stops.first.arrivalSoc, 22);
    expect(stops.first.energyAddedKwh, 24);
    expect(stops.last.isBackup, isTrue);
  });
}
