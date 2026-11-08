import '../../core/formatting/plain_format.dart';
import '../../core/ids.dart';
import '../../data/models/models.dart';
import '../policy.dart';

final class PaymentResult {
  const PaymentResult({
    required this.success,
    required this.payment,
    required this.message,
  });

  final bool success;
  final Payment? payment;
  final String message;

  String get paymentId => payment?.id ?? '';
  String get idempotencyKey => payment?.idempotencyKey ?? '';
  double get amount => payment?.authorizedAmount ?? 0;
}

abstract final class PaymentManager {
  static bool _gatewayAvailable = true;
  static final Set<String> _processedKeys = <String>{};

  static void setGatewayAvailable(bool available) {
    _gatewayAvailable = available;
  }

  static bool get isGatewayAvailable => _gatewayAvailable;

  static void resetIdempotencyCache() => _processedKeys.clear();

  static PaymentResult authorize({
    required String consumerId,
    required String hostId,
    required String reservationId,
    required double amount,
    required String idempotencyKey,
    int? nowMs,
  }) {
    final int now = nowMs ?? DateTime.now().millisecondsSinceEpoch;
    if (_processedKeys.contains(idempotencyKey)) {
      return PaymentResult(
        success: true,
        payment: Payment(
          id: 'PAY_IDEMPOTENT_$idempotencyKey',
          reservationId: reservationId,
          consumerId: consumerId,
          hostId: hostId,
          idempotencyKey: idempotencyKey,
          gateway: 'SANDBOX',
          gatewayReference: 'auth_$idempotencyKey',
          authorizedAmount: amount,
          status: AmpPolicy.paymentAuthorized,
          createdAtMs: now,
          updatedAtMs: now,
        ),
        message:
            'This authorization already exists, so no second charge was made.',
      );
    }
    if (!_gatewayAvailable) {
      return PaymentResult(
        success: false,
        payment: Payment(
          id: newId(),
          reservationId: reservationId,
          consumerId: consumerId,
          hostId: hostId,
          idempotencyKey: idempotencyKey,
          gateway: 'SANDBOX',
          authorizedAmount: amount,
          status: AmpPolicy.paymentFailed,
          failureReason: 'Gateway unreachable',
          createdAtMs: now,
          updatedAtMs: now,
        ),
        message:
            'The payment gateway could not be reached, so no paid reservation '
            'was created. You can retry safely — no duplicate booking will be made.',
      );
    }
    _processedKeys.add(idempotencyKey);
    return PaymentResult(
      success: true,
      payment: Payment(
        id: newId(),
        reservationId: reservationId,
        consumerId: consumerId,
        hostId: hostId,
        idempotencyKey: idempotencyKey,
        gateway: 'SANDBOX',
        gatewayReference: 'auth_${newId().substring(0, 10)}',
        authorizedAmount: amount,
        status: AmpPolicy.paymentAuthorized,
        createdAtMs: now,
        updatedAtMs: now,
      ),
      message: 'Sandbox payment authorized.',
    );
  }

  static PaymentResult capture(
    Payment? payment,
    String sessionId,
    double verifiedAmount, {
    int? nowMs,
  }) {
    if (payment == null) {
      return const PaymentResult(
        success: false,
        payment: null,
        message: 'No authorization found for this session.',
      );
    }
    if (payment.status == AmpPolicy.paymentFailed) {
      return PaymentResult(
        success: false,
        payment: payment,
        message: 'This authorization failed earlier and cannot be captured.',
      );
    }
    final Payment updated = payment.copyWith(
      sessionId: sessionId,
      capturedAmount: _round2(verifiedAmount < 0 ? 0 : verifiedAmount),
      status: AmpPolicy.paymentCaptured,
      updatedAtMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    return PaymentResult(
      success: true,
      payment: updated,
      message:
          'Captured ${PlainFormat.money(updated.capturedAmount)} based on verified meter readings.',
    );
  }

  static PaymentResult refund(
    Payment? payment,
    double amount,
    String reason, {
    int? nowMs,
  }) {
    if (payment == null) {
      return const PaymentResult(
        success: false,
        payment: null,
        message: 'Nothing to refund.',
      );
    }
    final double refundable = payment.capturedAmount - payment.refundedAmount;
    if (refundable <= 0) {
      return PaymentResult(
        success: false,
        payment: payment,
        message: 'The captured amount has already been refunded.',
      );
    }
    final double applied = amount.clamp(0, refundable);
    final Payment updated = payment.copyWith(
      refundedAmount: _round2(payment.refundedAmount + applied),
      status: AmpPolicy.paymentRefunded,
      failureReason: null,
      updatedAtMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    return PaymentResult(
      success: true,
      payment: updated,
      message: 'Refunded ${PlainFormat.money(applied)}. $reason',
    );
  }

  static PaymentResult release(
    Payment? payment,
    double lateCancellationFee, {
    int? nowMs,
  }) {
    if (payment == null) {
      return const PaymentResult(
        success: true,
        payment: null,
        message: 'No authorization to release.',
      );
    }
    final Payment updated = payment.copyWith(
      status: lateCancellationFee > 0
          ? AmpPolicy.paymentCaptured
          : AmpPolicy.paymentReleased,
      capturedAmount: _round2(lateCancellationFee),
      lateCancellationFee: _round2(lateCancellationFee),
      updatedAtMs: nowMs ?? DateTime.now().millisecondsSinceEpoch,
    );
    return PaymentResult(
      success: true,
      payment: updated,
      message: lateCancellationFee > 0
          ? 'Released the energy authorization; the disclosed '
                '${PlainFormat.money(lateCancellationFee)} late-cancellation fee was applied.'
          : 'Released the unused authorization. No energy charge applies.',
    );
  }

  static String newIdempotencyKey(
    String consumerId,
    String stationId,
    int slotStartMs,
  ) {
    return '$consumerId:$stationId:$slotStartMs';
  }

  static double _round2(double value) => (value * 100).round() / 100;
}
