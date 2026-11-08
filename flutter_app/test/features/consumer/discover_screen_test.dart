import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
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
  testWidgets('renders the catalogue with ports, meter status and age', (
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
          home: const DiscoverScreen(profile: AppUser(id: 'account')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nitte Community Charger'), findsOneWidget);
    expect(find.text('Nitte, Karnataka'), findsOneWidget);
    expect(find.text(AmpStrings.portsAvailable(1, 1)), findsOneWidget);
    expect(find.text(AmpStrings.meterMetered), findsOneWidget);
    expect(find.text(AmpStrings.filterDc), findsWidgets);
    expect(find.text(AmpStrings.discoverCount(1)), findsOneWidget);
    expect(find.text(AmpStrings.authSignedInAs), findsNothing);
  });
}
