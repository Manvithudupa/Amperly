import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/policy.dart';
import '../models/models.dart';
import 'repository_result.dart';

final class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<AppUser>> resolveOrCreate({
    required String authUserId,
    String? email,
    String? fallbackName,
  }) async {
    try {
      final Map<String, dynamic>? existing = await _client
          .from('users')
          .select()
          .eq('authUserId', authUserId)
          .maybeSingle();
      if (existing != null) {
        return RepositorySuccess<AppUser>(AppUser.fromJson(existing));
      }
      final String name = (fallbackName ?? '').trim().isNotEmpty
          ? fallbackName!.trim()
          : displayNameFrom(email);
      final Map<String, dynamic> row = await _client
          .from('users')
          .insert(
            newUserProfileRow(id: authUserId, email: email, displayName: name),
          )
          .select()
          .single();
      return RepositorySuccess<AppUser>(AppUser.fromJson(row));
    } on Object catch (error) {
      return RepositoryFailure<AppUser>.from(error);
    }
  }

  static String displayNameFrom(String? email) {
    final String value = (email ?? '').trim();
    if (value.isEmpty) {
      return 'Amperly user';
    }
    final int at = value.indexOf('@');
    return at > 0 ? value.substring(0, at) : value;
  }

  /// Exactly the columns the old Java profile fallback wrote.
  static Map<String, Object?> newUserProfileRow({
    required String id,
    required String? email,
    required String displayName,
  }) {
    return <String, Object?>{
      'id': id,
      'authUserId': id,
      'email': email,
      'name': displayName,
      'phone': '',
      'role': AmpPolicy.roleConsumer,
      'organizationName': '',
      'verificationStatus': 'VERIFIED',
      'isBlocked': false,
    };
  }
}
