import 'dart:async';

import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/location/device_location.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/geoapify/geoapify_client.dart';
import 'package:amperly/data/geoapify/geoapify_tiles.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/journey_repository.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/data/repositories/station_repository.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/consumer/application/battery_providers.dart';
import 'package:amperly/features/consumer/application/discovery_providers.dart';
import 'package:amperly/features/consumer/application/journey_providers.dart';
import 'package:amperly/features/consumer/application/trip_providers.dart';
import 'package:amperly/features/consumer/presentation/trip_planner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const String _placeFixture = '''
{"features":[
 {"properties":{"place_id":"p1","formatted":"Mangaluru","address_line1":"Mangaluru","lat":12.914,"lon":74.856},
  "geometry":{"coordinates":[74.856,12.914]}}
]}
''';

const String _routeFixture = '''
{"features":[{"properties":{
  "distance":1500,"time":120,
  "legs":[{"steps":[{"distance":1500,"time":120,"from_index":1,
    "instruction":{"text":"Turn left","type":"turn-left"}}]}]
},"geometry":{"type":"LineString","coordinates":[[74.8,13.0],[74.9,13.1]]}}]}
''';

final class _LocatedService implements DeviceLocationService {
  const _LocatedService();

  @override
  Future<DeviceLocationPermission> checkPermission() async =>
      DeviceLocationPermission.granted;

  @override
  Future<DeviceLocationFix> current() async =>
      const DeviceLocationFix.found(13.34, 74.75);

  @override
  Future<bool> openSettings() async => true;
}

final class _BatteryAt extends BatterySocController {
  @override
  int? build() => 80;
}

void main() {
  testWidgets('a second Plan tap waits for the in-flight plan', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(460, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final Completer<void> releaseRoute = Completer<void>();
    final Completer<void> routeStarted = Completer<void>();
    int routeCalls = 0;

    final MockClient geoapify = MockClient((http.Request request) async {
      final String path = request.url.path;
      if (path.contains('/v1/routing')) {
        routeCalls++;
        if (!routeStarted.isCompleted) {
          routeStarted.complete();
        }
        await releaseRoute.future;
        return http.Response(
          _routeFixture,
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }
      return http.Response(
        _placeFixture,
        200,
        headers: <String, String>{'content-type': 'application/json'},
      );
    });
    final GeoapifyClient client = GeoapifyClient(
      apiKey: 'test-key',
      httpClient: geoapify,
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          geoapifyClientProvider.overrideWithValue(client),
          geoapifyMapConfigProvider.overrideWithValue(
            const GeoapifyMapConfig(style: 'osm-bright', apiKey: 'test-key'),
          ),
          discoveryProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<DiscoveryData>(
              DiscoveryData(entries: <StationCatalogueEntry>[], vehicle: null),
            ),
          ),
          savedJourneyProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<SavedJourney?>(null),
          ),
          currentProfileProvider.overrideWith(
            (Ref ref) async =>
                const RepositorySuccess<AppUser>(AppUser(id: 'profile-1')),
          ),
          journeyRepositoryProvider.overrideWithValue(null),
          deviceLocationServiceProvider.overrideWithValue(
            const _LocatedService(),
          ),
          batterySocProvider.overrideWith(_BatteryAt.new),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const TripPlannerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Mangaluru');
    await tester.pump();
    await tester.tap(find.text(AmpStrings.tripPlanAction));
    await tester.tap(find.text(AmpStrings.tripPlanAction));

    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (routeStarted.isCompleted) {
        break;
      }
    }
    expect(routeStarted.isCompleted, isTrue, reason: 'the plan never started');
    await tester.pump(const Duration(milliseconds: 200));

    expect(routeCalls, 1);

    releaseRoute.complete();
    await tester.pumpAndSettle();
  });
}
