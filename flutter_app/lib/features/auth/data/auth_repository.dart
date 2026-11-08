import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/native_session_storage.dart';
import '../../../data/supabase/supabase_bootstrap.dart';

/// What the sign-in screen should do after a successful account creation.
class AuthResult {
  const AuthResult({this.needsEmailConfirmation = false});

  /// True when Supabase created the account but returned no session because
  /// the project requires the address to be confirmed first.
  final bool needsEmailConfirmation;
}

/// The phone's authentication calls.
///
/// There is no local or demo identity. Every method talks to Supabase, and the
/// session is persisted by [NativeSessionStorage] or, outside the APK, by the
/// encrypted standalone store selected in `SupabaseBootstrap`.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    if (response.session == null) {
      throw const AuthException('The sign-in did not return a session.');
    }
    return const AuthResult();
  }

  Future<AuthResult> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final AuthResponse response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: <String, Object?>{'name': name.trim()},
    );
    return AuthResult(needsEmailConfirmation: response.session == null);
  }

  Future<void> signOut() async {
    try {
      try {
        await _client.auth.signOut();
      } on Object {
        // A dead session or an unreachable server must not trap the person
        // inside the account. Local scope removes the tokens without a server
        // round trip.
        try {
          await _client.auth.signOut(scope: SignOutScope.local);
        } on Object {
          // The first call may have removed the local session before its
          // server request failed. In that case there is nothing left to
          // report to the person.
          if (_client.auth.currentSession != null) {
            rethrow;
          }
        }
      }
    } finally {
      await NativeSessionStorage.clearCarAccount();
    }
  }
}

final Provider<AuthRepository?> authRepositoryProvider =
    Provider<AuthRepository?>((Ref ref) {
      final SupabaseClient? client = SupabaseBootstrap.clientOrNull;
      return client == null ? null : AuthRepository(client);
    });
