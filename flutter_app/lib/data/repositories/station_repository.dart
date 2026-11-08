import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../models/models.dart';
import 'repository_result.dart';

/// One live station with the ports a discovery screen needs to describe it.
final class StationCatalogueEntry {
  const StationCatalogueEntry({required this.station, required this.ports});

  final ChargerStation station;
  final List<ChargerPort> ports;
}

final class StationCatalogue {
  const StationCatalogue(this.entries);

  final List<StationCatalogueEntry> entries;
}

final class StationRepository {
  StationRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<List<ChargerStation>>> approvedStations() async {
    try {
      final List<dynamic> rows = await _client
          .from('charger_stations')
          .select()
          .eq('approvalStatus', 'APPROVED')
          .eq('isPaused', false)
          .order('name');
      return RepositorySuccess<List<ChargerStation>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  ChargerStation.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<ChargerStation>>.from(error);
    }
  }

  Future<RepositoryResult<List<ChargerPort>>> ports(String stationId) async {
    try {
      final List<dynamic> rows = await _client
          .from('charger_ports')
          .select()
          .eq('stationId', stationId)
          .order('portNumber');
      return RepositorySuccess<List<ChargerPort>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  ChargerPort.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<ChargerPort>>.from(error);
    }
  }

  /// Every approved, unpaused station with its ports.
  ///
  /// Two grouped reads rather than two per station. Reservations are
  /// deliberately not read here: Row Level Security only exposes the caller's
  /// own bookings, so using them to claim global availability would undercount
  /// demand. The card reports the port's published status and its age instead.
  Future<RepositoryResult<StationCatalogue>> catalogue() async {
    try {
      final StationCatalogue catalogue = await _loadCatalogue();
      return RepositorySuccess<StationCatalogue>(catalogue);
    } on Object catch (error) {
      return RepositoryFailure<StationCatalogue>.from(error);
    }
  }

  Future<RepositoryResult<StationCatalogueEntry>> detail(
    String stationId,
  ) async {
    try {
      final Map<String, dynamic>? row = await _client
          .from('charger_stations')
          .select()
          .eq('id', stationId)
          .eq('approvalStatus', 'APPROVED')
          .eq('isPaused', false)
          .maybeSingle();
      if (row == null) {
        return RepositoryFailure<StationCatalogueEntry>(
          kind: UserMessageKind.notFound,
          message: UserMessages.messageFor(UserMessageKind.notFound),
        );
      }
      final ChargerStation station = ChargerStation.fromJson(row);
      final List<ChargerPort> ports = await _portsFor(<String>[station.id]);
      return RepositorySuccess<StationCatalogueEntry>(
        StationCatalogueEntry(
          station: station,
          ports: _portsForStation(ports, station.id),
        ),
      );
    } on Object catch (error) {
      return RepositoryFailure<StationCatalogueEntry>.from(error);
    }
  }

  /// The published weekly windows for every port at a station.
  ///
  /// Row Level Security exposes schedules only for approved, unpaused
  /// stations. They describe when a port may be booked; the server still
  /// re-checks the actual slot when a reservation is created.
  Future<RepositoryResult<List<AvailabilitySchedule>>> schedules(
    String stationId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from('availability_schedules')
          .select()
          .eq('stationId', stationId)
          .order('portId');
      return RepositorySuccess<List<AvailabilitySchedule>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  AvailabilitySchedule.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<AvailabilitySchedule>>.from(error);
    }
  }

  Future<StationCatalogue> _loadCatalogue() async {
    final List<dynamic> stationRows = await _client
        .from('charger_stations')
        .select()
        .eq('approvalStatus', 'APPROVED')
        .eq('isPaused', false)
        .order('name');
    final List<ChargerStation> stations = stationRows
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> row) =>
              ChargerStation.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
    if (stations.isEmpty) {
      return const StationCatalogue(<StationCatalogueEntry>[]);
    }

    final List<String> ids = stations
        .map((ChargerStation station) => station.id)
        .toList(growable: false);
    final List<ChargerPort> ports = await _portsFor(ids);

    return StationCatalogue(
      stations
          .map(
            (ChargerStation station) => StationCatalogueEntry(
              station: station,
              ports: _portsForStation(ports, station.id),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<List<ChargerPort>> _portsFor(List<String> stationIds) async {
    if (stationIds.isEmpty) {
      return const <ChargerPort>[];
    }
    final List<dynamic> rows = await _client
        .from('charger_ports')
        .select()
        .inFilter('stationId', stationIds)
        .order('portNumber');
    return rows
        .whereType<Map<String, dynamic>>()
        .map(
          (Map<String, dynamic> row) =>
              ChargerPort.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
  }

  static List<ChargerPort> _portsForStation(
    List<ChargerPort> ports,
    String stationId,
  ) {
    return ports
        .where((ChargerPort port) => port.stationId == stationId)
        .toList(growable: false);
  }
}
