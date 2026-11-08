import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../models/models.dart';
import 'repository_result.dart';

final class VehicleRepository {
  VehicleRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<List<Vehicle>>> forUser(String userId) async {
    try {
      return RepositorySuccess<List<Vehicle>>(await _load(userId));
    } on Object catch (error) {
      return RepositoryFailure<List<Vehicle>>.from(error);
    }
  }

  /// Saves one profile and makes it the only active profile.
  ///
  /// Every vehicle row is written in one upsert, with the saved row active and
  /// the rest inactive. Doing this in one statement avoids leaving two active
  /// profiles behind while the garage is switched from one car to another.
  Future<RepositoryResult<List<Vehicle>>> saveAndActivate(
    Vehicle vehicle,
  ) async {
    final String? userId = vehicle.userId;
    if (userId == null) {
      return _failure<List<Vehicle>>(UserMessageKind.validation);
    }

    try {
      final List<Vehicle> existing = await _load(userId);
      final List<Vehicle> next = <Vehicle>[
        for (final Vehicle item in existing)
          if (item.id != vehicle.id) item.copyWith(isActive: false),
        vehicle.copyWith(isActive: true),
      ];
      await _upsertAll(next);
      return RepositorySuccess<List<Vehicle>>(_sorted(next));
    } on Object catch (error) {
      return RepositoryFailure<List<Vehicle>>.from(error);
    }
  }

  /// Selects the profile used for planning and clears every other profile.
  Future<RepositoryResult<List<Vehicle>>> setActive(Vehicle vehicle) async {
    final String? userId = vehicle.userId;
    if (userId == null) {
      return _failure<List<Vehicle>>(UserMessageKind.validation);
    }

    try {
      final List<Vehicle> existing = await _load(userId);
      if (!existing.any((Vehicle item) => item.id == vehicle.id)) {
        return _failure<List<Vehicle>>(UserMessageKind.notFound);
      }
      final List<Vehicle> next = <Vehicle>[
        for (final Vehicle item in existing)
          item.copyWith(isActive: item.id == vehicle.id),
      ];
      await _upsertAll(next);
      return RepositorySuccess<List<Vehicle>>(_sorted(next));
    } on Object catch (error) {
      return RepositoryFailure<List<Vehicle>>.from(error);
    }
  }

  /// Deletes one profile and promotes another when it was the active one.
  ///
  /// The remaining rows are written in one upsert. That keeps planning pointed
  /// at a real vehicle after the car in use is removed.
  Future<RepositoryResult<List<Vehicle>>> deleteAndPromote(
    Vehicle vehicle,
  ) async {
    final String? userId = vehicle.userId;
    if (userId == null) {
      return _failure<List<Vehicle>>(UserMessageKind.validation);
    }

    try {
      await _client
          .from('vehicles')
          .delete()
          .eq('id', vehicle.id)
          .eq('userId', userId);
      final List<Vehicle> remaining = await _load(userId);
      if (remaining.isEmpty) {
        return const RepositorySuccess<List<Vehicle>>(<Vehicle>[]);
      }

      final Vehicle active = remaining.firstWhere(
        (Vehicle item) => item.isActive,
        orElse: () => remaining.first,
      );
      final List<Vehicle> next = <Vehicle>[
        for (final Vehicle item in remaining)
          item.copyWith(isActive: item.id == active.id),
      ];
      await _upsertAll(next);
      return RepositorySuccess<List<Vehicle>>(_sorted(next));
    } on Object catch (error) {
      return RepositoryFailure<List<Vehicle>>.from(error);
    }
  }

  Future<List<Vehicle>> _load(String userId) async {
    final List<dynamic> rows = await _client
        .from('vehicles')
        .select()
        .eq('userId', userId)
        .order('isActive', ascending: false);
    return rows
        .whereType<Map<String, dynamic>>()
        .map(Vehicle.fromJson)
        .toList(growable: false);
  }

  Future<void> _upsertAll(List<Vehicle> vehicles) async {
    final List<Map<String, dynamic>> payloads = <Map<String, dynamic>>[
      for (final Vehicle vehicle in vehicles) _payload(vehicle),
    ];
    await _client.from('vehicles').upsert(payloads);
  }

  Map<String, dynamic> _payload(Vehicle vehicle) {
    return vehicle.toJson()..remove('serverUpdatedAt');
  }

  List<Vehicle> _sorted(List<Vehicle> vehicles) {
    final List<Vehicle> sorted = List<Vehicle>.of(vehicles);
    sorted.sort((Vehicle a, Vehicle b) {
      if (a.isActive != b.isActive) {
        return a.isActive ? -1 : 1;
      }
      final int byMake = (a.make ?? '').toLowerCase().compareTo(
        (b.make ?? '').toLowerCase(),
      );
      if (byMake != 0) {
        return byMake;
      }
      return (a.model ?? '').toLowerCase().compareTo(
        (b.model ?? '').toLowerCase(),
      );
    });
    return sorted;
  }

  RepositoryFailure<T> _failure<T>(UserMessageKind kind) {
    return RepositoryFailure<T>(
      kind: kind,
      message: UserMessages.messageFor(kind),
    );
  }
}
