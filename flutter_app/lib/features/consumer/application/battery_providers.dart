import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The driver's own battery reading for the car in use.
///
/// This is entered by hand, never estimated. It lives for the app session so
/// Discover and the trip planner use the same number until the driver changes
/// it or the active vehicle changes.
class BatterySocController extends Notifier<int?> {
  @override
  int? build() => null;

  void setSoc(int percent) {
    state = percent < 0
        ? 0
        : percent > 100
        ? 100
        : percent;
  }

  void clear() => state = null;
}

final NotifierProvider<BatterySocController, int?> batterySocProvider =
    NotifierProvider<BatterySocController, int?>(BatterySocController.new);
