import 'dart:math' as math;

import '../../core/geo/geo_utils.dart';
import '../repositories/repository_result.dart';

final class GeoPoint {
  const GeoPoint(this.lat, this.lng);

  final double lat;
  final double lng;

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);

  @override
  String toString() => 'GeoPoint($lat, $lng)';
}

final class GeoPlace {
  const GeoPlace({
    required this.placeId,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String placeId;
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  GeoPoint get point => GeoPoint(latitude, longitude);
}

final class RouteStep {
  const RouteStep({
    required this.instruction,
    required this.distanceText,
    required this.durationText,
    required this.maneuver,
    required this.startLat,
    required this.startLng,
  });

  final String instruction;
  final String distanceText;
  final String durationText;
  final String maneuver;
  final double startLat;
  final double startLng;
}

final class DirectionsRoute {
  const DirectionsRoute({
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    required this.durationInTrafficMinutes,
    required this.startAddress,
    required this.endAddress,
    required this.steps,
    required this.approximate,
  });

  final List<GeoPoint> points;
  final double distanceKm;
  final int durationMinutes;
  final int durationInTrafficMinutes;
  final String startAddress;
  final String endAddress;
  final List<RouteStep> steps;
  final bool approximate;

  double get originLat => points.isEmpty ? 0 : points.first.lat;
  double get originLng => points.isEmpty ? 0 : points.first.lng;
  double get destinationLat => points.isEmpty ? 0 : points.last.lat;
  double get destinationLng => points.isEmpty ? 0 : points.last.lng;

  int get effectiveDurationMinutes =>
      durationInTrafficMinutes > 0 ? durationInTrafficMinutes : durationMinutes;

  static DirectionsRoute straightLineEstimate(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
    double speedKmh,
  ) {
    final List<GeoPoint> points = <GeoPoint>[
      for (int i = 0; i <= 32; i++)
        _geodesicPoint(fromLat, fromLng, toLat, toLng, i / 32),
    ];
    final double distanceKm = GeoUtils.distanceKm(
      fromLat,
      fromLng,
      toLat,
      toLng,
    );
    final int minutes = (distanceKm / (speedKmh < 1 ? 1 : speedKmh) * 60)
        .round();
    return DirectionsRoute(
      points: points,
      distanceKm: distanceKm,
      durationMinutes: minutes,
      durationInTrafficMinutes: minutes,
      startAddress: 'Estimated start',
      endAddress: 'Estimated destination',
      steps: <RouteStep>[
        RouteStep(
          instruction:
              'Straight-line estimate — the routing service could not be reached.',
          distanceText: '${distanceKm.toStringAsFixed(1)} km',
          durationText: '$minutes min',
          maneuver: '',
          startLat: fromLat,
          startLng: fromLng,
        ),
      ],
      approximate: true,
    );
  }

  static GeoPoint _geodesicPoint(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
    double fraction,
  ) {
    final double phi1 = _radians(lat1);
    final double lambda1 = _radians(lon1);
    final double phi2 = _radians(lat2);
    final double lambda2 = _radians(lon2);
    final double d =
        2 *
        math.asin(
          math.sqrt(
            math.pow(math.sin((phi2 - phi1) / 2), 2) +
                math.cos(phi1) *
                    math.cos(phi2) *
                    math.pow(math.sin((lambda2 - lambda1) / 2), 2),
          ),
        );
    if (d == 0 || d.isNaN) {
      return GeoPoint(lat1, lon1);
    }
    final double a = math.sin((1 - fraction) * d) / math.sin(d);
    final double b = math.sin(fraction * d) / math.sin(d);
    final double x =
        a * math.cos(phi1) * math.cos(lambda1) +
        b * math.cos(phi2) * math.cos(lambda2);
    final double y =
        a * math.cos(phi1) * math.sin(lambda1) +
        b * math.cos(phi2) * math.sin(lambda2);
    final double z = a * math.sin(phi1) + b * math.sin(phi2);
    return GeoPoint(
      math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi,
      math.atan2(y, x) * 180 / math.pi,
    );
  }

  static double _radians(double value) => value * math.pi / 180;
}

final class GeoapifyException implements Exception, GeoapifyExceptionLike {
  const GeoapifyException(this.technicalMessage, {this.httpStatus});

  final String technicalMessage;

  @override
  final int? httpStatus;

  @override
  String toString() => technicalMessage;
}
