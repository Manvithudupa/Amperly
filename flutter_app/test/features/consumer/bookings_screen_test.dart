import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/amp_chip.dart';
import 'package:amperly/core/widgets/departure_row.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:amperly/core/widgets/text_action.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/booking_providers.dart';
import 'package:amperly/features/consumer/presentation/bookings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders bookings as paper rows with code and actions', (
    WidgetTester tester,
  ) async {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int startMs = nowMs + 24 * 60 * 60000;
    final Reservation reservation = Reservation(
      id: 'reservation-1',
      stationId: 'station-1',
      stationName: 'Hampankatta Charger Hub',
      portLabel: 'Port 2 · CCS2 · 60 kW',
      bookingCode: 'AMP-D6NAUU',
      startTimeMs: startMs,
      endTimeMs: startMs + 60 * 60000,
      status: AmpPolicy.statusReserved,
      pricePerKwh: 18,
      serviceFee: 5,
      gatewayFee: 4,
    );

    tester.view.physicalSize = const Size(460, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consumerReservationsProvider.overrideWith(
            (Ref ref) async => RepositorySuccess<List<Reservation>>(
              <Reservation>[reservation],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const BookingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final DateTime start = DateTime.fromMillisecondsSinceEpoch(startMs);
    expect(find.text('Hampankatta Charger Hub'), findsOneWidget);
    expect(find.text(AmpFormat.dayNumber(start)), findsOneWidget);
    expect(find.text(AmpFormat.monthShort(start)), findsOneWidget);
    expect(find.textContaining('AMP-D6NAUU'), findsOneWidget);
    expect(find.text('₹18'), findsOneWidget);
    expect(find.text(AmpStrings.perKwh), findsOneWidget);
    expect(find.text(AmpStrings.bookingShowCode), findsOneWidget);
    expect(find.text(AmpStrings.sessionOpenAction), findsOneWidget);
    expect(find.text(AmpStrings.chatMessageHost), findsOneWidget);
    expect(find.text(AmpStrings.bookingViewCharger), findsOneWidget);
    expect(find.text(AmpStrings.bookingNavigateAction), findsOneWidget);
    expect(find.text(AmpStrings.bookingCancelAction), findsOneWidget);
    expect(find.byType(DepartureRow), findsOneWidget);
    expect(find.byType(StatusDotLabel), findsOneWidget);
    expect(find.byType(TextAction), findsNWidgets(6));
    expect(find.byType(AmpBadge), findsNothing);
    expect(find.byType(AmpChip), findsNothing);
  });
}
