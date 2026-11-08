import '../../../core/ui/strings.dart';
import '../../../domain/policy.dart';

abstract final class TripPlannerRules {
  static String? startSocError(String? value) {
    final int? soc = int.tryParse((value ?? '').trim());
    if (soc == null || soc < 0 || soc > 100) {
      return AmpStrings.tripBatteryInvalid;
    }
    return null;
  }

  static String? destinationError(String value, {required bool resolved}) {
    if (resolved) {
      return null;
    }
    if (value.trim().length < AmpPolicy.searchMinimumCharacters) {
      return AmpStrings.tripDestinationRequired;
    }
    return null;
  }
}
