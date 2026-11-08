import 'dart:math';

import '../../core/formatting/plain_format.dart';
import '../../data/models/models.dart';
import '../policy.dart';
import 'route_planner_engine.dart';

final class BookingCheck {
  const BookingCheck({
    required this.allowed,
    required this.reason,
    required this.requiresPaidAuthorization,
  });

  final bool allowed;
  final String reason;
  final bool requiresPaidAuthorization;
}

final class PricePreview {
  const PricePreview({
    required this.estimatedKwh,
    required this.energyCharge,
    required this.serviceFee,
    required this.gatewayFee,
    required this.estimatedTotal,
    required this.authorizedAmount,
  });

  final double estimatedKwh;
  final double energyCharge;
  final double serviceFee;
  final double gatewayFee;
  final double estimatedTotal;
  final double authorizedAmount;
}

abstract final class ReservationEngine {
  static const String cancellationPolicy =
      '• Free cancellation until 60 minutes before the slot.\n'
      '• A disclosed ₹20 late-cancellation fee is recorded after that window.\n'
      '• No energy charge is applied when no energy was consumed.\n'
      '• No payment is collected in this build: no card is charged and there is '
      'no authorization to release.\n'
      '• No hidden penalties: energy, service and gateway charges are always itemised.';

  static final Random _random = Random.secure();

  static BookingCheck check({
    required ChargerStation? station,
    required ChargerPort? port,
    Vehicle? vehicle,
    required int startMs,
    required int endMs,
    required int conflictingReservations,
    required bool stationPaused,
  }) {
    if (station == null) {
      return const BookingCheck(
        allowed: false,
        reason: 'Station not found.',
        requiresPaidAuthorization: false,
      );
    }
    if (stationPaused || station.isPaused) {
      return const BookingCheck(
        allowed: false,
        reason: 'This station is paused by the host right now.',
        requiresPaidAuthorization: false,
      );
    }
    if ((station.approvalStatus ?? '').toUpperCase() !=
        AmpPolicy.approvalApproved) {
      return const BookingCheck(
        allowed: false,
        reason: 'This station is still awaiting admin verification.',
        requiresPaidAuthorization: false,
      );
    }
    if (port == null) {
      return const BookingCheck(
        allowed: false,
        reason: 'Select an available port first.',
        requiresPaidAuthorization: false,
      );
    }
    if ((port.status ?? '').toUpperCase() != AmpPolicy.portAvailable) {
      return BookingCheck(
        allowed: false,
        reason:
            'Port ${port.portNumber} is ${(port.status ?? '').toLowerCase()} '
            'and cannot be reserved.',
        requiresPaidAuthorization: false,
      );
    }
    if (endMs <= startMs) {
      return const BookingCheck(
        allowed: false,
        reason: 'The selected slot is invalid.',
        requiresPaidAuthorization: false,
      );
    }
    if (conflictingReservations > 0) {
      return const BookingCheck(
        allowed: false,
        reason:
            'Another reservation already occupies this port in that window. '
            'Amperly prevents double booking.',
        requiresPaidAuthorization: false,
      );
    }
    if (vehicle?.connectorType != null &&
        port.connectorType != null &&
        port.connectorType!.toUpperCase() !=
            vehicle!.connectorType!.toUpperCase()) {
      return BookingCheck(
        allowed: false,
        reason:
            'Port ${port.portNumber} '
            '(${PlainFormat.connectorLabel(port.connectorType)}) is not '
            'compatible with your vehicle connector '
            '(${PlainFormat.connectorLabel(vehicle.connectorType)}).',
        requiresPaidAuthorization: false,
      );
    }
    if (vehicle != null &&
        station.connectorTypes != null &&
        !RoutePlannerEngine.isConnectorCompatible(station, vehicle)) {
      return BookingCheck(
        allowed: false,
        reason:
            'This station publishes '
            '${station.connectorTypeList.map(PlainFormat.connectorLabel).join(', ')}, '
            'which does not match your vehicle connector '
            '(${PlainFormat.connectorLabel(vehicle.connectorType)}).',
        requiresPaidAuthorization: false,
      );
    }
    if (!station.supportsPaidEnergyBilling) {
      return const BookingCheck(
        allowed: true,
        reason:
            'Reservation confirmed without automatic billing: this station has '
            'no verified meter, so no energy-based payment is captured.',
        requiresPaidAuthorization: false,
      );
    }
    return const BookingCheck(
      allowed: true,
      reason:
          'Slot is free and the station can bill a verified energy session.',
      requiresPaidAuthorization: true,
    );
  }

  static PricePreview preview(ChargerStation? station, double estimatedKwh) {
    final double tariff =
        station?.pricePerKwh ?? AmpPolicy.fallbackTariffInrPerKwh;
    final double service =
        station?.serviceFee ?? AmpPolicy.defaultServiceFeeInr;
    final double gateway =
        station?.gatewayFee ?? AmpPolicy.defaultGatewayFeeInr;
    final double energy = estimatedKwh * tariff;
    final double total = energy + service + gateway;
    return PricePreview(
      estimatedKwh: estimatedKwh,
      energyCharge: _round2(energy),
      serviceFee: service,
      gatewayFee: gateway,
      estimatedTotal: _round2(total),
      authorizedAmount: _round2(total * 1.2),
    );
  }

  static String buildBookingCode() {
    final StringBuffer code = StringBuffer(AmpPolicy.bookingPrefix);
    for (int i = 0; i < AmpPolicy.bookingCodeLength; i++) {
      code.write(
        AmpPolicy.bookingAlphabet[_random.nextInt(
          AmpPolicy.bookingAlphabet.length,
        )],
      );
    }
    return code.toString();
  }

  static String bookingQrPayload(Reservation? reservation) {
    if (reservation == null) {
      return 'amperly://booking/unknown';
    }
    return 'amperly://booking/${reservation.bookingCode}'
        '?station=${reservation.stationId}'
        '&port=${reservation.portId}'
        '&start=${reservation.startTimeMs}'
        '&end=${reservation.endTimeMs}';
  }

  static bool isValidBookingCode(String code) {
    final RegExp pattern = RegExp(
      '^${AmpPolicy.bookingPrefix}[${AmpPolicy.bookingAlphabet}]{${AmpPolicy.bookingCodeLength}}\$',
    );
    return pattern.hasMatch(code);
  }

  static double _round2(double value) => (value * 100).round() / 100;
}
