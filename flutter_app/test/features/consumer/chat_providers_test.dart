import 'dart:async';

import 'package:amperly/data/models/models.dart';
import 'package:amperly/features/consumer/application/chat_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('closing a chat thread disposes its live message stream', () async {
    final StreamController<List<ChatMessage>> messages =
        StreamController<List<ChatMessage>>();
    bool disposed = false;
    final ProviderContainer container = ProviderContainer(
      overrides: [
        chatMessagesProvider('thread-1').overrideWith((Ref ref) {
          ref.onDispose(() => disposed = true);
          return messages.stream;
        }),
      ],
    );
    addTearDown(() async {
      await messages.close();
      container.dispose();
    });

    final ProviderSubscription<AsyncValue<List<ChatMessage>>> subscription =
        container.listen(
          chatMessagesProvider('thread-1'),
          (
            AsyncValue<List<ChatMessage>>? previous,
            AsyncValue<List<ChatMessage>> next,
          ) {},
        );
    await Future<void>.delayed(Duration.zero);
    expect(disposed, isFalse);

    subscription.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(disposed, isTrue);
  });
}
