import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../../core/ids.dart';
import '../../domain/policy.dart';
import '../models/models.dart';
import 'repository_result.dart';

/// A saved plan and the charging stops that belong to it.
///
/// The car reads the same two tables, so this is the shape both surfaces share.
final class SavedJourney {
  const SavedJourney({required this.plan, required this.stops});

  final RoutePlan plan;
  final List<RouteStop> stops;

  int get chargingStopCount =>
      stops.where((RouteStop stop) => !stop.isBackup).length;
}

/// Reads and writes the route-plan tables the Java car layer also syncs.
final class JourneyRepository {
  JourneyRepository(this._client);

  final SupabaseClient _client;

  /// The one plan marked ACTIVE for this consumer, with its stops.
  ///
  /// The status is what the Java DAO selects. Ordering by creation time is a
  /// tie-breaker for older installs that still have more than one active row.
  Future<RepositoryResult<SavedJourney?>> activeForConsumer(
    String consumerId,
  ) async {
    try {
      final Map<String, dynamic>? row = await _client
          .from('route_plans')
          .select()
          .eq('consumerId', consumerId)
          .eq('status', AmpPolicy.routePlanActive)
          .order('createdAtMs', ascending: false)
          .limit(1)
          .maybeSingle();
      if (row == null) {
        return RepositorySuccess<SavedJourney?>(null);
      }

      final RoutePlan plan = RoutePlan.fromJson(row);
      final List<dynamic> stopRows = await _client
          .from('route_stops')
          .select()
          .eq('planId', plan.id)
          .order('sequence', ascending: true);
      final List<RouteStop> stops = stopRows
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> stop) =>
                RouteStop.fromJson(Map<String, dynamic>.from(stop)),
          )
          .toList(growable: false);
      return RepositorySuccess<SavedJourney?>(
        SavedJourney(plan: plan, stops: stops),
      );
    } on Object catch (error) {
      return RepositoryFailure<SavedJourney?>.from(error);
    }
  }

  /// Writes the new plan, its stops, then supersedes the previous active plan.
  ///
  /// The new row is written first so a failed stop write cannot leave the
  /// consumer without a plan. The old active row is moved to SUPERSEDED only
  /// after the new one is on the server; the car's DAO also orders by creation
  /// time, so a transient duplicate cannot make it pick the old trip.
  Future<RepositoryResult<SavedJourney>> saveActivePlan({
    required String consumerId,
    required RoutePlan plan,
    required List<RouteStop> stops,
  }) async {
    if (consumerId.trim().isEmpty || plan.id.trim().isEmpty) {
      return _failure<SavedJourney>(UserMessageKind.validation);
    }

    final RoutePlan active = plan.copyWith(
      consumerId: consumerId,
      status: AmpPolicy.routePlanActive,
    );
    final List<RouteStop> nextStops = <RouteStop>[
      for (final RouteStop stop in stops) stop.copyWith(planId: active.id),
    ];

    try {
      await _client.from('route_plans').upsert(_planPayload(active));
      if (nextStops.isNotEmpty) {
        await _client
            .from('route_stops')
            .upsert(nextStops.map(_stopPayload).toList(growable: false));
      }
      await _client
          .from('route_plans')
          .update(<String, Object?>{'status': AmpPolicy.routePlanSuperseded})
          .eq('consumerId', consumerId)
          .eq('status', AmpPolicy.routePlanActive)
          .neq('id', active.id);
      return RepositorySuccess<SavedJourney>(
        SavedJourney(plan: active, stops: nextStops),
      );
    } on Object catch (error) {
      return RepositoryFailure<SavedJourney>.from(error);
    }
  }

  /// Records the dashboard reading the driver confirmed.
  ///
  /// A reading belongs to a vehicle, which is also what the battery_updates
  /// policy checks. Without a vehicle the row cannot be accepted, so callers
  /// only record after the garage has one.
  Future<RepositoryResult<bool>> recordBatteryConfirmation({
    required String vehicleId,
    String? tripPlanId,
    required int estimatedSoc,
    required int actualSoc,
    required int timestampMs,
    double latitude = 0,
    double longitude = 0,
  }) async {
    if (vehicleId.trim().isEmpty) {
      return _failure<bool>(UserMessageKind.validation);
    }
    final BatteryUpdate update = BatteryUpdate(
      id: newId(),
      vehicleId: vehicleId,
      tripPlanId: tripPlanId,
      estimatedSoc: _soc(estimatedSoc),
      actualDashboardSoc: _soc(actualSoc),
      latitude: latitude,
      longitude: longitude,
      timestampMs: timestampMs,
    );
    try {
      await _client
          .from('battery_updates')
          .insert(update.toJson()..remove('serverUpdatedAt'));
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Map<String, dynamic> _planPayload(RoutePlan plan) {
    return plan.toJson()..remove('serverUpdatedAt');
  }

  Map<String, dynamic> _stopPayload(RouteStop stop) {
    return stop.toJson()..remove('serverUpdatedAt');
  }

  static int _soc(int value) => value < 0
      ? 0
      : value > 100
      ? 100
      : value;

  RepositoryFailure<T> _failure<T>(UserMessageKind kind) {
    return RepositoryFailure<T>(
      kind: kind,
      message: UserMessages.messageFor(kind),
    );
  }
}
