import 'package:amperly/core/geo/geo_utils.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/domain/engines/chat_manager.dart';
import 'package:amperly/domain/engines/payment_manager.dart';
import 'package:amperly/domain/policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatManager', () {
    test('masks phone numbers and sanitises free text', () {
      expect(ChatManager.maskPhoneNumber(null), '••••');
      expect(ChatManager.maskPhoneNumber('12'), '••••');
      expect(ChatManager.maskPhoneNumber('+91 98765 43210'), '+91 •••• ••10');
      expect(
        ChatManager.sanitizeText('Call 9876543210', '9876543210', null),
        'Call +91 •••• ••10',
      );
      expect(
        ChatManager.sanitizeText('Use 98765 43210 now', null, null),
        'Use •••• masked •••• now',
      );
      expect(ChatManager.sanitizeText(null, null, null), '');
    });

    test(
      'flags off-platform payment requests without blocking the message',
      () {
        expect(
          ChatManager.containsOffPlatformPaymentRequest('Pay cash'),
          isTrue,
        );
        expect(
          ChatManager.containsOffPlatformPaymentRequest('See you at the port'),
          isFalse,
        );
        final message = ChatManager.createMessage(
          threadId: 't1',
          reservationId: 'r1',
          senderId: 'u1',
          receiverId: 'u2',
          rawText: 'Pay cash at the gate, call 9876543210',
          ownPhone: '9876543210',
          nowMs: 5,
        );
        expect(message.messageText, contains('••••'));
        expect(message.messageText, contains('off-platform payment requests'));
        expect(message.createdAtMs, 5);
      },
    );

    test('thread expiry follows the slot and is never open after expiry', () {
      const reservation = Reservation(id: 'r1', endTimeMs: 1000);
      final thread = ChatManager.createThread(
        reservation: reservation,
        consumer: const AppUser(id: 'c1', name: 'Asha', phone: '9876543210'),
        host: const AppUser(id: 'h1', name: 'Ravi', phone: '9123456780'),
        nowMs: 0,
      );
      expect(thread.expiresAtMs, 1000 + ChatManager.threadLifetimeAfterSlotMs);
      expect(ChatManager.isThreadOpen(thread, 999), isTrue);
      expect(ChatManager.isThreadOpen(thread, thread.expiresAtMs + 1), isFalse);
      expect(ChatManager.isThreadOpen(null, 0), isFalse);

      final reused = ChatManager.reuseForReservation(
        thread: thread,
        reservation: reservation,
        consumer: null,
        host: null,
        nowMs: 100,
      );
      expect(reused, isNotNull);
      expect(reused!.expiresAtMs, thread.expiresAtMs);
      expect(ChatManager.expiryLabel(0), isNotEmpty);
    });
  });

  group('PaymentManager sandbox', () {
    setUp(() {
      PaymentManager.setGatewayAvailable(true);
      PaymentManager.resetIdempotencyCache();
    });

    test('authorizes once and reuses the idempotency key', () {
      final first = PaymentManager.authorize(
        consumerId: 'c1',
        hostId: 'h1',
        reservationId: 'r1',
        amount: 100,
        idempotencyKey: 'c1:st1:10',
        nowMs: 1,
      );
      expect(first.success, isTrue);
      expect(first.amount, 100);
      expect(first.payment!.status, AmpPolicy.paymentAuthorized);

      final second = PaymentManager.authorize(
        consumerId: 'c1',
        hostId: 'h1',
        reservationId: 'r1',
        amount: 100,
        idempotencyKey: 'c1:st1:10',
        nowMs: 2,
      );
      expect(second.success, isTrue);
      expect(second.paymentId, startsWith('PAY_IDEMPOTENT_'));
      expect(second.message, contains('no second charge'));
      expect(PaymentManager.newIdempotencyKey('c1', 'st1', 10), 'c1:st1:10');
    });

    test('failed gateway creates no usable authorization', () {
      PaymentManager.setGatewayAvailable(false);
      final result = PaymentManager.authorize(
        consumerId: 'c1',
        hostId: 'h1',
        reservationId: 'r1',
        amount: 100,
        idempotencyKey: 'k',
      );
      expect(result.success, isFalse);
      expect(result.payment!.status, AmpPolicy.paymentFailed);
      expect(result.message, contains('no paid reservation'));
      expect(result.payment!.failureReason, isNotNull);
    });

    test('capture, refund and release stay tied to verified amounts', () {
      final authorized = PaymentManager.authorize(
        consumerId: 'c1',
        hostId: 'h1',
        reservationId: 'r1',
        amount: 100,
        idempotencyKey: 'k',
      ).payment!;
      final captured = PaymentManager.capture(
        authorized,
        'sess1',
        80.255,
        nowMs: 10,
      );
      expect(captured.success, isTrue);
      expect(captured.payment!.capturedAmount, 80.26);
      expect(captured.payment!.status, AmpPolicy.paymentCaptured);
      expect(captured.message, contains('verified meter'));
      expect(PaymentManager.capture(null, 's', 1).success, isFalse);

      final refunded = PaymentManager.refund(
        captured.payment,
        100,
        'Goodwill',
        nowMs: 11,
      );
      expect(refunded.success, isTrue);
      expect(refunded.payment!.refundedAmount, 80.26);
      expect(refunded.payment!.status, AmpPolicy.paymentRefunded);
      expect(refunded.message, contains('Goodwill'));
      expect(
        PaymentManager.refund(refunded.payment, 1, 'again').success,
        isFalse,
      );

      final released = PaymentManager.release(authorized, 20, nowMs: 12);
      expect(released.payment!.status, AmpPolicy.paymentCaptured);
      expect(released.payment!.lateCancellationFee, 20);
      expect(released.message, contains('late-cancellation'));
      final clear = PaymentManager.release(authorized, 0);
      expect(clear.payment!.status, AmpPolicy.paymentReleased);
      expect(clear.message, contains('No energy charge'));
    });
  });

  group('GeoUtils', () {
    test('haversine, projection, detour and compass are consistent', () {
      expect(GeoUtils.distanceKm(0, 0, 0, 0), 0);
      expect(GeoUtils.distanceKm(0, 0, 0, 1), closeTo(111.19, 0.1));
      expect(
        GeoUtils.fractionAlongRoute(0.5, 0.5, 0, 0, 0, 1),
        closeTo(0.5, 0.001),
      );
      expect(GeoUtils.distanceToRouteKm(0, 0.5, 0, 0, 0, 1), closeTo(0, 0.001));
      expect(GeoUtils.detourKm(2), 4.4);
      expect(GeoUtils.detourMinutes(45), 60);
      expect(GeoUtils.drivingMinutes(45), 60);
      expect(GeoUtils.bearingDegrees(0, 0, 0, 1), closeTo(90, 0.001));
      expect(GeoUtils.compassLabel(90), 'east');
    });
  });
}
