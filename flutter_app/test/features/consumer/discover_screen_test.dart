import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_bottom_bar.dart';
import 'package:amperly/core/widgets/amp_button.dart';
import 'package:amperly/core/widgets/port_dots.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/data/repositories/station_repository.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/discovery_providers.dart';
import 'package:amperly/features/consumer/presentation/discover_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders departure rows with ports, status and price', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final DiscoveryData data = DiscoveryData(
      vehicle: const Vehicle(id: 'vehicle', connectorType: 'CCS2'),
      entries: <StationCatalogueEntry>[
        StationCatalogueEntry(
          station: ChargerStation(
            id: 'station-1',
            name: 'Nitte Community Charger',
            address: 'Nitte, Karnataka',
            connectorTypes: 'CCS2',
            isDcCapable: true,
            maxPowerKw: 60,
            pricePerKwh: 18,
            serviceFee: 5,
            gatewayFee: 4,
            verificationLevel: AmpPolicy.level1VerifiedManual,
            lastUpdatedMs: nowMs - 4 * 60000,
          ),
          ports: <ChargerPort>[
            const ChargerPort(
              id: 'port-1',
              stationId: 'station-1',
              portNumber: '1',
              connectorType: 'CCS2',
              powerKw: 60,
              isDc: true,
              status: AmpPolicy.portAvailable,
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          discoveryProvider.overrideWith(
            (Ref ref) async => RepositorySuccess<DiscoveryData>(data),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const DiscoverScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nitte Community Charger'), findsOneWidget);
    expect(find.text('CCS2'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('kW'), findsOneWidget);
    expect(find.text('₹27'), findsOneWidget);
    expect(find.textContaining(AmpStrings.discoverAvailable), findsOneWidget);
    expect(find.text(AmpStrings.discoverSearchHint), findsOneWidget);
    expect(
      find.text(AmpStrings.discoverNearby(1).toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(AmpStrings.filterDc), findsOneWidget);
    expect(find.byType(AmpBottomBar), findsOneWidget);
    expect(find.text(AmpStrings.navTrips), findsOneWidget);
    expect(find.text(AmpStrings.navBookings), findsOneWidget);
    expect(find.text(AmpStrings.navMessages), findsOneWidget);
    expect(find.text(AmpStrings.navProfile), findsOneWidget);

    final PortDots ports = tester.widget<PortDots>(find.byType(PortDots));
    expect(ports.available, 1);
    expect(ports.total, 1);

    // The old tonal navigation row is gone.
    expect(find.byType(AmpButton), findsNothing);
    expect(find.text(AmpStrings.bookingListTitle), findsNothing);
    expect(find.text(AmpStrings.sessionHistoryTitle), findsNothing);
    expect(find.text(AmpStrings.authSignedInAs), findsNothing);
  });
}
