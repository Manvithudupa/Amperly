import 'package:flutter/material.dart';

import '../ui/strings.dart';
import '../widgets/confirm_dialog.dart';
import 'device_location.dart';

/// Explains why Amperly needs a location before asking the operating system.
///
/// The result is intentionally a [DeviceLocationFix]: the caller only has to
/// handle the same found/denied/unavailable states it already renders. Setting
/// [explainFirst] to false lets a screen check silently at startup; it never
/// opens the system prompt in that mode.
Future<DeviceLocationFix> requestDeviceLocation(
  BuildContext context,
  DeviceLocationService service, {
  bool explainFirst = true,
}) async {
  final DeviceLocationPermission permission = await service.checkPermission();
  switch (permission) {
    case DeviceLocationPermission.servicesDisabled:
      return const DeviceLocationFix.servicesDisabled();
    case DeviceLocationPermission.deniedForever:
      return const DeviceLocationFix.permissionDeniedForever();
    case DeviceLocationPermission.unavailable:
      return const DeviceLocationFix.unavailable();
    case DeviceLocationPermission.denied:
      if (!explainFirst) {
        return const DeviceLocationFix.permissionDenied();
      }
      if (!context.mounted) {
        return const DeviceLocationFix.permissionDenied();
      }
      final bool allow = await showAmpConfirmDialog(
        context,
        title: AmpStrings.locationPermissionTitle,
        message: AmpStrings.locationPermissionBody,
        confirmLabel: AmpStrings.locationPermissionAllow,
        cancelLabel: AmpStrings.locationPermissionNotNow,
        destructive: false,
      );
      if (!allow) {
        return const DeviceLocationFix.permissionDenied();
      }
    case DeviceLocationPermission.granted:
      break;
  }
  return service.current();
}
