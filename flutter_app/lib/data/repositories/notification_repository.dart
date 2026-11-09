import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'repository_result.dart';

final class NotificationRepository {
  NotificationRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<List<AppNotification>>> forUser(String userId) async {
    try {
      final List<dynamic> rows = await _client
          .from('notifications')
          .select()
          .eq('userId', userId)
          .order('createdAtMs', ascending: false);
      return RepositorySuccess<List<AppNotification>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  AppNotification.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<AppNotification>>.from(error);
    }
  }

  Stream<List<AppNotification>> watch(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: <String>['id'])
        .eq('userId', userId)
        .order('createdAtMs')
        .map(
          (List<Map<String, dynamic>> rows) =>
              rows.map(AppNotification.fromJson).toList(growable: false),
        );
  }

  Future<RepositoryResult<bool>> markRead(String id) async {
    try {
      await _client
          .from('notifications')
          .update(<String, Object?>{'isRead': true})
          .eq('id', id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Future<RepositoryResult<bool>> markAllRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update(<String, Object?>{'isRead': true})
          .eq('userId', userId)
          .eq('isRead', false);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }
}
