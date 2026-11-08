import '../../core/formatting/plain_format.dart';
import '../../core/geo/geo_utils.dart';
import '../../core/ids.dart';
import '../../data/models/models.dart';
import '../policy.dart';

final class PlannedStop {
  PlannedStop({
    required this.station,
    required this.sequence,
    required this.backup,
    required this.reachable,
    required this.distanceAlongRouteKm,
    required this.detourKm,
    required this.detourMinutes,
    required this.arrivalSoc,
    required this.departureSoc,
    required this.energyAddedKwh,
    required this.chargingMinutes,
    required this.estimatedCost,
    required this.recommendationReason,
    String? id,
  }) : id = id ?? newId();

  final String id;
  final ChargerStation station;
  final int sequence;
  final bool backup;
  final bool reachable;
  final double distanceAlongRouteKm;
  final double detourKm;
  final int detourMinutes;
  final int arrivalSoc;
  final int departureSoc;
  final double energyAddedKwh;
  final int chargingMinutes;
  final double estimatedCost;
  final String recommendationReason;
}

final class CandidateEvaluation {
  const CandidateEvaluation({
    required this.station,
    required this.distanceFromRouteKm,
    required this.distanceAlongRouteKm,
    required this.detourKm,
    required this.detourMinutes,
    required this.arrivalSoc,
    required this.departureSoc,
    required this.arrivalAtDestinationSoc,
    required this.energyAddedKwh,
    required this.chargingMinutes,
    required this.estimatedCost,
    required this.reachable,
    required this.paidBillingAvailable,
    required this.score,
    required this.reason,
  });

  final ChargerStation station;
  final double distanceFromRouteKm;
  final double distanceAlongRouteKm;
  final double detourKm;
  final int detourMinutes;
  final int arrivalSoc;
  final int departureSoc;
  final int arrivalAtDestinationSoc;
  final double energyAddedKwh;
  final int chargingMinutes;
  final double estimatedCost;
  final bool reachable;
  final bool paidBillingAvailable;
  final double score;
  final String reason;
}

final class ExcludedStation {
  const ExcludedStation(this.station, this.reason);

  final ChargerStation station;
  final String reason;
}

final class RoutePlanResult {
  const RoutePlanResult({
    required this.origin,
    required this.destination,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.totalDistanceKm,
    required this.corridorKm,
    required this.driveMinutes,
    required this.detourMinutes,
    required this.chargingMinutes,
    required this.totalJourneyMinutes,
    required this.startSoc,
    required this.arrivalTargetSoc,
    required this.preference,
    required this.recommendedStop,
    required this.candidates,
    required this.plannedStops,
    required this.backups,
    required this.excluded,
    required this.assumptions,
    required this.confidence,
    required this.noStopWarning,
  });

  final String origin;
  final String destination;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final double totalDistanceKm;
  final double corridorKm;
  final int driveMinutes;
  final int detourMinutes;
  final int chargingMinutes;
  final int totalJourneyMinutes;
  final int startSoc;
  final int arrivalTargetSoc;
  final String preference;
  final CandidateEvaluation? recommendedStop;
  final List<CandidateEvaluation> candidates;
  final List<PlannedStop> plannedStops;
  final List<PlannedStop> backups;
  final List<ExcludedStation> excluded;
  final List<String> assumptions;
  final String confidence;
  final String? noStopWarning;

  bool get needsCharging => plannedStops.isNotEmpty;
}

abstract final class RoutePlannerEngine {
  static const String prefFastest = 'FASTEST';
  static const String prefCheapest = 'CHEAPEST';
  static const String prefReliable = 'RELIABLE';
  static const String prefShortestDetour = 'SHORTEST_DETOUR';
  static const String confidenceHigh = 'HIGH';
  static const String confidenceMedium = 'MEDIUM';
  static const String confidenceLow = 'LOW';

  static RoutePlanResult planRoute({
    required String origin,
    required String destination,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double totalDistanceKm,
    required double corridorKm,
    required int startSoc,
    required bool socIsAuthoritative,
    required bool socEstimatedFromProfile,
    required String preference,
    Vehicle? vehicle,
    required List<ChargerStation> stations,
    int measuredDriveMinutes = 0,
  }) {
    final double capacity = vehicle?.effectiveCapacityKwh ?? 40;
    final double efficiency = vehicle?.effectiveEfficiencyKmPerKwh ?? 6.5;
    final int reserve =
        vehicle?.minArrivalSocPercent != null &&
            vehicle!.minArrivalSocPercent > 0
        ? vehicle.minArrivalSocPercent
        : AmpPolicy.defaultMinReserveSocPercent;
    final int maxTarget =
        vehicle?.maxChargeSocPercent != null && vehicle!.maxChargeSocPercent > 0
        ? vehicle.maxChargeSocPercent
        : AmpPolicy.defaultMaxTargetSocPercent;
    int arrivalTarget = (reserve + 5).clamp(reserve, maxTarget);
    if (vehicle != null && vehicle.minArrivalSocPercent > 0) {
      arrivalTarget = (vehicle.minArrivalSocPercent + 5).clamp(0, maxTarget);
    }

    final List<CandidateEvaluation> candidates = <CandidateEvaluation>[];
    final List<ExcludedStation> excluded = <ExcludedStation>[];
    final List<ChargerStation> corridor = <ChargerStation>[];

    for (final ChargerStation station in stations) {
      if (!station.isLiveOnMarketplace) {
        excluded.add(
          ExcludedStation(station, 'Paused or awaiting admin verification'),
        );
        continue;
      }
      final double distanceFromRoute = GeoUtils.distanceToRouteKm(
        station.latitude,
        station.longitude,
        originLat,
        originLng,
        destinationLat,
        destinationLng,
      );
      if (distanceFromRoute > corridorKm) {
        excluded.add(
          ExcludedStation(
            station,
            '${distanceFromRoute.toStringAsFixed(0)} km from the route, '
            'outside the ${corridorKm.toInt()} km corridor — widen the '
            'corridor to include it.',
          ),
        );
        continue;
      }
      if (vehicle != null && !isConnectorCompatible(station, vehicle)) {
        excluded.add(
          ExcludedStation(
            station,
            'Connector ${station.connectorTypeList.map(PlainFormat.connectorLabel).join(', ')} '
            'is not supported by your '
            '${vehicle.make == null ? 'vehicle' : '${vehicle.make} ${vehicle.model}'}',
          ),
        );
        continue;
      }
      corridor.add(station);
      candidates.add(
        _evaluate(
          station: station,
          distanceFromRoute: distanceFromRoute,
          originLat: originLat,
          originLng: originLng,
          destinationLat: destinationLat,
          destinationLng: destinationLng,
          totalDistanceKm: totalDistanceKm,
          startSoc: startSoc,
          capacity: capacity,
          efficiency: efficiency,
          reserve: reserve,
          maxTarget: maxTarget,
          vehicle: vehicle,
          preference: preference,
        ),
      );
    }

    final List<PlannedStop> plannedStops = <PlannedStop>[];
    final List<PlannedStop> backups = <PlannedStop>[];
    String? noStopWarning;

    final List<CandidateEvaluation> ordered = List<CandidateEvaluation>.from(
      candidates,
    )..sort((a, b) => a.distanceAlongRouteKm.compareTo(b.distanceAlongRouteKm));
    final List<CandidateEvaluation> reachableSorted =
        ordered.where((CandidateEvaluation item) => item.reachable).toList()
          ..sort((a, b) => a.score.compareTo(b.score));

    double soc = startSoc.toDouble();
    double distanceCovered = 0;
    for (
      int stopIndex = 0;
      stopIndex < AmpPolicy.maxPlannedStops;
      stopIndex++
    ) {
      final double remainingDistance = totalDistanceKm - distanceCovered;
      final int socAtDestination =
          (soc - drain(remainingDistance, capacity, efficiency)).round();
      if (socAtDestination >= arrivalTarget) {
        break;
      }
      CandidateEvaluation? chosen;
      for (final CandidateEvaluation evaluation in reachableSorted) {
        if (evaluation.distanceAlongRouteKm <= distanceCovered + 1) {
          continue;
        }
        final int socAtCandidate =
            (soc -
                    drain(
                      evaluation.distanceAlongRouteKm - distanceCovered,
                      capacity,
                      efficiency,
                    ))
                .round();
        if (socAtCandidate < reserve) {
          continue;
        }
        if (chosen == null || evaluation.score < chosen.score) {
          chosen = evaluation;
        }
      }
      if (chosen == null) {
        noStopWarning =
            'No compatible charger inside the ${corridorKm.toInt()} km corridor '
            'can be reached before the $reserve% arrival reserve. No charging '
            'stop was planned, and Amperly will not route you beyond the '
            'estimated safe range.';
        break;
      }
      final PlannedStop stop = _toPlannedStop(
        chosen,
        plannedStops.length + 1,
        false,
        soc,
        capacity,
        efficiency,
      );
      plannedStops.add(stop);
      soc = stop.departureSoc.toDouble();
      distanceCovered = stop.distanceAlongRouteKm + stop.detourKm;
    }

    CandidateEvaluation? recommended;
    if (plannedStops.isNotEmpty) {
      recommended = _findCandidate(candidates, plannedStops.first.station.id);
    } else if (reachableSorted.isNotEmpty) {
      recommended = reachableSorted.first;
    } else if (candidates.isNotEmpty) {
      recommended = candidates.first;
    }

    if (recommended != null) {
      backups.addAll(
        _buildBackups(
          reachableSorted,
          recommended.station.id,
          capacity,
          efficiency,
          startSoc,
        ),
      );
    }

    int detourMinutes = 0;
    int chargingMinutes = 0;
    for (final PlannedStop stop in plannedStops) {
      detourMinutes += stop.detourMinutes;
      chargingMinutes += stop.chargingMinutes;
    }
    if (plannedStops.isEmpty && recommended != null && !recommended.reachable) {
      detourMinutes = recommended.detourMinutes;
      chargingMinutes = recommended.chargingMinutes;
    }

    final bool measuredDriveTime = measuredDriveMinutes > 0;
    final int driveMinutes = measuredDriveTime
        ? measuredDriveMinutes
        : ((totalDistanceKm / AmpPolicy.averageSpeedKmh) * 60).round();
    final int totalJourneyMinutes =
        driveMinutes + detourMinutes + chargingMinutes;

    final List<String> assumptions = <String>[
      if (measuredDriveTime)
        'Distance and drive time from Geoapify (OpenStreetMap data) for this '
            'route: ${totalDistanceKm.toStringAsFixed(1)} km, '
            '$measuredDriveMinutes min (no live traffic data).'
      else
        'Distance of ${totalDistanceKm.toStringAsFixed(0)} km at an average '
            '${AmpPolicy.averageSpeedKmh.toInt()} km/h, with no live traffic or weather.',
      'Vehicle efficiency of ${efficiency.toStringAsFixed(1)} km/kWh on a '
          'usable capacity of ${capacity.toStringAsFixed(1)} kWh.',
      'Starting battery $startSoc% '
          '${socIsAuthoritative
              ? '(your dashboard value, treated as authoritative)'
              : socEstimatedFromProfile
              ? '(Amperly estimate from the vehicle profile — you can correct it)'
              : '(entered by you)'}.',
      'Minimum arrival reserve $reserve%, corridor ${corridorKm.toInt()} km.',
      'Charging time assumes 80% of the lower of vehicle and charger peak '
          'power to allow for taper.',
    ];

    final String confidence;
    if (socIsAuthoritative && totalDistanceKm <= 200 && corridor.isNotEmpty) {
      confidence = confidenceHigh;
    } else if (socEstimatedFromProfile && totalDistanceKm > 250) {
      confidence = confidenceLow;
    } else if (corridor.isEmpty) {
      confidence = confidenceLow;
    } else {
      confidence = confidenceMedium;
    }

    return RoutePlanResult(
      origin: origin,
      destination: destination,
      originLat: originLat,
      originLng: originLng,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      totalDistanceKm: totalDistanceKm,
      corridorKm: corridorKm,
      driveMinutes: driveMinutes,
      detourMinutes: detourMinutes,
      chargingMinutes: chargingMinutes,
      totalJourneyMinutes: totalJourneyMinutes,
      startSoc: startSoc,
      arrivalTargetSoc: arrivalTarget,
      preference: preference,
      recommendedStop: recommended,
      candidates: List<CandidateEvaluation>.unmodifiable(candidates),
      plannedStops: List<PlannedStop>.unmodifiable(plannedStops),
      backups: List<PlannedStop>.unmodifiable(backups),
      excluded: List<ExcludedStation>.unmodifiable(excluded),
      assumptions: List<String>.unmodifiable(assumptions),
      confidence: confidence,
      noStopWarning: noStopWarning,
    );
  }

  static CandidateEvaluation _evaluate({
    required ChargerStation station,
    required double distanceFromRoute,
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    required double totalDistanceKm,
    required int startSoc,
    required double capacity,
    required double efficiency,
    required int reserve,
    required int maxTarget,
    required Vehicle? vehicle,
    required String preference,
  }) {
    double fraction = GeoUtils.fractionAlongRoute(
      station.latitude,
      station.longitude,
      originLat,
      originLng,
      destinationLat,
      destinationLng,
    );
    fraction = fraction.clamp(0.05, 1.0);
    final double distanceAlong = totalDistanceKm * fraction;
    final double detourKm = GeoUtils.detourKm(distanceFromRoute);
    final int detourMinutes = GeoUtils.detourMinutes(detourKm);
    final int arrivalSoc = clampSoc(
      (startSoc - drain(distanceAlong, capacity, efficiency)).round(),
    );
    final double distanceAfterCharging =
        (totalDistanceKm - distanceAlong) + detourKm;
    final double drainAfterCharging = drain(
      distanceAfterCharging,
      capacity,
      efficiency,
    );
    final int socNeeded = drainAfterCharging.ceil();
    int targetDeparture = (arrivalSoc + socNeeded).clamp(0, maxTarget);
    targetDeparture =
        targetDeparture <
            (arrivalSoc + AmpPolicy.minimumChargeSocGain).clamp(0, maxTarget)
        ? (arrivalSoc + AmpPolicy.minimumChargeSocGain).clamp(0, maxTarget)
        : targetDeparture;
    targetDeparture = targetDeparture.clamp(0, 100);
    final double energyAdded = ((targetDeparture - arrivalSoc) / 100 * capacity)
        .clamp(0, double.infinity);
    final int chargingMinutes = _chargingMinutes(energyAdded, station, vehicle);
    final int departureSoc = clampSoc(
      (arrivalSoc + (energyAdded / capacity * 100)).round(),
    );
    final int arrivalAtDestination = clampSoc(
      (departureSoc - drainAfterCharging).round(),
    );
    final bool reachable = arrivalSoc >= reserve;
    final bool paidBilling = station.supportsPaidEnergyBilling;
    final double estimatedCost =
        energyAdded * station.pricePerKwh +
        station.serviceFee +
        station.gatewayFee;
    final double score = _score(
      preference: preference,
      detourMinutes: detourMinutes,
      chargingMinutes: chargingMinutes,
      estimatedCost: estimatedCost,
      detourKm: detourKm,
      station: station,
      paidBilling: paidBilling,
      arrivalAtDestination: arrivalAtDestination,
    );
    final String reason =
        'Detour: +${detourKm.toStringAsFixed(1)} km / '
        '+$detourMinutes min\n'
        'Estimated charge: $chargingMinutes min\n'
        'Estimated energy added: ${energyAdded.toStringAsFixed(1)} kWh\n'
        'Expected battery on arrival: $arrivalSoc%\n'
        'Expected battery after charging: $departureSoc%\n'
        'Expected battery at destination: $arrivalAtDestination%'
        '${paidBilling ? '' : '\nNo verified meter: discovery only, no automatic paid billing.'}';

    return CandidateEvaluation(
      station: station,
      distanceFromRouteKm: distanceFromRoute,
      distanceAlongRouteKm: distanceAlong,
      detourKm: detourKm,
      detourMinutes: detourMinutes,
      arrivalSoc: arrivalSoc,
      departureSoc: departureSoc,
      arrivalAtDestinationSoc: arrivalAtDestination,
      energyAddedKwh: energyAdded,
      chargingMinutes: chargingMinutes,
      estimatedCost: estimatedCost,
      reachable: reachable,
      paidBillingAvailable: paidBilling,
      score: score,
      reason: reason,
    );
  }

  static double _score({
    required String preference,
    required int detourMinutes,
    required int chargingMinutes,
    required double estimatedCost,
    required double detourKm,
    required ChargerStation station,
    required bool paidBilling,
    required int arrivalAtDestination,
  }) {
    double base;
    if (preference == prefCheapest) {
      base = estimatedCost + detourKm * 2;
    } else if (preference == prefReliable) {
      base =
          detourMinutes +
          (100 - station.reliabilityScore).clamp(0, 100) * 1.5 +
          station.incidentCount * 8;
    } else if (preference == prefShortestDetour) {
      base = detourKm * 10;
    } else {
      base = detourMinutes + chargingMinutes.toDouble();
    }
    if (!paidBilling) {
      base += 25;
    }
    if (arrivalAtDestination < 0) {
      base += 40;
    }
    return base;
  }

  static int _chargingMinutes(
    double energyAddedKwh,
    ChargerStation station,
    Vehicle? vehicle,
  ) {
    if (energyAddedKwh <= 0.1) {
      return 0;
    }
    final double chargerPower = station.maxPowerKw > 0
        ? station.maxPowerKw
        : 7.2;
    final double vehiclePower = vehicle == null
        ? chargerPower
        : (station.isDcCapable
              ? (vehicle.maxDcKw < 1 ? 1 : vehicle.maxDcKw)
              : (vehicle.maxAcKw < 1 ? 1 : vehicle.maxAcKw));
    final double effectivePower =
        (min(chargerPower, vehiclePower) * AmpPolicy.chargingEfficiencyFactor)
            .clamp(1, double.infinity);
    final int minutes = (energyAddedKwh / effectivePower * 60).ceil();
    return minutes < AmpPolicy.minimumChargingMinutes
        ? AmpPolicy.minimumChargingMinutes
        : minutes;
  }

  static PlannedStop _toPlannedStop(
    CandidateEvaluation evaluation,
    int sequence,
    bool backup,
    double socBefore,
    double capacity,
    double efficiency,
  ) {
    final int arrivalSoc = clampSoc(
      (socBefore - drain(evaluation.distanceAlongRouteKm, capacity, efficiency))
          .round(),
    );
    final double energyAdded =
        ((evaluation.departureSoc - arrivalSoc) / 100 * capacity).clamp(
          0,
          double.infinity,
        );
    return PlannedStop(
      station: evaluation.station,
      sequence: sequence,
      backup: backup,
      reachable: evaluation.reachable,
      distanceAlongRouteKm: evaluation.distanceAlongRouteKm,
      detourKm: evaluation.detourKm,
      detourMinutes: evaluation.detourMinutes,
      arrivalSoc: arrivalSoc,
      departureSoc: evaluation.departureSoc,
      energyAddedKwh: energyAdded,
      chargingMinutes: evaluation.chargingMinutes,
      estimatedCost: evaluation.estimatedCost,
      recommendationReason: evaluation.reason,
    );
  }

  static List<PlannedStop> _buildBackups(
    List<CandidateEvaluation> reachableSorted,
    String chosenStationId,
    double capacity,
    double efficiency,
    int startSoc,
  ) {
    final List<PlannedStop> backups = <PlannedStop>[];
    final CandidateEvaluation? chosen = _findCandidate(
      reachableSorted,
      chosenStationId,
    );
    if (chosen == null) {
      return backups;
    }
    CandidateEvaluation? before;
    CandidateEvaluation? after;
    for (final CandidateEvaluation evaluation in reachableSorted) {
      if (evaluation.station.id == chosenStationId) {
        continue;
      }
      if (evaluation.distanceAlongRouteKm < chosen.distanceAlongRouteKm) {
        if (before == null ||
            evaluation.distanceAlongRouteKm > before.distanceAlongRouteKm) {
          before = evaluation;
        }
      } else if (after == null ||
          evaluation.distanceAlongRouteKm < after.distanceAlongRouteKm) {
        after = evaluation;
      }
    }
    if (before != null) {
      backups.add(
        _toPlannedStop(
          before,
          0,
          true,
          startSoc.toDouble(),
          capacity,
          efficiency,
        ),
      );
    }
    if (after != null) {
      backups.add(
        _toPlannedStop(
          after,
          0,
          true,
          startSoc.toDouble(),
          capacity,
          efficiency,
        ),
      );
    }
    return backups;
  }

  static CandidateEvaluation? _findCandidate(
    List<CandidateEvaluation> values,
    String? stationId,
  ) {
    for (final CandidateEvaluation value in values) {
      if (value.station.id == stationId) {
        return value;
      }
    }
    return null;
  }

  static bool isConnectorCompatible(ChargerStation station, Vehicle? vehicle) {
    if (vehicle == null || vehicle.connectorType == null) {
      return true;
    }
    return station.connectorTypeList.any(
      (String connector) =>
          connector.toLowerCase() == vehicle.connectorType!.toLowerCase(),
    );
  }

  static double drain(double distanceKm, double capacity, double efficiency) {
    if (capacity <= 0 || efficiency <= 0) {
      return 0;
    }
    return ((distanceKm / efficiency) / capacity) * 100;
  }

  static int clampSoc(int soc) => soc.clamp(0, 100);

  static double min(double a, double b) => a < b ? a : b;
}
