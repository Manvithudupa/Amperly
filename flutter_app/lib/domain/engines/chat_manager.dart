import '../../core/formatting/plain_format.dart';
import '../../core/ids.dart';
import '../../data/models/models.dart';
import '../policy.dart';

abstract final class ChatManager {
  static const int threadLifetimeAfterSlotMs =
      AmpPolicy.chatThreadLifetimeDays * 24 * 60 * 60 * 1000;

  static const List<String> quickQuestions = <String>[
    'Where is the charging entrance?',
    'The port looks occupied, can you help?',
    'Can I extend my slot by 15 minutes?',
    'Can you confirm the meter readings?',
  ];

  static String maskPhoneNumber(String? phone) {
    final String trimmed = (phone ?? '').trim();
    if (trimmed.isEmpty) {
      return '••••';
    }
    final String digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) {
      return '••••';
    }
    return '+91 •••• ••${digits.substring(digits.length - 2)}';
  }

  static String sanitizeText(
    String? text,
    String? ownPhone,
    String? otherPhone,
  ) {
    if (text == null) {
      return '';
    }
    String sanitized = text;
    if ((ownPhone ?? '').trim().isNotEmpty) {
      sanitized = sanitized.replaceAll(
        ownPhone!.trim(),
        maskPhoneNumber(ownPhone),
      );
    }
    if ((otherPhone ?? '').trim().isNotEmpty) {
      sanitized = sanitized.replaceAll(
        otherPhone!.trim(),
        maskPhoneNumber(otherPhone),
      );
    }
    return sanitized.replaceAll(
      RegExp(r'(?<!\d)(\d[\d\s-]{8,}\d)(?!\d)'),
      '•••• masked ••••',
    );
  }

  static bool containsOffPlatformPaymentRequest(String? text) {
    final String lower = (text ?? '').toLowerCase();
    return lower.contains('pay cash') ||
        lower.contains('direct gpay') ||
        lower.contains('off platform') ||
        lower.contains('transfer account') ||
        lower.contains('paytm me directly') ||
        lower.contains('upi to my') ||
        lower.contains('outside the app');
  }

  static int expiryFor(Reservation? reservation, int nowMs) {
    final int slotEnd = reservation?.endTimeMs ?? nowMs;
    return (slotEnd > nowMs ? slotEnd : nowMs) + threadLifetimeAfterSlotMs;
  }

  static CommunicationThread createThread({
    required Reservation? reservation,
    required AppUser? consumer,
    required AppUser? host,
    int? nowMs,
  }) {
    final int now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    return CommunicationThread(
      id: newId(),
      reservationId: reservation?.id,
      consumerId: consumer?.id,
      consumerName: consumer?.name ?? 'Consumer',
      hostId: host?.id,
      hostName: host?.name ?? 'Host',
      maskedConsumerNumber: maskPhoneNumber(consumer?.phone),
      maskedHostNumber: maskPhoneNumber(host?.phone),
      createdAtMs: now,
      expiresAtMs: expiryFor(reservation, now),
    );
  }

  static CommunicationThread? reuseForReservation({
    required CommunicationThread? thread,
    required Reservation? reservation,
    required AppUser? consumer,
    required AppUser? host,
    int? nowMs,
  }) {
    if (thread == null) {
      return null;
    }
    final int now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    final int freshExpiry = expiryFor(reservation, now);
    return thread.copyWith(
      reservationId: reservation?.id ?? thread.reservationId,
      consumerName: consumer?.name ?? thread.consumerName,
      hostName: host?.name ?? thread.hostName,
      maskedConsumerNumber: consumer == null
          ? thread.maskedConsumerNumber
          : maskPhoneNumber(consumer.phone),
      maskedHostNumber: host == null
          ? thread.maskedHostNumber
          : maskPhoneNumber(host.phone),
      expiresAtMs: thread.expiresAtMs > freshExpiry
          ? thread.expiresAtMs
          : freshExpiry,
    );
  }

  static ChatMessage createMessage({
    required String threadId,
    required String? reservationId,
    required String senderId,
    required String receiverId,
    required String rawText,
    String? ownPhone,
    String? otherPhone,
    int? nowMs,
  }) {
    final bool offPlatform = containsOffPlatformPaymentRequest(rawText);
    String body = sanitizeText(rawText, ownPhone, otherPhone);
    if (offPlatform) {
      body +=
          '\n[Amperly: off-platform payment requests are flagged. Paying '
          'outside the app removes your dispute protection.]';
    }
    return ChatMessage(
      id: newId(),
      threadId: threadId,
      reservationId: reservationId,
      senderId: senderId,
      receiverId: receiverId,
      messageText: body,
      createdAtMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  static bool isThreadOpen(CommunicationThread? thread, int nowMs) {
    return thread != null && !thread.isBlocked && !thread.isExpired(nowMs);
  }

  static String expiryLabel(int expiresAtMs) =>
      PlainFormat.dateTime(expiresAtMs);
}
