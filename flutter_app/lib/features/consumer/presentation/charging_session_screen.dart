import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ids.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/receipt_rows.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/reservation_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../domain/engines/billing_engine.dart';
import '../../../domain/policy.dart';
import '../application/booking_providers.dart';
import '../application/session_providers.dart';
import '../application/session_rules.dart';

/// The consumer charging session: check in, start charging, enter the ending
/// meter reading and let the server issue the receipt.
class ChargingSessionScreen extends ConsumerStatefulWidget {
  const ChargingSessionScreen({required this.reservationId, super.key});

  final String reservationId;

  @override
  ConsumerState<ChargingSessionScreen> createState() =>
      _ChargingSessionScreenState();
}

class _ChargingSessionScreenState extends ConsumerState<ChargingSessionScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final ScrollController _bodyScroll = ScrollController();

  bool _busy = false;
  bool _scrolledToCharging = false;
  String? _error;
  String? _startError;
  String? _endError;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _bodyScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<SessionData>> async = ref.watch(
      sessionDataProvider(widget.reservationId),
    );
    final SessionData? data = async.asData?.value.valueOrNull;
    final ChargingSession? session = data?.session;
    final bool canCheckIn =
        data != null &&
        session == null &&
        SessionRules.canOpen(data.reservation, data.station);
    final bool canStart = session != null && SessionRules.canStart(session);
    final bool canSettle = session != null && SessionRules.canSettle(session);
    final bool completed = session != null && SessionRules.isCompleted(session);

    return AmpScaffold(
      title: AmpStrings.sessionTitle,
      body: async.when(
        loading: () => const _SessionLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () =>
              ref.invalidate(sessionDataProvider(widget.reservationId)),
        ),
        data: (RepositoryResult<SessionData> result) {
          final RepositoryFailure<SessionData>? failure = result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () =>
                  ref.invalidate(sessionDataProvider(widget.reservationId)),
            );
          }
          return _body(context, result.valueOrNull!);
        },
      ),
      bottomBar: _bottomBar(
        data,
        canCheckIn: canCheckIn,
        canStart: canStart,
        canSettle: canSettle,
        completed: completed,
      ),
    );
  }

  Widget? _bottomBar(
    SessionData? data, {
    required bool canCheckIn,
    required bool canStart,
    required bool canSettle,
    required bool completed,
  }) {
    if (data == null) {
      return null;
    }
    if (canCheckIn) {
      return AmpButton(
        label: _busy
            ? AmpStrings.sessionCheckingIn
            : AmpStrings.sessionCheckInAction,
        loading: _busy,
        onPressed: _busy ? null : () => _checkIn(data),
      );
    }
    if (canStart) {
      return AmpButton(
        label: _busy
            ? AmpStrings.sessionStarting
            : AmpStrings.sessionStartChargingAction,
        loading: _busy,
        onPressed: _busy ? null : () => _startCharging(data),
      );
    }
    if (canSettle) {
      return AmpButton(
        label: _busy
            ? AmpStrings.sessionFinishing
            : AmpStrings.sessionFinishAction,
        loading: _busy,
        onPressed: _busy ? null : () => _finish(data),
      );
    }
    if (completed) {
      return AmpButton(
        label: AmpStrings.sessionHistoryTitle,
        onPressed: () => context.go('/sessions'),
      );
    }
    return null;
  }

  Widget _body(BuildContext context, SessionData data) {
    final TextTheme text = Theme.of(context).textTheme;
    final ChargingSession? session = data.session;
    final String stationName = _stationName(data);
    final String status = AmpFormat.bookingStatus(
      session?.status ?? data.reservation.status,
    );
    final String slot = data.reservation.startTimeMs > 0
        ? '${AmpFormat.dayLabel(DateTime.fromMillisecondsSinceEpoch(data.reservation.startTimeMs))}, '
              '${AmpFormat.timeRange(data.reservation.startTimeMs, data.reservation.endTimeMs)}'
        : AmpStrings.availabilityUnknown;
    final bool charging =
        (session?.status ?? '').toUpperCase() == AmpPolicy.statusCharging;

    // The ending-reading form sits at the bottom of a long page. Bring it into
    // view once charging starts, instead of leaving its field under the action
    // bar until the person works out that the page scrolls.
    if (charging && !_scrolledToCharging) {
      _scrolledToCharging = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_bodyScroll.hasClients) {
          return;
        }
        _bodyScroll.animateTo(
          _bodyScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      });
    } else if (!charging) {
      _scrolledToCharging = false;
    }

    return ListView(
      controller: _bodyScroll,
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl + 96,
      ),
      children: <Widget>[
        Eyebrow(slot),
        const SizedBox(height: 4),
        Text(stationName, style: text.displaySmall),
        const SizedBox(height: 6),
        StatusDotLabel(
          status.isEmpty ? AmpStrings.labelUnknown : status,
          detail: AmpFormat.meterLevel(data.station.verificationLevel),
          tone: _statusTone(session?.status ?? data.reservation.status),
        ),
        const SizedBox(height: AmpTheme.spaceM),
        _summaryCard(context, data, slot: slot),
        if (session == null)
          ..._checkInSection(context, data)
        else
          ..._sessionSection(context, data, session),
        if (_error != null) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          _Callout(message: _error!, error: true),
        ],
      ],
    );
  }

  List<Widget> _checkInSection(BuildContext context, SessionData data) {
    final TextTheme text = Theme.of(context).textTheme;
    if (!SessionRules.canOpen(data.reservation, data.station)) {
      return <Widget>[
        _SectionTitle(AmpStrings.sessionNoSessionTitle),
        _Callout(
          message: data.reservation.status == AmpPolicy.statusReserved
              ? AmpStrings.sessionNoMeter
              : AmpStrings.sessionNoSessionBody,
        ),
      ];
    }
    return <Widget>[
      _SectionTitle(AmpStrings.sessionCheckInTitle),
      Text(AmpStrings.sessionCheckInBody, style: text.bodySmall),
      const SizedBox(height: AmpTheme.spaceM),
      AmpField(
        controller: _startController,
        label: AmpStrings.sessionStartReadingLabel,
        helper: AmpStrings.sessionStartReadingHelper,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        errorText: _startError,
        onChanged: (String value) {
          if (_startError != null || _error != null) {
            setState(() {
              _startError = null;
              _error = null;
            });
          }
        },
      ),
      const SizedBox(height: AmpTheme.spaceS),
      Text(AmpStrings.sessionReadingHint, style: text.bodySmall),
    ];
  }

  List<Widget> _sessionSection(
    BuildContext context,
    SessionData data,
    ChargingSession session,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    final String status = (session.status ?? '').toUpperCase();
    final List<Widget> children = <Widget>[];

    if (status == AmpPolicy.statusCompleted) {
      children.add(_SectionTitle(AmpStrings.sessionReceiptTitle));
      children.add(_receiptCard(context, data, session));
      return children;
    }

    if (status == AmpPolicy.statusCheckedIn) {
      children.add(_SectionTitle(AmpStrings.sessionCheckedInTitle));
      children.add(
        Text(AmpStrings.sessionCheckedInBody, style: text.bodySmall),
      );
    } else if (status == AmpPolicy.statusCharging) {
      children.add(_SectionTitle(AmpStrings.sessionChargingTitle));
      children.add(Text(AmpStrings.sessionChargingBody, style: text.bodySmall));
    } else {
      children.add(_SectionTitle(AmpStrings.sessionTitle));
    }

    children.add(const SizedBox(height: AmpTheme.spaceM));
    children.add(_activeFacts(context, session));
    children.add(const SizedBox(height: AmpTheme.spaceM));

    if (status == AmpPolicy.statusCharging) {
      children.add(
        AmpField(
          controller: _endController,
          label: AmpStrings.sessionEndReadingLabel,
          helper: AmpStrings.sessionEndReadingHelper,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          errorText: _endError,
          onChanged: (String value) {
            setState(() {
              _endError = null;
              _error = null;
            });
          },
        ),
      );
      children.add(const SizedBox(height: AmpTheme.spaceS));
      children.add(Text(AmpStrings.sessionReadingHint, style: text.bodySmall));
      final Widget? preview = _previewCard(data, session);
      if (preview != null) {
        children.add(const SizedBox(height: AmpTheme.spaceM));
        children.add(preview);
      }
    }

    return children;
  }

  Widget _summaryCard(
    BuildContext context,
    SessionData data, {
    required String slot,
  }) {
    final Reservation reservation = data.reservation;
    final String portLabel = (reservation.portLabel ?? '').trim();
    final String code = (reservation.bookingCode ?? '').trim();

    return Column(
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ReceiptRows(
            lines: <ReceiptLine>[
              ReceiptLine(
                label: AmpStrings.sessionPortLabel,
                value: portLabel.isEmpty ? AmpStrings.labelUnknown : portLabel,
              ),
              ReceiptLine(label: AmpStrings.sessionSlotLabel, value: slot),
              if (code.isNotEmpty)
                ReceiptLine(label: AmpStrings.sessionCodeLabel, value: code),
            ],
          ),
        ),
        const Hairline(),
      ],
    );
  }

  Widget _activeFacts(BuildContext context, ChargingSession session) {
    final AmpColors colors = context.amp;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final bool charging =
        (session.status ?? '').toUpperCase() == AmpPolicy.statusCharging;
    final double? delivered = charging ? _deliveredKwh(session) : null;
    final String elapsed = AmpFormat.duration(
      Duration(
        minutes: SessionRules.elapsedMinutes(
          session.startTimeMs,
          session.endTimeMs,
          nowMs,
        ),
      ),
    );
    final String started = session.startTimeMs > 0
        ? AmpFormat.clock(session.startTimeMs)
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (charging)
          BigNumber(
            value: delivered == null ? '—' : delivered.toStringAsFixed(1),
            unit: delivered == null ? null : AmpStrings.kwh,
            label: delivered == null
                ? AmpStrings.sessionReadEndForEnergy
                : AmpStrings.sessionDeliveredLabel,
            size: 60,
          )
        else
          BigNumber(
            value: session.startingMeterKwh.toStringAsFixed(1),
            unit: AmpStrings.kwh,
            label: AmpStrings.sessionMeterStartLabel,
            size: 56,
          ),
        const SizedBox(height: AmpTheme.spaceM),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _Metric(
                label: AmpStrings.sessionElapsedLabel,
                value: elapsed,
              ),
            ),
            Container(width: 1, height: 36, color: colors.divider),
            const SizedBox(width: AmpTheme.spaceM),
            Expanded(
              child: _Metric(
                label: AmpStrings.sessionStartedLabel,
                value: started,
              ),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceM),
        const Hairline(),
      ],
    );
  }

  double? _deliveredKwh(ChargingSession session) {
    final String? readingError = SessionRules.endReadingError(
      _endController.text,
      session.startingMeterKwh,
    );
    if (readingError != null) {
      return null;
    }
    final double? end = SessionRules.parseReading(_endController.text);
    if (end == null) {
      return null;
    }
    final double delivered = end - session.startingMeterKwh;
    return delivered > 0 ? delivered : null;
  }

  Widget? _previewCard(SessionData data, ChargingSession session) {
    final String? readingError = SessionRules.endReadingError(
      _endController.text,
      session.startingMeterKwh,
    );
    if (readingError != null) {
      return null;
    }
    final double end = SessionRules.parseReading(_endController.text)!;
    final BillingCalculationResult preview = _calculateBill(data, session, end);
    if (!preview.valid) {
      return _Callout(
        message: preview.errorMessage ?? AmpStrings.sessionFinishFailed,
        error: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ReceiptRows(
            lines: <ReceiptLine>[
              ReceiptLine(
                label: AmpStrings.receiptVerifiedKwh,
                value: AmpFormat.kWh(preview.verifiedKwh),
              ),
              ReceiptLine(
                label: AmpStrings.receiptEnergy,
                value: AmpFormat.rupees(preview.energyCharge),
              ),
              ReceiptLine(
                label: AmpStrings.receiptServiceFee,
                value: AmpFormat.rupees(preview.serviceFee),
              ),
              ReceiptLine(
                label: AmpStrings.receiptGatewayFee,
                value: AmpFormat.rupees(preview.gatewayFee),
              ),
              ReceiptLine(
                label: AmpStrings.receiptTotal,
                value: AmpFormat.rupees(preview.finalTotal),
                emphasis: true,
              ),
            ],
          ),
        ),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceS),
        Text(
          AmpStrings.sessionReadingNote,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _receiptCard(
    BuildContext context,
    SessionData data,
    ChargingSession session,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    final Invoice? invoice = data.invoice;
    final double adjustment = invoice?.adjustment ?? 0;
    final double total = invoice?.finalTotal ?? session.totalPaid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ReceiptRows(
            lines: <ReceiptLine>[
              ReceiptLine(
                label: AmpStrings.receiptStartReading,
                value: AmpFormat.kWh(session.startingMeterKwh),
              ),
              ReceiptLine(
                label: AmpStrings.receiptEndReading,
                value: AmpFormat.kWh(session.endingMeterKwh),
              ),
              ReceiptLine(
                label: AmpStrings.receiptVerifiedKwh,
                value: AmpFormat.kWh(session.verifiedKwhConsumed),
              ),
            ],
          ),
        ),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceS),
        ReceiptRows(
          lines: <ReceiptLine>[
            ReceiptLine(
              label: AmpStrings.receiptEnergy,
              value: AmpFormat.rupees(session.energyCharge),
            ),
            ReceiptLine(
              label: AmpStrings.receiptServiceFee,
              value: AmpFormat.rupees(session.serviceFee),
            ),
            ReceiptLine(
              label: AmpStrings.receiptGatewayFee,
              value: AmpFormat.rupees(session.gatewayFee),
            ),
            if (adjustment > 0)
              ReceiptLine(
                label: AmpStrings.receiptAdjustment,
                value: '-${AmpFormat.rupees(adjustment)}',
              ),
          ],
        ),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceM),
        BigNumber(
          value: AmpFormat.rupees(total),
          label: AmpStrings.receiptTotal,
          size: 56,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        const StatusDotLabel(AmpStrings.receiptIssued),
        const SizedBox(height: 4),
        Text(AmpStrings.sessionNoPayment, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceS),
        Text(AmpStrings.sessionMeterNote, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceM),
        const Hairline(),
        const SizedBox(height: AmpTheme.spaceS),
        TextAction(
          AmpStrings.reportTitle,
          onPressed: () => context.push(
            Uri(
              path: '/report',
              queryParameters: <String, String>{
                'stationId': data.station.id,
                'hostId': data.station.hostId ?? '',
                'sessionId': session.id,
                'stationName': _stationName(data),
              },
            ).toString(),
          ),
        ),
      ],
    );
  }

  Future<void> _checkIn(SessionData data) async {
    final String? startError = SessionRules.startReadingError(
      _startController.text,
    );
    if (startError != null) {
      setState(() => _startError = startError);
      return;
    }
    final double start = SessionRules.parseReading(_startController.text)!;
    final SessionRepository? repository = ref.read(sessionRepositoryProvider);
    if (repository == null) {
      _showError(AmpStrings.sessionServerRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _startError = null;
    });

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final RepositoryResult<ChargingSession> opened = await repository.open(
      id: newId(),
      reservationId: data.reservation.id,
      consumerId: data.consumer.id,
      hostId: data.station.hostId,
      stationId: data.station.id,
      stationName: _stationName(data),
      portId: data.reservation.portId,
      startTimeMs: nowMs,
      startingMeterKwh: start,
      verificationLevel: data.station.verificationLevel,
    );
    if (!mounted) {
      return;
    }

    final RepositoryFailure<ChargingSession>? failure = opened.failureOrNull;
    if (failure != null) {
      final String message = SessionRules.serverMessage(
        failure.cause,
        fallback: AmpStrings.sessionOpenFailed,
      );
      setState(() {
        _busy = false;
        _error = message;
      });
      AmpSnackbar.show(context, message, tone: AmpSnackbarTone.error);
      return;
    }

    final ReservationRepository? reservationRepository = ref.read(
      reservationRepositoryProvider,
    );
    bool statusWarning = reservationRepository == null;
    if (reservationRepository != null) {
      final RepositoryResult<bool> patched = await reservationRepository
          .updateStatus(
            data.reservation.id,
            status: AmpPolicy.statusCheckedIn,
            checkedInAtMs: nowMs,
          );
      statusWarning = patched.failureOrNull != null;
    }
    if (!mounted) {
      return;
    }

    _startController.clear();
    setState(() {
      _busy = false;
      _startError = null;
    });
    _invalidate(data);
    AmpSnackbar.show(
      context,
      statusWarning
          ? AmpStrings.sessionStatusWarning
          : AmpStrings.sessionCheckedInToast(AmpFormat.kWh(start)),
      tone: statusWarning ? AmpSnackbarTone.info : AmpSnackbarTone.success,
    );
  }

  Future<void> _startCharging(SessionData data) async {
    final ChargingSession? session = data.session;
    if (session == null) {
      return;
    }
    final SessionRepository? repository = ref.read(sessionRepositoryProvider);
    if (repository == null) {
      _showError(AmpStrings.sessionServerRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final RepositoryResult<bool> updated = await repository.setStatus(
      sessionId: session.id,
      status: AmpPolicy.statusCharging,
    );
    if (!mounted) {
      return;
    }
    final RepositoryFailure<bool>? failure = updated.failureOrNull;
    if (failure != null) {
      final String message = SessionRules.serverMessage(
        failure.cause,
        fallback: AmpStrings.sessionStartFailed,
      );
      setState(() {
        _busy = false;
        _error = message;
      });
      AmpSnackbar.show(context, message, tone: AmpSnackbarTone.error);
      return;
    }

    final ReservationRepository? reservationRepository = ref.read(
      reservationRepositoryProvider,
    );
    bool statusWarning = reservationRepository == null;
    if (reservationRepository != null) {
      final RepositoryResult<bool> patched = await reservationRepository
          .updateStatus(data.reservation.id, status: AmpPolicy.statusCharging);
      statusWarning = patched.failureOrNull != null;
    }
    if (!mounted) {
      return;
    }

    setState(() => _busy = false);
    _invalidate(data);
    AmpSnackbar.show(
      context,
      statusWarning
          ? AmpStrings.sessionStatusWarning
          : AmpStrings.sessionChargingStarted,
      tone: statusWarning ? AmpSnackbarTone.info : AmpSnackbarTone.success,
    );
  }

  Future<void> _finish(SessionData data) async {
    final ChargingSession? session = data.session;
    if (session == null) {
      return;
    }
    final String? endError = SessionRules.endReadingError(
      _endController.text,
      session.startingMeterKwh,
    );
    if (endError != null) {
      setState(() => _endError = endError);
      return;
    }
    final double end = SessionRules.parseReading(_endController.text)!;
    final BillingCalculationResult billing = _calculateBill(data, session, end);
    final Invoice? invoice = billing.invoice;
    if (!billing.valid || invoice == null) {
      _showError(billing.errorMessage ?? AmpStrings.sessionFinishFailed);
      return;
    }

    final SessionRepository? repository = ref.read(sessionRepositoryProvider);
    if (repository == null) {
      _showError(AmpStrings.sessionServerRequired);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _endError = null;
    });
    final RepositoryResult<String> settled = await repository.finalize(
      sessionId: session.id,
      reservationId: data.reservation.id,
      startMeterKwh: session.startingMeterKwh,
      endMeterKwh: end,
      isSimulated: false,
      meterReadingId: newId(),
      invoiceId: invoice.id,
    );
    if (!mounted) {
      return;
    }

    final RepositoryFailure<String>? failure = settled.failureOrNull;
    if (failure != null) {
      final String message = SessionRules.serverMessage(
        failure.cause,
        fallback: AmpStrings.sessionFinishFailed,
      );
      setState(() {
        _busy = false;
        _error = message;
      });
      AmpSnackbar.show(context, message, tone: AmpSnackbarTone.error);
      return;
    }

    _endController.clear();
    setState(() {
      _busy = false;
      _endError = null;
    });
    _invalidate(data);
    AmpSnackbar.show(
      context,
      AmpStrings.sessionSettled,
      tone: AmpSnackbarTone.success,
    );
  }

  BillingCalculationResult _calculateBill(
    SessionData data,
    ChargingSession session,
    double end,
  ) {
    return BillingEngine.calculateBill(
      sessionId: session.id,
      consumerId: data.consumer.id,
      hostId: data.station.hostId ?? '',
      stationName: _stationName(data),
      station: data.station,
      meterLevel: data.station.verificationLevel,
      simulated: false,
      startMeterKwh: session.startingMeterKwh,
      endMeterKwh: end,
    );
  }

  String _stationName(SessionData data) {
    final String reservationName = (data.reservation.stationName ?? '').trim();
    if (reservationName.isNotEmpty) {
      return reservationName;
    }
    final String stationName = (data.station.name ?? '').trim();
    return stationName.isEmpty ? AmpStrings.unnamedCharger : stationName;
  }

  void _invalidate(SessionData data) {
    ref.invalidate(sessionDataProvider(widget.reservationId));
    ref.invalidate(consumerSessionsProvider);
    ref.invalidate(consumerReservationsProvider);
    if (data.station.id.isNotEmpty) {
      ref.invalidate(bookingDataProvider(data.station.id));
    }
  }

  void _showError(String message) {
    setState(() => _error = message);
    AmpSnackbar.show(context, message, tone: AmpSnackbarTone.error);
  }
}

StatusDotTone _statusTone(String? status) {
  return switch ((status ?? '').toUpperCase()) {
    AmpPolicy.statusCompleted ||
    AmpPolicy.statusCharging => StatusDotTone.available,
    AmpPolicy.statusCheckedIn => StatusDotTone.neutral,
    AmpPolicy.statusCancelled || AmpPolicy.statusExpired => StatusDotTone.busy,
    _ => StatusDotTone.neutral,
  };
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Eyebrow(label),
        const SizedBox(height: 3),
        Text(
          value,
          style: AmpType.tabular(
            Theme.of(context).textTheme.titleMedium ?? const TextStyle(),
          ),
        ),
      ],
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color background = error ? colors.errorTint : colors.busyTint;
    final Color foreground = error ? colors.error : colors.busyInk;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AmpTheme.radiusField),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmpIcon(AmpIconName.alert, size: 18, color: foreground),
          const SizedBox(width: AmpTheme.spaceS),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AmpTheme.spaceL,
        bottom: AmpTheme.spaceS,
      ),
      child: Eyebrow(label),
    );
  }
}

class _SessionLoading extends StatelessWidget {
  const _SessionLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.28, height: 9),
        SizedBox(height: AmpTheme.spaceS),
        SkeletonLine(widthFactor: 0.68, height: 30),
        SizedBox(height: AmpTheme.spaceS),
        SkeletonLine(widthFactor: 0.42),
        SizedBox(height: AmpTheme.spaceM),
        Hairline(),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.5, height: 44),
        SizedBox(height: AmpTheme.spaceM),
        Row(
          children: <Widget>[
            Expanded(child: SkeletonLine(widthFactor: 0.55)),
            SizedBox(width: AmpTheme.spaceM),
            Expanded(child: SkeletonLine(widthFactor: 0.55)),
          ],
        ),
        SizedBox(height: AmpTheme.spaceM),
        Hairline(),
      ],
    );
  }
}
