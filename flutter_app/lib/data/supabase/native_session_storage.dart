import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The bridge to the Java session store.
///
/// The Android Auto layer is Java and can start without Flutter. Both surfaces
/// must therefore see the same bearer tokens: Flutter persists through this
/// channel into `SupabaseAuth`'s Keystore-backed preferences instead of
/// keeping a second encrypted copy. That also means a token refreshed by
/// either surface is the token the other one reads next.
class NativeSessionBridge {
  NativeSessionBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'com.amperly.app/session';

  final MethodChannel _channel;

  /// Null when there is no Java host (tests, desktop, standalone module run).
  static Future<NativeSessionBridge?> create() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    final NativeSessionBridge bridge = NativeSessionBridge();
    try {
      final bool? available = await bridge._channel.invokeMethod<bool>(
        'isAvailable',
      );
      return available == true ? bridge : null;
    } on MissingPluginException {
      return null;
    } on PlatformException catch (error) {
      debugPrint('Native session bridge unavailable: ${error.code}');
      return null;
    }
  }

  Future<bool> hasSession() async {
    return await _channel.invokeMethod<bool>('hasSession') ?? false;
  }

  Future<String?> readSession() {
    return _channel.invokeMethod<String>('readSession');
  }

  Future<void> writeSession(String json) {
    return _channel.invokeMethod<void>('writeSession', <String, Object?>{
      'session': json,
    });
  }

  Future<void> removeSession() {
    return _channel.invokeMethod<void>('clearSession');
  }

  Future<void> clearAccount() {
    return _channel.invokeMethod<void>('clearAppSession');
  }

  /// Receives a session refreshed by the Java car layer.
  void listenForSessionChanges(Future<void> Function(String json) handler) {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'sessionChanged' && call.arguments is String) {
        await handler(call.arguments as String);
      }
    });
  }
}

/// Supabase's persisted session, stored by the Java application.
///
/// The fallback [SecureSessionStorage] remains for standalone Flutter runs.
/// In the integrated APK this store is selected before Supabase initializes,
/// so session restore goes through the same encryption and the same tokens as
/// the car surface.
class NativeSessionStorage extends LocalStorage {
  NativeSessionStorage._(this._bridge);

  /// Lets the storage contract be exercised with a mock channel.
  @visibleForTesting
  NativeSessionStorage.withBridge(this._bridge);

  static NativeSessionStorage? _active;

  final NativeSessionBridge _bridge;

  static NativeSessionStorage? get active => _active;

  static Future<NativeSessionStorage?> create() async {
    final NativeSessionBridge? bridge = await NativeSessionBridge.create();
    if (bridge == null) {
      return null;
    }
    final NativeSessionStorage storage = NativeSessionStorage._(bridge);
    _active = storage;
    return storage;
  }

  /// Clears the Java account cache after Flutter has ended the session.
  ///
  /// The token removal itself happens through [removePersistedSession]; this
  /// call also drops the car's resolved user and cached rows so the next person
  /// on the device cannot inherit them.
  static Future<void> clearCarAccount() async {
    final NativeSessionStorage? storage = _active;
    if (storage == null) {
      return;
    }
    try {
      await storage._bridge.clearAccount();
    } on MissingPluginException {
      // A standalone module host has no Java car layer.
    } on PlatformException catch (error) {
      debugPrint('Car session cleanup failed: ${error.code}');
    }
  }

  @override
  Future<void> initialize() async {
    // The Java store is opened on the first method call.
  }

  @override
  Future<bool> hasAccessToken() => _bridge.hasSession();

  @override
  Future<String?> accessToken() => _bridge.readSession();

  @override
  Future<void> persistSession(String persistSessionString) =>
      _bridge.writeSession(persistSessionString);

  @override
  Future<void> removePersistedSession() => _bridge.removeSession();

  /// Adopts a token refreshed by Java while this Flutter client is running.
  void listenForNativeSessionChanges() {
    _bridge.listenForSessionChanges(_adoptNativeRefresh);
  }

  Future<void> _adoptNativeRefresh(String json) async {
    try {
      final Object? decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      final Object? refreshToken = decoded['refresh_token'];
      if (refreshToken is! String || refreshToken.isEmpty) {
        return;
      }
      // This refreshes through Supabase and persists the result back to Java.
      // Java's adopt path does not emit another event, so this cannot loop.
      await Supabase.instance.client.auth.setSession(refreshToken);
    } on Object catch (error) {
      debugPrint(
        'Native session refresh could not be adopted: ${error.runtimeType}',
      );
    }
  }
}
