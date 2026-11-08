import 'package:amperly/core/env/app_env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String publishable = 'sb_publishable_test_value';

  test('a secret key is refused before anything starts', () {
    const AppEnv env = AppEnv(
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: 'sb_secret_test_value',
      geoapifyApiKey: '',
      mapStyleUrl: '',
    );
    expect(env.hasSecretKey, isTrue);
    expect(() => env.assertSafe(), throwsA(isA<ConfigurationError>()));
  });

  test('a service_role key is refused too', () {
    const AppEnv env = AppEnv(
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: 'service_role_key',
      geoapifyApiKey: '',
      mapStyleUrl: '',
    );
    expect(env.hasSecretKey, isTrue);
    expect(() => env.assertSafe(), throwsA(isA<ConfigurationError>()));
  });

  test('half a Supabase configuration is refused', () {
    const AppEnv env = AppEnv(
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: '',
      geoapifyApiKey: '',
      mapStyleUrl: '',
    );
    expect(env.hasSupabase, isFalse);
    expect(env.isIncomplete, isTrue);
    expect(() => env.assertSafe(), throwsA(isA<ConfigurationError>()));
  });

  test('a complete publishable configuration is accepted', () {
    const AppEnv env = AppEnv(
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: publishable,
      geoapifyApiKey: 'geo-key',
      mapStyleUrl: '',
    );
    expect(env.hasSupabase, isTrue);
    expect(env.hasSecretKey, isFalse);
    expect(env.assertSafe, returnsNormally);
    expect(env.resolvedMapStyleUrl, contains('apiKey=geo-key'));
    expect(env.resolvedMapStyleUrl, startsWith(AppEnv.defaultMapStyleUrl));
  });

  test('native host values are mapped and trimmed', () {
    final AppEnv env = AppEnv.fromNative(<Object?, Object?>{
      'SUPABASE_URL': '  https://example.supabase.co  ',
      'SUPABASE_PUBLISHABLE_KEY': ' $publishable ',
      'GEOAPIFY_API_KEY': ' geo-key ',
      'MAP_STYLE_URL': ' https://example.com/style.json ',
      'APP_VERSION': ' 5.0.0 ',
    });
    expect(env.supabaseUrl, 'https://example.supabase.co');
    expect(env.supabasePublishableKey, publishable);
    expect(env.geoapifyApiKey, 'geo-key');
    expect(env.mapStyleUrl, 'https://example.com/style.json');
    expect(env.hasSupabase, isTrue);
    expect(env.assertSafe, returnsNormally);
  });

  test('native host missing values stay empty, never invented', () {
    final AppEnv env = AppEnv.fromNative(<Object?, Object?>{
      'SUPABASE_URL': 42,
      'SUPABASE_PUBLISHABLE_KEY': null,
    });
    expect(env.supabaseUrl, isEmpty);
    expect(env.supabasePublishableKey, isEmpty);
    expect(env.hasSupabase, isFalse);
  });

  test('an explicit style URL keeps its query string', () {
    const AppEnv env = AppEnv(
      supabaseUrl: 'https://example.supabase.co',
      supabasePublishableKey: publishable,
      geoapifyApiKey: 'geo-key',
      mapStyleUrl: 'https://example.com/style.json?theme=paper',
    );
    expect(
      env.resolvedMapStyleUrl,
      'https://example.com/style.json?theme=paper&apiKey=geo-key',
    );
  });
}
