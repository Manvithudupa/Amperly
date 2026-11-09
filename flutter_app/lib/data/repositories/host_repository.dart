import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../../core/ids.dart';
import '../../core/ui/strings.dart';
import '../../domain/engines/host_analytics_engine.dart';
import '../../domain/policy.dart';
import '../models/models.dart';
import 'repository_result.dart';

/// One host station and the ports visible to that host.
final class HostStationEntry {
  const HostStationEntry({required this.station, required this.ports});

  final ChargerStation station;
  final List<ChargerPort> ports;

  int get portCount => ports.isEmpty ? station.portCount : ports.length;
}

final class HostWorkspaceData {
  const HostWorkspaceData({
    required this.stations,
    required this.sessions,
    required this.reservations,
    required this.invoices,
    required this.disputes,
    required this.analytics,
  });

  final List<HostStationEntry> stations;
  final List<ChargingSession> sessions;
  final List<Reservation> reservations;
  final List<Invoice> invoices;
  final List<Dispute> disputes;
  final HostAnalytics analytics;
}

/// The station fields the host actually controls. Platform fees are fixed and
/// are written from [AmpPolicy], never from this form.
final class HostStationDraft {
  const HostStationDraft({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.locationType,
    required this.operatingHours,
    required this.pricePerKwh,
    required this.verificationLevel,
    required this.accessRules,
    required this.ports,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String locationType;
  final String operatingHours;
  final double pricePerKwh;
  final String verificationLevel;
  final String accessRules;
  final List<HostPortDraft> ports;
}

final class HostPortDraft {
  const HostPortDraft({
    required this.connectorType,
    required this.count,
    required this.powerKw,
    required this.isDc,
  });

  final String connectorType;
  final int count;
  final double powerKw;
  final bool isDc;
}

final class HostRepository {
  HostRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<HostWorkspaceData>> workspace(String hostId) async {
    try {
      final List<dynamic> stationRows = await _client
          .from('charger_stations')
          .select()
          .eq('hostId', hostId)
          .order('name');
      final List<ChargerStation> stations = stationRows
          .whereType<Map<String, dynamic>>()
          .map(ChargerStation.fromJson)
          .toList(growable: false);
      final List<String> stationIds = stations
          .map((ChargerStation station) => station.id)
          .toList(growable: false);

      final List<ChargerPort> ports = stationIds.isEmpty
          ? const <ChargerPort>[]
          : (await _client
                    .from('charger_ports')
                    .select()
                    .inFilter('stationId', stationIds)
                    .order('portNumber'))
                .whereType<Map<String, dynamic>>()
                .map(ChargerPort.fromJson)
                .toList(growable: false);

      final List<ChargingSession> sessions =
          (await _client
                  .from('charging_sessions')
                  .select()
                  .eq('hostId', hostId)
                  .order('startTimeMs', ascending: false))
              .whereType<Map<String, dynamic>>()
              .map(ChargingSession.fromJson)
              .toList(growable: false);

      final List<Reservation> reservations = stationIds.isEmpty
          ? const <Reservation>[]
          : (await _client
                    .from('reservations')
                    .select()
                    .inFilter('stationId', stationIds)
                    .order('createdAtMs', ascending: false))
                .whereType<Map<String, dynamic>>()
                .map(Reservation.fromJson)
                .toList(growable: false);

      final List<Invoice> invoices =
          (await _client
                  .from('invoices')
                  .select()
                  .eq('hostId', hostId)
                  .order('issuedAtMs', ascending: false))
              .whereType<Map<String, dynamic>>()
              .map(Invoice.fromJson)
              .toList(growable: false);

      final List<Dispute> disputes =
          (await _client
                  .from('disputes')
                  .select()
                  .eq('hostId', hostId)
                  .order('createdAtMs', ascending: false))
              .whereType<Map<String, dynamic>>()
              .map(Dispute.fromJson)
              .toList(growable: false);

      final List<HostStationEntry> entries = stations
          .map(
            (ChargerStation station) => HostStationEntry(
              station: station,
              ports: ports
                  .where((ChargerPort port) => port.stationId == station.id)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false);

      return RepositorySuccess<HostWorkspaceData>(
        HostWorkspaceData(
          stations: entries,
          sessions: sessions,
          reservations: reservations,
          invoices: invoices,
          disputes: disputes,
          analytics: HostAnalyticsEngine.compute(
            stations: stations,
            ports: ports,
            sessions: sessions,
            reservations: reservations,
            invoices: invoices,
            disputes: disputes,
          ),
        ),
      );
    } on Object catch (error) {
      return RepositoryFailure<HostWorkspaceData>.from(error);
    }
  }

  Future<RepositoryResult<String>> saveStation({
    required AppUser host,
    required HostStationDraft draft,
  }) async {
    final String stationId = newId('stn_');
    final int now = DateTime.now().millisecondsSinceEpoch;
    final List<ChargerPort> ports = <ChargerPort>[];
    final List<String> connectors = <String>[];
    double maxPowerKw = 0;
    bool anyDc = false;
    int portNumber = 0;

    for (final HostPortDraft row in draft.ports) {
      final int count = row.count < 1 ? 1 : row.count;
      final double power = row.powerKw <= 0 ? 7.2 : row.powerKw;
      maxPowerKw = power > maxPowerKw ? power : maxPowerKw;
      anyDc = anyDc || row.isDc;
      if (!connectors.contains(row.connectorType)) {
        connectors.add(row.connectorType);
      }
      for (int index = 0; index < count; index++) {
        portNumber++;
        ports.add(
          ChargerPort(
            id: newId('prt_'),
            stationId: stationId,
            portNumber: '$portNumber',
            connectorType: row.connectorType,
            powerKw: power,
            isDc: row.isDc,
            status: AmpPolicy.portAvailable,
          ),
        );
      }
    }

    try {
      await _client.from('charger_stations').insert(<String, Object?>{
        'id': stationId,
        'hostId': host.id,
        'hostName': host.name,
        'name': draft.name,
        'address': draft.address,
        'latitude': draft.latitude,
        'longitude': draft.longitude,
        'locationType': draft.locationType,
        'operatingHours': draft.operatingHours,
        'pricePerKwh': draft.pricePerKwh,
        'serviceFee': AmpPolicy.defaultServiceFeeInr,
        'gatewayFee': AmpPolicy.defaultGatewayFeeInr,
        'verificationLevel': draft.verificationLevel,
        'isVerified': false,
        'isPaused': false,
        'approvalStatus': AmpPolicy.approvalPending,
        'reviewNote': '',
        'connectorTypes': connectors.join(','),
        'maxPowerKw': maxPowerKw,
        'isDcCapable': anyDc,
        'portCount': ports.length,
        'accessRules': draft.accessRules,
        'rating': 0,
        'reliabilityScore': 0,
        'incidentCount': 0,
        'lastUpdatedMs': now,
      });

      if (ports.isNotEmpty) {
        await _client
            .from('charger_ports')
            .insert(
              ports
                  .map(
                    (ChargerPort port) => <String, Object?>{
                      'id': port.id,
                      'stationId': port.stationId,
                      'portNumber': port.portNumber,
                      'connectorType': port.connectorType,
                      'powerKw': port.powerKw,
                      'isDc': port.isDc,
                      'status': port.status,
                    },
                  )
                  .toList(growable: false),
            );

        final List<Map<String, Object?>> schedules = <Map<String, Object?>>[];
        for (final ChargerPort port in ports) {
          for (int day = 1; day <= 7; day++) {
            schedules.add(<String, Object?>{
              'id': '${port.id}_d$day',
              'stationId': stationId,
              'portId': port.id,
              'dayOfWeek': day,
              'openMinutes': 8 * 60,
              'closeMinutes': 20 * 60,
              'isBlocked': false,
              'blockReason': null,
              'updatedAtMs': now,
            });
          }
        }
        await _client.from('availability_schedules').insert(schedules);
      }

      return RepositorySuccess<String>(stationId);
    } on Object catch (error) {
      // Do not leave an empty pending station behind if a child write failed.
      try {
        await _client
            .from('availability_schedules')
            .delete()
            .eq('stationId', stationId);
        await _client.from('charger_ports').delete().eq('stationId', stationId);
        await _client.from('charger_stations').delete().eq('id', stationId);
      } on Object {
        // The original failure is the useful one.
      }
      return RepositoryFailure<String>.from(error);
    }
  }

  Future<RepositoryResult<bool>> setPaused(
    ChargerStation station, {
    required bool paused,
  }) async {
    try {
      await _client
          .from('charger_stations')
          .update(<String, Object?>{
            'isPaused': paused,
            'lastUpdatedMs': DateTime.now().millisecondsSinceEpoch,
          })
          .eq('id', station.id);
      await _client
          .from('availability_schedules')
          .update(<String, Object?>{
            'isBlocked': paused,
            'blockReason': paused ? AmpStrings.hostPausedReason : null,
            'updatedAtMs': DateTime.now().millisecondsSinceEpoch,
          })
          .eq('stationId', station.id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Future<RepositoryResult<bool>> deleteStation(ChargerStation station) async {
    try {
      final List<dynamic> activeRows = await _client
          .from('reservations')
          .select()
          .eq('stationId', station.id);
      final bool hasActiveBooking = activeRows
          .whereType<Map<String, dynamic>>()
          .map(Reservation.fromJson)
          .any((Reservation reservation) => reservation.isActive);
      if (hasActiveBooking) {
        return RepositoryFailure<bool>(
          kind: UserMessageKind.conflict,
          message: AmpStrings.hostDeleteBlocked(
            station.name ?? AmpStrings.unnamedCharger,
          ),
        );
      }

      await _client
          .from('availability_schedules')
          .delete()
          .eq('stationId', station.id);
      await _client.from('charger_ports').delete().eq('stationId', station.id);
      await _client.from('charger_stations').delete().eq('id', station.id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Future<RepositoryResult<bool>> recordMeterEvidence({
    required ChargerStation station,
    required double startKwh,
    required double endKwh,
  }) async {
    if (!startKwh.isFinite || !endKwh.isFinite || endKwh < startKwh) {
      return RepositoryFailure<bool>(
        kind: UserMessageKind.validation,
        message: AmpStrings.sessionInvalidReading,
      );
    }
    try {
      await _client.from('meter_readings').insert(<String, Object?>{
        'id': newId('mtr_'),
        'sessionId': null,
        'stationId': station.id,
        'startMeterKwh': startKwh,
        'endMeterKwh': endKwh,
        'photoEvidenceUri': null,
        'verificationLevel': station.verificationLevel,
        'timestampMs': DateTime.now().millisecondsSinceEpoch,
        'isSimulated': true,
      });
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }
}
