import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/formatting/amp_format.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
import 'package:amperly/core/widgets/status_dot_label.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/consumer/application/chat_providers.dart';
import 'package:amperly/features/consumer/presentation/messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a dated thread with station context', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(460, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final int now = DateTime.now().millisecondsSinceEpoch;
    final CommunicationThread thread = CommunicationThread(
      id: 'thread-1',
      reservationId: 'reservation-1',
      consumerId: 'consumer-1',
      consumerName: 'Asha',
      hostId: 'host-1',
      hostName: 'Ravi',
      createdAtMs: now - Duration.millisecondsPerDay,
      expiresAtMs: now + Duration.millisecondsPerDay,
    );
    final ChatMessage latest = ChatMessage(
      id: 'message-1',
      threadId: 'thread-1',
      senderId: 'host-1',
      receiverId: 'consumer-1',
      messageText: 'The charger is free now.',
      createdAtMs: now - Duration.millisecondsPerHour,
    );
    const Reservation reservation = Reservation(
      id: 'reservation-1',
      stationId: 'station-1',
      stationName: 'Padubidri Service Road Charger',
    );
    final ChatInboxData data = ChatInboxData(
      viewerId: 'consumer-1',
      threads: <CommunicationThread>[thread],
      latestMessages: <String, ChatMessage>{thread.id: latest},
      reservations: <String, Reservation>{reservation.id: reservation},
    );
    final DateTime stamp = DateTime.fromMillisecondsSinceEpoch(
      latest.createdAtMs,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatInboxProvider.overrideWith(
            (Ref ref) async => RepositorySuccess<ChatInboxData>(data),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const MessagesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text('The charger is free now.'), findsOneWidget);
    expect(
      find.text(AmpStrings.chatAboutStation('Padubidri Service Road Charger')),
      findsOneWidget,
    );
    expect(find.text(AmpFormat.dayNumber(stamp)), findsOneWidget);
    expect(find.text(AmpFormat.monthShort(stamp)), findsOneWidget);
    expect(find.textContaining(AmpStrings.chatOpen), findsOneWidget);
    expect(find.byType(StatusDotLabel), findsOneWidget);
    expect(find.byType(AmpBadge), findsNothing);
  });

  testWidgets('empty inbox is led by type and a text action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatInboxProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<ChatInboxData>(
              ChatInboxData(
                viewerId: 'consumer-1',
                threads: <CommunicationThread>[],
                latestMessages: <String, ChatMessage>{},
                reservations: <String, Reservation>{},
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const MessagesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.chatEmptyTitle), findsOneWidget);
    expect(find.text(AmpStrings.chatEmptyBody), findsOneWidget);
    expect(find.text(AmpStrings.chatOpenBookings), findsOneWidget);
    expect(find.byType(AmpBadge), findsNothing);
  });
}
