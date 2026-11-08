import 'dart:math' as math;

import '../../domain/policy.dart';

/// Straight-line geodesy used for corridor filtering and detour estimates.
///
/// These are planning estimates on a sphere, never a road route. The single
/// average-speed source is [AmpPolicy.averageSpeedKmh].
abstract final class GeoUtils {
  static const double earthRadiusKm = 6371.0088;

  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    final double dLat = _radians(lat2 - lat1);
    final double dLng = _radians(lng2 - lng1);
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_radians(lat1)) *
            math.cos(_radians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }

  static double distanceToRouteKm(
    double lat,
    double lng,
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final _Projection projected = _projectFraction(
      lat,
      lng,
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return projected.distanceKm;
  }

  static double fractionAlongRoute(
    double lat,
    double lng,
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return _projectFraction(
      lat,
      lng,
      startLat,
      startLng,
      endLat,
      endLng,
    ).fraction;
  }

  static double detourKm(double distanceFromRouteKm) {
    return (distanceFromRouteKm * 2) + 0.4;
  }

  static int detourMinutes(double detourKm) {
    return ((detourKm / AmpPolicy.averageSpeedKmh) * 60).round();
  }

  static int drivingMinutes(double distanceKm) {
    return ((distanceKm / AmpPolicy.averageSpeedKmh) * 60).round();
  }

  static double bearingDegrees(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final double dLng = _radians(lng2 - lng1);
    final double y = math.sin(dLng) * math.cos(_radians(lat2));
    final double x =
        math.cos(_radians(lat1)) * math.sin(_radians(lat2)) -
        math.sin(_radians(lat1)) * math.cos(_radians(lat2)) * math.cos(dLng);
    final double degrees = _degrees(math.atan2(y, x));
    return (degrees + 360) % 360;
  }

  static String compassLabel(double bearing) {
    const List<String> points = <String>[
      'north',
      'north-east',
      'east',
      'south-east',
      'south',
      'south-west',
      'west',
      'north-west',
    ];
    return points[(bearing / 45).round() % 8];
  }

  static _Projection _projectFraction(
    double lat,
    double lng,
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final double refLat = _radians((startLat + endLat) / 2);
    final double scaleX = math.cos(refLat);
    final double ax = startLng * scaleX;
    final double ay = startLat;
    final double bx = endLng * scaleX;
    final double by = endLat;
    final double px = lng * scaleX;
    final double py = lat;
    final double dx = bx - ax;
    final double dy = by - ay;
    final double lengthSq = dx * dx + dy * dy;
    if (lengthSq <= 0.0000001) {
      return _Projection(0, distanceKm(lat, lng, startLat, startLng));
    }
    double t = ((px - ax) * dx + (py - ay) * dy) / lengthSq;
    t = t.clamp(0.0, 1.0);
    final double projLat = startLat + (endLat - startLat) * t;
    final double projLng = startLng + (endLng - startLng) * t;
    return _Projection(t, distanceKm(lat, lng, projLat, projLng));
  }

  static double _radians(double value) => value * math.pi / 180;

  static double _degrees(double value) => value * 180 / math.pi;
}

final class _Projection {
  const _Projection(this.fraction, this.distanceKm);

  final double fraction;
  final double distanceKm;
}
