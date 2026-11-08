import 'package:geolocator/geolocator.dart';

enum DeviceLocationStatus {
  found,
  permissionDenied,
  servicesDisabled,
  unavailable,
}

/// A position, or the reason there is no usable one.
///
/// There is deliberately no default coordinate. A route planner that silently
/// substitutes a pilot city would be planning from the wrong place.
final class DeviceLocationFix {
  const DeviceLocationFix._({
    required this.status,
    this.latitude = 0,
    this.longitude = 0,
  });

  const DeviceLocationFix.found(double latitude, double longitude)
    : this._(
        status: DeviceLocationStatus.found,
        latitude: latitude,
        longitude: longitude,
      );

  const DeviceLocationFix.permissionDenied()
    : this._(status: DeviceLocationStatus.permissionDenied);

  const DeviceLocationFix.servicesDisabled()
    : this._(status: DeviceLocationStatus.servicesDisabled);

  const DeviceLocationFix.unavailable()
    : this._(status: DeviceLocationStatus.unavailable);

  final DeviceLocationStatus status;
  final double latitude;
  final double longitude;

  bool get hasPosition => status == DeviceLocationStatus.found;
}

abstract interface class DeviceLocationService {
  Future<DeviceLocationFix> current();
}

final class GeolocatorDeviceLocationService implements DeviceLocationService {
  const GeolocatorDeviceLocationService();

  @override
  Future<DeviceLocationFix> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const DeviceLocationFix.servicesDisabled();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const DeviceLocationFix.permissionDenied();
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return DeviceLocationFix.found(position.latitude, position.longitude);
    } on Object {
      return const DeviceLocationFix.unavailable();
    }
  }
}
