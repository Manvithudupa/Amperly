import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../domain/engines/billing_engine.dart';
import '../../../domain/policy.dart';

/// Pure rules for the consumer charging-session flow.
///
/// Meter arithmetic is only a preview. The server recomputes the bill inside
/// `finalize_charging_session` from the readings the driver enters.
abstract final class SessionRules {
  static bool canOpen(Reservation? reservation, ChargerStation? station) {
    return reservation?.status == AmpPolicy.statusReserved &&
        station != null &&
        BillingEngine.isVerifiedMeterLevel(station.verificationLevel);
  }

  static bool canStart(ChargingSession? session) {
    return session?.status == AmpPolicy.statusCheckedIn;
  }

  static bool canSettle(ChargingSession? session) {
    return session?.status == AmpPolicy.statusCheckedIn ||
        session?.status == AmpPolicy.statusCharging;
  }

  static bool isCompleted(ChargingSession? session) {
    return session?.status == AmpPolicy.statusCompleted;
  }

  static String? startReadingError(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return AmpStrings.sessionStartReadingRequired;
    }
    final double? reading = parseReading(value);
    if (reading == null) {
      return AmpStrings.sessionStartReadingInvalid;
    }
    return null;
  }

  static String? endReadingError(String raw, double startReadingKwh) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return AmpStrings.sessionEndReadingRequired;
    }
    final double? reading = parseReading(value);
    if (reading == null) {
      return AmpStrings.sessionEndReadingInvalid;
    }
    if (reading < startReadingKwh) {
      return AmpStrings.sessionEndReadingBelowStart;
    }
    return null;
  }

  static double? parseReading(String raw) {
    final double? value = double.tryParse(raw.trim());
    if (value == null || !value.isFinite || value < 0) {
      return null;
    }
    return value;
  }

  static int elapsedMinutes(int startMs, int? endMs, int nowMs) {
    final int end = endMs == null || endMs <= 0 ? nowMs : endMs;
    final int minutes = (end - startMs) ~/ 60000;
    return minutes < 0 ? 0 : minutes;
  }

  /// Maps a settlement refusal to written copy without exposing its raw text.
  static String serverMessage(Object? cause, {required String fallback}) {
    final String text = (cause?.toString() ?? '').toLowerCase();
    if (text.contains('can no longer be settled') ||
        text.contains('no reservation')) {
      return AmpStrings.sessionNoLongerSettle;
    }
    if (text.contains('no verified meter')) {
      return AmpStrings.sessionNoMeter;
    }
    if (text.contains('different reservation')) {
      return AmpStrings.sessionMismatch;
    }
    if (text.contains('do not match the meter evidence')) {
      return AmpStrings.sessionEvidenceMismatch;
    }
    if (text.contains('ending meter') ||
        text.contains('below the starting') ||
        text.contains('readings are required') ||
        text.contains('reading is not a valid')) {
      return AmpStrings.sessionEndReadingInvalid;
    }
    if (text.contains('not_allowed') ||
        text.contains('not allowed') ||
        text.contains('only the consumer') ||
        text.contains('permission')) {
      return AmpStrings.errorPermission;
    }
    return fallback;
  }
}
