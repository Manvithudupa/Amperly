import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/amp_button.dart';
import 'package:amperly/core/widgets/port_dots.dart';
import 'package:amperly/core/widgets/receipt_rows.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/data/repositories/station_repository.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/station_detail_provider.dart';
import 'package:amperly/features/consumer/presentation/charger_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders charger facts, ports and receipt as paper', (
    WidgetTester tester,
  ) async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final StationCatalogueEntry entry = _entry(
      verificationLevel: AmpPolicy.level1VerifiedManual,
      lastUpdatedMs: nowMs - 3 * 60000,
    );

    await _pump(tester, entry);

    expect(find.text('Nitte Community Charger'), findsOneWidget);
    expect(find.text('Nitte, Karnataka'), findsOneWidget);
    expect(find.text('₹27'), findsOneWidget);
    expect(find.text(AmpStrings.detailsTotal.toUpperCase()), findsOneWidget);
    expect(find.text('CCS2 · 60 kW'), findsNWidgets(2));
    expect(find.text(AmpStrings.bookingReserveAction), findsOneWidget);
    expect(find.byType(AmpButton), findsOneWidget);
    expect(find.byType(PortDots), findsOneWidget);
    expect(find.byType(ReceiptRows), findsOneWidget);
    expect(find.byType(StatusDotLabel), findsWidgets);
    expect(find.byType(AmpBadge), findsNothing);
  });

  testWidgets('hides the reserve action when no verified meter can bill', (
    WidgetTester tester,
  ) async {
    final StationCatalogueEntry entry = _entry(verificationLevel: 'NONE');

    await _pump(tester, entry);

    expect(find.text(AmpStrings.detailsMeterGating), findsOneWidget);
    expect(find.text(AmpStrings.bookingReserveAction), findsNothing);
    expect(find.byType(AmpButton), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, StationCatalogueEntry entry) async {
  tester.view.physicalSize = const Size(460, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        stationDetailProvider('station-1').overrideWith(
          (Ref ref) async => RepositorySuccess<StationCatalogueEntry>(entry),
        ),
      ],
      child: MaterialApp(
        theme: AmpTheme.light(),
        home: const ChargerDetailsScreen(stationId: 'station-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

StationCatalogueEntry _entry({
  required String verificationLevel,
  int lastUpdatedMs = 0,
}) {
  return StationCatalogueEntry(
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
      verificationLevel: verificationLevel,
      lastUpdatedMs: lastUpdatedMs,
      operatingHours: '6 am – 10 pm',
      accessRules: 'Park in the community lot.',
      hostName: 'Nitte Community',
      rating: 4.6,
      reliabilityScore: 92,
    ),
    ports: const <ChargerPort>[
      ChargerPort(
        id: 'port-1',
        stationId: 'station-1',
        portNumber: '1',
        connectorType: 'CCS2',
        powerKw: 60,
        isDc: true,
        status: AmpPolicy.portAvailable,
      ),
      ChargerPort(
        id: 'port-2',
        stationId: 'station-1',
        portNumber: '2',
        connectorType: 'CCS2',
        powerKw: 60,
        isDc: true,
        status: 'OCCUPIED',
      ),
    ],
  );
}
