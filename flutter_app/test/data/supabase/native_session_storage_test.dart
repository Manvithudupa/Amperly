import 'package:amperly/data/supabase/native_session_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.amperly.app/session.test');
  final NativeSessionBridge bridge = NativeSessionBridge(channel: channel);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('round-trips the session JSON through the native callbacks', () async {
    final List<MethodCall> calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return switch (call.method) {
            'hasSession' => true,
            'readSession' => '{"access_token":"stored"}',
            _ => null,
          };
        });

    expect(await bridge.hasSession(), isTrue);
    expect(await bridge.readSession(), '{"access_token":"stored"}');

    await bridge.writeSession('{"access_token":"new"}');
    await bridge.removeSession();
    await bridge.clearAccount();

    expect(calls.map((MethodCall call) => call.method), <String>[
      'hasSession',
      'readSession',
      'writeSession',
      'clearSession',
      'clearAppSession',
    ]);
    expect(calls[2].arguments, <String, Object?>{
      'session': '{"access_token":"new"}',
    });
  });

  test('a missing native session is null, not an invented token', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => null);

    expect(await bridge.hasSession(), isFalse);
    expect(await bridge.readSession(), isNull);
  });

  test('Supabase LocalStorage delegates to the same bridge', () async {
    final List<MethodCall> calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          calls.add(call);
          return switch (call.method) {
            'hasSession' => true,
            'readSession' => '{"access_token":"bridge"}',
            _ => null,
          };
        });
    final NativeSessionStorage storage = NativeSessionStorage.withBridge(
      bridge,
    );

    expect(await storage.hasAccessToken(), isTrue);
    expect(await storage.accessToken(), '{"access_token":"bridge"}');
    await storage.persistSession('{"access_token":"persisted"}');
    await storage.removePersistedSession();

    expect(calls.map((MethodCall call) => call.method), <String>[
      'hasSession',
      'readSession',
      'writeSession',
      'clearSession',
    ]);
  });
}
