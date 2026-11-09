import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/journey_repository.dart';
import 'package:amperly/features/consumer/presentation/widgets/saved_trip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a saved trip shows its route and offers Resume trip', (
    WidgetTester tester,
  ) async {
    int resumes = 0;
    const RoutePlan plan = RoutePlan(
      id: 'plan-1',
      origin: 'Mysore',
      destination: 'Mangalore',
      totalDistanceKm: 140,
      totalJourneyMinutes: 124,
      plannedStartSoc: 55,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: Scaffold(
          body: SavedTripCard(
            journey: const SavedJourney(plan: plan, stops: <RouteStop>[]),
            onResume: () => resumes += 1,
          ),
        ),
      ),
    );

    expect(find.text(AmpStrings.tripSavedTitle.toUpperCase()), findsOneWidget);
    expect(find.text('Mysore → Mangalore'), findsOneWidget);
    expect(
      find.text(AmpStrings.tripSavedSummary('140 km', '2 h 04 min', 0)),
      findsOneWidget,
    );

    await tester.tap(find.text(AmpStrings.tripResumeAction));
    expect(resumes, 1);
  });
}
