import 'package:geolocator/geolocator.dart';

enum DeviceLocationStatus {
  found,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  unavailable,
}

enum DeviceLocationPermission {
  granted,
  denied,
  deniedForever,
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

  const DeviceLocationFix.permissionDeniedForever()
    : this._(status: DeviceLocationStatus.permissionDeniedForever);

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
  /// Reads the current grant without prompting. Startup uses this so the app
  /// never opens a system permission dialog before explaining itself.
  Future<DeviceLocationPermission> checkPermission();

  /// Requests permission when necessary, then reads the position. Callers
  /// should show [requestDeviceLocation] first.
  Future<DeviceLocationFix> current();

  /// Opens this app's system settings page for a permanent denial.
  Future<bool> openSettings();
}

final class GeolocatorDeviceLocationService implements DeviceLocationService {
  const GeolocatorDeviceLocationService();

  @override
  Future<DeviceLocationPermission> checkPermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return DeviceLocationPermission.servicesDisabled;
      }
      final LocationPermission permission = await Geolocator.checkPermission();
      return switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse => DeviceLocationPermission.granted,
        LocationPermission.deniedForever =>
          DeviceLocationPermission.deniedForever,
        LocationPermission.denied ||
        LocationPermission.unableToDetermine => DeviceLocationPermission.denied,
      };
    } on Object {
      return DeviceLocationPermission.unavailable;
    }
  }

  @override
  Future<DeviceLocationFix> current() async {
    try {
      final DeviceLocationPermission current = await checkPermission();
      if (current == DeviceLocationPermission.servicesDisabled) {
        return const DeviceLocationFix.servicesDisabled();
      }
      if (current == DeviceLocationPermission.deniedForever) {
        return const DeviceLocationFix.permissionDeniedForever();
      }
      if (current == DeviceLocationPermission.unavailable) {
        return const DeviceLocationFix.unavailable();
      }

      LocationPermission permission = LocationPermission.denied;
      if (current == DeviceLocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      } else {
        permission = await Geolocator.checkPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationFix.permissionDeniedForever();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
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

  @override
  Future<bool> openSettings() => Geolocator.openAppSettings();
}
