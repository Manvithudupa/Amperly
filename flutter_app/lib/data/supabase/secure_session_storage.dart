import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase's session, persisted through the platform's encrypted storage.
///
/// A Supabase session contains bearer tokens. Plain SharedPreferences is
/// readable from a backup or a rooted device, so this implementation replaces
/// the default store rather than sitting next to it. There is no fallback: if
/// secure storage fails, the session is not written anywhere else.
class SecureSessionStorage extends LocalStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'amperly.supabase.session.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<void> initialize() async {
    // Nothing to warm up: the platform store is opened per call.
  }

  @override
  Future<bool> hasAccessToken() => _storage.containsKey(key: _sessionKey);

  @override
  Future<String?> accessToken() => _storage.read(key: _sessionKey);

  @override
  Future<void> persistSession(String persistSessionString) {
    return _storage.write(key: _sessionKey, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _sessionKey);
}
