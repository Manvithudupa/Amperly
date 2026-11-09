import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/receipt_rows.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:amperly/core/widgets/ticket_card.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/booking_providers.dart';
import 'package:amperly/features/consumer/presentation/booking_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the confirmed booking as a ticket and receipt', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final Reservation reservation = Reservation(
      id: 'reservation-1',
      stationId: 'station-1',
      stationName: 'Hampankatta Charger Hub',
      portLabel: 'Port 2 · CCS2 · 60 kW',
      bookingCode: 'AMP-D6NAUU',
      startTimeMs: nowMs + 24 * 60 * 60000,
      endTimeMs: nowMs + 25 * 60 * 60000,
      status: AmpPolicy.statusReserved,
      pricePerKwh: 18,
      serviceFee: 5,
      gatewayFee: 4,
    );

    await _pump(tester, reservation);
    final String slot =
        '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs))}, '
        '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}';

    expect(find.text(AmpStrings.bookingSuccessTitle), findsOneWidget);
    expect(find.text('Hampankatta Charger Hub'), findsOneWidget);
    expect(find.text('AMP-D6NAUU'), findsOneWidget);
    expect(
      find.text(AmpStrings.bookingCodeLabel.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('₹18/kWh'), findsOneWidget);
    expect(find.text(AmpStrings.sessionOpenAction), findsOneWidget);
    expect(find.text(AmpStrings.bookingCancelAction), findsOneWidget);
    expect(find.text(AmpStrings.bookingFreeCancellation), findsOneWidget);
    expect(find.byType(TicketCard), findsOneWidget);
    expect(find.byType(ReceiptRows), findsOneWidget);
    expect(find.byType(StatusDotLabel), findsOneWidget);
    expect(find.byType(AmpBadge), findsNothing);
    expect(
      find.bySemanticsLabel(
        AmpStrings.bookingTicketSemantics(
          'AMP-D6NAUU',
          'Hampankatta Charger Hub',
        ),
      ),
      findsOneWidget,
    );
    semantics.dispose();

    final RenderBox ticket = tester.renderObject(find.byType(TicketCard));
    final double tearY =
        ticket.localToGlobal(Offset.zero).dy + ticket.size.height * 0.5;
    expect(tearY, greaterThan(tester.getBottomLeft(find.text(slot)).dy));
    expect(
      tearY,
      lessThan(
        tester
            .getTopLeft(find.text(AmpStrings.bookingCodeLabel.toUpperCase()))
            .dy,
      ),
    );
  });
}

Future<void> _pump(WidgetTester tester, Reservation reservation) async {
  tester.view.physicalSize = const Size(460, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        consumerReservationsProvider.overrideWith(
          (Ref ref) async =>
              RepositorySuccess<List<Reservation>>(<Reservation>[reservation]),
        ),
      ],
      child: MaterialApp(
        theme: AmpTheme.light(),
        home: const BookingCodeScreen(reservationId: 'reservation-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
