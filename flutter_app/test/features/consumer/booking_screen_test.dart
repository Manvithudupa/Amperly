import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/amp_button.dart';
import 'package:amperly/core/widgets/amp_chip.dart';
import 'package:amperly/core/widgets/receipt_rows.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/data/repositories/station_repository.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/booking_providers.dart';
import 'package:amperly/features/consumer/application/booking_rules.dart';
import 'package:amperly/features/consumer/application/vehicle_providers.dart';
import 'package:amperly/features/consumer/presentation/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the paper booking form and enables a free day', (
    WidgetTester tester,
  ) async {
    const Vehicle vehicle = Vehicle(
      id: 'vehicle-1',
      make: 'Tata',
      model: 'Nexon EV',
      connectorType: 'CCS2',
    );
    const ChargerPort port = ChargerPort(
      id: 'port-1',
      stationId: 'station-1',
      portNumber: '1',
      connectorType: 'CCS2',
      powerKw: 60,
      isDc: true,
      status: AmpPolicy.portAvailable,
    );
    final StationBookingData data = StationBookingData(
      entry: StationCatalogueEntry(
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
          approvalStatus: AmpPolicy.approvalApproved,
        ),
        ports: const <ChargerPort>[port],
      ),
      schedules: <AvailabilitySchedule>[
        for (int weekday = 1; weekday <= 7; weekday++)
          AvailabilitySchedule(
            id: 'schedule-$weekday',
            stationId: 'station-1',
            portId: port.id,
            dayOfWeek: weekday,
            openMinutes: 0,
            closeMinutes: 24 * 60,
          ),
      ],
      reservations: const <Reservation>[],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bookingDataProvider('station-1').overrideWith(
            (Ref ref) async => RepositorySuccess<StationBookingData>(data),
          ),
          activeVehicleProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<Vehicle?>(vehicle),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const BookingScreen(stationId: 'station-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nitte Community Charger'), findsOneWidget);
    expect(find.text('Tata Nexon EV'), findsOneWidget);
    expect(find.text(BookingRules.portLabel(port)), findsOneWidget);
    expect(find.text(AmpStrings.bookingReserveAction), findsOneWidget);
    expect(find.byType(AmpBadge), findsNothing);
    expect(find.byType(AmpChip), findsNothing);

    // Today may have no future slots late in the day; tomorrow always does.
    final String tomorrow = AmpFormat.dayLabel(
      DateTime.now().add(const Duration(days: 1)),
    );
    await tester.tap(find.text(tomorrow));
    await tester.pumpAndSettle();

    final AmpButton reserve = tester.widget<AmpButton>(find.byType(AmpButton));
    expect(reserve.onPressed, isNotNull);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byType(ReceiptRows), findsOneWidget);
  });
}
