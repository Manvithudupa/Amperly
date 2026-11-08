import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/domain/engines/availability_engine.dart';
import 'package:amperly/domain/engines/reservation_engine.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/booking_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ChargerPort ccsPort = ChargerPort(
    id: 'port-ccs',
    portNumber: '1',
    connectorType: 'CCS2',
    powerKw: 60,
    status: AmpPolicy.portAvailable,
  );
  const ChargerPort type2Port = ChargerPort(
    id: 'port-type2',
    portNumber: '2',
    connectorType: 'TYPE_2',
    powerKw: 7.2,
    status: AmpPolicy.portAvailable,
  );
  const ChargerPort busyPort = ChargerPort(
    id: 'port-busy',
    portNumber: '3',
    connectorType: 'CCS2',
    powerKw: 60,
    status: 'OCCUPIED',
  );
  const ChargerStation station = ChargerStation(
    id: 'station-1',
    name: 'Test charger',
    approvalStatus: AmpPolicy.approvalApproved,
    verificationLevel: 'LEVEL_2',
    pricePerKwh: 18,
    serviceFee: 5,
    gatewayFee: 4,
  );
  const Vehicle vehicle = Vehicle(id: 'vehicle-1', connectorType: 'CCS2');

  group('BookingRules.dayStarts', () {
    test('starts at local midnight and covers three consecutive days', () {
      final DateTime now = DateTime(2026, 11, 8, 23, 45);
      final List<int> starts = BookingRules.dayStarts(
        now.millisecondsSinceEpoch,
      );

      expect(starts, hasLength(3));
      final DateTime first = DateTime.fromMillisecondsSinceEpoch(starts.first);
      expect(first, DateTime(2026, 11, 8));
      for (int index = 1; index < starts.length; index++) {
        final DateTime previous = DateTime.fromMillisecondsSinceEpoch(
          starts[index - 1],
        );
        final DateTime current = DateTime.fromMillisecondsSinceEpoch(
          starts[index],
        );
        expect(current.difference(previous), const Duration(days: 1));
      }
    });
  });

  group('BookingRules.availablePorts', () {
    test('keeps only available ports compatible with the active vehicle', () {
      final List<ChargerPort> ports = BookingRules.availablePorts(<ChargerPort>[
        ccsPort,
        type2Port,
        busyPort,
      ], vehicle);

      expect(ports.map((ChargerPort port) => port.id), <String>['port-ccs']);
    });

    test('leaves connector checks open when no vehicle is saved', () {
      final List<ChargerPort> ports = BookingRules.availablePorts(<ChargerPort>[
        ccsPort,
        type2Port,
        busyPort,
      ], null);

      expect(ports.map((ChargerPort port) => port.id), <String>[
        'port-ccs',
        'port-type2',
      ]);
    });
  });

  group('BookingRules.slotsFor', () {
    test('returns only free slots inside the published hours', () {
      final DateTime day = DateTime(2026, 11, 9);
      final int dayStartMs = day.millisecondsSinceEpoch;
      const int slotMs = BookingRules.slotMinutes * 60000;
      final AvailabilitySchedule schedule = AvailabilitySchedule(
        id: 'schedule-1',
        stationId: station.id,
        portId: ccsPort.id,
        dayOfWeek: day.weekday,
        openMinutes: 8 * 60,
        closeMinutes: 20 * 60,
      );

      final List<Slot> slots = BookingRules.slotsFor(
        station: station,
        port: ccsPort,
        schedules: <AvailabilitySchedule>[schedule],
        reservations: const <Reservation>[],
        dayStartMs: dayStartMs,
        nowMs: dayStartMs + 7 * 3600000,
      );

      expect(slots, isNotEmpty);
      for (final Slot slot in slots) {
        expect(slot.available, isTrue);
        expect(slot.portId, ccsPort.id);
        expect(slot.endMs - slot.startMs, slotMs);
        expect(slot.startMs, greaterThanOrEqualTo(dayStartMs + 8 * 3600000));
        expect(slot.endMs, lessThanOrEqualTo(dayStartMs + 20 * 3600000));
      }
    });

    test('drops a slot this account already holds', () {
      final DateTime day = DateTime(2026, 11, 9);
      final int dayStartMs = day.millisecondsSinceEpoch;
      final AvailabilitySchedule schedule = AvailabilitySchedule(
        id: 'schedule-1',
        stationId: station.id,
        portId: ccsPort.id,
        dayOfWeek: day.weekday,
        openMinutes: 8 * 60,
        closeMinutes: 20 * 60,
      );
      final List<Slot> free = BookingRules.slotsFor(
        station: station,
        port: ccsPort,
        schedules: <AvailabilitySchedule>[schedule],
        reservations: const <Reservation>[],
        dayStartMs: dayStartMs,
        nowMs: dayStartMs,
      );
      final Slot first = free.first;
      final Reservation held = Reservation(
        id: 'reservation-1',
        portId: ccsPort.id,
        startTimeMs: first.startMs,
        endTimeMs: first.endMs,
        status: AmpPolicy.statusReserved,
      );

      final List<Slot> after = BookingRules.slotsFor(
        station: station,
        port: ccsPort,
        schedules: <AvailabilitySchedule>[schedule],
        reservations: <Reservation>[held],
        dayStartMs: dayStartMs,
        nowMs: dayStartMs,
      );

      expect(after.any((Slot slot) => slot.startMs == first.startMs), isFalse);
    });
  });

  group('BookingRules price preview', () {
    test('uses the 90 minute slot at 75 percent load', () {
      expect(BookingRules.estimatedKwh(ccsPort), closeTo(67.5, 0.001));

      final PricePreview preview = BookingRules.previewFor(station, ccsPort);
      expect(preview.energyCharge, closeTo(1215, 0.001));
      expect(preview.serviceFee, 5);
      expect(preview.gatewayFee, 4);
      expect(preview.estimatedTotal, closeTo(1224, 0.001));
    });

    test(
      'a station needs a verified meter and a live listing to be bookable',
      () {
        expect(BookingRules.isBookable(station), isTrue);
        expect(
          BookingRules.isBookable(
            station.copyWith(verificationLevel: 'UNVERIFIED'),
          ),
          isFalse,
        );
        expect(
          BookingRules.isBookable(station.copyWith(isPaused: true)),
          isFalse,
        );
      },
    );
  });

  group('BookingRules.refusalMessage', () {
    test('maps server codes to written copy, never the raw code', () {
      expect(
        BookingRules.refusalMessage(
          Exception('SLOT_TAKEN'),
          fallback: 'fallback',
        ),
        AmpStrings.bookingSlotTaken,
      );
      expect(
        BookingRules.refusalMessage(
          Exception('SLOT_IN_PAST'),
          fallback: 'fallback',
        ),
        AmpStrings.bookingSlotPast,
      );
      expect(
        BookingRules.refusalMessage(
          Exception('SLOT_TOO_LONG'),
          fallback: 'fallback',
        ),
        AmpStrings.bookingSlotTooLong,
      );
      expect(
        BookingRules.refusalMessage(
          Exception('STATION_UNAVAILABLE'),
          fallback: 'fallback',
        ),
        AmpStrings.bookingStationUnavailable,
      );
      expect(
        BookingRules.refusalMessage(
          Exception('PORT_UNAVAILABLE'),
          fallback: 'fallback',
        ),
        AmpStrings.bookingPortUnavailable,
      );
      expect(
        BookingRules.refusalMessage(
          Exception('NOT_ALLOWED'),
          fallback: 'fallback',
        ),
        AmpStrings.errorPermission,
      );
      expect(
        BookingRules.refusalMessage(
          Exception('network down'),
          fallback: 'fallback',
        ),
        'fallback',
      );
    });
  });

  group('BookingRules.portLabel', () {
    test('uses plain connector and power copy', () {
      expect(BookingRules.portLabel(ccsPort), 'Port 1 · CCS2 · 60 kW');
    });
  });
}
