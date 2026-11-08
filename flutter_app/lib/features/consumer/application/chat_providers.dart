import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';
import '../../auth/application/profile_providers.dart';

final class ChatInboxData {
  const ChatInboxData({
    required this.viewerId,
    required this.threads,
    required this.latestMessages,
    required this.reservations,
  });

  final String viewerId;
  final List<CommunicationThread> threads;
  final Map<String, ChatMessage> latestMessages;
  final Map<String, Reservation> reservations;
}

final class ChatThreadData {
  const ChatThreadData({required this.consumer, required this.thread});

  final AppUser consumer;
  final CommunicationThread thread;
}

RepositoryFailure<T> _propagate<T, S>(RepositoryFailure<S> failure) {
  return RepositoryFailure<T>(
    kind: failure.kind,
    message: failure.message,
    cause: failure.cause,
  );
}

int _latestStamp(CommunicationThread thread, Map<String, ChatMessage> latest) {
  final ChatMessage? message = latest[thread.id];
  return message?.createdAtMs ?? thread.createdAtMs;
}

/// Every conversation the signed-in consumer has, newest activity first.
final FutureProvider<RepositoryResult<ChatInboxData>> chatInboxProvider =
    FutureProvider<RepositoryResult<ChatInboxData>>((Ref ref) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return _propagate<ChatInboxData, AppUser>(profileFailure);
      }

      final chatRepository = ref.watch(chatRepositoryProvider);
      final reservationRepository = ref.watch(reservationRepositoryProvider);
      if (chatRepository == null || reservationRepository == null) {
        return RepositoryFailure<ChatInboxData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      final AppUser consumer = profile.valueOrNull!;
      final RepositoryResult<List<CommunicationThread>> threadsResult =
          await chatRepository.threadsForConsumer(consumer.id);
      final RepositoryFailure<List<CommunicationThread>>? threadsFailure =
          threadsResult.failureOrNull;
      if (threadsFailure != null) {
        return _propagate<ChatInboxData, List<CommunicationThread>>(
          threadsFailure,
        );
      }

      final List<CommunicationThread> threads = List<CommunicationThread>.of(
        threadsResult.valueOrNull ?? const <CommunicationThread>[],
      );
      if (threads.isEmpty) {
        return RepositorySuccess<ChatInboxData>(
          ChatInboxData(
            viewerId: consumer.id,
            threads: threads,
            latestMessages: const <String, ChatMessage>{},
            reservations: const <String, Reservation>{},
          ),
        );
      }

      final RepositoryResult<List<Reservation>> reservationsResult =
          await reservationRepository.forConsumer(consumer.id);
      final RepositoryFailure<List<Reservation>>? reservationsFailure =
          reservationsResult.failureOrNull;
      if (reservationsFailure != null) {
        return _propagate<ChatInboxData, List<Reservation>>(
          reservationsFailure,
        );
      }
      final Map<String, Reservation> reservations = <String, Reservation>{
        for (final Reservation reservation
            in reservationsResult.valueOrNull ?? const <Reservation>[])
          reservation.id: reservation,
      };

      final RepositoryResult<List<ChatMessage>> messagesResult =
          await chatRepository.messagesForThreads(
            threads
                .map((CommunicationThread thread) => thread.id)
                .toList(growable: false),
          );
      final RepositoryFailure<List<ChatMessage>>? messagesFailure =
          messagesResult.failureOrNull;
      if (messagesFailure != null) {
        return _propagate<ChatInboxData, List<ChatMessage>>(messagesFailure);
      }

      // The repository returns newest first, so the first message for a thread
      // is the one the inbox previews.
      final Map<String, ChatMessage> latest = <String, ChatMessage>{};
      for (final ChatMessage message
          in messagesResult.valueOrNull ?? const <ChatMessage>[]) {
        final String? threadId = message.threadId;
        if (threadId != null && threadId.isNotEmpty) {
          latest.putIfAbsent(threadId, () => message);
        }
      }
      threads.sort(
        (CommunicationThread a, CommunicationThread b) =>
            _latestStamp(b, latest).compareTo(_latestStamp(a, latest)),
      );

      return RepositorySuccess<ChatInboxData>(
        ChatInboxData(
          viewerId: consumer.id,
          threads: threads,
          latestMessages: latest,
          reservations: reservations,
        ),
      );
    });

/// One conversation and the signed-in profile that is reading it.
final chatThreadProvider =
    FutureProvider.family<RepositoryResult<ChatThreadData>, String>((
      Ref ref,
      String threadId,
    ) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return _propagate<ChatThreadData, AppUser>(profileFailure);
      }

      final chatRepository = ref.watch(chatRepositoryProvider);
      if (chatRepository == null) {
        return RepositoryFailure<ChatThreadData>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      final RepositoryResult<CommunicationThread?> threadResult =
          await chatRepository.thread(threadId);
      final RepositoryFailure<CommunicationThread?>? threadFailure =
          threadResult.failureOrNull;
      if (threadFailure != null) {
        return _propagate<ChatThreadData, CommunicationThread?>(threadFailure);
      }

      final CommunicationThread? thread = threadResult.valueOrNull;
      if (thread == null) {
        return RepositoryFailure<ChatThreadData>(
          kind: UserMessageKind.notFound,
          message: AmpStrings.chatNotFoundBody,
        );
      }

      return RepositorySuccess<ChatThreadData>(
        ChatThreadData(consumer: profile.valueOrNull!, thread: thread),
      );
    });

/// Live messages for one conversation. The stream still emits the current rows
/// when Realtime is unavailable, so opening a thread always shows its history.
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  Ref ref,
  String threadId,
) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  if (chatRepository == null) {
    return Stream<List<ChatMessage>>.error(
      StateError('No backend is configured.'),
    );
  }
  return chatRepository.watchMessages(threadId);
});

/// Finds the signed-in booking, its station's host and the pair's thread.
///
/// Creating the thread is a direct participant write because the schema has no
/// chat RPC; the host and consumer ids come from the booking and station rows.
final chatStarterProvider =
    FutureProvider.family<RepositoryResult<CommunicationThread>, String>((
      Ref ref,
      String reservationId,
    ) async {
      final RepositoryResult<AppUser> profile = await ref.watch(
        currentProfileProvider.future,
      );
      final RepositoryFailure<AppUser>? profileFailure = profile.failureOrNull;
      if (profileFailure != null) {
        return _propagate<CommunicationThread, AppUser>(profileFailure);
      }

      final chatRepository = ref.watch(chatRepositoryProvider);
      final reservationRepository = ref.watch(reservationRepositoryProvider);
      final stationRepository = ref.watch(stationRepositoryProvider);
      if (chatRepository == null ||
          reservationRepository == null ||
          stationRepository == null) {
        return RepositoryFailure<CommunicationThread>(
          kind: UserMessageKind.sessionExpired,
          message: UserMessages.messageFor(UserMessageKind.sessionExpired),
        );
      }

      final AppUser consumer = profile.valueOrNull!;
      final RepositoryResult<List<Reservation>> reservations =
          await reservationRepository.forConsumer(consumer.id);
      final RepositoryFailure<List<Reservation>>? reservationsFailure =
          reservations.failureOrNull;
      if (reservationsFailure != null) {
        return _propagate<CommunicationThread, List<Reservation>>(
          reservationsFailure,
        );
      }

      Reservation? reservation;
      for (final Reservation candidate
          in reservations.valueOrNull ?? const <Reservation>[]) {
        if (candidate.id == reservationId) {
          reservation = candidate;
          break;
        }
      }
      if (reservation == null) {
        return RepositoryFailure<CommunicationThread>(
          kind: UserMessageKind.notFound,
          message: AmpStrings.bookingNotFoundBody,
        );
      }

      final String stationId = (reservation.stationId ?? '').trim();
      if (stationId.isEmpty) {
        return const RepositoryFailure<CommunicationThread>(
          kind: UserMessageKind.notFound,
          message: AmpStrings.sessionStationMissing,
        );
      }

      final RepositoryResult<StationCatalogueEntry> detail =
          await stationRepository.detail(stationId);
      final RepositoryFailure<StationCatalogueEntry>? stationFailure =
          detail.failureOrNull;
      if (stationFailure != null) {
        return _propagate<CommunicationThread, StationCatalogueEntry>(
          stationFailure,
        );
      }

      final ChargerStation station = detail.valueOrNull!.station;
      final String hostId = (station.hostId ?? '').trim();
      if (hostId.isEmpty) {
        return const RepositoryFailure<CommunicationThread>(
          kind: UserMessageKind.validation,
          message: AmpStrings.chatNoHost,
        );
      }

      return chatRepository.ensureThread(
        consumer: consumer,
        reservation: reservation,
        hostId: hostId,
        hostName: station.hostName ?? '',
      );
    });
