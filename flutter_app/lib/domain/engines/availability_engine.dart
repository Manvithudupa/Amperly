import '../../core/formatting/plain_format.dart';
import '../../data/models/models.dart';
import '../policy.dart';

final class Slot {
  const Slot({
    this.portId,
    this.portLabel,
    required this.startMs,
    required this.endMs,
    required this.available,
    this.reason,
  });

  final String? portId;
  final String? portLabel;
  final int startMs;
  final int endMs;
  final bool available;
  final String? reason;

  String get label => PlainFormat.dayAndSlot(startMs, endMs);
}

final class AvailabilitySummary {
  const AvailabilitySummary({
    required this.totalPorts,
    required this.freePorts,
    required this.nextFreeSlotMs,
    required this.lastUpdatedMs,
    required this.paused,
    required this.label,
  });

  final int totalPorts;
  final int freePorts;
  final int nextFreeSlotMs;
  final int lastUpdatedMs;
  final bool paused;
  final String label;
}

abstract final class AvailabilityEngine {
  static const int defaultSlotMinutes = 90;

  static List<Slot> generateSlots({
    required ChargerStation? station,
    required List<ChargerPort> ports,
    required List<AvailabilitySchedule> schedules,
    required List<Reservation> reservations,
    required int dayStartMs,
    int slotMinutes = defaultSlotMinutes,
    int maxSlots = 16,
    int? nowMs,
  }) {
    final List<Slot> slots = <Slot>[];
    if (station == null || ports.isEmpty || station.isPaused) {
      return slots;
    }
    final int now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final int stepMinutes = slotMinutes < 15 ? 15 : slotMinutes;
    final List<bool> seenStart = List<bool>.filled(
      (24 * 60 / stepMinutes).ceil() + 2,
      false,
    );
    for (int index = 0; index < maxSlots; index++) {
      final int startMs = dayStartMs + index * slotMinutes * 60000;
      final int endMs = startMs + slotMinutes * 60000;
      if (startMs < now) {
        continue;
      }
      final int startOfDayIndex =
          (((startMs - dayStartMs) ~/ 60000) / stepMinutes).floor();
      if (startOfDayIndex >= 0 && startOfDayIndex < seenStart.length) {
        if (seenStart[startOfDayIndex]) {
          continue;
        }
        seenStart[startOfDayIndex] = true;
      }

      bool anyFree = false;
      String? reason;
      String? chosenPortId;
      String? chosenPortLabel;
      for (final ChargerPort port in ports) {
        if (!_isPortUsable(port)) {
          reason =
              'Port ${port.portNumber} is ${(port.status ?? '').toLowerCase()}';
          continue;
        }
        final AvailabilitySchedule? schedule = _scheduleFor(
          schedules,
          port.id,
          startMs,
        );
        if (schedule == null) {
          reason = 'No published opening hours for this port';
          continue;
        }
        if (schedule.isBlocked) {
          reason =
              'Blocked by the host: '
              '${schedule.blockReason == null || schedule.blockReason!.isEmpty ? 'maintenance' : schedule.blockReason}';
          continue;
        }
        if (!_withinWindow(schedule, startMs, endMs)) {
          reason = 'Outside published hours';
          continue;
        }
        if (hasConflict(reservations, port.id, startMs, endMs)) {
          reason = 'Already reserved';
          continue;
        }
        anyFree = true;
        chosenPortId = port.id;
        chosenPortLabel = portLabel(port);
        break;
      }
      if (anyFree) {
        slots.add(
          Slot(
            portId: chosenPortId,
            portLabel: chosenPortLabel,
            startMs: startMs,
            endMs: endMs,
            available: true,
            reason: 'Free for a $slotMinutes-minute slot',
          ),
        );
      } else if (reason != null) {
        slots.add(
          Slot(
            startMs: startMs,
            endMs: endMs,
            available: false,
            reason: reason,
          ),
        );
      }
    }
    return slots;
  }

  static AvailabilitySummary summarise({
    required ChargerStation? station,
    required List<ChargerPort> ports,
    required List<AvailabilitySchedule> schedules,
    required List<Reservation> reservations,
    required int nowMs,
  }) {
    final int total = ports.length;
    int free = 0;
    for (final ChargerPort port in ports) {
      final bool busy = reservations.any(
        (Reservation reservation) =>
            port.id == reservation.portId &&
            reservation.isActive &&
            nowMs >= reservation.startTimeMs &&
            nowMs <= reservation.endTimeMs,
      );
      if (_isPortUsable(port) && !busy) {
        free++;
      }
    }

    int nextFree = 0;
    if (free == 0 && station != null) {
      final DateTime now = DateTime.fromMillisecondsSinceEpoch(nowMs);
      final int dayStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).millisecondsSinceEpoch;
      for (int offset = 0; offset < 7 && nextFree == 0; offset++) {
        final List<Slot> slots = generateSlots(
          station: station,
          ports: ports,
          schedules: schedules,
          reservations: reservations,
          dayStartMs: dayStart + offset * 86400000,
          maxSlots: 16,
          nowMs: nowMs,
        );
        for (final Slot slot in slots) {
          if (slot.available) {
            nextFree = slot.startMs;
            break;
          }
        }
      }
    }

    final bool paused = station?.isPaused ?? false;
    final String label;
    if (paused) {
      label = 'Paused by the host';
    } else if (total == 0) {
      label = 'No ports published';
    } else if (free == total) {
      label = 'All $total ports free';
    } else if (free > 0) {
      label = '$free of $total ports free';
    } else {
      label =
          'All ports busy — next free '
          '${nextFree > 0 ? PlainFormat.clock(nextFree) : 'unavailable'}';
    }

    return AvailabilitySummary(
      totalPorts: total,
      freePorts: free,
      nextFreeSlotMs: nextFree,
      lastUpdatedMs: station?.lastUpdatedMs ?? nowMs,
      paused: paused,
      label: label,
    );
  }

  static bool hasConflict(
    List<Reservation> reservations,
    String? portId,
    int startMs,
    int endMs,
  ) {
    for (final Reservation reservation in reservations) {
      if (portId != null && portId != reservation.portId) {
        continue;
      }
      if (!reservation.isActive) {
        continue;
      }
      if (reservation.startTimeMs < endMs && reservation.endTimeMs > startMs) {
        return true;
      }
    }
    return false;
  }

  static String portLabel(ChargerPort? port) {
    if (port == null) {
      return '';
    }
    final String connector = _connectorType(port.connectorType);
    return 'Port ${port.portNumber} · $connector · ${port.powerKw.toInt()} kW';
  }

  static bool _isPortUsable(ChargerPort? port) =>
      port != null &&
      (port.status ?? '').toUpperCase() == AmpPolicy.portAvailable;

  static AvailabilitySchedule? _scheduleFor(
    List<AvailabilitySchedule> schedules,
    String portId,
    int startMs,
  ) {
    final int weekday = DateTime.fromMillisecondsSinceEpoch(
      startMs,
    ).weekday; // Mon=1..Sun=7
    for (final AvailabilitySchedule schedule in schedules) {
      if (portId == schedule.portId && schedule.dayOfWeek == weekday) {
        return schedule;
      }
    }
    return null;
  }

  static bool _withinWindow(
    AvailabilitySchedule schedule,
    int startMs,
    int endMs,
  ) {
    final DateTime start = DateTime.fromMillisecondsSinceEpoch(startMs);
    final DateTime end = DateTime.fromMillisecondsSinceEpoch(endMs);
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;
    if (endMinutes <= startMinutes) {
      endMinutes = 24 * 60;
    }
    return startMinutes >= schedule.openMinutes &&
        endMinutes <= schedule.closeMinutes;
  }

  static String _connectorType(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    if (code.startsWith('CCS')) {
      return 'CCS2';
    }
    if (code.startsWith('TYPE_2') || code.startsWith('TYPE2')) {
      return 'Type 2 AC';
    }
    if (code == 'CHADEMO') {
      return 'CHAdeMO';
    }
    return stored ?? '';
  }
}
