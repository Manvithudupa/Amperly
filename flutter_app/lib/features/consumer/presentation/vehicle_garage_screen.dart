import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/errors/user_messages.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../data/repositories/vehicle_repository.dart';
import '../application/discovery_providers.dart';
import '../application/vehicle_providers.dart';

/// The saved cars for one account.
///
/// A tap opens the editor. A separate action makes a car active, because the
/// card also needs to be tappable for editing and an accidental switch changes
/// every range and compatibility decision.
class VehicleGarageScreen extends ConsumerStatefulWidget {
  const VehicleGarageScreen({super.key});

  @override
  ConsumerState<VehicleGarageScreen> createState() =>
      _VehicleGarageScreenState();
}

class _VehicleGarageScreenState extends ConsumerState<VehicleGarageScreen> {
  String? _switchingId;

  Future<void> _switch(Vehicle vehicle) async {
    if (_switchingId != null) {
      return;
    }
    setState(() => _switchingId = vehicle.id);

    final VehicleRepository? repository = ref.read(vehicleRepositoryProvider);
    if (repository == null) {
      if (mounted) {
        setState(() => _switchingId = null);
        AmpSnackbar.show(
          context,
          AmpStrings.vehicleSwitchFailed,
          tone: AmpSnackbarTone.error,
        );
      }
      return;
    }

    final RepositoryResult<List<Vehicle>> result = await repository.setActive(
      vehicle,
    );
    if (!mounted) {
      return;
    }
    setState(() => _switchingId = null);

    final RepositoryFailure<List<Vehicle>>? failure = result.failureOrNull;
    if (failure != null) {
      AmpSnackbar.show(context, failure.message, tone: AmpSnackbarTone.error);
      return;
    }

    ref.invalidate(vehicleGarageProvider);
    ref.invalidate(activeVehicleProvider);
    ref.invalidate(discoveryProvider);
    AmpSnackbar.show(
      context,
      AmpStrings.vehicleSwitched(vehicle.displayName),
      tone: AmpSnackbarTone.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RepositoryResult<List<Vehicle>>> garage = ref.watch(
      vehicleGarageProvider,
    );

    return AmpScaffold(
      title: AmpStrings.vehicleGarageTitle,
      subtitle: AmpStrings.vehicleGarageSubtitle,
      body: garage.when(
        loading: () => const _GarageLoading(),
        error: (Object error, StackTrace stack) => ErrorState(
          message: UserMessages.from(error),
          onRetry: () => ref.invalidate(vehicleGarageProvider),
        ),
        data: (RepositoryResult<List<Vehicle>> result) {
          final RepositoryFailure<List<Vehicle>>? failure =
              result.failureOrNull;
          if (failure != null) {
            return ErrorState(
              message: failure.message,
              onRetry: () => ref.invalidate(vehicleGarageProvider),
            );
          }
          return _GarageBody(
            vehicles: result.valueOrNull!,
            switchingId: _switchingId,
            onSwitch: _switch,
          );
        },
      ),
    );
  }
}

class _GarageBody extends ConsumerWidget {
  const _GarageBody({
    required this.vehicles,
    required this.switchingId,
    required this.onSwitch,
  });

  final List<Vehicle> vehicles;
  final String? switchingId;
  final ValueChanged<Vehicle> onSwitch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // The provider is watched by the screen; waiting for it keeps the
        // platform refresh indicator up until the network answer arrives.
        ref.invalidate(vehicleGarageProvider);
        await ref.read(vehicleGarageProvider.future);
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
          Text(
            AmpStrings.vehicleGarageIntro,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          if (vehicles.isEmpty)
            const _GarageEmpty()
          else ...<Widget>[
            for (final Vehicle vehicle in vehicles) ...<Widget>[
              _GarageCard(
                vehicle: vehicle,
                busy: switchingId == vehicle.id,
                onTap: () => context.push('/vehicles/${vehicle.id}'),
                onSwitch: () => onSwitch(vehicle),
              ),
              const SizedBox(height: AmpTheme.spaceM),
            ],
            AmpButton(
              label: AmpStrings.vehicleAdd,
              onPressed: () => context.push('/vehicles/new'),
            ),
          ],
        ],
      ),
    );
  }
}

class _GarageEmpty extends StatelessWidget {
  const _GarageEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AmpTheme.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Eyebrow(AmpStrings.vehicleGarageTitle),
          const SizedBox(height: AmpTheme.spaceM),
          Text(
            AmpStrings.vehicleEmptyTitle,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.vehicleEmptyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          TextAction(
            AmpStrings.vehicleAdd,
            onPressed: () => context.push('/vehicles/new'),
          ),
        ],
      ),
    );
  }
}

class _GarageCard extends StatelessWidget {
  const _GarageCard({
    required this.vehicle,
    required this.busy,
    required this.onTap,
    required this.onSwitch,
  });

  final Vehicle vehicle;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final String plate = (vehicle.licensePlate ?? '').trim();
    final String connector = AmpFormat.connectorLabel(vehicle.connectorType);
    final String meta = switch ((plate.isEmpty, connector.isEmpty)) {
      (true, true) => AmpStrings.vehicleNoRegistration,
      (true, false) => connector,
      (false, true) => plate,
      (false, false) => AmpStrings.vehicleCardMeta(plate, connector),
    };
    final double capacity = vehicle.effectiveCapacityKwh;
    final double efficiency = vehicle.effectiveEfficiencyKmPerKwh;
    final int range = (capacity * efficiency).round();

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (vehicle.isActive) ...<Widget>[
                          const StatusDotLabel(
                            AmpStrings.vehicleActiveBadge,
                            tone: StatusDotTone.available,
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(vehicle.displayName, style: text.titleLarge),
                        const SizedBox(height: 2),
                        Text(meta, style: text.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: AmpTheme.spaceS),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text('$range', style: AmpType.metric(context, size: 28)),
                      const SizedBox(height: 1),
                      Eyebrow(AmpStrings.km),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AmpTheme.spaceM),
              const Hairline(),
              const SizedBox(height: AmpTheme.spaceS),
              Text(
                AmpStrings.vehicleCardStats(capacity, efficiency, range),
                style: text.bodySmall,
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: AmpTheme.spaceL,
                runSpacing: 0,
                children: <Widget>[
                  TextAction(AmpStrings.vehicleEditTitle, onPressed: onTap),
                  if (!vehicle.isActive)
                    TextAction(
                      AmpStrings.vehicleUseThis,
                      onPressed: busy ? null : onSwitch,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GarageLoading extends StatelessWidget {
  const _GarageLoading();

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
        SkeletonLine(widthFactor: 0.72),
        SizedBox(height: AmpTheme.spaceM),
        SkeletonLine(widthFactor: 0.28, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.58, height: 24),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.42),
        SizedBox(height: 14),
        Hairline(),
        SizedBox(height: 14),
        SkeletonLine(widthFactor: 0.66),
        SizedBox(height: AmpTheme.spaceL),
        SkeletonLine(widthFactor: 0.28, height: 9),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.5, height: 24),
        SizedBox(height: 8),
        SkeletonLine(widthFactor: 0.38),
        SizedBox(height: 14),
        Hairline(),
      ],
    );
  }
}
