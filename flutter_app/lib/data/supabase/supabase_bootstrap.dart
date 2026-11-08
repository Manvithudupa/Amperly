import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env/app_env.dart';
import 'native_session_storage.dart';
import 'secure_session_storage.dart';

/// Initializes Supabase exactly once, with an encrypted session store.
///
/// In the APK the Android host supplies a Keystore-backed store that the Java
/// car layer also reads. A standalone Flutter run falls back to the platform's
/// encrypted store. A build with no backend settings is allowed to start (so
/// the configuration screen can explain the problem), but it is explicitly
/// not configured. A missing half, or a secret key, is refused before this is
/// called.
abstract final class SupabaseBootstrap {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize(AppEnv env) async {
    if (!env.hasSupabase || _initialized) {
      return;
    }

    // The integrated app must use the Java store: the car service can start
    // without Flutter and has to find the same bearer token. Outside the APK
    // there is no channel, so the standalone encrypted store is used.
    final NativeSessionStorage? nativeStore =
        await NativeSessionStorage.create();

    await Supabase.initialize(
      url: env.supabaseUrl.trim(),
      publishableKey: env.supabasePublishableKey.trim(),
      authOptions: FlutterAuthClientOptions(
        localStorage: nativeStore ?? SecureSessionStorage(),
      ),
      debug: false,
    );
    nativeStore?.listenForNativeSessionChanges();
    _initialized = true;
  }

  /// The client after initialization, or null in a build with no backend.
  static SupabaseClient? get clientOrNull {
    if (!_initialized) {
      return null;
    }
    return Supabase.instance.client;
  }
}
