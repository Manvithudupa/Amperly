import '../../core/formatting/plain_format.dart';
import '../../core/geo/geo_utils.dart';
import '../../core/ids.dart';
import '../../data/models/models.dart';
import '../policy.dart';
import 'route_planner_engine.dart';

final class SocEstimate {
  const SocEstimate({
    required this.soc,
    required this.fromProfile,
    required this.source,
  });

  final int soc;
  final bool fromProfile;
  final String source;
}

final class RemainingStop {
  const RemainingStop({
    required this.station,
    required this.distanceFromCurrentKm,
    required this.detourKm,
    required this.detourMinutes,
    required this.arrivalSoc,
    required this.departureSoc,
    required this.chargingMinutes,
    required this.energyAddedKwh,
    required this.reachable,
    required this.note,
  });

  final ChargerStation station;
  final double distanceFromCurrentKm;
  final double detourKm;
  final int detourMinutes;
  final int arrivalSoc;
  final int departureSoc;
  final int chargingMinutes;
  final double energyAddedKwh;
  final bool reachable;
  final String note;
}

final class RecalculationResult {
  const RecalculationResult({
    required this.previousEstimatedSoc,
    required this.actualDashboardSoc,
    required this.wasOverrideApplied,
    required this.currentLat,
    required this.currentLng,
    required this.remainingDistanceKm,
    required this.safeReachableStations,
    required this.unreachableStations,
    required this.newlyReachableStations,
    required this.recommendedNextCharger,
    required this.recommendedStop,
    required this.remainingOptions,
    required this.estimatedRangeKm,
    required this.remainingDriveMinutes,
    required this.remainingChargingMinutes,
    required this.remainingJourneyMinutes,
    required this.noSafeCharger,
    required this.warningMessage,
    required this.explanation,
    required this.reservationAdvice,
    required this.needsWiderRadius,
    required this.auditRecord,
  });

  final int previousEstimatedSoc;
  final int actualDashboardSoc;
  final bool wasOverrideApplied;
  final double currentLat;
  final double currentLng;
  final double remainingDistanceKm;
  final List<ChargerStation> safeReachableStations;
  final List<ChargerStation> unreachableStations;
  final List<ChargerStation> newlyReachableStations;
  final ChargerStation? recommendedNextCharger;
  final RemainingStop? recommendedStop;
  final List<RemainingStop> remainingOptions;
  final int estimatedRangeKm;
  final int remainingDriveMinutes;
  final int remainingChargingMinutes;
  final int remainingJourneyMinutes;
  final bool noSafeCharger;
  final String? warningMessage;
  final String explanation;
  final String reservationAdvice;
  final bool needsWiderRadius;
  final BatteryUpdate auditRecord;
}

abstract final class SoCEstimatorEngine {
  static const int defaultReservePercent =
      AmpPolicy.defaultMinReserveSocPercent;

  static int estimateSocAfterDistance(
    int startSoc,
    double distanceKm,
    Vehicle? vehicle,
  ) {
    if (vehicle == null) {
      return (startSoc - (distanceKm / 5).round()).clamp(0, 100);
    }
    final double used = _drain(distanceKm, vehicle);
    return (startSoc - used.round()).clamp(0, 100);
  }

  static SocEstimate estimateStartingSoc(
    Vehicle? vehicle,
    double typicalDailyDistanceKm,
  ) {
    if (vehicle == null) {
      return const SocEstimate(
        soc: 60,
        fromProfile: true,
        source:
            'Amperly estimate: no vehicle profile, using a neutral 60% assumption.',
      );
    }
    final double capacity = vehicle.effectiveCapacityKwh;
    final double efficiency = vehicle.effectiveEfficiencyKmPerKwh;
    final double consumed =
        (typicalDailyDistanceKm < 0 ? 0 : typicalDailyDistanceKm) /
        (efficiency < 1 ? 1 : efficiency);
    final int used = (consumed / capacity * 100).round();
    final int soc = (95 - used).clamp(20, 95);
    return SocEstimate(
      soc: soc,
      fromProfile: true,
      source:
          'Amperly estimate from ${vehicle.make} ${vehicle.model} '
          '(${capacity.toStringAsFixed(1)} kWh usable, '
          '${efficiency.toStringAsFixed(1)} km/kWh) — not a reading from the car.',
    );
  }

  static RecalculationResult applyAuthoritativeSocOverride({
    required String vehicleId,
    required String tripPlanId,
    required int currentEstimatedSoc,
    required int actualDashboardSoc,
    required double currentLat,
    required double currentLng,
    required double remainingDistanceKm,
    required double destinationLat,
    required double destinationLng,
    Vehicle? vehicle,
    required List<ChargerStation> candidateStations,
    List<ChargerStation>? previouslyReachable,
    int reserveOverridePercent = 0,
  }) {
    final int reserve = reserveOverridePercent > 0
        ? reserveOverridePercent
        : vehicle != null && vehicle.minArrivalSocPercent > 0
        ? vehicle.minArrivalSocPercent
        : defaultReservePercent;
    final double capacity = vehicle?.effectiveCapacityKwh ?? 40;
    final double efficiency = vehicle?.effectiveEfficiencyKmPerKwh ?? 6.5;

    final List<ChargerStation> safe = <ChargerStation>[];
    final List<ChargerStation> unreachable = <ChargerStation>[];
    final List<ChargerStation> newlyReachable = <ChargerStation>[];
    final List<RemainingStop> options = <RemainingStop>[];

    for (final ChargerStation station in candidateStations) {
      if (!station.isLiveOnMarketplace) {
        continue;
      }
      if (vehicle != null &&
          !RoutePlannerEngine.isConnectorCompatible(station, vehicle)) {
        continue;
      }
      final double distanceToStation = GeoUtils.distanceKm(
        currentLat,
        currentLng,
        station.latitude,
        station.longitude,
      );
      final double detourKm = GeoUtils.detourKm(distanceToStation);
      final int detourMinutes = GeoUtils.detourMinutes(detourKm);
      final int socUsed = (distanceToStation / efficiency / capacity * 100)
          .round();
      final int arrivalSoc = (actualDashboardSoc - socUsed).clamp(0, 100);
      final int socAfterDestination =
          (actualDashboardSoc -
                  (remainingDistanceKm / efficiency / capacity * 100))
              .round();

      double energyAdded = 0;
      int departureSoc = arrivalSoc;
      int chargingMinutes = 0;
      if (arrivalSoc >= reserve) {
        final int maxCharge =
            vehicle?.maxChargeSocPercent != null &&
                vehicle!.maxChargeSocPercent > 0
            ? vehicle.maxChargeSocPercent
            : AmpPolicy.defaultMaxTargetSocPercent;
        int target = (arrivalSoc + AmpPolicy.minimumChargeSocGain).clamp(
          0,
          maxCharge,
        );
        final int alternativeTarget = (arrivalSoc - socAfterDestination).clamp(
          0,
          maxCharge,
        );
        if (alternativeTarget > target) {
          target = alternativeTarget;
        }
        target = target.clamp(arrivalSoc, 100);
        energyAdded = ((target - arrivalSoc) / 100 * capacity).clamp(
          0,
          double.infinity,
        );
        final double chargerPower = station.maxPowerKw > 0
            ? station.maxPowerKw
            : 7.2;
        final double vehiclePower = vehicle == null
            ? chargerPower
            : (station.isDcCapable
                  ? (vehicle.maxDcKw < 1 ? 1 : vehicle.maxDcKw)
                  : (vehicle.maxAcKw < 1 ? 1 : vehicle.maxAcKw));
        final double effectivePower =
            (chargerPower < vehiclePower ? chargerPower : vehiclePower) *
            AmpPolicy.chargingEfficiencyFactor;
        chargingMinutes = energyAdded <= 0.1
            ? 0
            : ((energyAdded / (effectivePower < 1 ? 1 : effectivePower) * 60)
                      .ceil())
                  .clamp(AmpPolicy.minimumChargingMinutes, 1 << 30);
        departureSoc = (arrivalSoc + (energyAdded / capacity * 100).round())
            .clamp(0, 100);
      }

      final String note;
      if (arrivalSoc >= reserve) {
        safe.add(station);
        note =
            'Safely reachable: $arrivalSoc% on arrival, '
            '$departureSoc% after charging.';
        if (previouslyReachable != null &&
            previouslyReachable.isNotEmpty &&
            !_contains(previouslyReachable, station.id)) {
          newlyReachable.add(station);
        }
      } else {
        unreachable.add(station);
        note =
            'Removed: only $arrivalSoc% would remain on arrival, below the '
            '$reserve% reserve.';
      }
      final RemainingStop stop = RemainingStop(
        station: station,
        distanceFromCurrentKm: distanceToStation,
        detourKm: detourKm,
        detourMinutes: detourMinutes,
        arrivalSoc: arrivalSoc,
        departureSoc: departureSoc,
        chargingMinutes: chargingMinutes,
        energyAddedKwh: energyAdded,
        reachable: arrivalSoc >= reserve,
        note: note,
      );
      if (arrivalSoc >= reserve) {
        options.add(stop);
      }
    }

    options.sort(
      (a, b) => a.distanceFromCurrentKm.compareTo(b.distanceFromCurrentKm),
    );
    final RemainingStop? recommended = options.isEmpty ? null : options.first;
    final int estimatedRangeKm =
        (((actualDashboardSoc - reserve) / 100) * capacity * efficiency)
            .floor()
            .clamp(0, 1 << 30);
    final int remainingDriveMinutes = GeoUtils.drivingMinutes(
      remainingDistanceKm,
    );
    final int remainingChargingMinutes = recommended?.chargingMinutes ?? 0;
    final int remainingJourneyMinutes =
        remainingDriveMinutes +
        (recommended?.detourMinutes ?? 0) +
        remainingChargingMinutes;
    final bool noSafeCharger = options.isEmpty;
    final String? warning = noSafeCharger
        ? 'No safe charger found within the current range '
              '($actualDashboardSoc% battery, $reserve% reserve, about '
              '$estimatedRangeKm km usable). Amperly has not routed you beyond '
              'the estimated safe range.'
        : null;

    final StringBuffer explanation = StringBuffer()
      ..write(
        'Original estimate $currentEstimatedSoc% → your actual '
        '$actualDashboardSoc% → remaining route recalculated from your current location.\n',
      )
      ..write(
        'Previously reachable: ${previouslyReachable?.length ?? 0} charger(s). ',
      )
      ..write('Safely reachable now: ${safe.length}. ');
    if (unreachable.isNotEmpty) {
      explanation.write('Removed: ${unreachable.length}. ');
    }
    if (newlyReachable.isNotEmpty) {
      explanation.write('Newly reachable: ${newlyReachable.length}. ');
    }
    if (recommended != null) {
      explanation.write(
        '\nNearest safe compatible charger: '
        '${recommended.station.name}, '
        '${recommended.distanceFromCurrentKm.toStringAsFixed(1)} km away, '
        '${recommended.detourMinutes}-minute detour.',
      );
    }

    final String reservationAdvice = noSafeCharger
        ? 'Keep any existing reservation only if you can still reach it; '
              'otherwise cancel it free of charge before the 60-minute cut-off.'
        : 'Existing reservations are preserved. '
              '${recommended == null ? '' : 'Consider keeping your booking if ${recommended.station.name} is the same station, or changing it to this closer option.'}';

    return RecalculationResult(
      previousEstimatedSoc: currentEstimatedSoc,
      actualDashboardSoc: actualDashboardSoc,
      wasOverrideApplied: true,
      currentLat: currentLat,
      currentLng: currentLng,
      remainingDistanceKm: remainingDistanceKm,
      safeReachableStations: List<ChargerStation>.unmodifiable(safe),
      unreachableStations: List<ChargerStation>.unmodifiable(unreachable),
      newlyReachableStations: List<ChargerStation>.unmodifiable(newlyReachable),
      recommendedNextCharger: recommended?.station,
      recommendedStop: recommended,
      remainingOptions: List<RemainingStop>.unmodifiable(options),
      estimatedRangeKm: estimatedRangeKm,
      remainingDriveMinutes: remainingDriveMinutes,
      remainingChargingMinutes: remainingChargingMinutes,
      remainingJourneyMinutes: remainingJourneyMinutes,
      noSafeCharger: noSafeCharger,
      warningMessage: warning,
      explanation: explanation.toString(),
      reservationAdvice: reservationAdvice,
      needsWiderRadius: noSafeCharger,
      auditRecord: BatteryUpdate(
        id: newId(),
        vehicleId: vehicleId,
        tripPlanId: tripPlanId,
        estimatedSoc: currentEstimatedSoc,
        actualDashboardSoc: actualDashboardSoc,
        latitude: currentLat,
        longitude: currentLng,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static List<ChargerStation> safeAlternatives(
    List<ChargerStation>? stations,
    int soc,
    double currentLat,
    double currentLng,
    Vehicle? vehicle,
    int maxResults,
  ) {
    if (stations == null || stations.isEmpty) {
      return const <ChargerStation>[];
    }
    final double capacity = vehicle?.effectiveCapacityKwh ?? 40;
    final double efficiency = vehicle?.effectiveEfficiencyKmPerKwh ?? 6.5;
    final int reserve = vehicle != null && vehicle.minArrivalSocPercent > 0
        ? vehicle.minArrivalSocPercent
        : defaultReservePercent;
    final List<ChargerStation> ordered = List<ChargerStation>.from(stations)
      ..sort(
        (a, b) =>
            GeoUtils.distanceKm(
              currentLat,
              currentLng,
              a.latitude,
              a.longitude,
            ).compareTo(
              GeoUtils.distanceKm(
                currentLat,
                currentLng,
                b.latitude,
                b.longitude,
              ),
            ),
      );
    final List<ChargerStation> result = <ChargerStation>[];
    for (final ChargerStation station in ordered) {
      final double distance = GeoUtils.distanceKm(
        currentLat,
        currentLng,
        station.latitude,
        station.longitude,
      );
      final int used = (distance / efficiency / capacity * 100).round();
      if (soc - used >= reserve) {
        result.add(station);
      }
      if (result.length >= maxResults) {
        break;
      }
    }
    return List<ChargerStation>.unmodifiable(result);
  }

  static double _drain(double distanceKm, Vehicle vehicle) {
    return ((distanceKm / vehicle.effectiveEfficiencyKmPerKwh) /
            vehicle.effectiveCapacityKwh) *
        100;
  }

  static bool _contains(List<ChargerStation> stations, String id) =>
      stations.any((ChargerStation station) => station.id == id);

  static String describeExpiry(int expiresAtMs) =>
      PlainFormat.dateTime(expiresAtMs);
}
