import 'package:supabase_flutter/supabase_flutter.dart';

import 'repository_result.dart';

final class TableRepository<T> {
  TableRepository(this._client, {required this.table, required this.fromJson});

  final SupabaseClient _client;
  final String table;
  final T Function(Map<String, dynamic>) fromJson;

  Future<RepositoryResult<List<T>>> all({
    Map<String, Object?> equals = const <String, Object?>{},
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      dynamic query = _client.from(table).select();
      for (final MapEntry<String, Object?> entry in equals.entries) {
        query = query.eq(entry.key, entry.value);
      }
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }
      final List<dynamic> rows = await query as List<dynamic>;
      return RepositorySuccess<List<T>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<T>>.from(error);
    }
  }

  Future<RepositoryResult<T>> insert(Map<String, Object?> values) async {
    try {
      final Map<String, dynamic> row = await _client
          .from(table)
          .insert(values)
          .select()
          .single();
      return RepositorySuccess<T>(fromJson(row));
    } on Object catch (error) {
      return RepositoryFailure<T>.from(error);
    }
  }

  Future<RepositoryResult<bool>> update(
    String id,
    Map<String, Object?> values,
  ) async {
    try {
      await _client.from(table).update(values).eq('id', id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Future<RepositoryResult<bool>> delete(String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }
}
