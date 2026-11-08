import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_chip.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_illustration.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/connector_glyph.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/freshness_label.dart';
import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';
import '../application/discovery_providers.dart';

/// The public charger catalogue.
///
/// This is read-only on purpose: a charger is visible only after approval, and
/// the card never claims live hardware telemetry. It shows the host's port
/// status and how old that status is.
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({required this.profile, super.key});

  final AppUser profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<DiscoveryData>> catalogue = ref.watch(
      discoveryProvider,
    );
    final AmpColors colors = context.amp;

    return AmpScaffold(
      title: AmpStrings.discoverTitle,
      subtitle: AmpStrings.discoverSubtitle,
      actions: <Widget>[
        IconButton(
          tooltip: AmpStrings.tripsTitle,
          onPressed: () => context.push('/trips'),
          icon: AmpIcon(AmpIconName.pin, size: 22, color: colors.ink),
        ),
        _ProfileButton(
          label: (profile.name ?? '').trim().isEmpty
              ? (profile.email ?? '').trim()
              : profile.name!.trim(),
        ),
      ],
      body: catalogue.when(
        loading: () => const _DiscoveryLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(discoveryProvider),
        ),
        data: (RepositoryResult<DiscoveryData> result) {
          final RepositoryFailure<DiscoveryData>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(discoveryProvider),
            );
          }
          return _DiscoveryBody(data: result.valueOrNull!);
        },
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final String initial = label.trim().isEmpty
        ? 'A'
        : label.trim().characters.first.toUpperCase();

    return IconButton(
      tooltip: AmpStrings.profileAction,
      onPressed: () => context.push('/account'),
      icon: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.primaryTint,
          shape: BoxShape.circle,
        ),
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: AmpTheme.uiFont,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: colors.onPrimaryTint,
          ),
        ),
      ),
    );
  }
}

class _DiscoveryBody extends ConsumerWidget {
  const _DiscoveryBody({required this.data});

  final DiscoveryData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DiscoveryFilter filter = ref.watch(discoveryFilterProvider);
    final List<StationCatalogueEntry> filtered = filterStationEntries(
      entries: data.entries,
      filter: filter,
      vehicle: data.vehicle,
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(discoveryProvider);
        await ref.read(discoveryProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceM,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: <Widget>[
          _VehicleContext(vehicle: data.vehicle),
          const SizedBox(height: AmpTheme.spaceM),
          Wrap(
            spacing: AmpTheme.spaceS,
            runSpacing: AmpTheme.spaceS,
            children: <Widget>[
              AmpButton(
                label: AmpStrings.bookingListTitle,
                icon: AmpIconName.ticket,
                variant: AmpButtonVariant.tonal,
                expand: false,
                height: 40,
                onPressed: () => context.push('/bookings'),
              ),
              AmpButton(
                label: AmpStrings.sessionHistoryTitle,
                icon: AmpIconName.clock,
                variant: AmpButtonVariant.tonal,
                expand: false,
                height: 40,
                onPressed: () => context.push('/sessions'),
              ),
              AmpButton(
                label: AmpStrings.chatInboxAction,
                icon: AmpIconName.chat,
                variant: AmpButtonVariant.tonal,
                expand: false,
                height: 40,
                onPressed: () => context.push('/messages'),
              ),
            ],
          ),
          const SizedBox(height: AmpTheme.spaceM),
          Text(
            AmpStrings.discoverCount(filtered.length),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Wrap(
            spacing: AmpTheme.spaceS,
            runSpacing: AmpTheme.spaceS,
            children: <Widget>[
              AmpChip(
                label: AmpStrings.filterAll,
                selected: filter == DiscoveryFilter.all,
                onTap: () => ref
                    .read(discoveryFilterProvider.notifier)
                    .select(DiscoveryFilter.all),
              ),
              AmpChip(
                label: AmpStrings.filterCompatible,
                selected: filter == DiscoveryFilter.compatible,
                onTap: data.vehicle == null
                    ? null
                    : () => ref
                          .read(discoveryFilterProvider.notifier)
                          .select(DiscoveryFilter.compatible),
              ),
              AmpChip(
                label: AmpStrings.filterDc,
                selected: filter == DiscoveryFilter.dc,
                onTap: () => ref
                    .read(discoveryFilterProvider.notifier)
                    .select(DiscoveryFilter.dc),
              ),
              AmpChip(
                label: AmpStrings.filterMeter,
                selected: filter == DiscoveryFilter.metered,
                onTap: () => ref
                    .read(discoveryFilterProvider.notifier)
                    .select(DiscoveryFilter.metered),
              ),
            ],
          ),
          if (data.vehicle == null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            Text(
              AmpStrings.filterNeedsVehicle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
          const SizedBox(height: AmpTheme.spaceM),
          if (data.entries.isEmpty)
            EmptyState(
              title: AmpStrings.discoverEmptyTitle,
              message: AmpStrings.discoverEmptyBody,
              action: AmpButton(
                label: AmpStrings.retry,
                variant: AmpButtonVariant.tonal,
                icon: AmpIconName.refresh,
                expand: false,
                onPressed: () => ref.invalidate(discoveryProvider),
              ),
            )
          else if (filtered.isEmpty)
            EmptyState(
              title: AmpStrings.noResultsTitle,
              message: AmpStrings.discoverNoMatchesBody,
              illustration: AmpIllustrationKind.carQuestion,
              action: AmpButton(
                label: AmpStrings.discoverShowAll,
                variant: AmpButtonVariant.tonal,
                expand: false,
                onPressed: () => ref
                    .read(discoveryFilterProvider.notifier)
                    .select(DiscoveryFilter.all),
              ),
            )
          else
            for (final StationCatalogueEntry entry in filtered) ...<Widget>[
              _StationCard(
                entry: entry,
                onTap: () => context.push('/chargers/${entry.station.id}'),
              ),
              const SizedBox(height: AmpTheme.spaceM),
            ],
        ],
      ),
    );
  }
}

class _VehicleContext extends StatelessWidget {
  const _VehicleContext({required this.vehicle});

  final Vehicle? vehicle;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String line = vehicle == null
        ? AmpStrings.discoverNoVehicle
        : AmpStrings.discoverVehicleLine(
            vehicle!.displayName,
            AmpFormat.connectorLabel(vehicle!.connectorType),
          );

    return Material(
      color: colors.surfaceVariant,
      borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/vehicles'),
        child: Padding(
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AmpIcon(AmpIconName.bolt, size: 19, color: colors.primary),
              const SizedBox(width: AmpTheme.spaceS),
              Expanded(
                child: Text(
                  line,
                  style: text.bodySmall?.copyWith(color: colors.inkSecondary),
                ),
              ),
              const SizedBox(width: AmpTheme.spaceS),
              AmpIcon(
                AmpIconName.chevronRight,
                size: 17,
                color: colors.inkSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  const _StationCard({required this.entry, required this.onTap});

  final StationCatalogueEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ChargerStation station = entry.station;
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String name = (station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : station.name!.trim();
    final String address = (station.address ?? '').trim().isEmpty
        ? AmpStrings.addressNotPublished
        : station.address!.trim();
    final String connectors = station.connectorTypeList.isEmpty
        ? AmpStrings.connectorNotPublished
        : station.connectorTypeList
              .map(AmpFormat.connectorLabel)
              .where((String value) => value.isNotEmpty)
              .join(', ');
    final String connectorKind = station.connectorTypeList.isEmpty
        ? station.connectorTypes ?? ''
        : station.connectorTypeList.first;
    final int available = availablePortCount(entry);
    final bool metered = station.supportsPaidEnergyBilling;
    final double totalPerKwh =
        station.pricePerKwh + station.serviceFee + station.gatewayFee;

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        side: BorderSide(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primaryTint,
                      borderRadius: BorderRadius.circular(AmpTheme.radiusField),
                    ),
                    child: Center(
                      child: ConnectorGlyph(
                        AmpFormat.connectorKind(connectorKind),
                        size: 23,
                        color: colors.onPrimaryTint,
                      ),
                    ),
                  ),
                  const SizedBox(width: AmpTheme.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(name, style: text.titleMedium),
                        const SizedBox(height: 2),
                        Text(address, style: text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AmpTheme.spaceS),
                  AmpIcon(
                    AmpIconName.chevronRight,
                    size: 18,
                    color: colors.inkSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AmpTheme.spaceM),
              Wrap(
                spacing: AmpTheme.spaceS,
                runSpacing: AmpTheme.spaceS,
                children: <Widget>[
                  AmpBadge(
                    availabilityLabel(entry),
                    tone: available > 0
                        ? AmpBadgeTone.success
                        : AmpBadgeTone.warning,
                    icon: AmpIconName.bolt,
                  ),
                  if (station.isDcCapable)
                    const AmpBadge(
                      AmpStrings.filterDc,
                      tone: AmpBadgeTone.info,
                      icon: AmpIconName.bolt,
                    ),
                  if (metered)
                    const AmpBadge(
                      AmpStrings.meterMetered,
                      tone: AmpBadgeTone.success,
                      icon: AmpIconName.check,
                    )
                  else
                    const AmpBadge(
                      AmpStrings.meterDiscoveryOnly,
                      tone: AmpBadgeTone.warning,
                      icon: AmpIconName.info,
                    ),
                ],
              ),
              const SizedBox(height: AmpTheme.spaceM),
              Row(
                children: <Widget>[
                  ConnectorGlyph(
                    AmpFormat.connectorKind(connectorKind),
                    size: 19,
                    color: colors.inkSecondary,
                  ),
                  const SizedBox(width: AmpTheme.spaceS),
                  Expanded(
                    child: Text(
                      '$connectors · '
                      '${station.maxPowerKw > 0 ? '${station.maxPowerKw.toInt()} kW' : AmpStrings.powerNotPublished}',
                      style: text.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AmpTheme.spaceM),
              Text(AmpStrings.detailsTotal, style: text.labelLarge),
              const SizedBox(height: 2),
              if (station.pricePerKwh > 0)
                PriceText(
                  totalPerKwh,
                  perUnit: AmpStrings.perKwh,
                  style: text.titleLarge,
                )
              else
                Text(AmpStrings.priceNotPublished, style: text.titleSmall),
              const SizedBox(height: AmpTheme.spaceS),
              if (station.lastUpdatedMs > 0)
                FreshnessLabel(
                  updatedAt: DateTime.fromMillisecondsSinceEpoch(
                    station.lastUpdatedMs,
                  ),
                )
              else
                Text(AmpStrings.availabilityUnknown, style: text.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _DiscoveryLoading extends StatelessWidget {
  const _DiscoveryLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: const <Widget>[
        Skeleton(height: 64, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.35),
        SizedBox(height: AmpTheme.spaceM),
        ChargerRowSkeleton(),
        ChargerRowSkeleton(),
        ChargerRowSkeleton(),
      ],
    );
  }
}
