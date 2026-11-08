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
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/freshness_label.dart';
import '../../../core/widgets/receipt_row.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/station_repository.dart';
import '../../../domain/policy.dart';
import '../application/discovery_providers.dart';
import '../application/station_detail_provider.dart';

/// A charger's published facts, live port status and fee breakdown.
///
/// Reserve opens the real booking form. It is hidden for stations without a
/// verified meter, because those cannot bill energy.
class ChargerDetailsScreen extends ConsumerWidget {
  const ChargerDetailsScreen({required this.stationId, super.key});

  final String stationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RepositoryResult<StationCatalogueEntry>> detail = ref
        .watch(stationDetailProvider(stationId));

    return AmpScaffold(
      title: AmpStrings.detailsTitle,
      body: detail.when(
        loading: () => const _DetailsLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(stationDetailProvider(stationId)),
        ),
        data: (RepositoryResult<StationCatalogueEntry> result) {
          final RepositoryFailure<StationCatalogueEntry>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(stationDetailProvider(stationId)),
            );
          }
          return _DetailsBody(entry: result.valueOrNull!);
        },
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.entry});

  final StationCatalogueEntry entry;

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
    final int available = availablePortCount(entry);
    final String? hours = (station.operatingHours ?? '').trim().isEmpty
        ? null
        : station.operatingHours!.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
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
              availabilityLabel(entry),
              tone: available > 0 ? AmpBadgeTone.success : AmpBadgeTone.warning,
              icon: AmpIconName.bolt,
            ),
            if (station.isDcCapable)
              const AmpBadge(
                AmpStrings.filterDc,
                tone: AmpBadgeTone.info,
                icon: AmpIconName.bolt,
              ),
            AmpBadge(
              AmpFormat.meterLevel(station.verificationLevel),
              tone: station.supportsPaidEnergyBilling
                  ? AmpBadgeTone.success
                  : AmpBadgeTone.warning,
              icon: station.supportsPaidEnergyBilling
                  ? AmpIconName.check
                  : AmpIconName.info,
            ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceS),
        if (station.lastUpdatedMs > 0)
          FreshnessLabel(
            updatedAt: DateTime.fromMillisecondsSinceEpoch(
              station.lastUpdatedMs,
            ),
          )
        else
          Text(AmpStrings.availabilityUnknown, style: text.labelLarge),
        if (!station.supportsPaidEnergyBilling) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          _Notice(message: AmpStrings.detailsMeterGating),
        ],
        const SizedBox(height: AmpTheme.spaceM),
        Text(AmpStrings.detailsBillingNote, style: text.bodySmall),
        if (hours != null) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          Text(AmpStrings.detailsOperatingHours, style: text.labelLarge),
          const SizedBox(height: 2),
          Text(hours, style: text.bodyMedium),
        ],
        _SectionTitle(AmpStrings.detailsAvailability),
        Text(AmpStrings.detailsAvailabilityNote, style: text.bodySmall),
        const SizedBox(height: AmpTheme.spaceS),
        Container(
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            children: <Widget>[
              AmpIcon(AmpIconName.bolt, size: 20, color: colors.primary),
              const SizedBox(width: AmpTheme.spaceS),
              Expanded(
                child: Text(availabilityLabel(entry), style: text.titleSmall),
              ),
            ],
          ),
        ),
        _SectionTitle(AmpStrings.detailsPorts),
        if (entry.ports.isEmpty)
          Text(AmpStrings.detailsNoPorts, style: text.bodySmall)
        else
          for (final ChargerPort port in entry.ports) ...<Widget>[
            _PortRow(port: port),
            const SizedBox(height: AmpTheme.spaceS),
          ],
        _SectionTitle(AmpStrings.detailsPrice),
        Container(
          padding: const EdgeInsets.all(AmpTheme.spaceM),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            children: <Widget>[
              ReceiptRow(
                label: AmpStrings.detailsEnergyPrice,
                value: AmpFormat.rupees(station.pricePerKwh),
              ),
              ReceiptRow(
                label: AmpStrings.detailsServiceFee,
                value: AmpFormat.rupees(station.serviceFee),
              ),
              ReceiptRow(
                label: AmpStrings.detailsGatewayFee,
                value: AmpFormat.rupees(station.gatewayFee),
              ),
              const Divider(height: AmpTheme.spaceL),
              ReceiptRow(
                label: AmpStrings.detailsTotal,
                value: AmpFormat.rupees(
                  station.pricePerKwh + station.serviceFee + station.gatewayFee,
                ),
                emphasis: true,
              ),
            ],
          ),
        ),
        _SectionTitle(AmpStrings.detailsAccess),
        Text(
          (station.accessRules ?? '').trim().isEmpty
              ? AmpStrings.detailsNoAccess
              : station.accessRules!.trim(),
          style: text.bodyMedium,
        ),
        _SectionTitle(AmpStrings.detailsHost),
        Text(
          (station.hostName ?? '').trim().isEmpty
              ? AmpStrings.detailsNoHost
              : station.hostName!.trim(),
          style: text.bodyMedium,
        ),
        const SizedBox(height: 4),
        if (station.rating > 0 ||
            station.reliabilityScore > 0 ||
            station.incidentCount > 0)
          Text(
            AmpStrings.detailsReliability(
              station.reliabilityScore.round(),
              station.rating.toStringAsFixed(1),
              station.incidentCount,
            ),
            style: text.bodySmall,
          )
        else
          Text(AmpStrings.detailsReliabilityUnknown, style: text.bodySmall),
        if (station.supportsPaidEnergyBilling) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceL),
          AmpButton(
            label: AmpStrings.bookingReserveAction,
            icon: AmpIconName.ticket,
            onPressed: () => context.push('/book/${station.id}'),
          ),
        ],
      ],
    );
  }
}

class _PortRow extends StatelessWidget {
  const _PortRow({required this.port});

  final ChargerPort port;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String status = AmpFormat.portStatus(port.status);
    final bool available =
        (port.status ?? '').toUpperCase() == AmpPolicy.portAvailable;
    final String label =
        'Port ${port.portNumber ?? '?'} · '
        '${AmpFormat.connectorLabel(port.connectorType)} · '
        '${port.powerKw > 0 ? '${port.powerKw.toInt()} kW' : AmpStrings.powerNotPublished}';

    return Container(
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: <Widget>[
          AmpIcon(
            AmpIconName.plug,
            size: 19,
            color: available ? colors.available : colors.inkSecondary,
          ),
          const SizedBox(width: AmpTheme.spaceS),
          Expanded(child: Text(label, style: text.bodyMedium)),
          const SizedBox(width: AmpTheme.spaceS),
          AmpBadge(
            status.isEmpty ? AmpStrings.labelUnknown : status,
            tone: available ? AmpBadgeTone.success : AmpBadgeTone.warning,
            icon: available ? AmpIconName.check : AmpIconName.info,
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.busyTint,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.busy.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmpIcon(AmpIconName.alert, size: 18, color: colors.busyInk),
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
        Skeleton(height: 48, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 120, radius: AmpTheme.radiusCard),
        SizedBox(height: AmpTheme.spaceL),
        Skeleton(height: 120, radius: AmpTheme.radiusCard),
      ],
    );
  }
}
