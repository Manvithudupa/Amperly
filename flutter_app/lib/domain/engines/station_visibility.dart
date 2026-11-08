import '../../data/models/models.dart';
import '../policy.dart';

abstract final class StationVisibility {
  static bool isPlotable(ChargerStation? station) {
    if (station == null) {
      return false;
    }
    if ((station.approvalStatus ?? '').toUpperCase() !=
        AmpPolicy.approvalApproved) {
      return false;
    }
    if (station.isPaused) {
      return false;
    }
    return hasValidCoordinates(station.latitude, station.longitude);
  }

  static bool hasValidCoordinates(double latitude, double longitude) {
    if (latitude < -90 || latitude > 90) {
      return false;
    }
    if (longitude < -180 || longitude > 180) {
      return false;
    }
    return !(latitude == 0 && longitude == 0);
  }
}
