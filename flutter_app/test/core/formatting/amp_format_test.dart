import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/connector_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('money', () {
    test('whole rupees stay whole and part rupees keep paise', () {
      expect(AmpFormat.rupees(18), '₹18');
      expect(AmpFormat.rupees(0), '₹0');
      expect(AmpFormat.rupees(18.5), '₹18.50');
      expect(AmpFormat.rupees(1240.5), '₹1,240.50');
      expect(AmpFormat.rupees(18, showPaise: true), '₹18.00');
    });

    test('a non-finite amount cannot produce a nonsense price', () {
      expect(AmpFormat.rupees(double.nan), '₹0');
    });
  });

  group('energy and distance', () {
    test('energy drops a pointless zero decimal', () {
      expect(AmpFormat.kWh(42.0), '42 kWh');
      expect(AmpFormat.kWh(42.6), '42.6 kWh');
    });

    test('distance is in kilometres', () {
      expect(AmpFormat.km(2.5), '2.5 km');
      expect(AmpFormat.km(12), '12 km');
    });

    test('durations read like a person says them', () {
      expect(AmpFormat.duration(const Duration(minutes: 35)), '35 min');
      expect(AmpFormat.duration(const Duration(minutes: 60)), '1 h');
      expect(AmpFormat.duration(const Duration(minutes: 125)), '2 h 05 min');
    });
  });

  group('freshness', () {
    final DateTime now = DateTime(2026, 11, 7, 12);

    test('never claims a reading is live', () {
      expect(
        AmpFormat.relative(now.subtract(const Duration(seconds: 20)), now: now),
        'just now',
      );
      expect(
        AmpFormat.relative(now.subtract(const Duration(minutes: 1)), now: now),
        '1 min ago',
      );
      expect(
        AmpFormat.relative(now.subtract(const Duration(minutes: 3)), now: now),
        '3 min ago',
      );
      expect(
        AmpFormat.relative(now.subtract(const Duration(hours: 2)), now: now),
        '2 h ago',
      );
      expect(
        AmpFormat.relative(now.subtract(const Duration(days: 1)), now: now),
        '1 day ago',
      );
      expect(
        AmpFormat.relative(now.add(const Duration(minutes: 5)), now: now),
        'just now',
      );
    });
  });

  group('chat timestamps', () {
    final DateTime now = DateTime(2026, 11, 8, 10, 30);

    test('today shows only the clock', () {
      final int stamp = DateTime(2026, 11, 8, 9, 5).millisecondsSinceEpoch;
      expect(AmpFormat.messageTimestamp(stamp, now: now), '9:05 am');
    });

    test('older lines carry their date', () {
      final int stamp = DateTime(2026, 11, 7, 21, 32).millisecondsSinceEpoch;
      final String label = AmpFormat.messageTimestamp(stamp, now: now);
      expect(label, contains('7 Nov'));
      expect(label, contains('9:32 pm'));
    });
  });

  group('stored codes', () {
    test('connector codes become labels and glyph families', () {
      expect(AmpFormat.connectorLabel('TYPE_2_AC'), 'Type 2 AC');
      expect(AmpFormat.connectorLabel('CCS2'), 'CCS2');
      expect(AmpFormat.connectorLabel('CHADEMO'), 'CHAdeMO');
      expect(AmpFormat.connectorKind('TYPE_2_AC'), ConnectorKind.type2);
      expect(AmpFormat.connectorKind('CCS2'), ConnectorKind.ccs2);
      expect(AmpFormat.connectorKind('CHADEMO'), ConnectorKind.chademo);
      expect(AmpFormat.connectorKind(null), ConnectorKind.plug);
    });

    test('status codes become sentence case', () {
      expect(AmpFormat.approvalStatus('PENDING'), 'Pending review');
      expect(
        AmpFormat.meterLevel('LEVEL_3_NO_VERIFIED_METER'),
        'No verified meter',
      );
      expect(AmpFormat.bookingStatus('CHECKED_IN'), 'Checked in');
      expect(AmpFormat.portStatus('MAINTENANCE'), 'Maintenance');
    });
  });
}
