import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/session_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ChargerStation metered = ChargerStation(
    id: 'station-1',
    name: 'Test charger',
    verificationLevel: 'LEVEL_2',
  );
  const ChargerStation unmetered = ChargerStation(
    id: 'station-2',
    name: 'Discovery only',
    verificationLevel: 'LEVEL_3',
  );
  const Reservation reserved = Reservation(
    id: 'reservation-1',
    status: AmpPolicy.statusReserved,
  );
  const Reservation cancelled = Reservation(
    id: 'reservation-2',
    status: AmpPolicy.statusCancelled,
  );
  const ChargingSession checkedIn = ChargingSession(
    id: 'session-1',
    status: AmpPolicy.statusCheckedIn,
  );
  const ChargingSession charging = ChargingSession(
    id: 'session-2',
    status: AmpPolicy.statusCharging,
  );
  const ChargingSession completed = ChargingSession(
    id: 'session-3',
    status: AmpPolicy.statusCompleted,
  );

  group('SessionRules gates', () {
    test('only a reserved booking at a metered station can check in', () {
      expect(SessionRules.canOpen(reserved, metered), isTrue);
      expect(SessionRules.canOpen(reserved, unmetered), isFalse);
      expect(SessionRules.canOpen(cancelled, metered), isFalse);
      expect(SessionRules.canOpen(null, metered), isFalse);
      expect(SessionRules.canOpen(reserved, null), isFalse);
    });

    test('charging starts only after check-in and settles only while live', () {
      expect(SessionRules.canStart(checkedIn), isTrue);
      expect(SessionRules.canStart(charging), isFalse);
      expect(SessionRules.canStart(completed), isFalse);
      expect(SessionRules.canSettle(checkedIn), isTrue);
      expect(SessionRules.canSettle(charging), isTrue);
      expect(SessionRules.canSettle(completed), isFalse);
      expect(SessionRules.isCompleted(completed), isTrue);
      expect(SessionRules.isCompleted(charging), isFalse);
    });
  });

  group('meter reading validation', () {
    test('starting reading must be present and non-negative', () {
      expect(
        SessionRules.startReadingError(''),
        AmpStrings.sessionStartReadingRequired,
      );
      expect(
        SessionRules.startReadingError('abc'),
        AmpStrings.sessionStartReadingInvalid,
      );
      expect(
        SessionRules.startReadingError('-1'),
        AmpStrings.sessionStartReadingInvalid,
      );
      expect(SessionRules.startReadingError('125.40'), isNull);
    });

    test('ending reading must be present and at least the start', () {
      expect(
        SessionRules.endReadingError('', 125.40),
        AmpStrings.sessionEndReadingRequired,
      );
      expect(
        SessionRules.endReadingError('not a number', 125.40),
        AmpStrings.sessionEndReadingInvalid,
      );
      expect(
        SessionRules.endReadingError('125.00', 125.40),
        AmpStrings.sessionEndReadingBelowStart,
      );
      expect(SessionRules.endReadingError('125.40', 125.40), isNull);
      expect(SessionRules.endReadingError('180.25', 125.40), isNull);
    });

    test('elapsed time never runs backwards before a session starts', () {
      expect(SessionRules.elapsedMinutes(1000, null, 1000 + 90 * 60000), 90);
      expect(SessionRules.elapsedMinutes(5000, 1000, 9000), 0);
      expect(
        SessionRules.elapsedMinutes(1000, 1000 + 30 * 60000, 999999999),
        30,
      );
    });
  });

  group('SessionRules.serverMessage', () {
    test('maps settlement refusals to written copy', () {
      expect(
        SessionRules.serverMessage(
          Exception('This reservation can no longer be settled.'),
          fallback: 'fallback',
        ),
        AmpStrings.sessionNoLongerSettle,
      );
      expect(
        SessionRules.serverMessage(
          Exception('Station has no verified meter, so it cannot be billed.'),
          fallback: 'fallback',
        ),
        AmpStrings.sessionNoMeter,
      );
      expect(
        SessionRules.serverMessage(
          Exception('Session belongs to a different reservation.'),
          fallback: 'fallback',
        ),
        AmpStrings.sessionMismatch,
      );
      expect(
        SessionRules.serverMessage(
          Exception(
            'The readings do not match the meter evidence recorded by the host.',
          ),
          fallback: 'fallback',
        ),
        AmpStrings.sessionEvidenceMismatch,
      );
      expect(
        SessionRules.serverMessage(
          Exception('NOT_ALLOWED'),
          fallback: 'fallback',
        ),
        AmpStrings.errorPermission,
      );
      expect(
        SessionRules.serverMessage(
          Exception('network down'),
          fallback: 'fallback',
        ),
        'fallback',
      );
    });
  });
}
