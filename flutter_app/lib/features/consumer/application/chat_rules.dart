import '../../../core/formatting/plain_format.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../domain/engines/chat_manager.dart';

/// Pure rules for the consumer messaging surface.
///
/// A thread closes itself a week after the booking slot ends, and either
/// participant can block it. The screen asks these rules before it offers a
/// composer, so a closed conversation never looks usable.
abstract final class ChatRules {
  static const int maxMessageLength = 1000;
  static const int previewLength = 96;

  static bool isOpen(CommunicationThread? thread, int nowMs) {
    return thread != null &&
        thread.isChatEnabled &&
        !thread.isBlocked &&
        !thread.isExpired(nowMs);
  }

  static String? closureMessage(CommunicationThread? thread, int nowMs) {
    if (thread == null) {
      return null;
    }
    if (thread.isBlocked) {
      return AmpStrings.chatBlocked;
    }
    if (!thread.isChatEnabled) {
      return AmpStrings.chatDisabled;
    }
    if (thread.isExpired(nowMs)) {
      return AmpStrings.chatExpired;
    }
    return null;
  }

  static String? messageError(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return AmpStrings.chatMessageRequired;
    }
    if (value.length > maxMessageLength) {
      return AmpStrings.chatMessageTooLong(maxMessageLength);
    }
    return null;
  }

  static String preview(String? raw) {
    final String value = (raw ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value.isEmpty) {
      return AmpStrings.chatNoMessagesPreview;
    }
    if (value.length <= previewLength) {
      return value;
    }
    return '${value.substring(0, previewLength)}…';
  }

  /// The name of the person on the other side of the conversation.
  static String title(CommunicationThread thread, String viewerId) {
    final bool viewingAsHost = viewerId == thread.hostId;
    final String name =
        (viewingAsHost ? thread.consumerName : thread.hostName)?.trim() ?? '';
    return name.isEmpty ? AmpStrings.chatHostFallback : name;
  }

  static String? counterpartId(CommunicationThread thread, String viewerId) {
    if (viewerId == thread.consumerId) {
      return thread.hostId;
    }
    if (viewerId == thread.hostId) {
      return thread.consumerId;
    }
    return null;
  }

  static String closesOn(CommunicationThread thread) {
    if (thread.expiresAtMs <= 0) {
      return '';
    }
    return AmpStrings.chatClosesOn(PlainFormat.dateTime(thread.expiresAtMs));
  }

  static bool warnsOffPlatform(String text) =>
      ChatManager.containsOffPlatformPaymentRequest(text);
}
