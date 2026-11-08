import 'package:amperly/data/models/models.dart';
import 'package:amperly/domain/engines/route_planner_engine.dart';
import 'package:amperly/domain/engines/soc_estimator_engine.dart';
import 'package:amperly/domain/policy.dart';
import 'package:flutter_test/flutter_test.dart';

const double originLat = 12.2958;
const double originLng = 76.6394;
const double destLat = 12.9141;
const double destLng = 74.8560;

Vehicle testVehicle() => const Vehicle(
  id: 'veh_1',
  userId: 'u1',
  make: 'Tata',
  model: 'Nexon EV',
  batteryCapacityKwh: 40.5,
  connectorType: 'CCS_2_DC',
  maxAcKw: 7.2,
  maxDcKw: 30,
  typicalEfficiencyKmPerKwh: 6.5,
  batteryHealthPercent: 96,
  minArrivalSocPercent: 15,
  maxChargeSocPercent: 80,
);

ChargerStation testStation(
  String id,
  String name,
  double lat,
  double lng, {
  String connector = 'CCS_2_DC',
  double power = 60,
  String level = AmpPolicy.level2SimulatedSmartMeter,
}) {
  return ChargerStation(
    id: id,
    hostId: 'host_1',
    name: name,
    address: 'Address',
    latitude: lat,
    longitude: lng,
    pricePerKwh: 18,
    serviceFee: 5,
    gatewayFee: 4,
    verificationLevel: level,
    approvalStatus: AmpPolicy.approvalApproved,
    connectorTypes: connector,
    maxPowerKw: power,
    isDcCapable: true,
    reliabilityScore: 92,
  );
}

List<ChargerStation> corridorStations() => <ChargerStation>[
  testStation('st_highway', 'Highway Hub', 12.600, 75.790),
  testStation('st_slow', 'Roadside DC', 12.605, 75.820, power: 22),
  testStation('st_far', 'Far Away', 13.400, 74.700),
  testStation('st_chademo', 'CHadeMO', 12.604, 75.800, connector: 'CHADEMO'),
];

RoutePlanResult plan({int soc = 55, int measured = 0}) {
  return RoutePlannerEngine.planRoute(
    origin: 'Mysore',
    destination: 'Mangalore',
    originLat: originLat,
    originLng: originLng,
    destinationLat: destLat,
    destinationLng: destLng,
    totalDistanceKm: 140,
    corridorKm: 10,
    startSoc: soc,
    socIsAuthoritative: true,
    socEstimatedFromProfile: false,
    preference: RoutePlannerEngine.prefFastest,
    vehicle: testVehicle(),
    stations: corridorStations(),
    measuredDriveMinutes: measured,
  );
}

void main() {
  test(
    'corridor filtering keeps compatible stations and explains exclusions',
    () {
      final result = plan();
      expect(result.candidates.length, 2);
      expect(
        result.candidates.map((CandidateEvaluation item) => item.station.id),
        containsAll(<String>['st_highway', 'st_slow']),
      );
      expect(result.excluded.length, 2);
      expect(
        result.excluded.map((ExcludedStation item) => item.reason).join(' '),
        contains('CHAdeMO'),
      );
    },
  );

  test('a low battery plans a stop and keeps a safe backup', () {
    final result = plan();
    expect(result.plannedStops, isNotEmpty);
    expect(result.recommendedStop, isNotNull);
    expect(result.recommendedStop!.reachable, isTrue);
    expect(result.recommendedStop!.reason, contains('Detour:'));
    expect(result.recommendedStop!.reason, contains('Estimated charge:'));
    expect(result.backups, isNotEmpty);
    expect(
      result.totalJourneyMinutes,
      result.driveMinutes + result.detourMinutes + result.chargingMinutes,
    );
    expect(result.assumptions.length, greaterThanOrEqualTo(4));
  });

  test(
    'full battery needs no stop and measured time overrides the estimate',
    () {
      final full = plan(soc: 100);
      expect(full.plannedStops, isEmpty);
      expect(full.needsCharging, isFalse);
      expect(full.chargingMinutes, 0);
      expect(full.confidence, RoutePlannerEngine.confidenceHigh);

      final measured = plan(soc: 60, measured: 75);
      expect(measured.driveMinutes, 75);
      expect(measured.assumptions.first, contains('Geoapify'));
      expect(measured.assumptions.first, contains('no live traffic'));
    },
  );

  test('SoC override is authoritative and produces an audit record', () {
    final result = SoCEstimatorEngine.applyAuthoritativeSocOverride(
      vehicleId: 'veh_1',
      tripPlanId: 'plan_1',
      currentEstimatedSoc: 35,
      actualDashboardSoc: 25,
      currentLat: 12.450,
      currentLng: 76.050,
      remainingDistanceKm: 84,
      destinationLat: destLat,
      destinationLng: destLng,
      vehicle: testVehicle(),
      candidateStations: corridorStations(),
      previouslyReachable: <ChargerStation>[corridorStations().first],
    );
    expect(result.wasOverrideApplied, isTrue);
    expect(result.actualDashboardSoc, 25);
    expect(result.auditRecord.estimatedSoc, 35);
    expect(result.auditRecord.actualDashboardSoc, 25);
    expect(result.explanation, contains('Original estimate 35%'));
  });

  test('no safe charger is reported instead of routing beyond range', () {
    final result = SoCEstimatorEngine.applyAuthoritativeSocOverride(
      vehicleId: 'veh_1',
      tripPlanId: 'plan_1',
      currentEstimatedSoc: 35,
      actualDashboardSoc: 6,
      currentLat: originLat,
      currentLng: originLng,
      remainingDistanceKm: 140,
      destinationLat: destLat,
      destinationLng: destLng,
      vehicle: testVehicle(),
      candidateStations: corridorStations(),
      previouslyReachable: const <ChargerStation>[],
    );
    expect(result.noSafeCharger, isTrue);
    expect(result.recommendedNextCharger, isNull);
    expect(result.warningMessage, contains('No safe charger'));
    expect(result.needsWiderRadius, isTrue);
    expect(
      SoCEstimatorEngine.estimateSocAfterDistance(80, 65, testVehicle()),
      lessThan(80),
    );
  });
}
