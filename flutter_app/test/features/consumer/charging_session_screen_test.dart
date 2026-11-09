import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/big_number.dart';
import 'package:amperly/core/widgets/receipt_rows.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/session_providers.dart';
import 'package:amperly/features/consumer/presentation/charging_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a settled session as a paper receipt with one total', (
    WidgetTester tester,
  ) async {
    final int startMs = DateTime.now()
        .subtract(const Duration(hours: 2))
        .millisecondsSinceEpoch;
    final int endMs = startMs + 35 * 60000;
    final SessionData data = SessionData(
      consumer: const AppUser(id: 'consumer-1'),
      reservation: Reservation(
        id: 'reservation-1',
        consumerId: 'consumer-1',
        stationId: 'station-1',
        stationName: 'Padubidri Service Road Charger',
        portId: 'port-1',
        portLabel: 'Port A · CCS2 · 60 kW',
        bookingCode: 'AMP-7K4Q2M',
        startTimeMs: startMs,
        endTimeMs: endMs,
        status: AmpPolicy.statusCompleted,
      ),
      station: const ChargerStation(
        id: 'station-1',
        hostId: 'host-1',
        name: 'Padubidri Service Road Charger',
        verificationLevel: AmpPolicy.level1VerifiedManual,
        pricePerKwh: 18,
        serviceFee: 5,
        gatewayFee: 4,
      ),
      session: ChargingSession(
        id: 'session-1',
        reservationId: 'reservation-1',
        stationId: 'station-1',
        stationName: 'Padubidri Service Road Charger',
        startTimeMs: startMs,
        endTimeMs: endMs,
        startingMeterKwh: 120.4,
        endingMeterKwh: 132.8,
        verifiedKwhConsumed: 12.4,
        energyCharge: 223.2,
        serviceFee: 5,
        gatewayFee: 4,
        totalPaid: 232.2,
        status: AmpPolicy.statusCompleted,
      ),
      invoice: const Invoice(
        id: 'invoice-1',
        sessionId: 'session-1',
        verifiedKwh: 12.4,
        energyCharge: 223.2,
        serviceFee: 5,
        gatewayFee: 4,
        adjustment: 7.8,
        finalTotal: 240,
        status: AmpPolicy.invoicePaid,
      ),
    );

    tester.view.physicalSize = const Size(460, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionDataProvider('reservation-1').overrideWith(
            (Ref ref) async => RepositorySuccess<SessionData>(data),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const ChargingSessionScreen(reservationId: 'reservation-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Padubidri Service Road Charger'), findsWidgets);
    expect(find.byType(BigNumber), findsOneWidget);
    // The issued invoice, not the session's local arithmetic, owns the total.
    expect(find.text(AmpFormat.rupees(240)), findsOneWidget);
    expect(find.text('-${AmpFormat.rupees(7.8)}'), findsOneWidget);
    expect(find.text(AmpFormat.rupees(232.2)), findsNothing);
    // Booking details plus the two receipt sections: readings and charges.
    expect(find.byType(ReceiptRows), findsNWidgets(3));
    expect(find.text(AmpStrings.receiptStartReading), findsOneWidget);
    expect(find.text(AmpStrings.receiptIssued), findsOneWidget);
    expect(find.text(AmpStrings.sessionInvoicePaid), findsNothing);
    expect(find.text(AmpStrings.sessionNoPayment), findsOneWidget);
    expect(find.text(AmpStrings.sessionHistoryTitle), findsOneWidget);
    expect(find.byType(StatusDotLabel), findsNWidgets(2));
    expect(find.byType(AmpBadge), findsNothing);
  });
}
