import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/features/consumer/application/active_journey_provider.dart';
import 'package:amperly/features/consumer/presentation/widgets/active_journey_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('an active session shows its station, energy and open action', (
    WidgetTester tester,
  ) async {
    int opens = 0;
    const ActiveJourney journey = ActiveJourney(
      reservationId: 'reservation-1',
      stationName: 'Udupi City',
      kind: ActiveJourneyKind.charging,
      energyKwh: 12.4,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: Scaffold(
          bottomNavigationBar: ActiveJourneyBanner(
            journey: journey,
            onOpen: () => opens += 1,
          ),
        ),
      ),
    );

    expect(find.text('Charging at Udupi City · 12.4 kWh'), findsOneWidget);
    await tester.tap(find.text(AmpStrings.activeJourneyOpen));
    expect(opens, 1);
  });

  testWidgets('the consumer banner disappears when nothing is active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeJourneyProvider.overrideWith((Ref ref) async => null),
        ],
        child: const MaterialApp(
          home: Scaffold(body: ConsumerActiveJourneyBanner()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ActiveJourneyBanner), findsNothing);
  });
}
