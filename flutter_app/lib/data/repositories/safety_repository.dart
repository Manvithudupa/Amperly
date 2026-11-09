import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../../core/ids.dart';
import '../../core/ui/strings.dart';
import '../models/models.dart';
import 'repository_result.dart';

final class SafetyData {
  const SafetyData({
    required this.contacts,
    required this.events,
    required this.activeSharing,
  });

  final List<TrustedContact> contacts;
  final List<SafetyEvent> events;
  final SafetyEvent? activeSharing;
}

final class SafetyRepository {
  SafetyRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<SafetyData>> load(String userId) async {
    try {
      final int now = DateTime.now().millisecondsSinceEpoch;
      // A sharing window is a record, not a live transmitter. Expire stale
      // windows before reading so the screen never claims one is still active.
      await _client
          .from('safety_events')
          .update(<String, Object?>{'isLiveLocationSharingActive': false})
          .eq('consumerId', userId)
          .eq('isLiveLocationSharingActive', true)
          .lt('expiresAtMs', now);

      final List<TrustedContact> contacts =
          (await _client
                  .from('trusted_contacts')
                  .select()
                  .eq('userId', userId)
                  .order('name'))
              .whereType<Map<String, dynamic>>()
              .map(TrustedContact.fromJson)
              .toList(growable: false);

      final List<SafetyEvent> events =
          (await _client
                  .from('safety_events')
                  .select()
                  .eq('consumerId', userId)
                  .order('createdAtMs', ascending: false))
              .whereType<Map<String, dynamic>>()
              .map(SafetyEvent.fromJson)
              .toList(growable: false);

      SafetyEvent? active;
      for (final SafetyEvent event in events) {
        if (event.isLiveLocationSharingActive && event.expiresAtMs > now) {
          active = event;
          break;
        }
      }

      return RepositorySuccess<SafetyData>(
        SafetyData(contacts: contacts, events: events, activeSharing: active),
      );
    } on Object catch (error) {
      return RepositoryFailure<SafetyData>.from(error);
    }
  }

  Future<RepositoryResult<TrustedContact>> addContact({
    required String userId,
    required String name,
    required String phone,
  }) async {
    final String cleanName = name.trim();
    final String cleanPhone = phone.trim();
    if (cleanName.isEmpty || cleanPhone.length < 6) {
      return RepositoryFailure<TrustedContact>(
        kind: UserMessageKind.validation,
        message: AmpStrings.safetyContactInvalid,
      );
    }
    final TrustedContact contact = TrustedContact(
      id: newId('con_'),
      userId: userId,
      name: cleanName,
      phone: cleanPhone,
    );
    try {
      await _client
          .from('trusted_contacts')
          .insert(contact.toJson()..remove('serverUpdatedAt'));
      return RepositorySuccess<TrustedContact>(contact);
    } on Object catch (error) {
      return RepositoryFailure<TrustedContact>.from(error);
    }
  }

  Future<RepositoryResult<bool>> deleteContact(String id) async {
    try {
      await _client.from('trusted_contacts').delete().eq('id', id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }

  Future<RepositoryResult<SafetyEvent>> recordSos({
    required String userId,
    String? stationId,
  }) async {
    final SafetyEvent event = SafetyEvent(
      id: newId('sft_'),
      consumerId: userId,
      stationId: stationId,
      emergencyType: 'SOS',
      isLiveLocationSharingActive: false,
      expiresAtMs: 0,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    try {
      await _client
          .from('safety_events')
          .insert(event.toJson()..remove('serverUpdatedAt'));
      return RepositorySuccess<SafetyEvent>(event);
    } on Object catch (error) {
      return RepositoryFailure<SafetyEvent>.from(error);
    }
  }

  Future<RepositoryResult<SafetyEvent>> startSharing({
    required String userId,
    required TrustedContact contact,
    String? stationId,
  }) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final SafetyEvent event = SafetyEvent(
      id: newId('sft_'),
      consumerId: userId,
      stationId: stationId,
      emergencyType: 'LIVE_LOCATION',
      isLiveLocationSharingActive: true,
      trustedContactPhone: contact.phone,
      expiresAtMs: now + const Duration(hours: 1).inMilliseconds,
      createdAtMs: now,
    );
    try {
      await _client
          .from('safety_events')
          .insert(event.toJson()..remove('serverUpdatedAt'));
      return RepositorySuccess<SafetyEvent>(event);
    } on Object catch (error) {
      return RepositoryFailure<SafetyEvent>.from(error);
    }
  }

  Future<RepositoryResult<bool>> stopSharing(SafetyEvent event) async {
    try {
      await _client
          .from('safety_events')
          .update(<String, Object?>{
            'isLiveLocationSharingActive': false,
            'expiresAtMs': DateTime.now().millisecondsSinceEpoch,
          })
          .eq('id', event.id);
      return const RepositorySuccess<bool>(true);
    } on Object catch (error) {
      return RepositoryFailure<bool>.from(error);
    }
  }
}
