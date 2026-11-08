import '../../data/models/models.dart';
import '../policy.dart';

final class HostAnalytics {
  const HostAnalytics({
    required this.sessionsCompleted,
    required this.energyDeliveredKwh,
    required this.utilizationPercent,
    required this.revenue,
    required this.refundsAndAdjustments,
    required this.repeatConsumers,
    required this.cancellationRatePercent,
    required this.averageSessionKwh,
    required this.disputes,
    required this.openDisputes,
    required this.activeReservations,
    required this.reservations,
    required this.ports,
    required this.utilizationNote,
  });

  final int sessionsCompleted;
  final double energyDeliveredKwh;
  final double utilizationPercent;
  final double revenue;
  final double refundsAndAdjustments;
  final int repeatConsumers;
  final double cancellationRatePercent;
  final double averageSessionKwh;
  final int disputes;
  final int openDisputes;
  final int activeReservations;
  final int reservations;
  final int ports;
  final String utilizationNote;
}

abstract final class HostAnalyticsEngine {
  static HostAnalytics compute({
    List<ChargerStation>? stations,
    List<ChargerPort>? ports,
    List<ChargingSession>? sessions,
    List<Reservation>? reservations,
    List<Invoice>? invoices,
    List<Dispute>? disputes,
  }) {
    int sessionsCompleted = 0;
    double energy = 0;
    double minutes = 0;
    final Map<String, int> consumerCounts = <String, int>{};

    for (final ChargingSession session
        in sessions ?? const <ChargingSession>[]) {
      final String status = (session.status ?? '').toUpperCase();
      if (status == AmpPolicy.statusCompleted ||
          status == AmpPolicy.statusDisputed ||
          status == AmpPolicy.statusRefunded) {
        sessionsCompleted++;
        energy += session.verifiedKwhConsumed < 0
            ? 0
            : session.verifiedKwhConsumed;
        final int duration = session.endTimeMs - session.startTimeMs;
        minutes += (duration < 0 ? 0 : duration) / 60000;
        final String? consumerId = session.consumerId;
        if (consumerId != null) {
          consumerCounts[consumerId] = (consumerCounts[consumerId] ?? 0) + 1;
        }
      }
    }

    final int repeatConsumers = consumerCounts.values
        .where((int count) => count > 1)
        .length;

    double revenue = 0;
    double adjustments = 0;
    for (final Invoice invoice in invoices ?? const <Invoice>[]) {
      revenue += invoice.finalTotal;
      adjustments += invoice.adjustment;
    }

    int cancelled = 0;
    int activeReservations = 0;
    final Set<String> allReservations = <String>{};
    for (final Reservation reservation
        in reservations ?? const <Reservation>[]) {
      allReservations.add(reservation.id);
      final String status = (reservation.status ?? '').toUpperCase();
      if (status == AmpPolicy.statusCancelled ||
          status == AmpPolicy.statusExpired) {
        cancelled++;
      }
      if (reservation.isActive) {
        activeReservations++;
      }
    }

    final int disputeCount = disputes?.length ?? 0;
    final int openDisputes = (disputes ?? const <Dispute>[])
        .where((Dispute dispute) => dispute.isOpen)
        .length;

    final int portCount = ports?.length ?? 0;
    final double availablePortMinutes = portCount * 12 * 60 * 30 < 1
        ? 1
        : portCount * 12 * 60 * 30;
    final double utilization = ((minutes / availablePortMinutes) * 100).clamp(
      0,
      100,
    );
    final double cancellationRate = allReservations.isEmpty
        ? 0
        : cancelled * 100 / allReservations.length;
    final double averageSession = sessionsCompleted == 0
        ? 0
        : energy / sessionsCompleted;

    return HostAnalytics(
      sessionsCompleted: sessionsCompleted,
      energyDeliveredKwh: round2(energy),
      utilizationPercent: round2(utilization),
      revenue: round2(revenue),
      refundsAndAdjustments: round2(adjustments),
      repeatConsumers: repeatConsumers,
      cancellationRatePercent: round2(cancellationRate),
      averageSessionKwh: round2(averageSession),
      disputes: disputeCount,
      openDisputes: openDisputes,
      activeReservations: activeReservations,
      reservations: allReservations.length,
      ports: portCount,
      utilizationNote:
          'Utilization is estimated from recorded session time over a '
          '12-hour bookable day per port for the last 30 days. The MVP has no '
          'charger telemetry, so idle time is not measured directly.',
    );
  }

  static String describe(HostAnalytics analytics) {
    return 'Sessions: ${analytics.sessionsCompleted} · '
        'Energy: ${analytics.energyDeliveredKwh.toStringAsFixed(1)} kWh · '
        'Utilization: ${analytics.utilizationPercent.toStringAsFixed(0)}% · '
        'Revenue: ₹${analytics.revenue.toStringAsFixed(2)}';
  }

  static double round2(double value) => (value * 100).round() / 100;
}
