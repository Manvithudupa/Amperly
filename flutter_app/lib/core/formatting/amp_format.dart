import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../ui/connector_kind.dart';
import '../ui/strings.dart';

/// Number, money and time formatting for the whole app.
///
/// All of it is pure and testable. Text styles add tabular figures at the
/// widget layer, so these functions never pad or align themselves.
abstract final class AmpFormat {
  static final NumberFormat _whole = NumberFormat('#,##0', 'en_IN');
  static final NumberFormat _decimal = NumberFormat('#,##0.00', 'en_IN');
  static final NumberFormat _compact = NumberFormat('0.##', 'en_IN');
  static final DateFormat _slotTime = DateFormat('h:mm a');
  static final DateFormat _shortDay = DateFormat('EEE d MMM');

  /// Rupees, with the symbol always attached to the number.
  ///
  /// Whole amounts stay whole (`₹18`); part-rupee amounts keep two places
  /// (`₹18.50`) because rounding a bill silently is not acceptable.
  static String rupees(num amount, {bool showPaise = false}) {
    final double value = amount.isFinite ? amount.toDouble() : 0;
    final bool whole = value == value.roundToDouble();
    final String digits = showPaise || !whole
        ? _decimal.format(value)
        : _whole.format(value);
    return '₹$digits';
  }

  /// Energy for display. One decimal is enough to see a session move.
  static String kWh(num value) => '${_compact.format(value)} ${AmpStrings.kwh}';

  /// Distance in kilometres, no trailing `.0`.
  static String km(num value) => '${_compact.format(value)} ${AmpStrings.km}';

  static String percent(num value) =>
      '${_compact.format(value)}${AmpStrings.percent}';

  /// A booking day tab: today, tomorrow, or a short weekday date.
  static String dayLabel(DateTime day, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final DateTime target = DateTime(day.year, day.month, day.day);
    if (target == today) {
      return AmpStrings.bookingToday;
    }
    if (target == today.add(const Duration(days: 1))) {
      return AmpStrings.bookingTomorrow;
    }
    return _shortDay.format(target);
  }

  /// One clock time, e.g. `6:30 pm`.
  static String clock(int epochMs) {
    return _slotTime
        .format(DateTime.fromMillisecondsSinceEpoch(epochMs))
        .toLowerCase();
  }

  /// A slot's clock window, e.g. `6:30 pm – 8:00 pm`.
  static String timeRange(int startMs, int endMs) =>
      '${clock(startMs)} – ${clock(endMs)}';

  /// A held slot, in the words a driver uses: `1 h 05 min`, `35 min`.
  static String duration(Duration duration) {
    final int totalMinutes = duration.inMinutes.abs();
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return minutes == 0
        ? '$hours h'
        : '$hours h ${minutes.toString().padLeft(2, '0')} min';
  }

  /// Honest age of a reading. There is no "live" claim anywhere.
  static String relative(DateTime then, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final Duration age = reference.difference(then);
    if (age.isNegative || age.inMinutes < 1) {
      return 'just now';
    }
    if (age.inMinutes < 60) {
      final int minutes = age.inMinutes;
      return minutes == 1 ? '1 min ago' : '$minutes min ago';
    }
    if (age.inHours < 24) {
      final int hours = age.inHours;
      return hours == 1 ? '1 h ago' : '$hours h ago';
    }
    final int days = age.inDays;
    return days == 1 ? '1 day ago' : '$days days ago';
  }

  /// A chat line's time. Today's messages show only the clock; older lines
  /// carry their date so a long conversation stays readable.
  static String messageTimestamp(int epochMs, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime value = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final bool today =
        value.year == reference.year &&
        value.month == reference.month &&
        value.day == reference.day;
    return today
        ? clock(epochMs)
        : '${_shortDay.format(value)}, ${clock(epochMs)}';
  }

  /// The label a person reads for a stored connector value.
  static String connectorLabel(String? stored) {
    if (stored == null || stored.trim().isEmpty) {
      return '';
    }
    final String code = stored.trim().toUpperCase();
    if (code == 'TYPE_2_AC' ||
        code == 'TYPE2_AC' ||
        code == 'TYPE_2' ||
        code == 'TYPE2') {
      return code.contains('AC') ? 'Type 2 AC' : 'Type 2';
    }
    if (code.startsWith('CCS')) {
      return 'CCS2';
    }
    if (code == 'CHADEMO') {
      return 'CHAdeMO';
    }
    if (code == 'GB_T' || code == 'GBT') {
      return 'GB/T';
    }
    return _humanize(stored);
  }

  static ConnectorKind connectorKind(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    if (code.startsWith('CCS')) {
      return ConnectorKind.ccs2;
    }
    if (code.startsWith('TYPE_2') || code.startsWith('TYPE2')) {
      return ConnectorKind.type2;
    }
    if (code == 'CHADEMO') {
      return ConnectorKind.chademo;
    }
    return ConnectorKind.plug;
  }

  /// Stored codes are not copy. `PENDING_VERIFICATION` is `Pending review`.
  static String approvalStatus(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    return switch (code) {
      'PENDING' => 'Pending review',
      'APPROVED' => 'Approved',
      'REJECTED' => 'Rejected',
      '' => '',
      _ => _humanize(stored!),
    };
  }

  static String meterLevel(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    if (code.startsWith('LEVEL_1')) {
      return 'Level 1 meter';
    }
    if (code.startsWith('LEVEL_2')) {
      return 'Level 2 meter';
    }
    return 'No verified meter';
  }

  static String bookingStatus(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    const Map<String, String> labels = <String, String>{
      'RESERVED': 'Reserved',
      'CHECKED_IN': 'Checked in',
      'CHARGING': 'Charging',
      'COMPLETED': 'Completed',
      'CANCELLED': 'Cancelled',
      'EXPIRED': 'Expired',
      'DISPUTED': 'Disputed',
      'REFUNDED': 'Refunded',
    };
    return labels[code] ??
        (stored == null || stored.trim().isEmpty ? '' : _humanize(stored));
  }

  static String portStatus(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    return switch (code) {
      'AVAILABLE' || 'FREE' => 'Available',
      'OCCUPIED' || 'IN_USE' || 'CHARGING' => 'In use',
      'MAINTENANCE' => 'Maintenance',
      'RESERVED' => 'Reserved',
      '' => '',
      _ => _humanize(stored!),
    };
  }

  static String _humanize(String stored) {
    final String words = stored.trim().replaceAll('_', ' ').toLowerCase();
    if (words.isEmpty) {
      return '';
    }
    return words[0].toUpperCase() + words.substring(1);
  }
}

/// Small helpers for tests and debug output that need a deterministic clock.
@visibleForTesting
DateTime fixedNow() => DateTime.utc(2026, 11, 7, 12);
