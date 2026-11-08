import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env/app_env.dart';
import '../core/env/native_config.dart';
import '../data/supabase/supabase_bootstrap.dart';
import 'app.dart';
import 'configuration_error_app.dart';

/// Starts the app in the one order that is safe:
/// check the settings, initialize the backend, then show a screen.
abstract final class AmpBootstrap {
  static Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();

    // The native host is the source of truth in the integrated APK. The
    // dart-define fallback keeps standalone module runs and tests working.
    final AppEnv env = await NativeConfig.load() ?? AppEnv.fromEnvironment();
    try {
      env.assertSafe();
    } on ConfigurationError catch (error) {
      runApp(ConfigurationErrorApp(problem: error.problem));
      return;
    }

    if (env.hasSupabase) {
      try {
        await SupabaseBootstrap.initialize(env);
      } on Object catch (error) {
        // The type is enough to debug this; the exception may contain a URL,
        // and nothing technical belongs on the screen or in a shipped log.
        debugPrint('Supabase bootstrap failed: ${error.runtimeType}');
        runApp(
          const ConfigurationErrorApp(
            problem: ConfigurationProblem.backendUnavailable,
          ),
        );
        return;
      }
    }

    runApp(
      ProviderScope(
        overrides: [appEnvProvider.overrideWithValue(env)],
        child: const AmpApp(),
      ),
    );
  }
}
