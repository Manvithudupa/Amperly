import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_chip.dart';
import 'package:amperly/core/widgets/text_action.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/consumer/application/chat_providers.dart';
import 'package:amperly/features/consumer/presentation/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const AppUser _consumer = AppUser(id: 'consumer-1', name: 'Asha');
const CommunicationThread _thread = CommunicationThread(
  id: 'thread-1',
  consumerId: 'consumer-1',
  consumerName: 'Asha',
  hostId: 'host-1',
  hostName: 'Ravi',
  createdAtMs: 1000,
  expiresAtMs: 9000000000000,
);

Widget _screen({
  required CommunicationThread thread,
  required List<ChatMessage> messages,
}) {
  final ChatThreadData data = ChatThreadData(
    consumer: _consumer,
    thread: thread,
  );
  return ProviderScope(
    overrides: [
      chatThreadProvider(thread.id).overrideWith(
        (Ref ref) async => RepositorySuccess<ChatThreadData>(data),
      ),
      chatMessagesProvider(
        thread.id,
      ).overrideWith((Ref ref) => Stream<List<ChatMessage>>.value(messages)),
    ],
    child: MaterialApp(
      theme: AmpTheme.light(),
      home: ChatScreen(threadId: thread.id),
    ),
  );
}

void main() {
  testWidgets('renders messages as a hairline ledger with text quick actions', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(460, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const List<ChatMessage> messages = <ChatMessage>[
      ChatMessage(
        id: 'message-1',
        threadId: 'thread-1',
        senderId: 'host-1',
        receiverId: 'consumer-1',
        messageText: 'The charger is free now.',
        createdAtMs: 1000,
      ),
      ChatMessage(
        id: 'message-2',
        threadId: 'thread-1',
        senderId: 'consumer-1',
        receiverId: 'host-1',
        messageText: 'On my way.',
        createdAtMs: 2000,
      ),
    ];

    await tester.pumpWidget(_screen(thread: _thread, messages: messages));
    await tester.pumpAndSettle();

    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('The charger is free now.'), findsOneWidget);
    expect(find.text('On my way.'), findsOneWidget);
    expect(find.text(AmpStrings.chatYou.toUpperCase()), findsOneWidget);
    expect(find.text(AmpStrings.chatComposerHint), findsOneWidget);
    expect(find.text(AmpStrings.chatSend), findsOneWidget);
    expect(find.byType(TextAction), findsWidgets);
    expect(find.byType(AmpChip), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('an expired thread shows closure copy instead of a composer', (
    WidgetTester tester,
  ) async {
    final CommunicationThread expired = _thread.copyWith(
      expiresAtMs: DateTime.now().millisecondsSinceEpoch - 1000,
    );

    await tester.pumpWidget(_screen(thread: expired, messages: const []));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.chatExpired), findsOneWidget);
    expect(find.text(AmpStrings.chatComposerHint), findsNothing);
    expect(find.text(AmpStrings.chatSend), findsNothing);
    expect(find.byType(AmpChip), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a thread with no messages shows empty copy and a composer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(460, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_screen(thread: _thread, messages: const []));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.chatNoMessagesTitle), findsOneWidget);
    expect(find.text(AmpStrings.chatNoMessagesBody), findsOneWidget);
    expect(find.text(AmpStrings.chatComposerHint), findsOneWidget);
    expect(find.text(AmpStrings.chatSend), findsOneWidget);
  });
}
