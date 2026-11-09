import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/safety_repository.dart';
import '../../auth/application/profile_providers.dart';
import '../application/safety_providers.dart';

/// Trusted contacts, the SOS event and the one-hour location-sharing window.
/// This is explicitly a record, not an emergency dispatch service.
class SafetyScreen extends ConsumerStatefulWidget {
  const SafetyScreen({super.key, this.stationId});

  final String? stationId;

  @override
  ConsumerState<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends ConsumerState<SafetyScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  bool _busy = false;
  String? _contactError;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  AppUser? get _profile =>
      ref.read(currentProfileProvider).asData?.value.valueOrNull;

  Future<void> _addContact() async {
    final AppUser? user = _profile;
    final SafetyRepository? repository = ref.read(safetyRepositoryProvider);
    if (user == null || repository == null) {
      return;
    }
    setState(() {
      _busy = true;
      _contactError = null;
    });
    final RepositoryResult<TrustedContact> result = await repository.addContact(
      userId: user.id,
      name: _name.text,
      phone: _phone.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    final RepositoryFailure<TrustedContact>? failure = result.failureOrNull;
    if (failure != null) {
      setState(() => _contactError = failure.message);
      return;
    }
    _name.clear();
    _phone.clear();
    ref.invalidate(safetyDataProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.safetyContactSaved,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _removeContact(TrustedContact contact) async {
    final String name = (contact.name ?? '').trim();
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.safetyDeleteContactTitle,
      message: AmpStrings.safetyDeleteContactBody(name),
      confirmLabel: AmpStrings.safetyRemove,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final SafetyRepository? repository = ref.read(safetyRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<bool> result = await repository.deleteContact(
      contact.id,
    );
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.safetyContactRemoveFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(safetyDataProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.safetyContactRemoved,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _recordSos() async {
    final AppUser? user = _profile;
    final SafetyRepository? repository = ref.read(safetyRepositoryProvider);
    if (user == null || repository == null) {
      return;
    }
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.safetySosTitle,
      message: AmpStrings.safetySosBody,
      confirmLabel: AmpStrings.safetySosConfirm,
      destructive: false,
    );
    if (!confirmed || !mounted) {
      return;
    }
    final RepositoryResult<SafetyEvent> result = await repository.recordSos(
      userId: user.id,
      stationId: widget.stationId,
    );
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.safetySosFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(safetyDataProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.safetySosRecorded,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _startSharing(SafetyData data) async {
    final AppUser? user = _profile;
    final SafetyRepository? repository = ref.read(safetyRepositoryProvider);
    if (user == null || repository == null) {
      return;
    }
    if (data.contacts.isEmpty) {
      AmpSnackbar.show(
        context,
        AmpStrings.safetyShareNeedsContact,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    final RepositoryResult<SafetyEvent> result = await repository.startSharing(
      userId: user.id,
      contact: data.contacts.first,
      stationId: widget.stationId,
    );
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.safetyShareFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(safetyDataProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.safetyShareStarted,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _callContact(TrustedContact contact) async {
    final String phone = (contact.phone ?? '').trim();
    if (phone.isEmpty) {
      return;
    }
    try {
      final bool opened = await launchUrl(Uri(scheme: 'tel', path: phone));
      if (!opened && mounted) {
        AmpSnackbar.show(
          context,
          AmpStrings.safetyCallFailed,
          tone: AmpSnackbarTone.error,
        );
      }
    } on Object {
      if (mounted) {
        AmpSnackbar.show(
          context,
          AmpStrings.safetyCallFailed,
          tone: AmpSnackbarTone.error,
        );
      }
    }
  }

  Future<void> _stopSharing(SafetyEvent event) async {
    final SafetyRepository? repository = ref.read(safetyRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<bool> result = await repository.stopSharing(event);
    if (!mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.safetyShareFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(safetyDataProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.safetyShareStopped,
      tone: AmpSnackbarTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<SafetyData>> async = ref.watch(
      safetyDataProvider,
    );

    return AmpScaffold(
      title: AmpStrings.safetyTitle,
      body: async.when(
        loading: () => const _SafetyLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(safetyDataProvider),
        ),
        data: (RepositoryResult<SafetyData> result) {
          final RepositoryFailure<SafetyData>? failure = result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(safetyDataProvider),
            );
          }
          return _body(result.valueOrNull!);
        },
      ),
    );
  }

  Widget _body(SafetyData data) {
    final TextTheme text = Theme.of(context).textTheme;
    final SafetyEvent? active = data.activeSharing;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        Text(AmpStrings.safetyDemoNotice, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceM),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceM),
        AmpButton(
          label: AmpStrings.safetySosButton,
          variant: AmpButtonVariant.danger,
          onPressed: _recordSos,
        ),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.safetyShareTitle),
        const SizedBox(height: AmpTheme.spaceS),
        Text(AmpStrings.safetyShareBody, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceS),
        if (active != null) ...<Widget>[
          StatusDotLabel(
            AmpStrings.safetyShareActiveLabel,
            detail: active.trustedContactPhone,
            tone: StatusDotTone.available,
          ),
          const SizedBox(height: 4),
          Text(
            AmpStrings.safetyShareActive(
              active.trustedContactPhone ?? AmpStrings.labelUnknown,
              AmpFormat.messageTimestamp(active.expiresAtMs),
            ),
            style: text.bodySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          TextAction(
            AmpStrings.safetyShareStop,
            tone: TextActionTone.danger,
            onPressed: () => _stopSharing(active),
          ),
        ] else
          TextAction(
            AmpStrings.safetyShareStart,
            onPressed: () => _startSharing(data),
          ),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.safetyTrustedTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.contacts.isEmpty)
          Text(AmpStrings.safetyTrustedEmpty, style: text.bodySmall)
        else
          for (final TrustedContact contact in data.contacts)
            _ContactRow(
              contact: contact,
              onCall: () => _callContact(contact),
              onRemove: () => _removeContact(contact),
            ),
        const SizedBox(height: AmpTheme.spaceM),
        AmpField(
          controller: _name,
          label: AmpStrings.safetyContactName,
          textCapitalization: TextCapitalization.words,
          errorText: _contactError,
          onChanged: (String value) {
            if (_contactError != null) {
              setState(() => _contactError = null);
            }
          },
        ),
        const SizedBox(height: AmpTheme.spaceS),
        AmpField(
          controller: _phone,
          label: AmpStrings.safetyContactPhone,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        AmpButton(
          label: _busy ? AmpStrings.vehicleSaving : AmpStrings.safetyAddContact,
          variant: AmpButtonVariant.tonal,
          loading: _busy,
          onPressed: _busy ? null : _addContact,
        ),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.safetyHistoryTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.events.isEmpty)
          Text(AmpStrings.safetyHistoryEmpty, style: text.bodySmall)
        else
          for (final SafetyEvent event in data.events.take(20))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                AmpStrings.safetyHistoryLine(
                  (event.emergencyType ?? '').toUpperCase() == 'SOS'
                      ? AmpStrings.safetyEventSos
                      : AmpStrings.safetyEventSharing,
                  AmpFormat.messageTimestamp(event.createdAtMs),
                ),
                style: text.bodyMedium,
              ),
            ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.onCall,
    required this.onRemove,
  });

  final TrustedContact contact;
  final VoidCallback onCall;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  (contact.name ?? '').trim().isEmpty
                      ? AmpStrings.labelUnknown
                      : contact.name!.trim(),
                  style: text.titleSmall,
                ),
                if ((contact.phone ?? '').trim().isNotEmpty)
                  Text(contact.phone!.trim(), style: text.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if ((contact.phone ?? '').trim().isNotEmpty)
                TextAction(AmpStrings.safetyCall, onPressed: onCall),
              TextAction(
                AmpStrings.safetyRemove,
                tone: TextActionTone.danger,
                onPressed: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyLoading extends StatelessWidget {
  const _SafetyLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.8),
        SizedBox(height: 10),
        SkeletonLine(widthFactor: 0.6),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 52, radius: AmpTheme.radiusField),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.4, height: 12),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.75),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.55),
      ],
    );
  }
}
