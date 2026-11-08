import '../../core/formatting/plain_format.dart';
import '../../core/ids.dart';
import '../../data/models/models.dart';
import '../policy.dart';

final class BillingLine {
  const BillingLine(this.label, this.value);

  final String label;
  final String value;
}

final class BillingCalculationResult {
  const BillingCalculationResult({
    required this.valid,
    this.errorMessage,
    required this.startMeterKwh,
    required this.endMeterKwh,
    required this.verifiedKwh,
    required this.energyCharge,
    required this.serviceFee,
    required this.gatewayFee,
    required this.adjustment,
    required this.finalTotal,
    required this.simulated,
    required this.flaggedForReview,
    required this.lines,
    this.invoice,
  });

  final bool valid;
  final String? errorMessage;
  final double startMeterKwh;
  final double endMeterKwh;
  final double verifiedKwh;
  final double energyCharge;
  final double serviceFee;
  final double gatewayFee;
  final double adjustment;
  final double finalTotal;
  final bool simulated;
  final bool flaggedForReview;
  final List<BillingLine> lines;
  final Invoice? invoice;
}

final class CancellationResult {
  const CancellationResult({
    required this.free,
    required this.fee,
    required this.refundAmount,
    required this.message,
  });

  final bool free;
  final double fee;
  final double refundAmount;
  final String message;
}

abstract final class BillingEngine {
  static BillingCalculationResult calculateBill({
    required String sessionId,
    required String consumerId,
    required String hostId,
    required String stationName,
    ChargerStation? station,
    required String? meterLevel,
    required bool simulated,
    required double startMeterKwh,
    required double endMeterKwh,
  }) {
    if (!isVerifiedMeterLevel(meterLevel)) {
      return _invalid(
        'This station has no verified meter, so automatic energy-based paid '
        'billing is not available. The station stays visible for discovery and '
        'can only take a reservation without automatic billing.',
      );
    }
    if (startMeterKwh.isNaN || startMeterKwh.isInfinite) {
      return _invalid('Starting meter reading is not a valid number.');
    }
    if (endMeterKwh.isNaN || endMeterKwh.isInfinite) {
      return _invalid('Ending meter reading is not a valid number.');
    }
    if (startMeterKwh < 0) {
      return _invalid('Starting meter reading must not be negative.');
    }
    if (endMeterKwh < startMeterKwh) {
      return _invalid(
        'Ending meter reading cannot be lower than the starting meter reading.',
      );
    }

    final double verifiedKwh = round2(endMeterKwh - startMeterKwh);
    final double tariff =
        station?.pricePerKwh ?? AmpPolicy.fallbackTariffInrPerKwh;
    double serviceFee = station?.serviceFee ?? AmpPolicy.defaultServiceFeeInr;
    double gatewayFee = station?.gatewayFee ?? AmpPolicy.defaultGatewayFeeInr;

    final double energyCharge = round2(verifiedKwh * tariff);
    final bool noEnergy = verifiedKwh <= 0;
    if (noEnergy) {
      serviceFee = 0;
      gatewayFee = 0;
    }
    final double finalTotal = round2(energyCharge + serviceFee + gatewayFee);
    final bool flagged = verifiedKwh > AmpPolicy.meterReadReviewThresholdKwh;

    final List<BillingLine> lines = <BillingLine>[
      BillingLine('Starting meter reading', PlainFormat.kwh(startMeterKwh)),
      BillingLine('Ending meter reading', PlainFormat.kwh(endMeterKwh)),
      BillingLine('Verified energy consumed', PlainFormat.kwh(verifiedKwh)),
      BillingLine(
        'Energy charge',
        '${PlainFormat.money(energyCharge)}  '
            '(${PlainFormat.money(tariff)}/kWh)',
      ),
      BillingLine('Amperly service fee', PlainFormat.money(serviceFee)),
      BillingLine('Payment gateway charge', PlainFormat.money(gatewayFee)),
      BillingLine('Final amount', PlainFormat.money(finalTotal)),
    ];
    if (simulated) {
      lines.add(
        const BillingLine(
          'Demo meter',
          'Simulated reading — not live charger hardware',
        ),
      );
    }
    if (flagged) {
      lines.add(
        const BillingLine(
          'Review',
          'Reading is unusually large and has been flagged for admin review',
        ),
      );
    }

    final Invoice invoice = Invoice(
      id: newId(),
      sessionId: sessionId,
      consumerId: consumerId,
      hostId: hostId,
      stationName: stationName,
      verifiedKwh: verifiedKwh,
      energyCharge: energyCharge,
      serviceFee: serviceFee,
      gatewayFee: gatewayFee,
      adjustment: 0,
      adjustmentNote: '',
      finalTotal: finalTotal,
      paymentId: '',
      status: AmpPolicy.invoiceIssued,
      issuedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    return BillingCalculationResult(
      valid: true,
      startMeterKwh: startMeterKwh,
      endMeterKwh: endMeterKwh,
      verifiedKwh: verifiedKwh,
      energyCharge: energyCharge,
      serviceFee: serviceFee,
      gatewayFee: gatewayFee,
      adjustment: 0,
      finalTotal: finalTotal,
      simulated: simulated,
      flaggedForReview: flagged,
      lines: List<BillingLine>.unmodifiable(lines),
      invoice: invoice,
    );
  }

  static CancellationResult calculateCancellation(
    Reservation? reservation,
    int nowMs, {
    double lateFee = AmpPolicy.lateCancellationFeeInr,
  }) {
    if (reservation == null) {
      return const CancellationResult(
        free: true,
        fee: 0,
        refundAmount: 0,
        message: 'Nothing to cancel.',
      );
    }
    if (reservation.isInFreeCancellationWindow(nowMs)) {
      return const CancellationResult(
        free: true,
        fee: 0,
        refundAmount: 0,
        message:
            'Cancelled free of charge. No payment is collected in this build, '
            'and no energy charge applies because no energy was consumed.',
      );
    }
    return CancellationResult(
      free: false,
      fee: lateFee,
      refundAmount: 0,
      message:
          'Late cancellation: the disclosed ${PlainFormat.money(lateFee)} '
          'reservation-protection fee is recorded on this booking. No energy '
          'charge applies because no energy was consumed. No payment is '
          'collected in this build.',
    );
  }

  static Invoice? applyRefund(
    Invoice? invoice,
    double refundAmount,
    String note,
  ) {
    if (invoice == null) {
      return null;
    }
    final double amount = round2(refundAmount < 0 ? 0 : refundAmount);
    final double adjustment = round2(invoice.adjustment + amount);
    final double total = round2(
      (invoice.energyCharge +
              invoice.serviceFee +
              invoice.gatewayFee -
              adjustment)
          .clamp(0, double.infinity),
    );
    final String status;
    if (adjustment >=
        invoice.energyCharge + invoice.serviceFee + invoice.gatewayFee) {
      status = AmpPolicy.invoiceRefunded;
    } else if (adjustment > 0) {
      status = AmpPolicy.invoicePartiallyRefunded;
    } else {
      status = invoice.status ?? AmpPolicy.invoiceIssued;
    }
    return invoice.copyWith(
      adjustment: adjustment,
      adjustmentNote: note,
      finalTotal: total,
      status: status,
    );
  }

  static bool isVerifiedMeterLevel(String? meterLevel) {
    final String level = (meterLevel ?? '').toUpperCase();
    return level.startsWith('LEVEL_1') || level.startsWith('LEVEL_2');
  }

  static double round2(double value) => (value * 100).round() / 100;

  static String money(double amount) => PlainFormat.money(amount);

  static BillingCalculationResult _invalid(String message) {
    return BillingCalculationResult(
      valid: false,
      errorMessage: message,
      startMeterKwh: 0,
      endMeterKwh: 0,
      verifiedKwh: 0,
      energyCharge: 0,
      serviceFee: 0,
      gatewayFee: 0,
      adjustment: 0,
      finalTotal: 0,
      simulated: false,
      flaggedForReview: false,
      lines: const <BillingLine>[],
    );
  }
}
