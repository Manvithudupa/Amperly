import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_sheet.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/departure_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/receipt_rows.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/host_repository.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/engines/host_analytics_engine.dart';
import '../../../domain/engines/reservation_engine.dart';
import '../../../domain/policy.dart';
import '../../auth/application/profile_providers.dart';
import '../application/host_providers.dart';

enum HostWorkspaceSection { dashboard, stations, bookings }

/// The host's three daily surfaces: performance, charger management and the
/// bookings drivers made against those chargers.
class HostWorkspaceScreen extends ConsumerStatefulWidget {
  const HostWorkspaceScreen({super.key, this.section});

  /// When set, the shell owns the destination and the local filter is hidden.
  final HostWorkspaceSection? section;

  @override
  ConsumerState<HostWorkspaceScreen> createState() =>
      _HostWorkspaceScreenState();
}

class _HostWorkspaceScreenState extends ConsumerState<HostWorkspaceScreen> {
  late HostWorkspaceSection _section =
      widget.section ?? HostWorkspaceSection.dashboard;

  @override
  void didUpdateWidget(HostWorkspaceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section != null && widget.section != oldWidget.section) {
      _section = widget.section!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<HostWorkspaceData>> async = ref.watch(
      hostWorkspaceProvider,
    );
    final HostWorkspaceData? data = async.asData?.value.valueOrNull;

    return AmpScaffold(
      title: AmpStrings.hostTitle,
      subtitle: data == null ? AmpStrings.hostSubtitle : null,
      body: async.when(
        loading: () => const _HostLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(hostWorkspaceProvider),
        ),
        data: (RepositoryResult<HostWorkspaceData> result) {
          final RepositoryFailure<HostWorkspaceData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(hostWorkspaceProvider),
            );
          }
          return _body(result.valueOrNull!);
        },
      ),
      bottomBar: _section == HostWorkspaceSection.stations
          ? AmpButton(
              label: AmpStrings.hostAddStation,
              onPressed: () => context.push('/host/stations/new'),
            )
          : null,
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(hostWorkspaceProvider);
    await ref.read(hostWorkspaceProvider.future);
  }

  Widget _body(HostWorkspaceData data) {
    return Column(
      children: <Widget>[
        if (widget.section == null) ...<Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AmpTheme.screenPadding,
              AmpTheme.spaceS,
              AmpTheme.screenPadding,
              0,
            ),
            child: TextFilterRow<HostWorkspaceSection>(
              options: const <TextFilterOption<HostWorkspaceSection>>[
                TextFilterOption<HostWorkspaceSection>(
                  value: HostWorkspaceSection.dashboard,
                  label: AmpStrings.hostTabDashboard,
                ),
                TextFilterOption<HostWorkspaceSection>(
                  value: HostWorkspaceSection.stations,
                  label: AmpStrings.hostTabStations,
                ),
                TextFilterOption<HostWorkspaceSection>(
                  value: HostWorkspaceSection.bookings,
                  label: AmpStrings.hostTabBookings,
                ),
              ],
              selected: _section,
              onSelected: (HostWorkspaceSection section) =>
                  setState(() => _section = section),
            ),
          ),
          const Hairline(),
        ],
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: switch (_section) {
              HostWorkspaceSection.dashboard => _Dashboard(data: data),
              HostWorkspaceSection.stations => _Stations(data: data),
              HostWorkspaceSection.bookings => _Bookings(data: data),
            },
          ),
        ),
      ],
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.data});

  final HostWorkspaceData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final HostAnalytics analytics = data.analytics;
    final TextTheme text = Theme.of(context).textTheme;
    final String hostName =
        (ref.watch(currentProfileProvider).asData?.value.valueOrNull?.name ??
                '')
            .trim();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        if (hostName.isNotEmpty) ...<Widget>[
          Eyebrow(AmpStrings.hostGreeting),
          const SizedBox(height: 2),
          Text(hostName, style: text.titleMedium),
          const SizedBox(height: AmpTheme.spaceM),
        ],
        BigNumber(
          value: AmpFormat.rupees(analytics.revenue),
          label: AmpStrings.hostIncomeLabel,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        Row(
          children: <Widget>[
            Expanded(
              child: _Stat(
                label: AmpStrings.hostDisputesLabel,
                value: analytics.disputes.toString(),
              ),
            ),
            Expanded(
              child: _Stat(
                label: AmpStrings.hostReservationsLabel,
                value: analytics.reservations.toString(),
              ),
            ),
            Expanded(
              child: _Stat(
                label: AmpStrings.hostUtilizationLabel,
                value: AmpFormat.percent(analytics.utilizationPercent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.hostAnalyticsTitle),
        const SizedBox(height: AmpTheme.spaceS),
        ReceiptRows(
          lines: <ReceiptLine>[
            ReceiptLine(
              label: AmpStrings.hostSessionCount,
              value: analytics.sessionsCompleted.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.hostEnergyDelivered,
              value: AmpFormat.kWh(analytics.energyDeliveredKwh),
            ),
            ReceiptLine(
              label: AmpStrings.hostRepeatConsumers,
              value: analytics.repeatConsumers.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.hostCancellationRate,
              value: AmpFormat.percent(analytics.cancellationRatePercent),
            ),
            ReceiptLine(
              label: AmpStrings.hostAverageSession,
              value: AmpFormat.kWh(analytics.averageSessionKwh),
            ),
            ReceiptLine(
              label: AmpStrings.hostRefunds,
              value: AmpFormat.rupees(analytics.refundsAndAdjustments),
            ),
            ReceiptLine(
              label: AmpStrings.hostActiveReservations,
              value: analytics.activeReservations.toString(),
            ),
            ReceiptLine(
              label: AmpStrings.hostPortsReported,
              value: analytics.ports.toString(),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(AmpStrings.hostUtilizationNote, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceL),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceL),
        const Eyebrow(AmpStrings.hostSessionsTitle),
        const SizedBox(height: AmpTheme.spaceS),
        if (data.sessions.isEmpty)
          Text(AmpStrings.hostNoSessions, style: text.bodySmall)
        else
          for (final ChargingSession session in data.sessions.take(20))
            _SessionRow(session: session),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(value, style: AmpType.metric(context, size: 27)),
        const SizedBox(height: 2),
        Eyebrow(label),
      ],
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session});

  final ChargingSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime start = DateTime.fromMillisecondsSinceEpoch(
      session.startTimeMs,
    );
    final bool hasDate = session.startTimeMs > 0;
    final String station = (session.stationName ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : session.stationName!.trim();
    final String detail = session.startTimeMs > 0
        ? '${AmpFormat.dayLabel(start)} · ${AmpFormat.clock(session.startTimeMs)}'
        : AmpStrings.availabilityUnknown;

    return DepartureRow(
      metric: hasDate ? AmpFormat.dayNumber(start) : '—',
      metricUnit: hasDate ? AmpFormat.monthShort(start) : '',
      title: station,
      detail: detail,
      statusLabel: AmpFormat.bookingStatus(session.status),
      statusTone: _sessionTone(session.status),
      price: session.totalPaid > 0 ? AmpFormat.rupees(session.totalPaid) : null,
      priceUnit: AmpStrings.hostIncomeLabel,
      onTap: () => _showSession(context, ref),
    );
  }

  Future<void> _showSession(BuildContext context, WidgetRef ref) async {
    final String station = (session.stationName ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : session.stationName!.trim();
    await showAmpSheet<void>(
      context: context,
      title: station,
      builder: (BuildContext sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StatusDotLabel(
              AmpFormat.bookingStatus(session.status),
              tone: _sessionTone(session.status),
            ),
            const SizedBox(height: AmpTheme.spaceM),
            ReceiptRows(
              lines: <ReceiptLine>[
                ReceiptLine(
                  label: AmpStrings.sessionStartedLabel,
                  value: session.startTimeMs > 0
                      ? AmpFormat.clock(session.startTimeMs)
                      : AmpStrings.availabilityUnknown,
                ),
                ReceiptLine(
                  label: AmpStrings.receiptVerifiedKwh,
                  value: AmpFormat.kWh(session.verifiedKwhConsumed),
                ),
                ReceiptLine(
                  label: AmpStrings.receiptTotal,
                  value: AmpFormat.rupees(session.totalPaid),
                  emphasis: true,
                ),
              ],
            ),
            const SizedBox(height: AmpTheme.spaceM),
            if ((session.reservationId ?? '').isNotEmpty)
              AmpButton(
                label: AmpStrings.sessionViewReceipt,
                variant: AmpButtonVariant.tonal,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/sessions/${session.reservationId}');
                },
              ),
            if ((session.reservationId ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: AmpTheme.spaceS),
              TextAction(
                AmpStrings.hostReportDriver,
                tone: TextActionTone.danger,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  final String stationId = (session.stationId ?? '').trim();
                  context.push(
                    Uri(
                      path: '/report',
                      queryParameters: <String, String>{
                        'sessionId': session.id,
                        'stationId': stationId,
                        'host': '1',
                      },
                    ).toString(),
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Stations extends ConsumerWidget {
  const _Stations({required this.data});

  final HostWorkspaceData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.stations.isEmpty) {
      return EmptyState(
        title: AmpStrings.hostNoStationsTitle,
        message: AmpStrings.hostNoStationsBody,
        action: AmpButton(
          label: AmpStrings.hostAddStation,
          onPressed: () => context.push('/host/stations/new'),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceXxl),
      children: <Widget>[
        const SizedBox(height: AmpTheme.spaceS),
        for (final HostStationEntry entry in data.stations)
          _StationCard(entry: entry),
      ],
    );
  }
}

class _StationCard extends ConsumerWidget {
  const _StationCard({required this.entry});

  final HostStationEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ChargerStation station = entry.station;
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final String address = (station.address ?? '').trim().isEmpty
        ? AmpStrings.addressNotPublished
        : station.address!.trim();
    final String status = station.isPaused
        ? AmpStrings.hostStationPaused
        : AmpFormat.approvalStatus(station.approvalStatus);
    final StatusDotTone tone = station.isPaused
        ? StatusDotTone.busy
        : (station.approvalStatus ?? '').toUpperCase() ==
              AmpPolicy.approvalApproved
        ? StatusDotTone.available
        : (station.approvalStatus ?? '').toUpperCase() ==
              AmpPolicy.approvalRejected
        ? StatusDotTone.error
        : StatusDotTone.neutral;
    final String connectors = station.connectorTypeList
        .map(AmpFormat.connectorLabel)
        .where((String value) => value.isNotEmpty)
        .join(' · ');
    final String meta = <String>[
      '${entry.portCount} ${entry.portCount == 1 ? AmpStrings.hostPortSingular : AmpStrings.hostPortPlural}',
      if (connectors.isNotEmpty) connectors,
      if (station.maxPowerKw > 0) '${station.maxPowerKw.toInt()} kW',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AmpTheme.screenPadding,
            AmpTheme.spaceM,
            AmpTheme.screenPadding,
            AmpTheme.spaceS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Text(name, style: text.titleMedium)),
                  const SizedBox(width: AmpTheme.spaceS),
                  StatusDotLabel(
                    status.isEmpty ? AmpStrings.labelUnknown : status,
                    tone: tone,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(address, style: text.bodySmall),
              const SizedBox(height: 2),
              Text(meta, style: text.bodySmall),
              const SizedBox(height: 2),
              Text(
                AmpFormat.meterLevel(station.verificationLevel),
                style: text.bodySmall,
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Wrap(
                spacing: AmpTheme.spaceM,
                runSpacing: 0,
                children: <Widget>[
                  TextAction(
                    station.isPaused
                        ? AmpStrings.hostStationReopen
                        : AmpStrings.hostStationPause,
                    onPressed: () => _togglePause(context, ref, station),
                  ),
                  TextAction(
                    AmpStrings.hostMeterEvidence,
                    onPressed: () => _recordEvidence(context, ref, station),
                  ),
                  TextAction(
                    AmpStrings.hostDeleteStation,
                    tone: TextActionTone.danger,
                    onPressed: () => _deleteStation(context, ref, station),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Hairline(),
      ],
    );
  }

  Future<void> _togglePause(
    BuildContext context,
    WidgetRef ref,
    ChargerStation station,
  ) async {
    final HostRepository? repository = ref.read(hostRepositoryProvider);
    if (repository == null) {
      return;
    }
    final bool paused = !station.isPaused;
    final RepositoryResult<bool> result = await repository.setPaused(
      station,
      paused: paused,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<bool>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(
        context,
        AmpStrings.hostStationPauseFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    ref.invalidate(hostWorkspaceProvider);
    AmpSnackbar.show(
      context,
      paused
          ? AmpStrings.hostStationPausedToast
          : AmpStrings.hostStationReopenedToast,
      tone: AmpSnackbarTone.success,
    );
  }

  Future<void> _recordEvidence(
    BuildContext context,
    WidgetRef ref,
    ChargerStation station,
  ) async {
    final _MeterInput? input = await showAmpSheet<_MeterInput>(
      context: context,
      title: AmpStrings.hostMeterEvidenceTitle,
      builder: (BuildContext sheetContext) =>
          _MeterEvidenceForm(station: station),
    );
    if (input == null) {
      return;
    }
    final HostRepository? repository = ref.read(hostRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<bool> result = await repository.recordMeterEvidence(
      station: station,
      startKwh: input.start,
      endKwh: input.end,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<bool>? failure = result.failureOrNull;
    AmpSnackbar.show(
      context,
      failure?.message ?? AmpStrings.hostMeterSaved,
      tone: failure == null ? AmpSnackbarTone.success : AmpSnackbarTone.error,
    );
  }

  Future<void> _deleteStation(
    BuildContext context,
    WidgetRef ref,
    ChargerStation station,
  ) async {
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final bool confirmed = await showAmpConfirmDialog(
      context,
      title: AmpStrings.hostDeleteStationTitle,
      message: AmpStrings.hostDeleteStationBody(name),
      confirmLabel: AmpStrings.delete,
    );
    if (!confirmed) {
      return;
    }
    final HostRepository? repository = ref.read(hostRepositoryProvider);
    if (repository == null) {
      return;
    }
    final RepositoryResult<bool> result = await repository.deleteStation(
      station,
    );
    if (!context.mounted) {
      return;
    }
    final RepositoryFailure<bool>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }
    ref.invalidate(hostWorkspaceProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.hostDeleteStationDone(name),
      tone: AmpSnackbarTone.success,
    );
  }
}

class _Bookings extends ConsumerWidget {
  const _Bookings({required this.data});

  final HostWorkspaceData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.reservations.isEmpty) {
      return EmptyState(
        title: AmpStrings.hostNoBookings,
        message: AmpStrings.hostNoBookingsBody,
        action: TextAction(
          AmpStrings.retry,
          onPressed: () => ref.invalidate(hostWorkspaceProvider),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceXxl),
      children: <Widget>[
        const SizedBox(height: AmpTheme.spaceS),
        for (final Reservation reservation in data.reservations)
          _BookingRow(reservation: reservation),
      ],
    );
  }
}

class _BookingRow extends ConsumerWidget {
  const _BookingRow({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime start = DateTime.fromMillisecondsSinceEpoch(
      reservation.startTimeMs,
    );
    final bool hasDate = reservation.startTimeMs > 0;
    final String station = (reservation.stationName ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : reservation.stationName!.trim();
    final String port = (reservation.portLabel ?? '').trim();
    final String slot = hasDate
        ? '${AmpFormat.dayLabel(start)} · ${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
        : AmpStrings.availabilityUnknown;

    return DepartureRow(
      metric: hasDate ? AmpFormat.dayNumber(start) : '—',
      metricUnit: hasDate ? AmpFormat.monthShort(start) : '',
      title: station,
      detail: <String>[if (port.isNotEmpty) port, slot].join(' · '),
      statusLabel: AmpFormat.bookingStatus(reservation.status),
      statusTone: _bookingTone(reservation.status),
      price: reservation.pricePerKwh > 0
          ? AmpFormat.rupees(reservation.pricePerKwh)
          : null,
      onTap: () => _showBooking(context, ref),
    );
  }

  Future<void> _showBooking(BuildContext context, WidgetRef ref) async {
    final String code = (reservation.bookingCode ?? '').trim();
    final String station = (reservation.stationName ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : reservation.stationName!.trim();
    await showAmpSheet<void>(
      context: context,
      title: AmpStrings.hostBookingCodeTitle,
      builder: (BuildContext sheetContext) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(station, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              reservation.startTimeMs > 0
                  ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(reservation.startTimeMs))}, '
                        '${AmpFormat.timeRange(reservation.startTimeMs, reservation.endTimeMs)}'
                  : AmpStrings.availabilityUnknown,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AmpTheme.spaceM),
            if (code.isEmpty)
              Text(
                AmpStrings.hostBookingCodeMissing,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else ...<Widget>[
              Center(
                child: Container(
                  width: 190,
                  height: 190,
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: QrImageView(
                    data: ReservationEngine.bookingQrPayload(reservation),
                    size: 166,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: AmpTheme.spaceM),
              Center(
                child: Text(
                  code,
                  style: AmpType.metric(
                    context,
                    size: 32,
                  ).copyWith(letterSpacing: 1.2),
                ),
              ),
            ],
            const SizedBox(height: AmpTheme.spaceL),
            if ((reservation.consumerId ?? '').isNotEmpty)
              AmpButton(
                label: AmpStrings.hostBookingMessageDriver,
                variant: AmpButtonVariant.tonal,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_messageDriver(context, ref));
                },
              ),
            if (reservation.isActive) ...<Widget>[
              const SizedBox(height: AmpTheme.spaceS),
              TextAction(
                AmpStrings.hostReportDriver,
                tone: TextActionTone.danger,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.push(
                    Uri(
                      path: '/report',
                      queryParameters: <String, String>{
                        'sessionId': '',
                        'stationId': reservation.stationId ?? '',
                        'host': '1',
                        'reservationId': reservation.id,
                      },
                    ).toString(),
                  );
                },
              ),
            ],
            if ((reservation.status ?? '').toUpperCase() ==
                AmpPolicy.statusCompleted) ...<Widget>[
              const SizedBox(height: AmpTheme.spaceS),
              TextAction(
                AmpStrings.hostBookingRequestReceipt,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/sessions/${reservation.id}');
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _messageDriver(BuildContext context, WidgetRef ref) async {
    final String consumerId = (reservation.consumerId ?? '').trim();
    if (consumerId.isEmpty) {
      AmpSnackbar.show(
        context,
        AmpStrings.hostChatUnavailable,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    final RepositoryResult<AppUser> profile = await ref.read(
      currentProfileProvider.future,
    );
    final AppUser? host = profile.valueOrNull;
    final repository = ref.read(chatRepositoryProvider);
    if (host == null || repository == null) {
      if (context.mounted) {
        AmpSnackbar.show(
          context,
          AmpStrings.hostChatOpeningFailed,
          tone: AmpSnackbarTone.error,
        );
      }
      return;
    }
    final RepositoryResult<CommunicationThread> result = await repository
        .ensureHostThread(host: host, reservation: reservation);
    if (!context.mounted) {
      return;
    }
    final CommunicationThread? thread = result.valueOrNull;
    if (thread == null) {
      AmpSnackbar.show(
        context,
        AmpStrings.hostChatOpeningFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }
    await context.push<void>('/messages/${thread.id}');
  }
}

class _MeterInput {
  const _MeterInput({required this.start, required this.end});

  final double start;
  final double end;
}

class _MeterEvidenceForm extends StatefulWidget {
  const _MeterEvidenceForm({required this.station});

  final ChargerStation station;

  @override
  State<_MeterEvidenceForm> createState() => _MeterEvidenceFormState();
}

class _MeterEvidenceFormState extends State<_MeterEvidenceForm> {
  final TextEditingController _start = TextEditingController();
  final TextEditingController _end = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    super.dispose();
  }

  void _save() {
    final double? start = double.tryParse(_start.text.trim());
    final double? end = double.tryParse(_end.text.trim());
    if (start == null || end == null || start < 0 || end < start) {
      setState(() => _error = AmpStrings.sessionInvalidReading);
      return;
    }
    Navigator.of(context).pop(_MeterInput(start: start, end: end));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          AmpStrings.hostMeterEvidenceBody,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        Text(
          (widget.station.name ?? '').trim().isEmpty
              ? AmpStrings.unnamedCharger
              : widget.station.name!.trim(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        AmpField(
          controller: _start,
          label: AmpStrings.hostMeterStart,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceM),
        AmpField(
          controller: _end,
          label: AmpStrings.hostMeterEnd,
          errorText: _error,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceL),
        Row(
          children: <Widget>[
            Expanded(
              child: AmpButton(
                label: AmpStrings.cancel,
                variant: AmpButtonVariant.quiet,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AmpTheme.spaceS),
            Expanded(
              child: AmpButton(
                label: AmpStrings.hostMeterSave,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

StatusDotTone _sessionTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    AmpPolicy.statusCompleted ||
    AmpPolicy.statusCharging => StatusDotTone.available,
    AmpPolicy.statusDisputed || AmpPolicy.statusRefunded => StatusDotTone.busy,
    _ => StatusDotTone.neutral,
  };
}

StatusDotTone _bookingTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    AmpPolicy.statusReserved => StatusDotTone.neutral,
    AmpPolicy.statusCheckedIn ||
    AmpPolicy.statusCharging => StatusDotTone.available,
    AmpPolicy.statusCompleted => StatusDotTone.available,
    AmpPolicy.statusCancelled || AmpPolicy.statusExpired => StatusDotTone.busy,
    _ => StatusDotTone.neutral,
  };
}

class _HostLoading extends StatelessWidget {
  const _HostLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.55, height: 40),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.4),
        SizedBox(height: AmpTheme.spaceL),
        Row(
          children: <Widget>[
            Expanded(child: SkeletonLine(widthFactor: 0.6, height: 28)),
            Expanded(child: SkeletonLine(widthFactor: 0.6, height: 28)),
            Expanded(child: SkeletonLine(widthFactor: 0.6, height: 28)),
          ],
        ),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.7),
        SizedBox(height: 10),
        SkeletonLine(widthFactor: 0.8),
        SizedBox(height: 10),
        SkeletonLine(widthFactor: 0.5),
      ],
    );
  }
}
