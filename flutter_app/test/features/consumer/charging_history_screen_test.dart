import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/departure_row.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/session_providers.dart';
import 'package:amperly/features/consumer/presentation/charging_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders charging history as paper rows', (
    WidgetTester tester,
  ) async {
    final int startMs = DateTime.now()
        .subtract(const Duration(days: 1))
        .millisecondsSinceEpoch;
    final ChargingSession session = ChargingSession(
      id: 'session-1',
      reservationId: 'reservation-1',
      stationName: 'Padubidri Service Road Charger',
      startTimeMs: startMs,
      endTimeMs: startMs + 35 * 60000,
      startingMeterKwh: 120.4,
      endingMeterKwh: 132.8,
      verifiedKwhConsumed: 12.4,
      energyCharge: 223.2,
      serviceFee: 5,
      gatewayFee: 4,
      totalPaid: 232.2,
      status: AmpPolicy.statusCompleted,
    );

    tester.view.physicalSize = const Size(460, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consumerSessionsProvider.overrideWith(
            (Ref ref) async => RepositorySuccess<List<ChargingSession>>(
              <ChargingSession>[session],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const ChargingHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final DateTime start = DateTime.fromMillisecondsSinceEpoch(startMs);
    expect(find.text('Padubidri Service Road Charger'), findsOneWidget);
    expect(find.text(AmpFormat.dayNumber(start)), findsOneWidget);
    expect(find.text(AmpFormat.monthShort(start)), findsOneWidget);
    expect(find.text(AmpFormat.rupees(232.2)), findsOneWidget);
    expect(find.text(AmpStrings.receiptTotal), findsOneWidget);
    expect(find.text(AmpStrings.sessionViewReceipt), findsOneWidget);
    expect(find.byType(DepartureRow), findsOneWidget);
    expect(find.byType(StatusDotLabel), findsOneWidget);
    expect(find.byType(AmpBadge), findsNothing);
  });

  testWidgets('empty history is led by type and a text action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          consumerSessionsProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<List<ChargingSession>>(
              <ChargingSession>[],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const ChargingHistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.sessionHistoryEmptyTitle), findsOneWidget);
    expect(find.text(AmpStrings.bookingFindCharger), findsOneWidget);
    expect(find.byType(DepartureRow), findsNothing);
    expect(find.byType(AmpBadge), findsNothing);
  });
}
