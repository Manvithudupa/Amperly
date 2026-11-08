import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/env/app_env.dart';
import '../../../core/location/device_location.dart';
import '../../../data/geoapify/geoapify_client.dart';
import '../../../data/geoapify/geoapify_tiles.dart';

/// The map and route client, or null when this build has no Geoapify key.
///
/// The client is created once and closed with the provider, so route and place
/// caches survive as long as the phone surface does.
final Provider<GeoapifyClient?> geoapifyClientProvider =
    Provider<GeoapifyClient?>((Ref ref) {
      final AppEnv env = ref.watch(appEnvProvider);
      if (!env.hasMapKey) {
        return null;
      }
      final GeoapifyClient client = GeoapifyClient(apiKey: env.geoapifyApiKey);
      ref.onDispose(client.dispose);
      return client;
    });

final Provider<GeoapifyMapConfig?> geoapifyMapConfigProvider =
    Provider<GeoapifyMapConfig?>((Ref ref) {
      final AppEnv env = ref.watch(appEnvProvider);
      return GeoapifyMapConfig.from(
        styleUrl: env.mapStyleUrl,
        apiKey: env.geoapifyApiKey,
      );
    });

final Provider<DeviceLocationService> deviceLocationServiceProvider =
    Provider<DeviceLocationService>(
      (Ref ref) => const GeolocatorDeviceLocationService(),
    );
