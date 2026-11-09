import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/location/device_location.dart';
import '../../../core/location/location_flow.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/freshness_label.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/port_dots.dart';
import '../../../core/widgets/receipt_rows.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../data/geoapify/geoapify_client.dart';
import '../../../data/geoapify/geoapify_models.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../domain/policy.dart';
import '../application/discovery_providers.dart';
import '../application/station_detail_provider.dart';
import '../application/trip_providers.dart';
import 'navigation_screen.dart';

/// A charger's published facts, live port status and fee breakdown.
///
/// Reserve opens the real booking form. It is hidden for stations without a
/// verified meter, because those cannot bill energy.
class ChargerDetailsScreen extends ConsumerStatefulWidget {
  const ChargerDetailsScreen({
    required this.stationId,
    super.key,
    this.autoDirections = false,
  });

  final String stationId;

  /// Used by one-tap Navigate from a booking. The screen still explains
  /// location access before the system prompt; it never invents a start point.
  final bool autoDirections;

  @override
  ConsumerState<ChargerDetailsScreen> createState() =>
      _ChargerDetailsScreenState();
}

class _ChargerDetailsScreenState extends ConsumerState<ChargerDetailsScreen> {
  TravelMode _mode = TravelMode.driving;
  bool _autoDirectionsStarted = false;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<StationCatalogueEntry>> detail = ref
        .watch(stationDetailProvider(widget.stationId));
    final StationCatalogueEntry? loaded = detail.asData?.value.valueOrNull;
    final ChargerStation? station = loaded?.station;
    final VoidCallback? reserve =
        station != null && station.supportsPaidEnergyBilling
        ? () => context.push('/book/${station.id}')
        : null;

    return AmpScaffold(
      title: AmpStrings.detailsTitle,
      body: detail.when(
        loading: () => const _DetailsLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () =>
              ref.invalidate(stationDetailProvider(widget.stationId)),
        ),
        data: (RepositoryResult<StationCatalogueEntry> result) {
          final RepositoryFailure<StationCatalogueEntry>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () =>
                  ref.invalidate(stationDetailProvider(widget.stationId)),
            );
          }
          final StationCatalogueEntry entry = result.valueOrNull!;
          if (widget.autoDirections && !_autoDirectionsStarted) {
            _autoDirectionsStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                unawaited(_navigate(context, ref, entry, _mode));
              }
            });
          }
          return _DetailsBody(
            entry: entry,
            mode: _mode,
            onModeChanged: (TravelMode value) => setState(() => _mode = value),
            onNavigate: () => _navigate(context, ref, entry, _mode),
            onRefresh: () async {
              ref.invalidate(stationDetailProvider(widget.stationId));
              await ref.read(stationDetailProvider(widget.stationId).future);
            },
          );
        },
      ),
      bottomBar: reserve == null
          ? null
          : AmpButton(
              label: AmpStrings.bookingReserveAction,
              icon: AmpIconName.ticket,
              onPressed: reserve,
            ),
    );
  }

  Future<void> _navigate(
    BuildContext context,
    WidgetRef ref,
    StationCatalogueEntry entry,
    TravelMode mode,
  ) async {
    final GeoapifyClient? client = ref.read(geoapifyClientProvider);
    if (client == null || ref.read(geoapifyMapConfigProvider) == null) {
      AmpSnackbar.show(
        context,
        AmpStrings.tripMapSetupBody,
        tone: AmpSnackbarTone.error,
      );
      return;
    }

    AmpSnackbar.show(
      context,
      AmpStrings.detailsLocating,
      tone: AmpSnackbarTone.info,
    );
    final DeviceLocationService service = ref.read(
      deviceLocationServiceProvider,
    );
    final DeviceLocationFix fix = await requestDeviceLocation(context, service);
    if (!context.mounted) {
      return;
    }
    if (!fix.hasPosition) {
      final bool needsSettings =
          fix.status == DeviceLocationStatus.permissionDeniedForever;
      final String message = switch (fix.status) {
        DeviceLocationStatus.permissionDeniedForever =>
          AmpStrings.locationPermissionForever,
        DeviceLocationStatus.permissionDenied =>
          AmpStrings.locationPermissionOff,
        DeviceLocationStatus.servicesDisabled => AmpStrings.locationServicesOff,
        DeviceLocationStatus.unavailable ||
        DeviceLocationStatus.found => AmpStrings.tripLocationUnavailable,
      };
      AmpSnackbar.show(
        context,
        message,
        tone: AmpSnackbarTone.error,
        actionLabel: needsSettings
            ? AmpStrings.locationPermissionOpenSettings
            : null,
        onAction: needsSettings ? service.openSettings : null,
      );
      return;
    }

    final RepositoryResult<DirectionsRoute> routed = await client.route(
      mode: mode,
      fromLat: fix.latitude,
      fromLng: fix.longitude,
      toLat: entry.station.latitude,
      toLng: entry.station.longitude,
    );
    if (!context.mounted) {
      return;
    }
    final DirectionsRoute? route = routed.valueOrNull;
    if (route == null || route.points.length < 2) {
      AmpSnackbar.show(
        context,
        routed.failureOrNull?.message ?? AmpStrings.detailsRouteFailed,
        tone: AmpSnackbarTone.error,
      );
      return;
    }

    final String name = (entry.station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : entry.station.name!.trim();
    unawaited(
      context.push(
        '/navigation',
        extra: NavigationTrip(label: name, route: route, mode: mode),
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.entry,
    required this.mode,
    required this.onModeChanged,
    required this.onNavigate,
    required this.onRefresh,
  });

  final StationCatalogueEntry entry;
  final TravelMode mode;
  final ValueChanged<TravelMode> onModeChanged;
  final VoidCallback onNavigate;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final ChargerStation station = entry.station;
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final String address = (station.address ?? '').trim().isEmpty
        ? AmpStrings.addressNotPublished
        : station.address!.trim();
    final int available = availablePortCount(entry);
    final int totalPorts = entry.ports.length;
    final bool hasPorts = totalPorts > 0;
    final String? hours = (station.operatingHours ?? '').trim().isEmpty
        ? null
        : station.operatingHours!.trim();
    final double totalPerKwh =
        station.pricePerKwh + station.serviceFee + station.gatewayFee;
    final bool showReliability =
        station.rating > 0 ||
        station.reliabilityScore > 0 ||
        station.incidentCount > 0;
    final String availability = !hasPorts
        ? AmpStrings.portsNotPublished
        : available > 0
        ? AmpStrings.discoverAvailable
        : AmpStrings.discoverBusy;
    final String? availabilityDetail = hasPorts
        ? AmpStrings.portsAvailable(available, totalPorts)
        : null;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
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
          const SizedBox(height: 10),
          Eyebrow(AmpStrings.detailsDirectionsMode),
          const SizedBox(height: 2),
          TextFilterRow<TravelMode>(
            options: const <TextFilterOption<TravelMode>>[
              TextFilterOption<TravelMode>(
                value: TravelMode.driving,
                label: AmpStrings.detailsDrive,
              ),
              TextFilterOption<TravelMode>(
                value: TravelMode.walking,
                label: AmpStrings.detailsWalk,
              ),
            ],
            selected: mode,
            onSelected: onModeChanged,
          ),
          const SizedBox(height: 2),
          TextAction(AmpStrings.detailsNavigate, onPressed: onNavigate),
          const SizedBox(height: 8),
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
          const _SectionHeading(AmpStrings.detailsAvailability, rule: false),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: StatusDotLabel(
                  availability,
                  detail: availabilityDetail,
                  tone: !hasPorts
                      ? StatusDotTone.neutral
                      : available > 0
                      ? StatusDotTone.available
                      : StatusDotTone.busy,
                ),
              ),
              if (hasPorts) ...<Widget>[
                const SizedBox(width: AmpTheme.spaceM),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: PortDots(available: available, total: totalPorts),
                ),
              ],
            ],
          ),
          if (station.lastUpdatedMs > 0) ...<Widget>[
            const SizedBox(height: 7),
            FreshnessLabel(
              updatedAt: DateTime.fromMillisecondsSinceEpoch(
                station.lastUpdatedMs,
              ),
            ),
          ] else ...<Widget>[
            const SizedBox(height: 7),
            Text(AmpStrings.availabilityUnknown, style: text.bodySmall),
          ],
          const SizedBox(height: AmpTheme.spaceS),
          Text(AmpStrings.detailsAvailabilityNote, style: text.bodySmall),
          if (!station.supportsPaidEnergyBilling) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceM),
            const _PaperNotice(message: AmpStrings.detailsMeterGating),
          ],
          const _SectionHeading(AmpStrings.detailsPorts),
          if (!hasPorts)
            _PortsEmpty(onRefresh: onRefresh)
          else
            for (
              int index = 0;
              index < entry.ports.length;
              index++
            ) ...<Widget>[
              _PortLine(port: entry.ports[index]),
              if (index < entry.ports.length - 1) const Hairline(),
            ],
          const _SectionHeading(AmpStrings.detailsPrice),
          if (totalPerKwh > 0) ...<Widget>[
            BigNumber(
              value: AmpFormat.rupees(totalPerKwh),
              unit: AmpStrings.perKwh,
              label: AmpStrings.detailsTotal,
            ),
            const SizedBox(height: AmpTheme.spaceS),
            ReceiptRows(
              lines: <ReceiptLine>[
                ReceiptLine(
                  label: AmpStrings.detailsEnergyPrice,
                  value: AmpFormat.rupees(station.pricePerKwh),
                ),
                ReceiptLine(
                  label: AmpStrings.detailsServiceFee,
                  value: AmpFormat.rupees(station.serviceFee),
                ),
                ReceiptLine(
                  label: AmpStrings.detailsGatewayFee,
                  value: AmpFormat.rupees(station.gatewayFee),
                ),
              ],
            ),
          ] else
            Text(AmpStrings.priceNotPublished, style: text.bodySmall),
          const SizedBox(height: AmpTheme.spaceS),
          Text(AmpStrings.detailsBillingNote, style: text.bodySmall),
          if (hours != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceL),
            const Eyebrow(AmpStrings.detailsOperatingHours),
            const SizedBox(height: 4),
            Text(hours, style: text.bodyMedium),
          ],
          const _SectionHeading(AmpStrings.detailsAccess),
          Text(
            (station.accessRules ?? '').trim().isEmpty
                ? AmpStrings.detailsNoAccess
                : station.accessRules!.trim(),
            style: text.bodyMedium,
          ),
          const _SectionHeading(AmpStrings.detailsHost),
          Text(
            (station.hostName ?? '').trim().isEmpty
                ? AmpStrings.detailsNoHost
                : station.hostName!.trim(),
            style: text.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            showReliability
                ? AmpStrings.detailsReliability(
                    station.reliabilityScore.round(),
                    station.rating.toStringAsFixed(1),
                    station.incidentCount,
                  )
                : AmpStrings.detailsReliabilityUnknown,
            style: text.bodySmall,
          ),
          const SizedBox(height: AmpTheme.spaceL),
          const Hairline(),
          const SizedBox(height: AmpTheme.spaceS),
          TextAction(
            AmpStrings.reportTitle,
            onPressed: () => context.push(
              Uri(
                path: '/report',
                queryParameters: <String, String>{
                  'stationId': station.id,
                  'hostId': station.hostId ?? '',
                  'stationName': name,
                },
              ).toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PortsEmpty extends StatelessWidget {
  const _PortsEmpty({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AmpStrings.detailsPortsEmptyTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 2),
        Text(
          AmpStrings.detailsNoPorts,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        TextAction(AmpStrings.retry, onPressed: onRefresh),
      ],
    );
  }
}

class _PortLine extends StatelessWidget {
  const _PortLine({required this.port});

  final ChargerPort port;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String storedStatus = (port.status ?? '').toUpperCase();
    final bool available = storedStatus == AmpPolicy.portAvailable;
    final String status = AmpFormat.portStatus(port.status);
    final String connector = AmpFormat.connectorLabel(port.connectorType);
    final String power = port.powerKw > 0
        ? '${port.powerKw.toInt()} kW'
        : AmpStrings.powerNotPublished;
    final String detail =
        '${connector.isEmpty ? AmpStrings.connectorNotPublished : connector} · '
        '$power';
    final StatusDotTone tone = storedStatus.isEmpty
        ? StatusDotTone.neutral
        : available
        ? StatusDotTone.available
        : StatusDotTone.busy;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 58,
            child: Text(
              (port.portNumber ?? '').trim().isEmpty
                  ? '?'
                  : port.portNumber!.trim(),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: AmpType.metric(context, size: 27),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(detail, style: text.titleSmall),
                const SizedBox(height: 5),
                StatusDotLabel(
                  status.isEmpty ? AmpStrings.labelUnknown : status,
                  tone: tone,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
  const _PaperNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return Container(
      padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.busy, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmpIcon(AmpIconName.alert, size: 17, color: colors.busyInk),
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

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AmpTheme.screenPadding),
      children: const <Widget>[
        SkeletonLine(widthFactor: 0.7, height: 26),
        SizedBox(height: AmpTheme.spaceS),
        SkeletonLine(widthFactor: 0.45),
        SizedBox(height: AmpTheme.spaceL),
        Hairline(),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.32),
        SizedBox(height: AmpTheme.spaceM),
        Skeleton(height: 120, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 120, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
