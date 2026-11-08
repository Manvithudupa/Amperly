import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ids.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_chip.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/receipt_row.dart';
import '../../../core/widgets/skeleton.dart';
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
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        Text(name, style: text.displaySmall),
        const SizedBox(height: 2),
        Text(address, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceM),
        Wrap(
          spacing: AmpTheme.spaceS,
          runSpacing: AmpTheme.spaceS,
          children: <Widget>[
            AmpBadge(
              AmpFormat.meterLevel(station.verificationLevel),
              tone: station.supportsPaidEnergyBilling
                  ? AmpBadgeTone.success
                  : AmpBadgeTone.warning,
              icon: station.supportsPaidEnergyBilling
                  ? AmpIconName.check
                  : AmpIconName.info,
            ),
            if (station.isDcCapable)
              const AmpBadge(
                AmpStrings.filterDc,
                tone: AmpBadgeTone.info,
                icon: AmpIconName.bolt,
              ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceM),
        _vehicleCard(context, vehicle),
        if (!bookable) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          const _Callout(message: AmpStrings.detailsMeterGating),
        ] else ...<Widget>[
          _SectionTitle(AmpStrings.bookingPortLabel),
          if (ports.isEmpty)
            Text(
              vehicle == null
                  ? AmpStrings.bookingNoPorts
                  : AmpStrings.bookingNoCompatiblePorts,
              style: text.bodySmall,
            )
          else
            Wrap(
              spacing: AmpTheme.spaceS,
              runSpacing: AmpTheme.spaceS,
              children: <Widget>[
                for (final ChargerPort option in ports)
                  AmpChip(
                    label: BookingRules.portLabel(option),
                    selected: option.id == port?.id,
                    onTap: () => _selectPort(option.id),
                  ),
              ],
            ),
          _SectionTitle(AmpStrings.bookingDayLabel),
          Wrap(
            spacing: AmpTheme.spaceS,
            runSpacing: AmpTheme.spaceS,
            children: <Widget>[
              for (int index = 0; index < _dayStarts.length; index++)
                AmpChip(
                  label: AmpFormat.dayLabel(
                    DateTime.fromMillisecondsSinceEpoch(_dayStarts[index]),
                  ),
                  selected: _selectedDayIndex == index,
                  onTap: () => _selectDay(index),
                ),
            ],
          ),
          _SectionTitle(AmpStrings.bookingSlotLabel),
          if (port == null)
            Text(AmpStrings.bookingNoPorts, style: text.bodySmall)
          else if (!hasSchedule)
            Text(AmpStrings.bookingNoSchedules, style: text.bodySmall)
          else if (slots.isEmpty)
            Text(AmpStrings.bookingNoSlots, style: text.bodySmall)
          else
            Wrap(
              spacing: AmpTheme.spaceS,
              runSpacing: AmpTheme.spaceS,
              children: <Widget>[
                for (final Slot option in slots)
                  AmpChip(
                    label: AmpFormat.timeRange(option.startMs, option.endMs),
                    selected: option.startMs == slot?.startMs,
                    onTap: () => _selectSlot(option.startMs),
                  ),
              ],
            ),
          _SectionTitle(AmpStrings.bookingPriceTitle),
          if (port != null) _priceCard(context, station, port),
          _SectionTitle(AmpStrings.bookingPolicyTitle),
          Text(ReservationEngine.cancellationPolicy, style: text.bodySmall),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceM),
            _Callout(message: _error!, error: true),
          ],
        ],
      ],
    );
  }

  Widget _vehicleCard(BuildContext context, Vehicle? vehicle) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primaryTint,
              borderRadius: BorderRadius.circular(AmpTheme.radiusField),
            ),
            child: Center(
              child: AmpIcon(
                AmpIconName.bolt,
                size: 20,
                color: colors.onPrimaryTint,
              ),
            ),
          ),
          const SizedBox(width: AmpTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AmpStrings.bookingVehicleLabel, style: text.labelLarge),
                const SizedBox(height: 2),
                Text(
                  vehicle == null
                      ? AmpStrings.bookingNoVehicle
                      : vehicle.displayName,
                  style: text.titleSmall,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => context.push('/vehicles'),
                    child: const Text(AmpStrings.tripManageVehicles),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard(
    BuildContext context,
    ChargerStation station,
    ChargerPort port,
  ) {
    final AmpColors colors = context.amp;
    final PricePreview preview = BookingRules.previewFor(station, port);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: <Widget>[
          ReceiptRow(
            label: AmpStrings.bookingEnergyEstimate,
            value: AmpFormat.kWh(preview.estimatedKwh),
          ),
          ReceiptRow(
            label: AmpStrings.bookingEnergyCharge,
            value: AmpStrings.bookingEnergyChargeValue(
              AmpFormat.rupees(preview.energyCharge),
              AmpFormat.rupees(station.pricePerKwh),
            ),
          ),
          ReceiptRow(
            label: AmpStrings.bookingServiceFee,
            value: AmpFormat.rupees(preview.serviceFee),
          ),
          ReceiptRow(
            label: AmpStrings.bookingGatewayFee,
            value: AmpFormat.rupees(preview.gatewayFee),
          ),
          const Divider(height: AmpTheme.spaceL),
          ReceiptRow(
            label: AmpStrings.bookingTotal,
            value: AmpFormat.rupees(preview.estimatedTotal),
            emphasis: true,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AmpStrings.bookingPriceNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
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
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
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
        Skeleton(height: 112, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 180, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 220, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
