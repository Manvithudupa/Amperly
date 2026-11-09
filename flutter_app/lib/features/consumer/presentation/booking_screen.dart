import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ids.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/receipt_rows.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/reservation_repository.dart';
import '../../../domain/engines/availability_engine.dart';
import '../../../domain/engines/reservation_engine.dart';
import '../application/booking_providers.dart';
import '../application/booking_rules.dart';
import '../application/vehicle_providers.dart';

/// Port, day and slot selection for a real server booking.
///
/// The screen offers only published, unlocked ports and free slots. The
/// `create_reservation` RPC still re-checks the slot under a lock; its refusal
/// is shown in plain language and the availability is reloaded.
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({required this.stationId, super.key});

  final String stationId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  late final List<int> _dayStarts;
  String? _selectedPortId;
  int _selectedDayIndex = 0;
  int? _selectedSlotStartMs;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dayStarts = BookingRules.dayStarts(DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<StationBookingData>> async = ref.watch(
      bookingDataProvider(widget.stationId),
    );
    final StationBookingData? data = async.asData?.value.valueOrNull;
    final Vehicle? vehicle = ref
        .watch(activeVehicleProvider)
        .asData
        ?.value
        .valueOrNull;
    final int nowMs = DateTime.now().millisecondsSinceEpoch;

    List<ChargerPort> ports = const <ChargerPort>[];
    ChargerPort? selectedPort;
    List<Slot> slots = const <Slot>[];
    Slot? selectedSlot;
    bool hasSchedule = false;
    if (data != null) {
      ports = BookingRules.availablePorts(data.entry.ports, vehicle);
      selectedPort = _pickPort(ports);
      if (selectedPort != null) {
        slots = BookingRules.slotsFor(
          station: data.entry.station,
          port: selectedPort,
          schedules: data.schedules,
          reservations: data.reservations,
          dayStartMs: _dayStarts[_selectedDayIndex],
          nowMs: nowMs,
        );
        selectedSlot = _pickSlot(slots);
        hasSchedule = BookingRules.hasScheduleForPort(
          data.schedules,
          selectedPort.id,
        );
      }
    }

    final bool bookable =
        data != null && BookingRules.isBookable(data.entry.station);
    final bool canReserve =
        bookable &&
        selectedPort != null &&
        selectedSlot != null &&
        !_submitting;
    final StationBookingData? actionData = data;
    final ChargerPort? actionPort = selectedPort;
    final Slot? actionSlot = selectedSlot;

    return AmpScaffold(
      title: AmpStrings.bookingTitle,
      subtitle: AmpStrings.bookingSubtitle,
      body: async.when(
        loading: () => const _BookingLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(bookingDataProvider(widget.stationId)),
        ),
        data: (RepositoryResult<StationBookingData> result) {
          final RepositoryFailure<StationBookingData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () =>
                  ref.invalidate(bookingDataProvider(widget.stationId)),
            );
          }
          return _body(
            context,
            data: result.valueOrNull!,
            vehicle: vehicle,
            ports: ports,
            port: selectedPort,
            slots: slots,
            slot: selectedSlot,
            hasSchedule: hasSchedule,
            bookable: bookable,
          );
        },
      ),
      bottomBar: bookable
          ? AmpButton(
              label: _submitting
                  ? AmpStrings.bookingReserving
                  : AmpStrings.bookingReserveAction,
              icon: AmpIconName.ticket,
              loading: _submitting,
              onPressed:
                  canReserve &&
                      actionData != null &&
                      actionPort != null &&
                      actionSlot != null
                  ? () => _reserve(actionData, vehicle, actionPort, actionSlot)
                  : null,
            )
          : null,
    );
  }

  ChargerPort? _pickPort(List<ChargerPort> ports) {
    final String? selectedId = _selectedPortId;
    if (selectedId != null) {
      for (final ChargerPort port in ports) {
        if (port.id == selectedId) {
          return port;
        }
      }
    }
    return ports.isEmpty ? null : ports.first;
  }

  Slot? _pickSlot(List<Slot> slots) {
    final int? selectedStart = _selectedSlotStartMs;
    if (selectedStart != null) {
      for (final Slot slot in slots) {
        if (slot.startMs == selectedStart) {
          return slot;
        }
      }
    }
    return slots.isEmpty ? null : slots.first;
  }

  Widget _body(
    BuildContext context, {
    required StationBookingData data,
    required Vehicle? vehicle,
    required List<ChargerPort> ports,
    required ChargerPort? port,
    required List<Slot> slots,
    required Slot? slot,
    required bool hasSchedule,
    required bool bookable,
  }) {
    final ChargerStation station = data.entry.station;
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final String address = (station.address ?? '').trim().isEmpty
        ? AmpStrings.addressNotPublished
        : station.address!.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceS,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        Text(name, style: text.displayMedium),
        const SizedBox(height: 4),
        Text(address, style: text.bodySmall),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: <Widget>[
            if (station.isDcCapable) const Eyebrow(AmpStrings.filterDc),
            Eyebrow(AmpFormat.meterLevel(station.verificationLevel)),
          ],
        ),
        const SizedBox(height: 18),
        const Hairline(),
        const _SectionHeading(AmpStrings.bookingVehicleLabel, rule: false),
        Text(
          vehicle == null ? AmpStrings.bookingNoVehicle : vehicle.displayName,
          style: text.titleMedium,
        ),
        const SizedBox(height: 2),
        TextAction(
          AmpStrings.tripManageVehicles,
          onPressed: () => context.push('/vehicles'),
        ),
        if (!bookable) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          const _PaperNotice(message: AmpStrings.detailsMeterGating),
        ] else ...<Widget>[
          const _SectionHeading(AmpStrings.bookingPortLabel),
          if (ports.isEmpty)
            Text(
              vehicle == null
                  ? AmpStrings.bookingNoPorts
                  : AmpStrings.bookingNoCompatiblePorts,
              style: text.bodySmall,
            )
          else
            TextFilterRow<String>(
              selected: port?.id,
              onSelected: _selectPort,
              options: <TextFilterOption<String>>[
                for (final ChargerPort option in ports)
                  TextFilterOption<String>(
                    value: option.id,
                    label: BookingRules.portLabel(option),
                  ),
              ],
            ),
          const _SectionHeading(AmpStrings.bookingDayLabel),
          TextFilterRow<int>(
            selected: _selectedDayIndex,
            onSelected: _selectDay,
            options: <TextFilterOption<int>>[
              for (int index = 0; index < _dayStarts.length; index++)
                TextFilterOption<int>(
                  value: index,
                  label: AmpFormat.dayLabel(
                    DateTime.fromMillisecondsSinceEpoch(_dayStarts[index]),
                  ),
                ),
            ],
          ),
          const _SectionHeading(AmpStrings.bookingSlotLabel),
          if (port == null)
            Text(AmpStrings.bookingNoPorts, style: text.bodySmall)
          else if (!hasSchedule)
            Text(AmpStrings.bookingNoSchedules, style: text.bodySmall)
          else if (slots.isEmpty)
            Text(AmpStrings.bookingNoSlots, style: text.bodySmall)
          else
            TextFilterRow<int>(
              selected: slot?.startMs,
              onSelected: _selectSlot,
              options: <TextFilterOption<int>>[
                for (final Slot option in slots)
                  TextFilterOption<int>(
                    value: option.startMs,
                    label: AmpFormat.timeRange(option.startMs, option.endMs),
                  ),
              ],
            ),
          const _SectionHeading(AmpStrings.bookingPriceTitle),
          if (port != null) _priceBody(context, station, port),
          const _SectionHeading(AmpStrings.bookingPolicyTitle),
          Text(ReservationEngine.cancellationPolicy, style: text.bodySmall),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceM),
            _PaperNotice(message: _error!, error: true),
          ],
        ],
      ],
    );
  }

  Widget _priceBody(
    BuildContext context,
    ChargerStation station,
    ChargerPort port,
  ) {
    final PricePreview preview = BookingRules.previewFor(station, port);
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BigNumber(
          value: AmpFormat.rupees(preview.estimatedTotal),
          label: AmpStrings.bookingTotal,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        ReceiptRows(
          lines: <ReceiptLine>[
            ReceiptLine(
              label: AmpStrings.bookingEnergyEstimate,
              value: AmpFormat.kWh(preview.estimatedKwh),
            ),
            ReceiptLine(
              label: AmpStrings.bookingEnergyCharge,
              value: AmpStrings.bookingEnergyChargeValue(
                AmpFormat.rupees(preview.energyCharge),
                AmpFormat.rupees(station.pricePerKwh),
              ),
            ),
            ReceiptLine(
              label: AmpStrings.bookingServiceFee,
              value: AmpFormat.rupees(preview.serviceFee),
            ),
            ReceiptLine(
              label: AmpStrings.bookingGatewayFee,
              value: AmpFormat.rupees(preview.gatewayFee),
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceS),
        Text(AmpStrings.bookingPriceNote, style: text.bodySmall),
      ],
    );
  }

  void _selectPort(String portId) {
    setState(() {
      _selectedPortId = portId;
      _selectedSlotStartMs = null;
      _error = null;
    });
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
      _selectedSlotStartMs = null;
      _error = null;
    });
  }

  void _selectSlot(int startMs) {
    setState(() {
      _selectedSlotStartMs = startMs;
      _error = null;
    });
  }

  Future<void> _reserve(
    StationBookingData data,
    Vehicle? vehicle,
    ChargerPort port,
    Slot slot,
  ) async {
    if (_submitting) {
      return;
    }
    final BookingCheck check = ReservationEngine.check(
      station: data.entry.station,
      port: port,
      vehicle: vehicle,
      startMs: slot.startMs,
      endMs: slot.endMs,
      conflictingReservations: BookingRules.conflictCount(
        data.reservations,
        port.id,
        slot.startMs,
        slot.endMs,
      ),
      stationPaused: data.entry.station.isPaused,
    );
    if (!check.allowed) {
      _showError(check.reason);
      return;
    }

    final ReservationRepository? repository = ref.read(
      reservationRepositoryProvider,
    );
    if (repository == null) {
      _showError(AmpStrings.bookingServerRequired);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final String id = newId();
    final RepositoryResult<String> result = await repository.create(
      id: id,
      stationId: widget.stationId,
      portId: port.id,
      startMs: slot.startMs,
      endMs: slot.endMs,
      bookingCode: ReservationEngine.buildBookingCode(),
    );
    if (!mounted) {
      return;
    }

    final RepositoryFailure<String>? failure = result.failureOrNull;
    if (failure != null) {
      final String message = BookingRules.refusalMessage(
        failure.cause,
        fallback: failure.message,
      );
      setState(() {
        _submitting = false;
        _error = message;
      });
      AmpSnackbar.show(context, message, tone: AmpSnackbarTone.error);
      ref.invalidate(bookingDataProvider(widget.stationId));
      return;
    }

    setState(() => _submitting = false);
    ref.invalidate(consumerReservationsProvider);
    ref.invalidate(bookingDataProvider(widget.stationId));
    context.pushReplacement('/bookings/$id');
  }

  void _showError(String message) {
    setState(() => _error = message);
    AmpSnackbar.show(context, message, tone: AmpSnackbarTone.error);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label, {this.rule = true});

  final String label;
  final bool rule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (rule) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceL),
          const Hairline(),
        ],
        Padding(
          padding: const EdgeInsets.only(
            top: AmpTheme.spaceL,
            bottom: AmpTheme.spaceS,
          ),
          child: Eyebrow(label),
        ),
      ],
    );
  }
}

class _PaperNotice extends StatelessWidget {
  const _PaperNotice({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final Color rule = error ? colors.error : colors.busy;
    final Color icon = error ? colors.error : colors.busyInk;
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: rule, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmpIcon(AmpIconName.alert, size: 17, color: icon),
          const SizedBox(width: AmpTheme.spaceS),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingLoading extends StatelessWidget {
  const _BookingLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.65, height: 26),
        SizedBox(height: AmpTheme.spaceS),
        SkeletonLine(widthFactor: 0.45),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.3),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.8),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.2),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.62),
      ],
    );
  }
}
