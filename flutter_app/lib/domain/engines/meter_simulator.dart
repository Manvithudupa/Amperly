final class SimulatedSession {
  const SimulatedSession({
    required this.startReadingKwh,
    required this.endReadingKwh,
    required this.deliveredKwh,
    required this.minutes,
    required this.simulated,
  });

  final double startReadingKwh;
  final double endReadingKwh;
  final double deliveredKwh;
  final int minutes;
  final bool simulated;
}

abstract final class MeterSimulator {
  static const double seedReading = 125.40;
  static final Map<String, double> _cumulative = <String, double>{};
  static final Map<String, bool> _offline = <String, bool>{};

  static double currentReading(String? stationId) {
    if (stationId == null) {
      return seedReading;
    }
    return _cumulative.putIfAbsent(stationId, () => seedReading);
  }

  static void setReading(String? stationId, double reading) {
    if (stationId != null) {
      _cumulative[stationId] = reading;
    }
  }

  static double beginSession(String? stationId) => currentReading(stationId);

  static double deliver(String? stationId, double powerKw, int minutes) {
    final double kwh =
        (powerKw < 0 ? 0 : powerKw) * ((minutes < 0 ? 0 : minutes) / 60) * 0.92;
    final double updated = currentReading(stationId) + round2(kwh);
    setReading(stationId, updated);
    return round2(kwh);
  }

  static double endSession(String? stationId) => currentReading(stationId);

  static SimulatedSession simulateSession(
    String? stationId,
    double powerKw,
    int minutes,
  ) {
    final double start = beginSession(stationId);
    final double delivered = deliver(stationId, powerKw, minutes);
    return SimulatedSession(
      startReadingKwh: start,
      endReadingKwh: endSession(stationId),
      deliveredKwh: delivered,
      minutes: minutes,
      simulated: true,
    );
  }

  static bool isOffline(String? stationId) =>
      stationId != null && (_offline[stationId] ?? false);

  static void setOffline(String? stationId, bool offline) {
    if (stationId != null) {
      _offline[stationId] = offline;
    }
  }

  static bool isValidReading(double startReading, double endReading) {
    return startReading >= 0 && endReading >= startReading;
  }

  static bool isImplausibleReading(
    double startReading,
    double endReading,
    double portPowerKw,
    int minutes,
  ) {
    final double physicalMax =
        (portPowerKw < 0.1 ? 0.1 : portPowerKw) *
        ((minutes < 1 ? 1 : minutes) / 60) *
        1.15;
    return (endReading - startReading) > physicalMax;
  }

  static double round2(double value) => (value * 100).round() / 100;

  /// Test-only reset so one scenario cannot leak into another.
  static void reset() {
    _cumulative.clear();
    _offline.clear();
  }
}
