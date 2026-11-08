import '../policy.dart';

final class TripTimeBreakdown {
  const TripTimeBreakdown({
    required this.drivingMinutes,
    required this.detourMinutes,
    required this.chargingMinutes,
  });

  final int drivingMinutes;
  final int detourMinutes;
  final int chargingMinutes;

  int get totalJourneyMinutes =>
      drivingMinutes + detourMinutes + chargingMinutes;
}

abstract final class TripTimeEngine {
  static TripTimeBreakdown calculateBreakdown(
    double distanceKm,
    int detourMinutes,
    int chargingMinutes,
  ) {
    final int drivingMinutes = ((distanceKm / AmpPolicy.averageSpeedKmh) * 60)
        .round();
    return TripTimeBreakdown(
      drivingMinutes: drivingMinutes,
      detourMinutes: detourMinutes,
      chargingMinutes: chargingMinutes,
    );
  }
}
