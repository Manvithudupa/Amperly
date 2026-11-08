import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/features/consumer/application/trip_planner_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a dashboard battery must be a whole number from 0 to 100', () {
    for (final String value in <String>['0', '1', '55', '100', ' 42 ']) {
      expect(
        TripPlannerRules.startSocError(value),
        isNull,
        reason: '$value should be accepted',
      );
    }
    for (final String? value in <String?>[
      null,
      '',
      '   ',
      '-1',
      '101',
      '55.5',
      'forty',
    ]) {
      expect(
        TripPlannerRules.startSocError(value),
        AmpStrings.tripBatteryInvalid,
        reason: '$value should be rejected',
      );
    }
  });

  test('a resolved destination needs no typed text', () {
    expect(TripPlannerRules.destinationError('', resolved: true), isNull);
  });

  test('an unresolved destination needs a searchable place', () {
    for (final String value in <String>['', '  ', 'a', 'ab']) {
      expect(
        TripPlannerRules.destinationError(value, resolved: false),
        AmpStrings.tripDestinationRequired,
        reason: '$value is too short to search',
      );
    }
    expect(TripPlannerRules.destinationError('abc', resolved: false), isNull);
    expect(
      TripPlannerRules.destinationError('  Pune  ', resolved: false),
      isNull,
    );
  });
}
