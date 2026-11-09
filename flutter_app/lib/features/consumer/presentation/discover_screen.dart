import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/input_formatters.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/departure_row.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../data/geoapify/geoapify_tiles.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../domain/policy.dart';
import '../../common/presentation/notification_bell.dart';
import '../application/battery_providers.dart';
import '../application/discovery_providers.dart';
import '../application/journey_providers.dart';
import '../application/trip_providers.dart';
import 'widgets/discovery_map.dart';

/// The public charger catalogue, with the map as the primary surface.
///
/// The sheet is paper over the map. Rows show published power, connector,
/// port status and price; no card, badge fill or invented distance.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<DiscoveryData>> catalogue = ref.watch(
      discoveryProvider,
    );
    final GeoapifyMapConfig? mapConfig = ref.watch(geoapifyMapConfigProvider);

    return Scaffold(
      backgroundColor: context.amp.background,
      body: catalogue.when(
        loading: () => _DiscoverShell(
          entries: const <StationCatalogueEntry>[],
          mapConfig: mapConfig,
          sheetBuilder: (BuildContext context, ScrollController controller) =>
              _DiscoveryLoadingSheet(controller: controller),
        ),
        error: (Object error, StackTrace stack) => _DiscoverShell(
          entries: const <StationCatalogueEntry>[],
          mapConfig: mapConfig,
          sheetBuilder: (BuildContext context, ScrollController controller) =>
              _DiscoveryErrorSheet(
                controller: controller,
                message: UserMessages.from(error),
                onRetry: () => ref.invalidate(discoveryProvider),
              ),
        ),
        data: (RepositoryResult<DiscoveryData> result) {
          final RepositoryFailure<DiscoveryData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return _DiscoverShell(
              entries: const <StationCatalogueEntry>[],
              mapConfig: mapConfig,
              sheetBuilder:
                  (BuildContext context, ScrollController controller) =>
                      _DiscoveryErrorSheet(
                        controller: controller,
                        message: failure.message,
                        onRetry: () => ref.invalidate(discoveryProvider),
                      ),
            );
          }
          return _DiscoveryBody(
            data: result.valueOrNull!,
            mapConfig: mapConfig,
          );
        },
      ),
    );
  }
}

class _DiscoveryBody extends ConsumerWidget {
  const _DiscoveryBody({required this.data, required this.mapConfig});

  final DiscoveryData data;
  final GeoapifyMapConfig? mapConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DiscoveryFilter filter = ref.watch(discoveryFilterProvider);
    final List<StationCatalogueEntry> filtered = filterStationEntries(
      entries: data.entries,
      filter: filter,
      vehicle: data.vehicle,
    );

    return _DiscoverShell(
      entries: filtered,
      mapConfig: mapConfig,
      sheetBuilder: (BuildContext context, ScrollController controller) =>
          _DiscoverySheet(
            controller: controller,
            data: data,
            filtered: filtered,
            filter: filter,
          ),
    );
  }
}

class _DiscoverShell extends StatelessWidget {
  const _DiscoverShell({
    required this.entries,
    required this.mapConfig,
    required this.sheetBuilder,
  });

  final List<StationCatalogueEntry> entries;
  final GeoapifyMapConfig? mapConfig;
  final Widget Function(BuildContext, ScrollController) sheetBuilder;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: DiscoveryMap(
            entries: entries,
            config: mapConfig,
            onSelect: (StationCatalogueEntry entry) =>
                context.push('/chargers/${entry.station.id}'),
          ),
        ),
        const _DiscoverTopBar(),
        if (mapConfig != null) const _MapAttribution(),
        DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.26,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const <double>[0.26, 0.5, 0.9],
          builder: (BuildContext context, ScrollController controller) {
            return Material(
              color: colors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AmpTheme.radiusCard),
                ),
                side: BorderSide(color: colors.divider),
              ),
              child: sheetBuilder(context, controller),
            );
          },
        ),
      ],
    );
  }
}

class _DiscoverTopBar extends StatelessWidget {
  const _DiscoverTopBar();

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

    return Positioned(
      left: AmpTheme.screenPadding,
      right: AmpTheme.screenPadding,
      top: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: AmpTheme.spaceS),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Material(
                  color: colors.surface,
                  elevation: 2,
                  shadowColor: colors.ink.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AmpTheme.radiusField),
                    side: BorderSide(color: colors.divider),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.go('/trips'),
                    child: SizedBox(
                      height: 48,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AmpTheme.spaceM,
                        ),
                        child: Row(
                          children: <Widget>[
                            AmpIcon(
                              AmpIconName.search,
                              size: 18,
                              color: colors.inkSecondary,
                            ),
                            const SizedBox(width: AmpTheme.spaceS),
                            Expanded(
                              child: Text(
                                AmpStrings.discoverSearchHint,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: colors.inkSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AmpTheme.spaceS),
              const NotificationBell(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 68,
      right: 14,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 230),
        child: ColoredBox(
          color: colors.surface.withValues(alpha: 0.88),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: Text(
              AmpPolicy.mapAttribution,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AmpTheme.uiFont,
                fontSize: 9,
                height: 1.2,
                color: colors.inkSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscoverySheet extends ConsumerWidget {
  const _DiscoverySheet({
    required this.controller,
    required this.data,
    required this.filtered,
    required this.filter,
  });

  final ScrollController controller;
  final DiscoveryData data;
  final List<StationCatalogueEntry> filtered;
  final DiscoveryFilter filter;

  Future<void> _editBattery(BuildContext context, WidgetRef ref) async {
    final int? previous = ref.read(batterySocProvider);
    final int? value = await showDialog<int>(
      context: context,
      builder: (BuildContext dialogContext) =>
          _BatteryDialog(initial: previous),
    );
    if (value == null || !context.mounted) {
      return;
    }
    ref.read(batterySocProvider.notifier).setSoc(value);

    final String? vehicleId = data.vehicle?.id;
    final repository = ref.read(journeyRepositoryProvider);
    bool? recorded;
    if (repository != null && vehicleId != null) {
      final saved = (await ref.read(savedJourneyProvider.future)).valueOrNull;
      final result = await repository.recordBatteryConfirmation(
        vehicleId: vehicleId,
        tripPlanId: saved?.plan.id,
        estimatedSoc: previous ?? value,
        actualSoc: value,
        timestampMs: DateTime.now().millisecondsSinceEpoch,
      );
      recorded = result.isSuccess;
    }
    if (!context.mounted) {
      return;
    }

    final bool failed = recorded == false;
    AmpSnackbar.show(
      context,
      failed
          ? AmpStrings.discoverBatteryNotRecorded
          : AmpStrings.discoverBatterySaved(value),
      tone: failed ? AmpSnackbarTone.error : AmpSnackbarTone.success,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? battery = ref.watch(batterySocProvider);
    final String vehicleLine = data.vehicle == null
        ? AmpStrings.discoverNoVehicle
        : AmpStrings.discoverVehicleLine(
            data.vehicle!.displayName,
            AmpFormat.connectorLabel(data.vehicle!.connectorType),
          );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(discoveryProvider);
        await ref.read(discoveryProvider.future);
      },
      child: CustomScrollView(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _SheetHandle(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AmpTheme.screenPadding,
                    2,
                    AmpTheme.screenPadding,
                    AmpTheme.spaceS,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Eyebrow(AmpStrings.discoverNearby(filtered.length)),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              vehicleLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: context.amp.inkSecondary),
                            ),
                          ),
                          TextAction(
                            data.vehicle == null
                                ? AmpStrings.discoverAddVehicle
                                : AmpStrings.discoverChange,
                            onPressed: () => context.push('/vehicles'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  battery == null
                                      ? AmpStrings.discoverBatteryUnset
                                      : AmpStrings.discoverBatteryLevel(
                                          battery,
                                        ),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: context.amp.inkSecondary,
                                      ),
                                ),
                                if (battery != null) ...<Widget>[
                                  const SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: battery / 100,
                                      minHeight: 3,
                                      color: context.amp.available,
                                      backgroundColor:
                                          context.amp.surfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: AmpTheme.spaceM),
                          TextAction(
                            battery == null
                                ? AmpStrings.discoverBatteryAdd
                                : AmpStrings.discoverBatteryUpdate,
                            onPressed: () => _editBattery(context, ref),
                          ),
                        ],
                      ),
                      if (data.vehicle == null) ...<Widget>[
                        const SizedBox(height: 10),
                        _AddVehiclePrompt(
                          onAdd: () => context.push('/vehicles'),
                        ),
                      ],
                      const SizedBox(height: 4),
                      TextFilterRow<DiscoveryFilter>(
                        selected: filter,
                        onSelected: (DiscoveryFilter value) => ref
                            .read(discoveryFilterProvider.notifier)
                            .select(value),
                        options: <TextFilterOption<DiscoveryFilter>>[
                          const TextFilterOption<DiscoveryFilter>(
                            value: DiscoveryFilter.all,
                            label: AmpStrings.filterAll,
                          ),
                          TextFilterOption<DiscoveryFilter>(
                            value: DiscoveryFilter.compatible,
                            label: AmpStrings.filterCompatible,
                            enabled: data.vehicle != null,
                          ),
                          const TextFilterOption<DiscoveryFilter>(
                            value: DiscoveryFilter.dc,
                            label: AmpStrings.filterDc,
                          ),
                          const TextFilterOption<DiscoveryFilter>(
                            value: DiscoveryFilter.metered,
                            label: AmpStrings.filterMeter,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Hairline(),
              ],
            ),
          ),
          if (data.entries.isEmpty)
            SliverToBoxAdapter(
              child: _DiscoveryEmpty(
                title: AmpStrings.discoverEmptyTitle,
                message: AmpStrings.discoverEmptyBody,
                action: AmpStrings.discoverEmptyAction,
                onAction: () => ref.invalidate(discoveryProvider),
              ),
            )
          else if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: _DiscoveryEmpty(
                title: AmpStrings.discoverNoMatchesTitle,
                message: AmpStrings.discoverNoMatchesBody,
                action: AmpStrings.discoverShowAll,
                onAction: () => ref
                    .read(discoveryFilterProvider.notifier)
                    .select(DiscoveryFilter.all),
              ),
            )
          else ...<Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final StationCatalogueEntry entry = filtered[index];
                return _DiscoveryRow(
                  entry: entry,
                  onTap: () => context.push('/chargers/${entry.station.id}'),
                );
              }, childCount: filtered.length),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AmpTheme.spaceXl)),
          ],
        ],
      ),
    );
  }
}

class _BatteryDialog extends StatefulWidget {
  const _BatteryDialog({required this.initial});

  final int? initial;

  @override
  State<_BatteryDialog> createState() => _BatteryDialogState();
}

class _BatteryDialogState extends State<_BatteryDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial?.toString() ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final int? value = int.tryParse(_controller.text.trim());
    if (value == null || value < 0 || value > 100) {
      setState(() => _error = AmpStrings.discoverBatteryInvalid);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text(AmpStrings.discoverBatteryTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AmpStrings.discoverBatteryBody,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          AmpField(
            controller: _controller,
            label: AmpStrings.discoverBatteryHint,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[AmpInputFormatters.digits],
            maxLength: 3,
            errorText: _error,
            onChanged: (String value) {
              if (_error != null) {
                setState(() => _error = null);
              }
            },
            onSubmitted: (String value) => _save(),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AmpStrings.cancel),
        ),
        TextButton(onPressed: _save, child: const Text(AmpStrings.confirm)),
      ],
    );
  }
}

class _DiscoveryRow extends StatelessWidget {
  const _DiscoveryRow({required this.entry, required this.onTap});

  final StationCatalogueEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChargerStation station = entry.station;
    final int available = availablePortCount(entry);
    final bool metered = station.supportsPaidEnergyBilling;
    final String connectors = station.connectorTypeList.isEmpty
        ? AmpStrings.connectorNotPublished
        : station.connectorTypeList
              .map(AmpFormat.connectorLabel)
              .where((String value) => value.isNotEmpty)
              .join(', ');
    final double totalPerKwh =
        station.pricePerKwh + station.serviceFee + station.gatewayFee;
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final String? freshness = station.lastUpdatedMs > 0
        ? AmpFormat.relative(
            DateTime.fromMillisecondsSinceEpoch(station.lastUpdatedMs),
          )
        : null;

    return DepartureRow(
      title: name,
      metric: station.maxPowerKw > 0
          ? station.maxPowerKw.toInt().toString()
          : '—',
      metricUnit: 'kW',
      detail: connectors,
      availablePorts: available,
      totalPorts: entry.ports.length,
      statusLabel: available > 0
          ? AmpStrings.discoverAvailable
          : AmpStrings.discoverBusy,
      statusDetail: freshness,
      statusTone: available > 0 ? StatusDotTone.available : StatusDotTone.busy,
      price: metered
          ? (totalPerKwh > 0 ? AmpFormat.rupees(totalPerKwh) : '—')
          : null,
      discoveryOnly: !metered,
      onTap: onTap,
    );
  }
}

class _AddVehiclePrompt extends StatelessWidget {
  const _AddVehiclePrompt({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AmpTheme.radiusField),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AmpIcon(
              AmpIconName.battery,
              size: 18,
              color: colors.inkSecondary,
            ),
          ),
          const SizedBox(width: AmpTheme.spaceS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AmpStrings.discoverAddVehiclePromptTitle,
                  style: text.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  AmpStrings.discoverAddVehiclePromptBody,
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AmpTheme.spaceS),
          TextAction(AmpStrings.vehicleAdd, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _DiscoveryEmpty extends StatelessWidget {
  const _DiscoveryEmpty({
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String message;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceXl,
        AmpTheme.screenPadding,
        AmpTheme.spaceXl,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AmpTheme.spaceS),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
            ),
          ),
          const SizedBox(height: AmpTheme.spaceS),
          TextAction(action, onPressed: onAction),
        ],
      ),
    );
  }
}

class _DiscoveryLoadingSheet extends StatelessWidget {
  const _DiscoveryLoadingSheet({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: const <Widget>[
        _SheetHandle(),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AmpTheme.screenPadding,
            2,
            AmpTheme.screenPadding,
            AmpTheme.spaceS,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Skeleton(width: 170, height: 11),
              SizedBox(height: AmpTheme.spaceS),
              Skeleton(width: 210, height: 13),
              SizedBox(height: AmpTheme.spaceM),
              Row(
                children: <Widget>[
                  Skeleton(width: 28, height: 12),
                  SizedBox(width: AmpTheme.spaceL),
                  Skeleton(width: 58, height: 12),
                  SizedBox(width: AmpTheme.spaceL),
                  Skeleton(width: 52, height: 12),
                ],
              ),
            ],
          ),
        ),
        Hairline(),
        _DepartureRowSkeleton(),
        _DepartureRowSkeleton(),
        _DepartureRowSkeleton(),
      ],
    );
  }
}

class _DepartureRowSkeleton extends StatelessWidget {
  const _DepartureRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AmpTheme.screenPadding,
        vertical: 18,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Skeleton(width: 34, height: 22),
                SizedBox(height: 5),
                Skeleton(width: 20, height: 9),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Skeleton(width: 190, height: 14),
                SizedBox(height: AmpTheme.spaceS),
                Skeleton(width: 118, height: 10),
                SizedBox(height: AmpTheme.spaceS),
                Skeleton(width: 142, height: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Skeleton(width: 46, height: 17),
                SizedBox(height: 5),
                Skeleton(width: 28, height: 9),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryErrorSheet extends StatelessWidget {
  const _DiscoveryErrorSheet({
    required this.controller,
    required this.message,
    required this.onRetry,
  });

  final ScrollController controller;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return ListView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: <Widget>[
        const _SheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AmpTheme.screenPadding,
            AmpTheme.spaceM,
            AmpTheme.screenPadding,
            AmpTheme.spaceXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Eyebrow(AmpStrings.errorTitle),
              const SizedBox(height: AmpTheme.spaceS),
              Text(
                AmpStrings.discoverTitle,
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: colors.ink),
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Text(message, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AmpTheme.spaceS),
              TextAction(AmpStrings.retry, onPressed: onRetry),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AmpStrings.discoverHandleLabel,
      child: SizedBox(
        height: 22,
        child: Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: context.amp.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
