import 'package:flutter/foundation.dart';

/// What went wrong with the build settings.
///
/// These values are for the app, never for the screen. A person sees a written
/// sentence from [AmpStrings], not one of these names.
enum ConfigurationProblem { secretKey, incompleteSupabase, backendUnavailable }

class ConfigurationError implements Exception {
  const ConfigurationError(this.problem);

  final ConfigurationProblem problem;

  @override
  String toString() => 'ConfigurationError(${problem.name})';
}

/// Build-time configuration, injected with
/// `--dart-define-from-file=env.json`, or read from the native host when the
/// Flutter UI is embedded in the Android app.
///
/// Only the Supabase publishable key may ship. A secret key bypasses Row Level
/// Security, so it is detected here and the app refuses to start rather than
/// trusting that nobody made a mistake.
@immutable
class AppEnv {
  const AppEnv({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.geoapifyApiKey,
    required this.mapStyleUrl,
  });

  factory AppEnv.fromEnvironment() {
    return const AppEnv(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL'),
      supabasePublishableKey: String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
      geoapifyApiKey: String.fromEnvironment('GEOAPIFY_API_KEY'),
      mapStyleUrl: String.fromEnvironment('MAP_STYLE_URL'),
    );
  }

  /// Values handed over by [NativeConfig] when Flutter is embedded in the
  /// Android app. Missing or non-string values are treated as empty, never as
  /// a reason to invent a backend.
  factory AppEnv.fromNative(Map<Object?, Object?> values) {
    String read(String key) {
      final Object? value = values[key];
      return value is String ? value.trim() : '';
    }

    return AppEnv(
      supabaseUrl: read('SUPABASE_URL'),
      supabasePublishableKey: read('SUPABASE_PUBLISHABLE_KEY'),
      geoapifyApiKey: read('GEOAPIFY_API_KEY'),
      mapStyleUrl: read('MAP_STYLE_URL'),
    );
  }

  final String supabaseUrl;
  final String supabasePublishableKey;
  final String geoapifyApiKey;
  final String mapStyleUrl;

  static const String defaultMapStyleUrl =
      'https://maps.geoapify.com/v1/styles/osm-bright/style.json';

  String get _url => supabaseUrl.trim();
  String get _key => supabasePublishableKey.trim();

  bool get hasSupabase => _url.isNotEmpty && _key.isNotEmpty;

  bool get isIncomplete => _url.isNotEmpty != _key.isNotEmpty;

  /// A key that must never leave the server.
  bool get hasSecretKey {
    final String key = _key;
    return key.startsWith('sb_secret_') || key.contains('service_role');
  }

  bool get hasMapKey => geoapifyApiKey.trim().isNotEmpty;

  /// The vector style with the key appended. Never log the result.
  String get resolvedMapStyleUrl {
    final String base = mapStyleUrl.trim().isEmpty
        ? defaultMapStyleUrl
        : mapStyleUrl.trim();
    final String key = geoapifyApiKey.trim();
    if (key.isEmpty || base.contains('apiKey=')) {
      return base;
    }
    return '$base${base.contains('?') ? '&' : '?'}apiKey=$key';
  }

  /// Throws before anything starts if the settings are unsafe or contradictory.
  void assertSafe() {
    if (hasSecretKey) {
      throw const ConfigurationError(ConfigurationProblem.secretKey);
    }
    if (isIncomplete) {
      throw const ConfigurationError(ConfigurationProblem.incompleteSupabase);
    }
  }
}
