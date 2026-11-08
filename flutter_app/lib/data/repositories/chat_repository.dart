import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/user_messages.dart';
import '../../core/ui/strings.dart';
import '../../domain/engines/chat_manager.dart';
import '../models/models.dart';
import 'repository_result.dart';

/// The two chat tables behind the phone messaging surface.
///
/// A conversation is keyed by the consumer and host pair, not by a single
/// booking. The latest booking refreshes the thread's context and expiry while
/// keeping the same id, so earlier messages stay in one history.
final class ChatRepository {
  ChatRepository(this._client);

  final SupabaseClient _client;

  Future<RepositoryResult<List<CommunicationThread>>> threadsForConsumer(
    String consumerId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from('communication_threads')
          .select()
          .eq('consumerId', consumerId)
          .order('createdAtMs', ascending: false);
      return RepositorySuccess<List<CommunicationThread>>(
        rows
            .whereType<Map<String, dynamic>>()
            .map(
              (Map<String, dynamic> row) =>
                  CommunicationThread.fromJson(Map<String, dynamic>.from(row)),
            )
            .toList(growable: false),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<CommunicationThread>>.from(error);
    }
  }

  Future<RepositoryResult<CommunicationThread?>> thread(String threadId) async {
    try {
      final Map<String, dynamic>? row = await _client
          .from('communication_threads')
          .select()
          .eq('id', threadId)
          .maybeSingle();
      return RepositorySuccess<CommunicationThread?>(
        row == null ? null : CommunicationThread.fromJson(row),
      );
    } on Object catch (error) {
      return RepositoryFailure<CommunicationThread?>.from(error);
    }
  }

  /// Messages for several threads in one read, newest first, so an inbox can
  /// preview the latest line without a query per conversation.
  Future<RepositoryResult<List<ChatMessage>>> messagesForThreads(
    List<String> threadIds,
  ) async {
    if (threadIds.isEmpty) {
      return const RepositorySuccess<List<ChatMessage>>(<ChatMessage>[]);
    }
    try {
      final List<dynamic> rows = await _client
          .from('chat_messages')
          .select()
          .inFilter('threadId', threadIds)
          .order('createdAtMs', ascending: false);
      final List<ChatMessage> messages = rows
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> row) =>
                ChatMessage.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
      // PostgREST orders this read, but the inbox still sorts client-side so a
      // thread preview cannot depend on transport ordering.
      messages.sort(
        (ChatMessage a, ChatMessage b) =>
            b.createdAtMs.compareTo(a.createdAtMs),
      );
      return RepositorySuccess<List<ChatMessage>>(messages);
    } on Object catch (error) {
      return RepositoryFailure<List<ChatMessage>>.from(error);
    }
  }

  Stream<List<ChatMessage>> watchMessages(String threadId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: <String>['id'])
        .eq('threadId', threadId)
        .order('createdAtMs')
        .map((List<Map<String, dynamic>> rows) {
          final List<ChatMessage> messages = rows
              .map(ChatMessage.fromJson)
              .toList();
          // Realtime does not guarantee the query's order in its local view.
          // The transcript is chronological regardless of how rows arrive.
          messages.sort(
            (ChatMessage a, ChatMessage b) =>
                a.createdAtMs.compareTo(b.createdAtMs),
          );
          return messages;
        });
  }

  /// Finds the pair's existing conversation or opens the first one.
  ///
  /// Row Level Security only lets a participant write the thread, and the
  /// consumer id comes from the signed-in profile.
  Future<RepositoryResult<CommunicationThread>> ensureThread({
    required AppUser consumer,
    required Reservation reservation,
    required String hostId,
    required String hostName,
  }) async {
    final String trimmedHostId = hostId.trim();
    if (trimmedHostId.isEmpty) {
      return RepositoryFailure<CommunicationThread>(
        kind: UserMessageKind.validation,
        message: AmpStrings.chatNoHost,
      );
    }

    try {
      final List<dynamic> rows = await _client
          .from('communication_threads')
          .select()
          .eq('consumerId', consumer.id)
          .eq('hostId', trimmedHostId)
          .order('createdAtMs')
          .limit(1);

      final AppUser host = AppUser(
        id: trimmedHostId,
        name: hostName.trim().isEmpty ? null : hostName.trim(),
      );

      CommunicationThread thread;
      final dynamic first = rows.isEmpty ? null : rows.first;
      if (first is Map<String, dynamic>) {
        final CommunicationThread existing = CommunicationThread.fromJson(
          Map<String, dynamic>.from(first),
        );
        thread =
            ChatManager.reuseForReservation(
              thread: existing,
              reservation: reservation,
              consumer: consumer,
              host: host,
            ) ??
            existing;
      } else {
        thread = ChatManager.createThread(
          reservation: reservation,
          consumer: consumer,
          host: host,
        );
      }

      final Map<String, dynamic> row = thread.toJson()
        ..remove('serverUpdatedAt');
      await _client.from('communication_threads').upsert(row);
      return RepositorySuccess<CommunicationThread>(thread);
    } on Object catch (error) {
      return RepositoryFailure<CommunicationThread>.from(error);
    }
  }

  Future<RepositoryResult<ChatMessage>> sendMessage({
    required CommunicationThread thread,
    required AppUser sender,
    required String text,
  }) async {
    final String? receiverId = sender.id == thread.consumerId
        ? thread.hostId
        : sender.id == thread.hostId
        ? thread.consumerId
        : null;
    if (receiverId == null || receiverId.trim().isEmpty) {
      return RepositoryFailure<ChatMessage>(
        kind: UserMessageKind.permission,
        message: AmpStrings.chatNotFoundBody,
      );
    }

    try {
      final ChatMessage draft = ChatManager.createMessage(
        threadId: thread.id,
        reservationId: thread.reservationId,
        senderId: sender.id,
        receiverId: receiverId,
        rawText: text,
        ownPhone: sender.phone,
      ).copyWith(expiresAtMs: thread.expiresAtMs);
      final Map<String, dynamic> row = draft.toJson()
        ..remove('serverUpdatedAt');
      final Map<String, dynamic> inserted = await _client
          .from('chat_messages')
          .insert(row)
          .select()
          .single();
      return RepositorySuccess<ChatMessage>(
        ChatMessage.fromJson(Map<String, dynamic>.from(inserted)),
      );
    } on Object catch (error) {
      return RepositoryFailure<ChatMessage>.from(error);
    }
  }
}
