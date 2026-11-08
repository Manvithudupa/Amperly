import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'app_env.dart';

/// Configuration supplied by the native Android host.
///
/// When the phone UI runs inside the Java app, the Supabase and Geoapify values
/// already exist in `BuildConfig`. Reading them over this channel keeps one
/// source of truth and means an integrated APK does not need a second
/// `--dart-define-from-file` step. A standalone/test run still falls back to
/// [AppEnv.fromEnvironment].
abstract final class NativeConfig {
  static const MethodChannel _channel = MethodChannel('com.amperly.app/native');

  /// Returns null when there is no native host (tests, desktop, web) or the
  /// channel is unavailable. It never exposes a platform error to the UI.
  static Future<AppEnv?> load() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    try {
      final Map<Object?, Object?>? values = await _channel
          .invokeMapMethod<Object?, Object?>('getConfig');
      if (values == null) {
        return null;
      }
      return AppEnv.fromNative(values);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('Native config unavailable: ${error.code}');
      return null;
    }
  }
}
