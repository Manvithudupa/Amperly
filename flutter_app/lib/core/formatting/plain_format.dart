/// Formatting used by the pure domain layer.
///
/// The Flutter layer keeps its richer [AmpFormat] wrapper; these helpers avoid
/// importing Flutter from an engine.
abstract final class PlainFormat {
  static String money(double amount) => '₹${amount.toStringAsFixed(2)}';

  static String dateTime(int epochMs) {
    final DateTime value = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${value.day} ${months[value.month - 1]}, ${clock(epochMs)}';
  }

  static String connectorLabel(String? stored) {
    final String code = (stored ?? '').trim().toUpperCase();
    if (code == 'TYPE_2_AC' || code == 'TYPE2_AC') {
      return 'Type 2 AC';
    }
    if (code == 'TYPE_2' || code == 'TYPE2') {
      return 'Type 2';
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
    if (code.isEmpty) {
      return '';
    }
    final String words = code.replaceAll('_', ' ').toLowerCase();
    return '${words[0].toUpperCase()}${words.substring(1)}';
  }

  static String connectorTypes(String? storedCsv) {
    final String csv = (storedCsv ?? '').trim();
    if (csv.isEmpty) {
      return '';
    }
    return csv
        .split(RegExp(r'\s*,\s*'))
        .map(connectorLabel)
        .where((String value) => value.isNotEmpty)
        .join(', ');
  }

  static String kwh(double value) => '${value.toStringAsFixed(2)} kWh';

  static String percent(num value) => '${_trim(value)}%';

  static String clock(int epochMs) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  static String dayAndSlot(int startMs, int endMs) {
    final DateTime start = DateTime.fromMillisecondsSinceEpoch(startMs);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(start.year, start.month, start.day);
    final String label;
    if (day == today) {
      label = 'Today';
    } else if (day == today.add(const Duration(days: 1))) {
      label = 'Tomorrow';
    } else {
      const List<String> weekdays = <String>[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      const List<String> months = <String>[
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      label =
          '${weekdays[start.weekday - 1]} ${start.day} ${months[start.month - 1]}';
    }
    return '$label, ${clock(startMs)} – ${clock(endMs)}';
  }

  static String durationMinutes(int totalMinutes) {
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    }
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;
    return minutes == 0
        ? '$hours h'
        : '$hours h ${minutes.toString().padLeft(2, '0')} min';
  }

  static String _trim(num value) {
    final double number = value.toDouble();
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(1);
  }
}
