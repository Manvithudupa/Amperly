import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A best-effort reachability probe. It resolves the backend host instead of
/// opening a socket, so it is cheap enough to run in the background and does
/// not send any account data.
final Provider<Future<bool> Function()> onlineProbeProvider =
    Provider<Future<bool> Function()>((Ref ref) {
      return () async {
        try {
          final List<InternetAddress> addresses = await InternetAddress.lookup(
            'supabase.co',
          ).timeout(const Duration(seconds: 5));
          return addresses.isNotEmpty;
        } on Object {
          return false;
        }
      };
    });

/// The app-wide connection state used by the one offline banner.
///
/// This is deliberately a lightweight check, not a claim that every request
/// will succeed. A failed probe means the shell says it is offline; a
/// successful probe means the banner stays quiet. Screens still handle their
/// own request failures with retry and plain-language copy.
class OnlineStatusNotifier extends Notifier<bool> {
  Timer? _timer;
  bool _checking = false;
  bool _disposed = false;

  @override
  bool build() {
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      unawaited(check());
    });
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
    });
    unawaited(Future<void>.microtask(check));
    return true;
  }

  Future<void> check() async {
    if (_checking || _disposed) {
      return;
    }
    _checking = true;
    final bool online = await ref.read(onlineProbeProvider)();
    _checking = false;
    if (!_disposed && state != online) {
      state = online;
    }
  }
}

final NotifierProvider<OnlineStatusNotifier, bool> onlineStatusProvider =
    NotifierProvider<OnlineStatusNotifier, bool>(OnlineStatusNotifier.new);
