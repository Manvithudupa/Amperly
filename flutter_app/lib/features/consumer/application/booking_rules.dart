import '../../../core/formatting/plain_format.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../domain/engines/availability_engine.dart';
import '../../../domain/engines/reservation_engine.dart';
import '../../../domain/policy.dart';

/// Pure rules for the booking screen.
///
/// The server still owns the slot. These helpers only stop the UI from
/// offering a port that is not published as available, a slot outside the
/// host's published hours, or a connector the active car cannot use.
abstract final class BookingRules {
  static const int dayCount = 3;
  static const int slotMinutes = AvailabilityEngine.defaultSlotMinutes;

  static List<int> dayStarts(int nowMs, {int days = dayCount}) {
    final DateTime now = DateTime.fromMillisecondsSinceEpoch(nowMs);
    final DateTime today = DateTime(now.year, now.month, now.day);
    return List<int>.generate(
      days,
      (int index) => today.add(Duration(days: index)).millisecondsSinceEpoch,
      growable: false,
    );
  }

  static List<ChargerPort> availablePorts(
    List<ChargerPort> ports,
    Vehicle? vehicle,
  ) {
    return ports
        .where(
          (ChargerPort port) =>
              (port.status ?? '').toUpperCase() == AmpPolicy.portAvailable &&
              isPortCompatible(port, vehicle),
        )
        .toList(growable: false);
  }

  static bool isPortCompatible(ChargerPort port, Vehicle? vehicle) {
    final String connector = (vehicle?.connectorType ?? '')
        .trim()
        .toUpperCase();
    if (connector.isEmpty) {
      return true;
    }
    final String portConnector = (port.connectorType ?? '')
        .trim()
        .toUpperCase();
    return portConnector == connector;
  }

  static bool hasScheduleForPort(
    List<AvailabilitySchedule> schedules,
    String portId,
  ) {
    return schedules.any(
      (AvailabilitySchedule schedule) =>
          schedule.portId == portId && !schedule.isBlocked,
    );
  }

  /// Free slots for one port on one day. Reservations are only the caller's own
  /// rows, so the server's per-port lock remains the final authority.
  static List<Slot> slotsFor({
    required ChargerStation station,
    required ChargerPort port,
    required List<AvailabilitySchedule> schedules,
    required List<Reservation> reservations,
    required int dayStartMs,
    required int nowMs,
  }) {
    return AvailabilityEngine.generateSlots(
      station: station,
      ports: <ChargerPort>[port],
      schedules: schedules,
      reservations: reservations,
      dayStartMs: dayStartMs,
      slotMinutes: slotMinutes,
      maxSlots: 16,
      nowMs: nowMs,
    ).where((Slot slot) => slot.available).toList(growable: false);
  }

  /// The first day in [dayStarts] with at least one free slot.
  ///
  /// Keeps the default selection on "next free" rather than "today" when
  /// today's published hours have passed or every slot is already taken.
  static int firstDayWithSlots({
    required ChargerStation station,
    required ChargerPort port,
    required List<AvailabilitySchedule> schedules,
    required List<Reservation> reservations,
    required List<int> dayStarts,
    required int nowMs,
  }) {
    for (int index = 0; index < dayStarts.length; index++) {
      final List<Slot> slots = slotsFor(
        station: station,
        port: port,
        schedules: schedules,
        reservations: reservations,
        dayStartMs: dayStarts[index],
        nowMs: nowMs,
      );
      if (slots.isNotEmpty) {
        return index;
      }
    }
    return 0;
  }

  static int conflictCount(
    List<Reservation> reservations,
    String portId,
    int startMs,
    int endMs,
  ) {
    return AvailabilityEngine.hasConflict(reservations, portId, startMs, endMs)
        ? 1
        : 0;
  }

  static double estimatedKwh(ChargerPort port) {
    final double powerKw = port.powerKw > 0 ? port.powerKw : 0;
    return powerKw * (slotMinutes / 60) * 0.75;
  }

  static PricePreview previewFor(ChargerStation station, ChargerPort port) {
    return ReservationEngine.preview(station, estimatedKwh(port));
  }

  static String portLabel(ChargerPort port) {
    final String number = (port.portNumber ?? '').trim();
    final String connector = PlainFormat.connectorLabel(port.connectorType);
    final String power = port.powerKw > 0
        ? '${port.powerKw.toInt()} kW'
        : AmpStrings.powerNotPublished;
    return 'Port ${number.isEmpty ? '?' : number} · '
        '${connector.isEmpty ? AmpStrings.connectorNotPublished : connector} · '
        '$power';
  }

  static bool isBookable(ChargerStation station) {
    return station.isLiveOnMarketplace && station.supportsPaidEnergyBilling;
  }

  /// Maps a server refusal to written copy without exposing its raw text.
  static String refusalMessage(Object? cause, {required String fallback}) {
    final String text = (cause?.toString() ?? '').toLowerCase();
    if (text.contains('slot_taken') ||
        text.contains('slot taken') ||
        text.contains('reservation_conflict')) {
      return AmpStrings.bookingSlotTaken;
    }
    if (text.contains('slot_in_past') || text.contains('slot in past')) {
      return AmpStrings.bookingSlotPast;
    }
    if (text.contains('slot_too_long') || text.contains('slot too long')) {
      return AmpStrings.bookingSlotTooLong;
    }
    if (text.contains('station_unavailable') ||
        text.contains('station unavailable')) {
      return AmpStrings.bookingStationUnavailable;
    }
    if (text.contains('port_unavailable') ||
        text.contains('port unavailable')) {
      return AmpStrings.bookingPortUnavailable;
    }
    if (text.contains('not_allowed') || text.contains('not allowed')) {
      return AmpStrings.errorPermission;
    }
    if (text.contains('server_required') || text.contains('server required')) {
      return AmpStrings.bookingServerRequired;
    }
    return fallback;
  }
}
