import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/features/consumer/application/chat_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const CommunicationThread open = CommunicationThread(
    id: 'thread-1',
    reservationId: 'reservation-1',
    consumerId: 'consumer-1',
    consumerName: 'Asha',
    hostId: 'host-1',
    hostName: 'Ravi',
    createdAtMs: 1000,
    expiresAtMs: 5000,
  );

  group('ChatRules gates', () {
    test('an unblocked, enabled thread is open until its expiry', () {
      expect(ChatRules.isOpen(open, 4000), isTrue);
      expect(ChatRules.isOpen(open, 5000), isTrue);
      expect(ChatRules.isOpen(open, 5001), isFalse);
      expect(ChatRules.isOpen(null, 4000), isFalse);
    });

    test('blocked, disabled and expired threads are closed with copy', () {
      final CommunicationThread blocked = open.copyWith(isBlocked: true);
      final CommunicationThread disabled = open.copyWith(isChatEnabled: false);
      final CommunicationThread expired = open.copyWith(expiresAtMs: 1000);

      expect(ChatRules.isOpen(blocked, 4000), isFalse);
      expect(ChatRules.closureMessage(blocked, 4000), AmpStrings.chatBlocked);
      expect(ChatRules.isOpen(disabled, 4000), isFalse);
      expect(ChatRules.closureMessage(disabled, 4000), AmpStrings.chatDisabled);
      expect(ChatRules.isOpen(expired, 2000), isFalse);
      expect(ChatRules.closureMessage(expired, 2000), AmpStrings.chatExpired);
      expect(ChatRules.closureMessage(open, 4000), isNull);
    });
  });

  group('message validation', () {
    test('empty and whitespace-only messages are refused', () {
      expect(ChatRules.messageError(''), AmpStrings.chatMessageRequired);
      expect(ChatRules.messageError('   \n  '), AmpStrings.chatMessageRequired);
    });

    test('the limit is inclusive and counts trimmed text', () {
      final String atLimit = List<String>.filled(
        ChatRules.maxMessageLength,
        'a',
      ).join();
      final String overLimit = '${atLimit}a';
      expect(ChatRules.messageError(atLimit), isNull);
      expect(
        ChatRules.messageError(overLimit),
        AmpStrings.chatMessageTooLong(ChatRules.maxMessageLength),
      );
      expect(ChatRules.messageError('  hello  '), isNull);
    });
  });

  group('preview and participants', () {
    test('preview collapses whitespace and truncates long text', () {
      expect(ChatRules.preview('  Hello\n\n there  '), 'Hello there');
      expect(ChatRules.preview(''), AmpStrings.chatNoMessagesPreview);
      expect(ChatRules.preview(null), AmpStrings.chatNoMessagesPreview);

      final String long = List<String>.filled(
        ChatRules.previewLength + 20,
        'b',
      ).join();
      final String preview = ChatRules.preview(long);
      expect(preview.endsWith('…'), isTrue);
      expect(preview.length, ChatRules.previewLength + 1);
    });

    test('each side sees the other participant', () {
      expect(ChatRules.title(open, 'consumer-1'), 'Ravi');
      expect(ChatRules.title(open, 'host-1'), 'Asha');
      expect(ChatRules.counterpartId(open, 'consumer-1'), 'host-1');
      expect(ChatRules.counterpartId(open, 'host-1'), 'consumer-1');
      expect(ChatRules.counterpartId(open, 'someone-else'), isNull);

      const CommunicationThread unnamed = CommunicationThread(
        id: 'thread-2',
        hostId: 'host-2',
      );
      expect(
        ChatRules.title(unnamed, 'consumer-1'),
        AmpStrings.chatHostFallback,
      );
    });

    test('expiry copy is written and off-platform requests are flagged', () {
      expect(ChatRules.closesOn(open), contains('Chat closes on'));
      expect(ChatRules.closesOn(open.copyWith(expiresAtMs: 0)), isEmpty);
      expect(ChatRules.warnsOffPlatform('Please pay cash'), isTrue);
      expect(ChatRules.warnsOffPlatform('See you at the charger'), isFalse);
    });
  });
}
