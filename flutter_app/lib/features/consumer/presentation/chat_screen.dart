import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/text_action.dart';
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

  Future<void> _reportThread(ChatThreadData data) async {
    if (data.thread.isReported) {
      return;
    }
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.chatReportTitle,
      message: AmpStrings.chatReportBody,
      confirmLabel: AmpStrings.chatReportConfirm,
      destructive: false,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final chatRepository = ref.read(chatRepositoryProvider);
    if (chatRepository == null) {
      return;
    }
    final RepositoryResult<bool> result = await chatRepository.setThreadFlags(
      threadId: data.thread.id,
      isReported: true,
    );
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.chatFlagFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(chatThreadProvider(widget.threadId));
    AmpSnackbar.show(
      context,
      AmpStrings.chatReported,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _blockThread(ChatThreadData data) async {
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.chatBlockTitle,
      message: AmpStrings.chatBlockBody,
      confirmLabel: AmpStrings.chatBlockConfirm,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final chatRepository = ref.read(chatRepositoryProvider);
    if (chatRepository == null) {
      return;
    }
    final RepositoryResult<bool> result = await chatRepository.setThreadFlags(
      threadId: data.thread.id,
      isBlocked: true,
    );
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.chatFlagFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(chatThreadProvider(widget.threadId));
    ref.invalidate(chatInboxProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.chatBlockedToast,
      tone: AmpSnackbarTone.success,
    );
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
        loading: () => const _ThreadLoading(),
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
            return const _MissingThread();
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
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ChatManager.quickQuestions.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 20),
            itemBuilder: (BuildContext context, int index) {
              final String question = ChatManager.quickQuestions[index];
              return Center(
                child: TextAction(
                  question,
                  underline: false,
                  onPressed: () {
                    _composer.text = question;
                    _send(data);
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Wrap(
          spacing: AmpTheme.spaceL,
          runSpacing: 0,
          children: <Widget>[
            if (!data.thread.isReported)
              TextAction(
                AmpStrings.chatReportThread,
                onPressed: () => _reportThread(data),
              ),
            if (!data.thread.isBlocked)
              TextAction(
                AmpStrings.chatBlockThread,
                tone: TextActionTone.danger,
                onPressed: () => _blockThread(data),
              ),
          ],
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
            loading: () => const _MessageLoading(),
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
                  padding: EdgeInsets.zero,
                  itemCount: list.isEmpty ? 1 : list.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (list.isEmpty) {
                      return const _EmptyConversation();
                    }
                    final ChatMessage message = list[index];
                    return _MessageEntry(
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
    return Column(
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AmpTheme.screenPadding,
            vertical: 10,
          ),
          child: Text(
            AmpStrings.chatMaskedNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Hairline(),
      ],
    );
  }
}

class _MessageEntry extends StatelessWidget {
  const _MessageEntry({required this.message, required this.own});

  final ChatMessage message;
  final bool own;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final String body = (message.messageText ?? '').trim();
    if (body.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(own ? 42 : 0, 12, own ? 0 : 42, 0),
          child: Align(
            alignment: own ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              padding: EdgeInsets.only(left: own ? 0 : 10, right: own ? 10 : 0),
              decoration: BoxDecoration(
                border: Border(
                  right: own
                      ? BorderSide(color: colors.energy, width: 2)
                      : BorderSide.none,
                  left: own
                      ? BorderSide.none
                      : BorderSide(color: colors.divider, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: own
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Eyebrow(
                    own ? AmpStrings.chatYou : AmpStrings.chatHostFallback,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    textAlign: own ? TextAlign.right : TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (message.createdAtMs > 0) ...<Widget>[
                    const SizedBox(height: 4),
                    Text(
                      AmpFormat.messageTimestamp(message.createdAtMs),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Hairline(),
      ],
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceXl,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AmpStrings.chatNoMessagesTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.chatNoMessagesBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MissingThread extends StatelessWidget {
  const _MissingThread();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AmpStrings.chatNotFoundTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.chatNotFoundBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ThreadLoading extends StatelessWidget {
  const _ThreadLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const <Widget>[
        Padding(
          padding: EdgeInsets.all(AmpTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SkeletonLine(widthFactor: 0.28, height: 9),
              SizedBox(height: 8),
              SkeletonLine(widthFactor: 0.62, height: 26),
              SizedBox(height: 8),
              SkeletonLine(widthFactor: 0.44),
              SizedBox(height: 20),
              Hairline(),
              SizedBox(height: 18),
              SkeletonLine(widthFactor: 0.55, height: 12),
              SizedBox(height: 8),
              SkeletonLine(widthFactor: 0.7, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageLoading extends StatelessWidget {
  const _MessageLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AmpTheme.screenPadding,
        vertical: AmpTheme.spaceM,
      ),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.2, height: 8),
        SizedBox(height: 6),
        SkeletonLine(widthFactor: 0.66, height: 14),
        SizedBox(height: 16),
        Hairline(),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: SkeletonLine(widthFactor: 0.46, height: 14),
        ),
        SizedBox(height: 16),
        Hairline(),
        SizedBox(height: 16),
        SkeletonLine(widthFactor: 0.58, height: 14),
        SizedBox(height: 16),
        Hairline(),
      ],
    );
  }
}
