import 'package:amperly/data/models/models.dart';
import 'package:amperly/domain/engines/availability_engine.dart';
import 'package:amperly/domain/engines/billing_engine.dart';
import 'package:amperly/domain/engines/enforcement_policy_engine.dart';
import 'package:amperly/domain/engines/host_analytics_engine.dart';
import 'package:amperly/domain/engines/meter_simulator.dart';
import 'package:amperly/domain/engines/reservation_engine.dart';
import 'package:amperly/domain/engines/role_guard.dart';
import 'package:amperly/domain/engines/station_visibility.dart';
import 'package:amperly/domain/engines/trip_time_engine.dart';
import 'package:amperly/domain/policy.dart';
import 'package:flutter_test/flutter_test.dart';

ChargerStation station({
  String id = 'st_1',
  String? connectorTypes = 'CCS_2_DC,TYPE_2_AC',
  double price = 14.4,
  String level = AmpPolicy.level1VerifiedManual,
  String approval = AmpPolicy.approvalApproved,
  bool paused = false,
}) {
  return ChargerStation(
    id: id,
    hostId: 'host_1',
    name: 'Campus Charger',
    address: 'Gate 2',
    latitude: 12.301,
    longitude: 76.645,
    pricePerKwh: price,
    serviceFee: 5,
    gatewayFee: 4,
    verificationLevel: level,
    approvalStatus: approval,
    isPaused: paused,
    connectorTypes: connectorTypes,
    maxPowerKw: 30,
    isDcCapable: true,
    portCount: 2,
    reliabilityScore: 92,
    lastUpdatedMs: 1000,
  );
}

ChargerPort port({
  String id = 'port_1',
  String status = AmpPolicy.portAvailable,
  String connector = 'CCS_2_DC',
}) {
  return ChargerPort(
    id: id,
    stationId: 'st_1',
    portNumber: '1',
    connectorType: connector,
    powerKw: 30,
    isDc: true,
    status: status,
  );
}

Vehicle vehicle() => const Vehicle(
  id: 'veh_1',
  userId: 'cons_1',
  make: 'Tata',
  model: 'Nexon EV',
  batteryCapacityKwh: 40.5,
  connectorType: 'CCS_2_DC',
  maxAcKw: 7.2,
  maxDcKw: 30,
  typicalEfficiencyKmPerKwh: 6.5,
  batteryHealthPercent: 96,
  minArrivalSocPercent: 15,
  maxChargeSocPercent: 80,
  isActive: true,
);

void main() {
  test('billing uses verified meter readings and itemises the bill', () {
    final result = BillingEngine.calculateBill(
      sessionId: 'sess_1',
      consumerId: 'cons_1',
      hostId: 'host_1',
      stationName: 'Campus Charger',
      station: station(),
      meterLevel: AmpPolicy.level1VerifiedManual,
      simulated: true,
      startMeterKwh: 125.40,
      endMeterKwh: 137.90,
    );

    expect(result.valid, isTrue);
    expect(result.verifiedKwh, closeTo(12.5, 0.001));
    expect(result.energyCharge, closeTo(180, 0.001));
    expect(result.finalTotal, closeTo(189, 0.001));
    expect(result.invoice?.status, AmpPolicy.invoiceIssued);
    expect(
      result.lines.any((BillingLine line) => line.label == 'Demo meter'),
      isTrue,
    );
  });

  test(
    'billing rejects invalid numbers, reversed readings and meterless sites',
    () {
      for (final (double start, double end) in <(double, double)>[
        (double.nan, 10),
        (10, double.infinity),
        (-1, 10),
        (10, 9),
      ]) {
        final result = BillingEngine.calculateBill(
          sessionId: 's',
          consumerId: 'c',
          hostId: 'h',
          stationName: 'S',
          station: station(),
          meterLevel: AmpPolicy.level1VerifiedManual,
          simulated: false,
          startMeterKwh: start,
          endMeterKwh: end,
        );
        expect(result.valid, isFalse);
        expect(result.invoice, isNull);
        expect(result.errorMessage, isNotEmpty);
      }

      final noMeter = BillingEngine.calculateBill(
        sessionId: 's',
        consumerId: 'c',
        hostId: 'h',
        stationName: 'S',
        station: station(level: AmpPolicy.level3NoVerifiedMeter),
        meterLevel: AmpPolicy.level3NoVerifiedMeter,
        simulated: false,
        startMeterKwh: 0,
        endMeterKwh: 1,
      );
      expect(noMeter.valid, isFalse);
      expect(noMeter.errorMessage, contains('no verified meter'));
    },
  );

  test(
    'zero energy has no charge and cancellation keeps its published window',
    () {
      final zero = BillingEngine.calculateBill(
        sessionId: 's',
        consumerId: 'c',
        hostId: 'h',
        stationName: 'S',
        station: station(),
        meterLevel: AmpPolicy.level1VerifiedManual,
        simulated: false,
        startMeterKwh: 100,
        endMeterKwh: 100,
      );
      expect(zero.finalTotal, 0);

      final now = DateTime.now().millisecondsSinceEpoch;
      final late = Reservation(
        id: 'r1',
        startTimeMs: now + 30 * 60000,
        endTimeMs: now + 90 * 60000,
      );
      expect(BillingEngine.calculateCancellation(late, now).free, isFalse);
      final later = Reservation(
        id: 'r2',
        startTimeMs: now + 5 * 3600000,
        endTimeMs: now + 6 * 3600000,
      );
      expect(BillingEngine.calculateCancellation(later, now).free, isTrue);
    },
  );

  test('billing rounds every displayed component and never says Paid', () {
    final result = BillingEngine.calculateBill(
      sessionId: 'sess_round',
      consumerId: 'cons_1',
      hostId: 'host_1',
      stationName: 'Campus Charger',
      station: station(),
      meterLevel: AmpPolicy.level1VerifiedManual,
      simulated: false,
      startMeterKwh: 100.1,
      endMeterKwh: 100.3,
    );

    expect(result.valid, isTrue);
    expect(result.verifiedKwh, 0.2);
    expect(result.energyCharge, 2.88);
    expect(result.finalTotal, 11.88);
    expect(result.invoice?.finalTotal, 11.88);
    expect(result.invoice?.status, AmpPolicy.invoiceIssued);
    expect(result.invoice?.status, isNot(AmpPolicy.invoicePaid));
  });

  test('free cancellation ends exactly sixty minutes before the slot', () {
    final DateTime start = DateTime(2026, 11, 9, 12);
    final Reservation reservation = Reservation(
      id: 'r-boundary',
      startTimeMs: start.millisecondsSinceEpoch,
      endTimeMs: start.add(const Duration(hours: 1)).millisecondsSinceEpoch,
    );
    final DateTime windowEdge = start.subtract(const Duration(minutes: 60));

    expect(
      BillingEngine.calculateCancellation(
        reservation,
        windowEdge.millisecondsSinceEpoch,
      ).free,
      isTrue,
    );
    expect(
      BillingEngine.calculateCancellation(
        reservation,
        windowEdge.add(const Duration(milliseconds: 1)).millisecondsSinceEpoch,
      ).free,
      isFalse,
    );
  });

  test(
    'reservation checks double booking, connectors and meterless billing',
    () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final allowed = ReservationEngine.check(
        station: station(),
        port: port(),
        vehicle: vehicle(),
        startMs: now,
        endMs: now + 5400000,
        conflictingReservations: 0,
        stationPaused: false,
      );
      expect(allowed.allowed, isTrue);
      expect(allowed.requiresPaidAuthorization, isTrue);

      final conflict = ReservationEngine.check(
        station: station(),
        port: port(),
        vehicle: vehicle(),
        startMs: now,
        endMs: now + 5400000,
        conflictingReservations: 1,
        stationPaused: false,
      );
      expect(conflict.allowed, isFalse);
      expect(conflict.reason, contains('double booking'));

      final incompatible = ReservationEngine.check(
        station: station(),
        port: port(connector: 'CHADEMO'),
        vehicle: vehicle(),
        startMs: now,
        endMs: now + 5400000,
        conflictingReservations: 0,
        stationPaused: false,
      );
      expect(incompatible.allowed, isFalse);
      expect(incompatible.reason, contains('compatible'));

      final meterless = ReservationEngine.check(
        station: station(level: AmpPolicy.level3NoVerifiedMeter),
        port: port(connector: 'TYPE_2_AC'),
        vehicle: null,
        startMs: now,
        endMs: now + 5400000,
        conflictingReservations: 0,
        stationPaused: false,
      );
      expect(meterless.allowed, isTrue);
      expect(meterless.requiresPaidAuthorization, isFalse);
      expect(meterless.reason, contains('no verified meter'));
    },
  );

  test('booking code is readable, secure-shaped and QR payload is stable', () {
    final String code = ReservationEngine.buildBookingCode();
    expect(ReservationEngine.isValidBookingCode(code), isTrue);
    expect(code.length, 10);
    expect(ReservationEngine.bookingQrPayload(null), contains('unknown'));
    final Reservation reservation = Reservation(
      id: 'r1',
      bookingCode: code,
      stationId: 'st_1',
      portId: 'port_1',
      startTimeMs: 1,
      endTimeMs: 2,
    );
    expect(ReservationEngine.bookingQrPayload(reservation), contains(code));
  });

  test(
    'meter simulator is labelled and rejects reversed or implausible readings',
    () {
      MeterSimulator.reset();
      final start = MeterSimulator.beginSession('st_sim');
      final simulated = MeterSimulator.simulateSession('st_sim', 30, 60);
      expect(simulated.deliveredKwh, greaterThan(20));
      expect(simulated.startReadingKwh, start);
      expect(
        simulated.endReadingKwh,
        closeTo(start + simulated.deliveredKwh, 0.001),
      );
      expect(simulated.simulated, isTrue);
      expect(MeterSimulator.isValidReading(137.9, 125.4), isFalse);
      expect(MeterSimulator.isImplausibleReading(100, 140, 7.2, 30), isTrue);
      expect(MeterSimulator.isImplausibleReading(100, 103, 7.2, 30), isFalse);
    },
  );

  test('enforcement does not punish an unproven accusation and escalates', () {
    final unverified = EnforcementPolicyEngine.forUnverifiedAccusation();
    expect(unverified.action, AmpPolicy.enforcementNone);
    expect(unverified.suspendStation, isFalse);
    expect(
      EnforcementPolicyEngine.decide(1, false, false).freezePayout,
      isTrue,
    );
    expect(
      EnforcementPolicyEngine.decide(1, true, false).action,
      AmpPolicy.enforcementWarning,
    );
    expect(
      EnforcementPolicyEngine.decide(2, true, false).action,
      AmpPolicy.enforcementFine,
    );
    expect(
      EnforcementPolicyEngine.decide(3, true, false).suspendStation,
      isTrue,
    );
    expect(EnforcementPolicyEngine.decide(4, true, false).banStation, isTrue);
    expect(EnforcementPolicyEngine.suggestedSuspensionDays(3), 30);
  });

  test('availability is derived from schedules, ports and reservations', () {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final dayStart = tomorrow.millisecondsSinceEpoch;
    final schedule = AvailabilitySchedule(
      id: 'sch_1',
      portId: 'port_1',
      dayOfWeek: tomorrow.weekday,
      openMinutes: 8 * 60,
      closeMinutes: 20 * 60,
    );
    final slots = AvailabilityEngine.generateSlots(
      station: station(),
      ports: <ChargerPort>[port()],
      schedules: <AvailabilitySchedule>[schedule],
      reservations: const <Reservation>[],
      dayStartMs: dayStart + 9 * 3600000,
      slotMinutes: 90,
      maxSlots: 6,
      nowMs: now.millisecondsSinceEpoch,
    );
    expect(slots, isNotEmpty);
    expect(slots.every((Slot slot) => slot.available), isTrue);
    expect(slots.first.label, isNotEmpty);

    final reservation = Reservation(
      id: 'r1',
      portId: 'port_1',
      startTimeMs: dayStart + 9 * 3600000,
      endTimeMs: dayStart + 10 * 3600000 + 1800000,
      status: AmpPolicy.statusReserved,
    );
    expect(
      AvailabilityEngine.hasConflict(
        <Reservation>[reservation],
        'port_1',
        dayStart + 9 * 3600000,
        dayStart + 10 * 3600000,
      ),
      isTrue,
    );
  });

  test(
    'host analytics counts only finished sessions and labels utilization',
    () {
      final sessions = <ChargingSession>[
        const ChargingSession(
          id: 's1',
          status: AmpPolicy.statusCompleted,
          consumerId: 'c1',
          verifiedKwhConsumed: 10,
          startTimeMs: 0,
          endTimeMs: 3600000,
        ),
        const ChargingSession(
          id: 's2',
          status: AmpPolicy.statusCharging,
          consumerId: 'c1',
          verifiedKwhConsumed: 99,
        ),
      ];
      final analytics = HostAnalyticsEngine.compute(
        sessions: sessions,
        invoices: const <Invoice>[
          Invoice(id: 'i1', finalTotal: 100.5, adjustment: 12.25),
        ],
        reservations: const <Reservation>[
          Reservation(id: 'r1', status: AmpPolicy.statusCancelled),
          Reservation(id: 'r2', status: AmpPolicy.statusReserved),
        ],
      );
      expect(analytics.sessionsCompleted, 1);
      expect(analytics.energyDeliveredKwh, 10);
      expect(analytics.revenue, 100.5);
      expect(analytics.refundsAndAdjustments, 12.25);
      expect(analytics.cancellationRatePercent, 50);
      expect(analytics.utilizationNote, contains('estimated'));
      expect(HostAnalyticsEngine.describe(analytics), contains('Revenue'));
    },
  );

  test('role, visibility and trip-time rules stay pure and honest', () {
    const admin = AppUser(id: 'u1', role: AmpPolicy.roleAdmin);
    const consumer = AppUser(id: 'u2', role: AmpPolicy.roleConsumer);
    const blocked = AppUser(
      id: 'u3',
      role: AmpPolicy.roleAdmin,
      isBlocked: true,
    );
    expect(RoleGuard.canPerformAdminAction(admin), isTrue);
    expect(RoleGuard.canPerformAdminAction(consumer), isFalse);
    expect(RoleGuard.canPerformAdminAction(blocked), isFalse);
    expect(RoleGuard.canManageStation(admin, 'someone'), isTrue);
    expect(RoleGuard.canReservePort(consumer), isTrue);
    expect(RoleGuard.isRestricted(blocked, 0, 0), isTrue);

    expect(StationVisibility.isPlotable(station()), isTrue);
    expect(StationVisibility.isPlotable(station(paused: true)), isFalse);
    expect(StationVisibility.isPlotable(null), isFalse);
    expect(StationVisibility.hasValidCoordinates(0, 0), isFalse);

    final breakdown = TripTimeEngine.calculateBreakdown(120, 10, 25);
    expect(breakdown.drivingMinutes, 160);
    expect(breakdown.totalJourneyMinutes, 195);
  });
}
