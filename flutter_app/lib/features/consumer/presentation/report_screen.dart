import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../core/widgets/unsaved_changes_guard.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../auth/application/profile_providers.dart';

/// Files a consumer report about a charger or host, or a host report about a
/// driver. Host reports name the session and let the admin desk resolve the
/// other party, exactly as the native report dialog did.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({
    super.key,
    this.stationId,
    this.hostId,
    this.sessionId,
    this.stationName,
    this.hostMode = false,
  });

  final String? stationId;
  final String? hostId;
  final String? sessionId;
  final String? stationName;
  final bool hostMode;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final TextEditingController _details = TextEditingController();
  late String _type = _types.first;
  bool _busy = false;
  bool _submitted = false;
  String? _error;

  bool get _hasUnsavedChanges =>
      !_submitted && (_details.text.trim().isNotEmpty || _type != _types.first);

  List<String> get _types => widget.hostMode
      ? const <String>[
          AmpStrings.reportTypeNoShow,
          AmpStrings.reportTypeDamage,
          AmpStrings.reportTypeAbuse,
          AmpStrings.reportTypePayment,
          AmpStrings.reportTypeOther,
        ]
      : const <String>[
          AmpStrings.reportTypeUnsafe,
          AmpStrings.reportTypeMeter,
          AmpStrings.reportTypeAccess,
          AmpStrings.reportTypeCleanliness,
          AmpStrings.reportTypeStation,
          AmpStrings.reportTypeHostConduct,
          AmpStrings.reportTypeOther,
        ];

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final String? stationId = (widget.stationId ?? '').trim().isEmpty
        ? null
        : widget.stationId!.trim();
    final String? hostId = (widget.hostId ?? '').trim().isEmpty
        ? null
        : widget.hostId!.trim();
    final String? sessionId = (widget.sessionId ?? '').trim().isEmpty
        ? null
        : widget.sessionId!.trim();
    if (!widget.hostMode && stationId == null && hostId == null) {
      setState(() => _error = AmpStrings.reportMissingTarget);
      return;
    }
    if (widget.hostMode && sessionId == null) {
      setState(() => _error = AmpStrings.reportMissingTarget);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final RepositoryResult<AppUser> profile = await ref.read(
      currentProfileProvider.future,
    );
    if (!mounted) {
      return;
    }
    final AppUser? reporter = profile.valueOrNull;
    final repository = ref.read(reportRepositoryProvider);
    if (reporter == null || repository == null) {
      setState(() {
        _busy = false;
        _error = UserMessages.messageFor(UserMessageKind.sessionExpired);
      });
      return;
    }

    final RepositoryResult<Report> result = await repository.submit(
      reporter: reporter,
      reportType: _type,
      description: _details.text,
      stationId: stationId,
      hostId: hostId,
      sessionId: sessionId,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    final RepositoryFailure<Report>? failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _error = failure.message);
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    setState(() => _submitted = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.pop();
      }
    });
    messenger.showSnackBar(
      const SnackBar(content: Text(AmpStrings.reportSubmitted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String target = (widget.stationName ?? '').trim();
    final String contextLabel = widget.hostMode
        ? AmpStrings.reportHostContext
        : AmpStrings.reportConsumerContext;

    return AmpUnsavedChangesGuard(
      hasUnsavedChanges: _hasUnsavedChanges,
      onDiscard: () {
        if (mounted) {
          context.pop();
        }
      },
      child: AmpScaffold(
        title: AmpStrings.reportTitle,
        subtitle: AmpStrings.reportSubtitle,
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AmpTheme.screenPadding,
            AmpTheme.spaceM,
            AmpTheme.screenPadding,
            AmpTheme.spaceXxl + 88,
          ),
          children: <Widget>[
            Eyebrow(contextLabel),
            const SizedBox(height: 4),
            Text(
              target.isEmpty
                  ? widget.hostMode
                        ? AmpStrings.reportAboutDriver
                        : AmpStrings.reportAboutCharger
                  : target,
              style: text.titleMedium,
            ),
            const SizedBox(height: AmpTheme.spaceL),
            const Hairline(),
            const SizedBox(height: AmpTheme.spaceL),
            const Eyebrow(AmpStrings.reportTypeLabel),
            const SizedBox(height: AmpTheme.spaceS),
            TextFilterRow<String>(
              options: <TextFilterOption<String>>[
                for (final String type in _types)
                  TextFilterOption<String>(value: type, label: type),
              ],
              selected: _type,
              onSelected: (String type) => setState(() => _type = type),
            ),
            const SizedBox(height: AmpTheme.spaceL),
            AmpField(
              controller: _details,
              label: AmpStrings.reportDetailsLabel,
              hint: AmpStrings.reportDetailsHint,
              maxLines: 5,
              minLines: 3,
              maxLength: 1200,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              errorText: _error,
              onChanged: (String value) {
                setState(() => _error = null);
              },
            ),
          ],
        ),
        bottomBar: AmpButton(
          label: _busy ? AmpStrings.reportSubmitting : AmpStrings.reportSubmit,
          loading: _busy,
          onPressed: _busy ? null : _submit,
        ),
      ),
    );
  }
}
