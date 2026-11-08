import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/supabase/supabase_bootstrap.dart';

/// The small, immutable view of the signed-in account that the router and
/// screens depend on.
@immutable
class SessionSnapshot {
  const SessionSnapshot._({
    required this.isSignedIn,
    this.userId,
    this.email,
    this.name,
  });

  const SessionSnapshot.signedOut() : this._(isSignedIn: false);

  factory SessionSnapshot.fromSession(Session? session) {
    if (session == null) {
      return const SessionSnapshot.signedOut();
    }
    final User user = session.user;
    final Object? metadataName = user.userMetadata?['name'];
    return SessionSnapshot._(
      isSignedIn: true,
      userId: user.id,
      email: user.email,
      name: metadataName is String ? metadataName.trim() : '',
    );
  }

  final bool isSignedIn;
  final String? userId;
  final String? email;
  final String? name;

  String get displayName {
    final String value = name?.trim() ?? '';
    if (value.isNotEmpty) {
      return value;
    }
    final String address = email?.trim() ?? '';
    return address;
  }
}

/// Follows Supabase auth instead of inventing a session.
///
/// Every state change — restored session, sign-in, token refresh, sign-out —
/// comes from the client's own stream. The redirect guard in `router.dart`
/// listens to this provider and is the only place that decides which route is
/// allowed.
class SessionController extends Notifier<SessionSnapshot> {
  StreamSubscription<AuthState>? _subscription;

  @override
  SessionSnapshot build() {
    final SupabaseClient? client = SupabaseBootstrap.clientOrNull;
    if (client == null) {
      return const SessionSnapshot.signedOut();
    }

    final GoTrueClient auth = client.auth;
    _subscription = auth.onAuthStateChange.listen(
      (AuthState event) {
        state = SessionSnapshot.fromSession(event.session);
      },
      onError: (Object error) {
        // A stream error is not an account result. Keep the last known state;
        // the next auth event will correct it.
        debugPrint('Auth state stream failed: ${error.runtimeType}');
      },
    );
    ref.onDispose(() {
      _subscription?.cancel();
      _subscription = null;
    });

    return SessionSnapshot.fromSession(auth.currentSession);
  }
}

final NotifierProvider<SessionController, SessionSnapshot> sessionProvider =
    NotifierProvider<SessionController, SessionSnapshot>(SessionController.new);
