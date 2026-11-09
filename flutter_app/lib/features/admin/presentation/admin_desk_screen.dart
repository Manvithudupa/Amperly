import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_sheet.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/receipt_rows.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/policy.dart';
import '../application/admin_providers.dart';

enum _AdminSection { queue, reports }

/// The administrator's two working queues: listing decisions and the reports
/// and disputes that need a recorded outcome.
class AdminDeskScreen extends ConsumerStatefulWidget {
  const AdminDeskScreen({super.key});

  @override
  ConsumerState<AdminDeskScreen> createState() => _AdminDeskScreenState();
}

class _AdminDeskScreenState extends ConsumerState<AdminDeskScreen> {
  _AdminSection _section = _AdminSection.queue;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<AdminDeskData>> async = ref.watch(
      adminDeskProvider,
    );

    return AmpScaffold(
      title: AmpStrings.adminTitle,
      subtitle: AmpStrings.adminSubtitle,
      body: async.when(
        loading: () => const _AdminLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: AmpStrings.adminDecisionFailed,
          onRetry: () => ref.invalidate(adminDeskProvider),
        ),
        data: (RepositoryResult<AdminDeskData> result) {
          final RepositoryFailure<AdminDeskData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(adminDeskProvider),
            );
          }
          return _body(result.valueOrNull!);
        },
      ),
    );
  }

  Widget _body(AdminDeskData data) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AmpTheme.screenPadding,
            AmpTheme.spaceS,
            AmpTheme.screenPadding,
            0,
          ),
          child: TextFilterRow<_AdminSection>(
            options: const <TextFilterOption<_AdminSection>>[
              TextFilterOption<_AdminSection>(
                value: _AdminSection.queue,
                label: AmpStrings.adminTabQueue,
              ),
              TextFilterOption<_AdminSection>(
                value: _AdminSection.reports,
                label: AmpStrings.adminTabReports,
              ),
            ],
            selected: _section,
            onSelected: (_AdminSection section) =>
                setState(() => _section = section),
          ),
        ),
        const Hairline(),
        Expanded(
          child: switch (_section) {
            _AdminSection.queue => _QueueSection(data: data),
            _AdminSection.reports => _ReportsSection(data: data),
          },
        ),
      ],
    );
  }
}

class _QueueSection extends ConsumerWidget {
  const _QueueSection({required this.data});

  final AdminDeskData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        const Eyebrow(AmpStrings.adminPlatformSummary),
        const SizedBox(height: AmpTheme.spaceS),
        ReceiptRows(
          lines: <ReceiptLine>[
            ReceiptLine(
              label: AmpStrings.adminPendingCount,
              value: data.pendingStations.length.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.adminDisputeCount,
              value: data.disputes.length.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.adminReportCount,
              value: data.reportCount.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.adminSessionsCount,
              value: data.analytics.sessionsCompleted.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.adminEnergyCount,
              value: AmpFormat.kWh(data.analytics.energyDeliveredKwh),
            ),
            ReceiptLine(
              label: AmpStrings.adminRevenueCount,
              value: AmpFormat.rupees(data.analytics.revenue),
            ),
            ReceiptLine(
              label: AmpStrings.adminRefundTotal,
              value: AmpFormat.rupees(data.analytics.refundsAndAdjustments),
            ),
            ReceiptLine(
              label: AmpStrings.adminUtilizationCount,
              value: AmpFormat.percent(data.analytics.utilizationPercent),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.adminQueueTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.pendingStations.isEmpty)
          Text(AmpStrings.adminQueueEmpty, style: text.bodySmall)
        else
          for (final ChargerStation station in data.pendingStations)
            _PendingStationCard(station: station),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.adminDisputesTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.disputes.isEmpty)
          Text(AmpStrings.adminDisputesEmpty, style: text.bodySmall)
        else
          for (final AdminDisputeRow row in data.disputes)
            _DisputeCard(row: row),
      ],
    );
  }
}

class _PendingStationCard extends ConsumerWidget {
  const _PendingStationCard({required this.station});

  final ChargerStation station;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final String address = (station.address ?? '').trim().isEmpty
        ? AmpStrings.addressNotPublished
        : station.address!.trim();
    final String host = (station.hostName ?? '').trim();
    final String meta = <String>[
      AmpFormat.meterLevel(station.verificationLevel),
      if (station.portCount > 0) '${station.portCount} ports',
      if (station.maxPowerKw > 0) '${station.maxPowerKw.toInt()} kW',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(name, style: text.titleMedium)),
              const SizedBox(width: AmpTheme.spaceS),
              const StatusDotLabel(
                AmpStrings.hostStationPending,
                tone: StatusDotTone.busy,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(address, style: text.bodySmall),
          if (host.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(host, style: text.bodySmall),
          ],
          const SizedBox(height: 2),
          Text(meta, style: text.bodySmall),
          const SizedBox(height: 2),
          Text(AmpStrings.adminApproveBody, style: text.bodySmall),
          const SizedBox(height: AmpTheme.spaceS),
          Wrap(
            spacing: AmpTheme.spaceM,
            children: <Widget>[
              TextAction(
                AmpStrings.adminApprove,
                onPressed: () => _decide(context, ref, true),
              ),
              TextAction(
                AmpStrings.adminDecline,
                tone: TextActionTone.danger,
                onPressed: () => _decide(context, ref, false),
              ),
            ],
          ),
          const SizedBox(height: AmpTheme.spaceS),
          const Hairline(),
        ],
      ),
    );
  }

  Future<void> _decide(
    BuildContext context,
    WidgetRef ref,
    bool approve,
  ) async {
    final AdminRepository? repository = ref.read(adminRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<String> result = await repository.decideStation(
      station: station,
      approve: approve,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<String>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.adminDecisionFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(adminDeskProvider);
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    AmpSnackbar.show(
      context,
      approve ? AmpStrings.adminApproved(name) : AmpStrings.adminDeclined(name),
      tone: AmpSnackbarTone.success,
    );
  }
}

class _DisputeCard extends ConsumerWidget {
  const _DisputeCard({required this.row});

  final AdminDisputeRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Dispute dispute = row.dispute;
    final TextTheme text = Theme.of(context).textTheme;
    final String station = (dispute.stationName ?? '').trim().isEmpty
        ? AmpStrings.adminStationFallback
        : dispute.stationName!.trim();
    final String consumer = (dispute.consumerName ?? '').trim().isEmpty
        ? AmpStrings.adminDisputeConsumer
        : dispute.consumerName!.trim();
    final String reason = (dispute.reason ?? '').trim();
    final String evidence = row.evidence.isNotEmpty
        ? row.evidence
              .map(
                (MeterReading reading) =>
                    '${reading.startMeterKwh.toStringAsFixed(2)} → '
                    '${reading.endMeterKwh.toStringAsFixed(2)} kWh',
              )
              .join(' · ')
        : (dispute.evidence ?? '').trim().isNotEmpty
        ? dispute.evidence!.trim()
        : AmpStrings.adminEvidenceNone;

    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(station, style: text.titleMedium)),
              const SizedBox(width: AmpTheme.spaceS),
              StatusDotLabel(
                dispute.isOpen
                    ? AmpStrings.adminReportOpen
                    : AmpStrings.adminReportResolved,
                tone: dispute.isOpen
                    ? StatusDotTone.busy
                    : StatusDotTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(consumer, style: text.bodySmall),
          if (reason.isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(reason, style: text.bodyMedium),
          ],
          if ((dispute.consumerNotes ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(dispute.consumerNotes!.trim(), style: text.bodySmall),
          ],
          const SizedBox(height: 5),
          Text(
            '${AmpStrings.adminEvidenceTitle}: $evidence',
            style: text.bodySmall,
          ),
          if (dispute.refundAmount > 0) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              '${AmpStrings.adminRefundAmount}: '
              '${AmpFormat.rupees(dispute.refundAmount)}',
              style: text.bodySmall,
            ),
          ],
          if (dispute.isPayoutFrozen) ...<Widget>[
            const SizedBox(height: 2),
            Text(AmpStrings.adminPayoutFrozen, style: text.bodySmall),
          ],
          if (dispute.isOpen) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            Wrap(
              spacing: AmpTheme.spaceM,
              runSpacing: 0,
              children: <Widget>[
                TextAction(
                  AmpStrings.adminDisputeRefund,
                  onPressed: () => _refund(context, ref),
                ),
                if (!dispute.isPayoutFrozen)
                  TextAction(
                    AmpStrings.adminDisputeFreeze,
                    onPressed: () => _freeze(context, ref),
                  ),
                TextAction(
                  AmpStrings.adminDisputeWarning,
                  onPressed: () =>
                      _enforce(context, ref, AmpPolicy.enforcementWarning, 0),
                ),
                TextAction(
                  AmpStrings.adminDisputeFine,
                  onPressed: () => _enforce(
                    context,
                    ref,
                    AmpPolicy.enforcementFine,
                    AmpPolicy.enforcementFineInr,
                  ),
                ),
                TextAction(
                  AmpStrings.adminDisputeSuspend,
                  onPressed: () => _enforce(
                    context,
                    ref,
                    AmpPolicy.enforcementSuspension,
                    0,
                  ),
                ),
                TextAction(
                  AmpStrings.adminDisputeBan,
                  tone: TextActionTone.danger,
                  onPressed: () =>
                      _enforce(context, ref, AmpPolicy.enforcementBan, 0),
                ),
              ],
            ),
          ],
          if ((dispute.resolutionNote ?? '').trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 4),
            Text(dispute.resolutionNote!.trim(), style: text.bodySmall),
          ],
          const SizedBox(height: AmpTheme.spaceS),
          const Hairline(),
        ],
      ),
    );
  }

  Future<void> _refund(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.adminConfirmRefundTitle,
      message: AmpStrings.adminConfirmRefundBody,
      confirmLabel: AmpStrings.adminRefundAction,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final AdminRepository? repository = ref.read(adminRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<String> result = await repository.refundDispute(
      row.dispute,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<String>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.adminRefundFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(adminDeskProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.adminRefunded,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _freeze(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.adminConfirmFreezeTitle,
      message: AmpStrings.adminConfirmFreezeBody,
      confirmLabel: AmpStrings.adminHoldAction,
      destructive: false,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final AdminRepository? repository = ref.read(adminRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<String> result = await repository
        .freezeDisputePayout(row.dispute);
    if (!context.mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.adminPayoutHoldFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(adminDeskProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.adminPayoutHeld,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _enforce(
    BuildContext context,
    WidgetRef ref,
    String action,
    double fine,
  ) async {
    final String title;
    final String body;
    final String confirm;
    final bool destructive;
    switch (action) {
      case AmpPolicy.enforcementWarning:
        title = AmpStrings.adminConfirmWarningTitle;
        body = AmpStrings.adminConfirmWarningBody;
        confirm = AmpStrings.adminWarningAction;
        destructive = false;
      case AmpPolicy.enforcementFine:
        title = AmpStrings.adminConfirmFineTitle;
        body = AmpStrings.adminConfirmFineBody(AmpFormat.rupees(fine));
        confirm = AmpStrings.adminFineAction;
        destructive = false;
      case AmpPolicy.enforcementSuspension:
        title = AmpStrings.adminConfirmSuspendTitle;
        body = AmpStrings.adminConfirmSuspendBody;
        confirm = AmpStrings.adminSuspendAction;
        destructive = true;
      default:
        title = AmpStrings.adminConfirmBanTitle;
        body = AmpStrings.adminConfirmBanBody;
        confirm = AmpStrings.adminBanAction;
        destructive = true;
    }

    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: title,
      message: body,
      confirmLabel: confirm,
      destructive: destructive,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    final AdminRepository? repository = ref.read(adminRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<String> result = await repository
        .applyDisputeEnforcement(
          dispute: row.dispute,
          action: action,
          fineAmount: fine,
        );
    if (!context.mounted) {
      return;
    }
    if (result.failureOrNull != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.adminEnforcementFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(adminDeskProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.adminEnforcementRecorded,
      tone: AmpSnackbarTone.success,
    );
  }
}

class _ReportsSection extends ConsumerWidget {
  const _ReportsSection({required this.data});

  final AdminDeskData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        const Eyebrow(AmpStrings.adminReportsTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.consumerReports.isEmpty)
          Text(AmpStrings.adminReportsEmpty, style: text.bodySmall)
        else
          for (final AdminReportRow row in data.consumerReports)
            _ReportCard(row: row),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.adminHostReportsTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.hostReports.isEmpty)
          Text(AmpStrings.adminReportsEmpty, style: text.bodySmall)
        else
          for (final AdminReportRow row in data.hostReports)
            _ReportCard(row: row),
      ],
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.row});

  final AdminReportRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final Report report = row.report;
    final String type = (report.reportType ?? '').trim().isEmpty
        ? AmpStrings.labelUnknown
        : report.reportType!.trim();
    final bool open = (report.status ?? '').toUpperCase() == 'OPEN';
    final String details = (report.description ?? '').trim().isEmpty
        ? AmpStrings.adminReportNoDetails
        : report.description!.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: Text(type, style: text.titleMedium)),
              const SizedBox(width: AmpTheme.spaceS),
              StatusDotLabel(
                open
                    ? AmpStrings.adminReportOpen
                    : AmpStrings.adminReportResolved,
                tone: open ? StatusDotTone.busy : StatusDotTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${AmpStrings.adminReportBy} ${row.reporterName} · '
            '${AmpStrings.adminReportAbout} ${row.targetName}',
            style: text.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(details, style: text.bodyMedium),
          if (open) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            Wrap(
              spacing: AmpTheme.spaceM,
              children: <Widget>[
                TextAction(
                  AmpStrings.adminReportWarning,
                  onPressed: () => _warning(context, ref),
                ),
                TextAction(
                  AmpStrings.adminReportSuspend,
                  onPressed: () => _suspend(context, ref),
                ),
                TextAction(
                  AmpStrings.adminReportBan,
                  tone: TextActionTone.danger,
                  onPressed: () => _ban(context, ref),
                ),
              ],
            ),
          ],
          const SizedBox(height: AmpTheme.spaceS),
          const Hairline(),
        ],
      ),
    );
  }

  Future<void> _warning(BuildContext context, WidgetRef ref) async {
    await _apply(context, ref, AmpPolicy.enforcementWarning, 0);
  }

  Future<void> _suspend(BuildContext context, WidgetRef ref) async {
    if (row.targetUserId == null || row.targetUserId!.isEmpty) {
      AmpSnackbar.show(
        context,
        AmpStrings.adminNoTargetBody,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    final AdminRepository? repository = ref.read(adminRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<int> count = await repository.enforcementCountFor(
      row.targetUserId,
    );
    if (!context.mounted) {
      return;
    }
    final int prior = count.valueOrNull ?? 0;
    final int suggested = repository.suggestedSuspensionDays(prior);
    final int? days = await showAmpSheet<int>(
      context: context,
      title: AmpStrings.adminSuspendTitle,
      builder: (BuildContext sheetContext) =>
          _SuspensionSheet(suggested: suggested),
    );
    if (days == null || !context.mounted) {
      return;
    }
    await _apply(
      context,
      ref,
      AmpPolicy.enforcementSuspension,
      days * AmpPolicy.suspensionDayMs,
      confirm: false,
    );
  }

  Future<void> _ban(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.adminConfirmBanTitle,
      message: AmpStrings.adminConfirmBanBody,
      confirmLabel: AmpStrings.adminBanAction,
    );
    if (!confirmed || !context.mounted) {
      return;
    }
    await _apply(context, ref, AmpPolicy.enforcementBan, 0, confirm: false);
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    String action,
    int expiresAtMs, {
    bool confirm = true,
  }) async {
    if (confirm) {
      final bool confirmed = await showAmpConfirmDialog(
        context,
        title: action == AmpPolicy.enforcementWarning
            ? AmpStrings.adminConfirmWarningTitle
            : AmpStrings.adminConfirmBanTitle,
        message: action == AmpPolicy.enforcementWarning
            ? AmpStrings.adminConfirmWarningBody
            : AmpStrings.adminConfirmBanBody,
        confirmLabel: action == AmpPolicy.enforcementWarning
            ? AmpStrings.adminWarningAction
            : AmpStrings.adminBanAction,
        destructive: action == AmpPolicy.enforcementBan,
      );
      if (!confirmed || !context.mounted) {
        return;
      }
    }
    final AdminRepository? repository = ref.read(adminRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<bool> result = await repository.applyReportAction(
      row: row,
      action: action,
      expiresAtMs: expiresAtMs,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<bool>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(
        context,
        failure.message.isEmpty
            ? AmpStrings.adminReportResolutionFailed
            : failure.message,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(adminDeskProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.adminActionRecorded,
      tone: AmpSnackbarTone.success,
    );
  }
}

class _SuspensionSheet extends StatefulWidget {
  const _SuspensionSheet({required this.suggested});

  final int suggested;

  @override
  State<_SuspensionSheet> createState() => _SuspensionSheetState();
}

class _SuspensionSheetState extends State<_SuspensionSheet> {
  late int _selected = widget.suggested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          AmpStrings.adminSuspendBody,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(
          AmpStrings.adminSuspendSuggested(_label(_selected)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        TextFilterRow<int>(
          options: <TextFilterOption<int>>[
            for (final int days in AmpPolicy.suspensionDays)
              TextFilterOption<int>(value: days, label: _label(days)),
          ],
          selected: _selected,
          onSelected: (int days) => setState(() => _selected = days),
        ),
        const SizedBox(height: AmpTheme.spaceL),
        AmpButton(
          label: AmpStrings.adminSuspendAction,
          onPressed: () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }

  String _label(int days) {
    return switch (days) {
      1 => AmpStrings.adminSuspend1d,
      7 => AmpStrings.adminSuspend7d,
      _ => AmpStrings.adminSuspend30d,
    };
  }
}

class _AdminLoading extends StatelessWidget {
  const _AdminLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.4, height: 12),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.8),
        SizedBox(height: 10),
        SkeletonLine(widthFactor: 0.7),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.45, height: 18),
        SizedBox(height: 12),
        SkeletonLine(widthFactor: 0.75),
        SizedBox(height: 10),
        SkeletonLine(widthFactor: 0.6),
      ],
    );
  }
}
