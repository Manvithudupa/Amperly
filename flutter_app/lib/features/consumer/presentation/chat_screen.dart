import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_chip.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/engines/chat_manager.dart';
import '../application/chat_providers.dart';
import '../application/chat_rules.dart';

/// One conversation with a station host.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({required this.threadId, super.key});

  final String threadId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _composer = TextEditingController();
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send(ChatThreadData data) async {
    if (_sending) {
      return;
    }
    final String raw = _composer.text;
    final String? problem = ChatRules.messageError(raw);
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    final chatRepository = ref.read(chatRepositoryProvider);
    if (chatRepository == null) {
      setState(() => _error = AmpStrings.chatSendFailed);
      return;
    }

    setState(() {
      _error = null;
      _sending = true;
    });
    final RepositoryResult<ChatMessage> result = await chatRepository
        .sendMessage(thread: data.thread, sender: data.consumer, text: raw);
    if (!mounted) {
      return;
    }
    setState(() => _sending = false);

    final RepositoryFailure<ChatMessage>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }

    _composer.clear();
    ref.invalidate(chatMessagesProvider(widget.threadId));
    if (ChatRules.warnsOffPlatform(raw)) {
      AmpSnackbar.show(
        context,
        AmpStrings.chatOffPlatformWarning,
        tone: AmpSnackbarTone.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<ChatThreadData>> thread = ref.watch(
      chatThreadProvider(widget.threadId),
    );
    final ChatThreadData? data = thread.asData?.value.valueOrNull;
    final String subtitle = data == null ? '' : ChatRules.closesOn(data.thread);
    final String? closure = data == null
        ? null
        : ChatRules.closureMessage(
            data.thread,
            DateTime.now().millisecondsSinceEpoch,
          );

    return AmpScaffold(
      title: data == null
          ? AmpStrings.chatTitle
          : ChatRules.title(data.thread, data.consumer.id),
      subtitle: subtitle.isEmpty ? null : subtitle,
      body: thread.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(chatThreadProvider(widget.threadId)),
        ),
        data: (RepositoryResult<ChatThreadData> result) {
          final RepositoryFailure<ChatThreadData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () =>
                  ref.invalidate(chatThreadProvider(widget.threadId)),
            );
          }
          final ChatThreadData? chat = result.valueOrNull;
          if (chat == null) {
            return const EmptyState(
              title: AmpStrings.chatNotFoundTitle,
              message: AmpStrings.chatNotFoundBody,
            );
          }
          return _ThreadBody(thread: chat.thread, consumer: chat.consumer);
        },
      ),
      bottomBar: data == null
          ? null
          : closure == null
          ? _composerBar(context, data)
          : _closedBar(context, closure),
    );
  }

  Widget _composerBar(BuildContext context, ChatThreadData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ChatManager.quickQuestions.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: AmpTheme.spaceS),
            itemBuilder: (BuildContext context, int index) {
              final String question = ChatManager.quickQuestions[index];
              return Center(
                child: AmpChip(
                  label: question,
                  onTap: () {
                    _composer.text = question;
                    _send(data);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: AmpField(
                controller: _composer,
                hint: AmpStrings.chatComposerHint,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                errorText: _error,
                onChanged: (String value) {
                  if (_error != null) {
                    setState(() => _error = null);
                  }
                },
              ),
            ),
            const SizedBox(width: AmpTheme.spaceS),
            AmpButton(
              label: AmpStrings.chatSend,
              icon: AmpIconName.arrowRight,
              expand: false,
              height: 48,
              loading: _sending,
              onPressed: () => _send(data),
            ),
          ],
        ),
      ],
    );
  }

  Widget _closedBar(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AmpTheme.spaceS),
      child: Text(message, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _ThreadBody extends ConsumerStatefulWidget {
  const _ThreadBody({required this.thread, required this.consumer});

  final CommunicationThread thread;
  final AppUser consumer;

  @override
  ConsumerState<_ThreadBody> createState() => _ThreadBodyState();
}

class _ThreadBodyState extends ConsumerState<_ThreadBody> {
  final ScrollController _scroll = ScrollController();
  int _lastCount = -1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd(int count) {
    if (count == _lastCount) {
      return;
    }
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) {
        return;
      }
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ChatMessage>> messages = ref.watch(
      chatMessagesProvider(widget.thread.id),
    );
    ref.listen<AsyncValue<List<ChatMessage>>>(
      chatMessagesProvider(widget.thread.id),
      (
        AsyncValue<List<ChatMessage>>? previous,
        AsyncValue<List<ChatMessage>> next,
      ) {
        if (next.hasValue) {
          _scrollToEnd(next.value?.length ?? 0);
        }
      },
    );

    return Column(
      children: <Widget>[
        const _SafetyNote(),
        Expanded(
          child: messages.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stack) => ErrorState(
              message: UserMessages.from(error),
              onRetry: () =>
                  ref.invalidate(chatMessagesProvider(widget.thread.id)),
            ),
            data: (List<ChatMessage> list) {
              _scrollToEnd(list.length);
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(chatMessagesProvider(widget.thread.id));
                  await ref.read(chatMessagesProvider(widget.thread.id).future);
                },
                child: ListView.builder(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AmpTheme.screenPadding,
                    AmpTheme.spaceM,
                    AmpTheme.screenPadding,
                    AmpTheme.spaceL,
                  ),
                  itemCount: list.isEmpty ? 1 : list.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (list.isEmpty) {
                      return const EmptyState(
                        title: AmpStrings.chatNoMessagesTitle,
                        message: AmpStrings.chatNoMessagesBody,
                      );
                    }
                    final ChatMessage message = list[index];
                    return _MessageBubble(
                      message: message,
                      own: message.senderId == widget.consumer.id,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

    return Container(
      width: double.infinity,
      color: colors.surfaceVariant,
      padding: const EdgeInsets.symmetric(
        horizontal: AmpTheme.screenPadding,
        vertical: AmpTheme.spaceS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmpIcon(AmpIconName.shield, size: 16, color: colors.inkSecondary),
          const SizedBox(width: AmpTheme.spaceS),
          Expanded(
            child: Text(
              AmpStrings.chatMaskedNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.own});

  final ChatMessage message;
  final bool own;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String body = (message.messageText ?? '').trim();
    if (body.isEmpty) {
      return const SizedBox.shrink();
    }

    final Color foreground = own ? colors.onPrimary : colors.ink;
    final Color timestamp = own
        ? colors.onPrimary.withValues(alpha: 0.68)
        : colors.inkSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
      child: Align(
        alignment: own ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: own ? colors.primary : colors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AmpTheme.radiusCard),
                topRight: const Radius.circular(AmpTheme.radiusCard),
                bottomLeft: Radius.circular(own ? AmpTheme.radiusCard : 4),
                bottomRight: Radius.circular(own ? 4 : AmpTheme.radiusCard),
              ),
              border: own ? null : Border.all(color: colors.divider),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    body,
                    style: text.bodyMedium?.copyWith(color: foreground),
                  ),
                  if (message.createdAtMs > 0) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      AmpFormat.messageTimestamp(message.createdAtMs),
                      style: text.bodySmall?.copyWith(
                        fontSize: 11,
                        color: timestamp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
