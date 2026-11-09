import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Runs the test suite at a chosen system text scale:
/// `AMP_TEXT_SCALE=2.0 flutter test`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();
  final double? scale = double.tryParse(
    Platform.environment['AMP_TEXT_SCALE'] ?? '',
  );
  if (scale != null) {
    binding.platformDispatcher.textScaleFactorTestValue = scale;
  }
  await testMain();
}
