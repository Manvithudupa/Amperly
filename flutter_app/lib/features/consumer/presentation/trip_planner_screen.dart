import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/formatting/amp_format.dart';
import '../../../core/location/device_location.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_badge.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_chip.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/timeline_node.dart';
import '../../../data/geoapify/geoapify_client.dart';
import '../../../data/geoapify/geoapify_models.dart';
import '../../../data/geoapify/geoapify_tiles.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/engines/route_planner_engine.dart';
import '../../../domain/policy.dart';
import '../application/discovery_providers.dart';
import '../application/trip_planner_rules.dart';
import '../application/trip_providers.dart';
import 'widgets/trip_route_map.dart';

/// The phone trip planner.
///
/// The map supplies a real road route, but the charger plan comes from the
/// shared [RoutePlannerEngine], so the phone and Android Auto follow the same
/// reserve, corridor and 45 km/h policy. No route plan is saved yet.
class TripPlannerScreen extends ConsumerStatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  ConsumerState<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends ConsumerState<TripPlannerScreen> {
  static const List<double> _corridorOptions = <double>[5, 10, 20];
  static const List<(String, String)> _preferenceOptions = <(String, String)>[
    (RoutePlannerEngine.prefFastest, AmpStrings.tripPrefFastest),
    (RoutePlannerEngine.prefCheapest, AmpStrings.tripPrefCheapest),
    (RoutePlannerEngine.prefReliable, AmpStrings.tripPrefReliable),
    (RoutePlannerEngine.prefShortestDetour, AmpStrings.tripPrefShortest),
  ];
  static const int _directionStepLimit = 6;
  static const int _excludedLimit = 8;

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _batteryController = TextEditingController();
  final FocusNode _destinationFocus = FocusNode();

  Timer? _debounce;
  int _searchToken = 0;
  int _originToken = 0;

  List<GeoPlace> _suggestions = const <GeoPlace>[];
  GeoPlace? _destination;
  String? _destinationError;
  String? _searchMessage;
  bool _searching = false;

  double? _originLat;
  double? _originLng;
  String? _originLabel;
  String? _locationMessage;
  bool _locating = false;
  bool _originLookingUp = false;

  String? _batteryError;
  double _corridorKm = 10;
  String _preference = RoutePlannerEngine.prefFastest;

  DirectionsRoute? _route;
  RoutePlanResult? _plan;
  String? _planError;
  bool _planning = false;
  String? _plannedVehicleId;
  String? _plannedVehicleName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (ref.read(geoapifyMapConfigProvider) == null) {
        return;
      }
      unawaited(_useCurrentLocation());
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _destinationController.dispose();
    _batteryController.dispose();
    _destinationFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GeoapifyMapConfig? mapConfig = ref.watch(geoapifyMapConfigProvider);
    final AsyncValue<RepositoryResult<DiscoveryData>> catalogue = ref.watch(
      discoveryProvider,
    );
    final DiscoveryData? data = catalogue.asData?.value.valueOrNull;

    if (mapConfig == null) {
      return AmpScaffold(
        title: AmpStrings.tripsTitle,
        subtitle: AmpStrings.tripsSubtitle,
        body: _mapSetup(context),
      );
    }

    return AmpScaffold(
      title: AmpStrings.tripsTitle,
      subtitle: AmpStrings.tripsSubtitle,
      body: _form(
        context,
        mapConfig: mapConfig,
        vehicle: data?.vehicle,
        garageLoading: catalogue.isLoading && data == null,
      ),
      bottomBar: AmpButton(
        label: _planning ? AmpStrings.tripPlanning : AmpStrings.tripPlanAction,
        icon: AmpIconName.bolt,
        loading: _planning,
        onPressed: _planning ? null : _planTrip,
      ),
    );
  }

  Widget _mapSetup(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceL,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        Text(AmpStrings.tripMapSetupTitle, style: text.displaySmall),
        const SizedBox(height: AmpTheme.spaceM),
        const _Callout(
          message: AmpStrings.tripMapSetupBody,
          tone: _CalloutTone.warning,
        ),
      ],
    );
  }

  Widget _form(
    BuildContext context, {
    required GeoapifyMapConfig mapConfig,
    required Vehicle? vehicle,
    required bool garageLoading,
  }) {
    final TextTheme text = Theme.of(context).textTheme;
    final AmpColors colors = context.amp;
    final GeoPlace? destination = _destination;
    final bool hasDestinationText = _destinationController.text
        .trim()
        .isNotEmpty;
    final bool vehicleChanged =
        _plan != null && _plannedVehicleId != vehicle?.id;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        _SectionHeader(AmpStrings.tripStartSection),
        TripRouteMap(
          config: mapConfig,
          origin: _originLat == null
              ? null
              : GeoPoint(_originLat!, _originLng!),
          destination: destination == null
              ? null
              : GeoPoint(destination.latitude, destination.longitude),
          routePoints: _route?.points ?? const <GeoPoint>[],
          stops: <TripMapStop>[
            for (final PlannedStop stop
                in _plan?.plannedStops ?? const <PlannedStop>[])
              TripMapStop(
                latitude: stop.station.latitude,
                longitude: stop.station.longitude,
                sequence: stop.sequence,
              ),
            for (final PlannedStop stop
                in _plan?.backups ?? const <PlannedStop>[])
              TripMapStop(
                latitude: stop.station.latitude,
                longitude: stop.station.longitude,
                sequence: stop.sequence,
                backup: true,
              ),
          ],
          onTap: _setOriginFromMap,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        if (_locationMessage != null) ...<Widget>[
          _Callout(message: _locationMessage!, tone: _CalloutTone.warning),
          const SizedBox(height: AmpTheme.spaceS),
        ],
        Row(
          children: <Widget>[
            AmpButton(
              label: AmpStrings.tripUseLocation,
              variant: AmpButtonVariant.tonal,
              icon: AmpIconName.pin,
              expand: false,
              height: 40,
              loading: _locating,
              onPressed: _locating ? null : _useCurrentLocation,
            ),
            const SizedBox(width: AmpTheme.spaceS),
            Expanded(child: Text(_originSummary, style: text.bodySmall)),
          ],
        ),
        _SectionHeader(AmpStrings.tripDestinationSection),
        AmpField(
          controller: _destinationController,
          focusNode: _destinationFocus,
          hint: AmpStrings.tripDestinationHint,
          prefixIcon: AmpIconName.search,
          textInputAction: TextInputAction.search,
          errorText: _destinationError,
          onChanged: _onDestinationChanged,
          onSubmitted: (String value) => _resolveTypedDestination(),
          suffix: hasDestinationText
              ? IconButton(
                  tooltip: AmpStrings.close,
                  onPressed: _clearDestination,
                  icon: AmpIcon(
                    AmpIconName.close,
                    size: 18,
                    color: colors.inkSecondary,
                  ),
                )
              : null,
        ),
        if (_searching)
          Padding(
            padding: const EdgeInsets.only(top: AmpTheme.spaceS),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AmpTheme.spaceS),
                Text(AmpStrings.tripSearching, style: text.bodySmall),
              ],
            ),
          )
        else if (_suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AmpTheme.spaceS),
            child: Material(
              color: colors.surface,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AmpTheme.radiusField),
                side: BorderSide(color: colors.divider),
              ),
              child: Column(
                children: <Widget>[
                  for (int index = 0; index < _suggestions.length; index++)
                    _suggestionRow(
                      context,
                      _suggestions[index],
                      showDivider: index > 0,
                    ),
                ],
              ),
            ),
          )
        else if (_searchMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: AmpTheme.spaceS),
            child: Text(_searchMessage!, style: text.bodySmall),
          ),
        if (destination != null)
          Padding(
            padding: const EdgeInsets.only(top: AmpTheme.spaceS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AmpIcon(AmpIconName.check, size: 16, color: colors.available),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AmpStrings.tripDestinationResolved(
                      _placeLabel(destination),
                    ),
                    style: text.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        _SectionHeader(AmpStrings.tripBatterySection),
        AmpField(
          controller: _batteryController,
          label: AmpStrings.tripBatteryLabel,
          helper: AmpStrings.tripBatteryHelper,
          errorText: _batteryError,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: _onBatteryChanged,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        _vehicleCard(context, vehicle, garageLoading),
        _SectionHeader(AmpStrings.tripPreferencesTitle),
        Text(AmpStrings.tripCorridorLabel, style: text.labelLarge),
        const SizedBox(height: AmpTheme.spaceS),
        Wrap(
          spacing: AmpTheme.spaceS,
          runSpacing: AmpTheme.spaceS,
          children: <Widget>[
            for (final double option in _corridorOptions)
              AmpChip(
                label: AmpStrings.tripCorridorOption(option.round()),
                selected: _corridorKm == option,
                onTap: () => _selectCorridor(option),
              ),
          ],
        ),
        const SizedBox(height: AmpTheme.spaceM),
        Text(AmpStrings.tripPreferenceLabel, style: text.labelLarge),
        const SizedBox(height: AmpTheme.spaceS),
        Wrap(
          spacing: AmpTheme.spaceS,
          runSpacing: AmpTheme.spaceS,
          children: <Widget>[
            for (final (String value, String label) in _preferenceOptions)
              AmpChip(
                label: label,
                selected: _preference == value,
                onTap: () => _selectPreference(value),
              ),
          ],
        ),
        if (_planError != null) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          _Callout(message: _planError!, tone: _CalloutTone.error),
        ],
        if (_plan != null)
          ..._buildResult(
            context,
            _plan!,
            vehicle,
            vehicleChanged: vehicleChanged,
          ),
      ],
    );
  }

  String get _originSummary {
    if (_locating) {
      return AmpStrings.tripLocating;
    }
    if (_originLat == null) {
      return AmpStrings.tripMapNeedsLocation;
    }
    if (_originLookingUp) {
      return AmpStrings.tripAddressLookup;
    }
    return _originLabel ?? AmpStrings.tripMapPin;
  }

  Widget _suggestionRow(
    BuildContext context,
    GeoPlace place, {
    required bool showDivider,
  }) {
    final TextTheme text = Theme.of(context).textTheme;
    final AmpColors colors = context.amp;
    final String label = _placeLabel(place);
    final String address = place.address.trim();

    return Column(
      children: <Widget>[
        if (showDivider) const Divider(height: 1),
        InkWell(
          onTap: () => _chooseDestination(place),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AmpTheme.spaceM,
              vertical: 10,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AmpIcon(
                  AmpIconName.search,
                  size: 17,
                  color: colors.inkSecondary,
                ),
                const SizedBox(width: AmpTheme.spaceS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(label, style: text.titleSmall),
                      if (address.isNotEmpty && address != label) ...<Widget>[
                        const SizedBox(height: 2),
                        Text(address, style: text.bodySmall),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _vehicleCard(
    BuildContext context,
    Vehicle? vehicle,
    bool garageLoading,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    final AmpColors colors = context.amp;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
                    Text(
                      AmpStrings.tripVehiclePlanningFor,
                      style: text.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    if (garageLoading)
                      Semantics(
                        label: AmpStrings.tripLoadingVehicle,
                        child: const SkeletonLine(widthFactor: 0.55),
                      )
                    else
                      Text(_vehicleName(vehicle), style: text.titleSmall),
                  ],
                ),
              ),
            ],
          ),
          if (!garageLoading && vehicle == null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            Text(AmpStrings.tripNoVehicle, style: text.bodySmall),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push('/vehicles'),
              child: const Text(AmpStrings.tripManageVehicles),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResult(
    BuildContext context,
    RoutePlanResult plan,
    Vehicle? vehicle, {
    required bool vehicleChanged,
  }) {
    final TextTheme text = Theme.of(context).textTheme;
    final DirectionsRoute? route = _route;

    return <Widget>[
      const SizedBox(height: AmpTheme.spaceL),
      if (vehicleChanged && _plannedVehicleName != null) ...<Widget>[
        _Callout(
          message: AmpStrings.tripVehicleChanged(
            _plannedVehicleName!,
            _vehicleName(vehicle),
          ),
          tone: _CalloutTone.warning,
        ),
        const SizedBox(height: AmpTheme.spaceM),
      ],
      _summaryCard(context, plan, vehicle),
      if (plan.noStopWarning != null) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceM),
        _Callout(
          title: AmpStrings.tripNoSafeTitle,
          message: plan.noStopWarning!,
          tone: _CalloutTone.warning,
          action: _corridorKm < _corridorOptions.last
              ? AmpButton(
                  label: AmpStrings.tripWiderSearch,
                  variant: AmpButtonVariant.tonal,
                  expand: false,
                  height: 40,
                  onPressed: _widenCorridor,
                )
              : null,
        ),
      ] else if (plan.plannedStops.isEmpty) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceM),
        const _Callout(
          message: AmpStrings.tripNoChargingStops,
          tone: _CalloutTone.success,
        ),
      ],
      if (plan.plannedStops.isNotEmpty) ...<Widget>[
        _SectionHeader(AmpStrings.tripStopsTitle),
        _timeline(context, plan),
      ],
      _SectionHeader(AmpStrings.tripBackupsTitle),
      if (plan.backups.isEmpty)
        Text(AmpStrings.tripNoBackups, style: text.bodySmall)
      else
        for (final PlannedStop stop in plan.backups) ...<Widget>[
          _backupCard(context, stop),
          const SizedBox(height: AmpTheme.spaceS),
        ],
      if (route != null) ...<Widget>[
        _SectionHeader(AmpStrings.tripDirectionsTitle),
        Text(
          AmpStrings.tripDirectionsMeta(
            AmpStrings.tripRouteProvider,
            AmpFormat.km(route.distanceKm),
            AmpFormat.duration(
              Duration(minutes: route.effectiveDurationMinutes),
            ),
          ),
          style: text.bodySmall,
        ),
        const SizedBox(height: AmpTheme.spaceS),
        for (
          int index = 0;
          index < route.steps.length && index < _directionStepLimit;
          index++
        )
          _directionStep(context, route.steps[index], index + 1),
        if (route.steps.length > _directionStepLimit)
          Padding(
            padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
            child: Text(
              AmpStrings.tripMoreSteps(
                route.steps.length - _directionStepLimit,
              ),
              style: text.bodySmall,
            ),
          ),
        Text(AmpStrings.tripDirectionsNote, style: text.bodySmall),
      ],
      _SectionHeader(AmpStrings.tripAssumptionsTitle),
      for (final String assumption in plan.assumptions)
        Padding(
          padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('•', style: text.bodySmall),
              const SizedBox(width: AmpTheme.spaceS),
              Expanded(child: Text(assumption, style: text.bodySmall)),
            ],
          ),
        ),
      if (plan.excluded.isNotEmpty) ...<Widget>[
        _SectionHeader(AmpStrings.tripExcludedTitle),
        for (final ExcludedStation excluded in plan.excluded.take(
          _excludedLimit,
        ))
          Padding(
            padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_stationName(excluded.station), style: text.titleSmall),
                const SizedBox(height: 2),
                Text(excluded.reason, style: text.bodySmall),
              ],
            ),
          ),
      ],
    ];
  }

  Widget _summaryCard(
    BuildContext context,
    RoutePlanResult plan,
    Vehicle? vehicle,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    final AmpColors colors = context.amp;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AmpStrings.tripTotalJourney, style: text.labelLarge),
          Text(
            AmpFormat.duration(Duration(minutes: plan.totalJourneyMinutes)),
            style: AmpType.metric(context, size: 34),
          ),
          const SizedBox(height: 2),
          Text(
            AmpStrings.tripSummary(
              AmpFormat.km(plan.totalDistanceKm),
              AmpFormat.duration(Duration(minutes: plan.driveMinutes)),
              AmpFormat.duration(Duration(minutes: plan.chargingMinutes)),
              AmpFormat.duration(Duration(minutes: plan.totalJourneyMinutes)),
            ),
            style: text.bodySmall,
          ),
          const SizedBox(height: AmpTheme.spaceM),
          AmpBadge(
            AmpStrings.tripConfidenceLabel(plan.confidence),
            tone: _confidenceTone(plan.confidence),
            icon: AmpIconName.shield,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(
            AmpStrings.tripConfidenceLine(
              AmpStrings.tripConfidenceLabel(plan.confidence),
              plan.corridorKm.round(),
              plan.candidates.length,
              plan.excluded.length,
            ),
            style: text.labelLarge,
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Row(
            children: <Widget>[
              AmpIcon(AmpIconName.bolt, size: 15, color: colors.inkSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(_vehicleName(vehicle), style: text.labelLarge),
              ),
            ],
          ),
          const SizedBox(height: AmpTheme.spaceS),
          Text(AmpStrings.tripEstimateNotice, style: text.bodySmall),
        ],
      ),
    );
  }

  Widget _timeline(BuildContext context, RoutePlanResult plan) {
    return Column(
      children: <Widget>[
        TimelineNode(
          kind: TimelineNodeKind.start,
          isFirst: true,
          title: plan.origin,
          subtitle: AmpStrings.journeyStart,
          detail: AmpStrings.tripDepartSoc(plan.startSoc),
        ),
        for (int index = 0; index < plan.plannedStops.length; index++)
          _stopNode(context, plan.plannedStops[index], isFirstStop: index == 0),
        TimelineNode(
          kind: TimelineNodeKind.arrival,
          isLast: true,
          title: plan.destination,
          subtitle: AmpStrings.journeyArrival,
          detail: AmpStrings.tripArrivalReserve(plan.arrivalTargetSoc),
        ),
      ],
    );
  }

  Widget _stopNode(
    BuildContext context,
    PlannedStop stop, {
    required bool isFirstStop,
  }) {
    final ChargerStation station = stop.station;
    return TimelineNode(
      kind: TimelineNodeKind.chargingStop,
      title: _stationName(station),
      subtitle: _stationAddress(station),
      trailing: isFirstStop
          ? const AmpBadge(
              AmpStrings.tripRecommendedStop,
              tone: AmpBadgeTone.success,
              icon: AmpIconName.check,
            )
          : null,
      detail:
          '${AmpStrings.tripStopDetail(AmpFormat.km(stop.distanceAlongRouteKm), AmpFormat.km(stop.detourKm), stop.detourMinutes, stop.chargingMinutes)}\n'
          '${AmpStrings.tripStopSoc(stop.arrivalSoc, stop.departureSoc)}',
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => context.push('/chargers/${station.id}'),
          child: const Text(AmpStrings.tripViewCharger),
        ),
      ),
    );
  }

  Widget _backupCard(BuildContext context, PlannedStop stop) {
    final TextTheme text = Theme.of(context).textTheme;
    final AmpColors colors = context.amp;
    final ChargerStation station = stop.station;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(_stationName(station), style: text.titleSmall),
              ),
              const SizedBox(width: AmpTheme.spaceS),
              const AmpBadge(AmpStrings.journeyBackup),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AmpStrings.tripStopDetail(
              AmpFormat.km(stop.distanceAlongRouteKm),
              AmpFormat.km(stop.detourKm),
              stop.detourMinutes,
              stop.chargingMinutes,
            ),
            style: text.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            AmpStrings.tripStopSoc(stop.arrivalSoc, stop.departureSoc),
            style: text.bodySmall,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push('/chargers/${station.id}'),
              child: const Text(AmpStrings.tripViewCharger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionStep(BuildContext context, RouteStep step, int number) {
    final TextTheme text = Theme.of(context).textTheme;
    final List<String> meta = <String>[
      if (step.distanceText.trim().isNotEmpty) step.distanceText.trim(),
      if (step.durationText.trim().isNotEmpty) step.durationText.trim(),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 22, child: Text('$number.', style: text.labelLarge)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(step.instruction, style: text.bodyMedium),
                if (meta.isNotEmpty)
                  Text(meta.join(' · '), style: text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    if (_locating) {
      return;
    }
    setState(() {
      _locating = true;
      _locationMessage = null;
    });

    final DeviceLocationFix fix = await ref
        .read(deviceLocationServiceProvider)
        .current();
    if (!mounted) {
      return;
    }

    if (!fix.hasPosition) {
      setState(() {
        _locating = false;
        _locationMessage = switch (fix.status) {
          DeviceLocationStatus.permissionDenied =>
            AmpStrings.tripLocationPermission,
          DeviceLocationStatus.servicesDisabled =>
            AmpStrings.tripLocationServices,
          DeviceLocationStatus.unavailable ||
          DeviceLocationStatus.found => AmpStrings.tripLocationUnavailable,
        };
      });
      return;
    }

    setState(() {
      _locating = false;
      _locationMessage = null;
      _originLat = fix.latitude;
      _originLng = fix.longitude;
      _originLabel = AmpStrings.tripCurrentLocation;
      _originLookingUp = true;
      _clearPlan();
    });
    await _lookupOriginAddress(fix.latitude, fix.longitude, fromGps: true);
  }

  void _setOriginFromMap(LatLng point) {
    setState(() {
      _originLat = point.latitude;
      _originLng = point.longitude;
      _originLabel = AmpStrings.tripMapPin;
      _originLookingUp = true;
      _locationMessage = null;
      _clearPlan();
    });
    unawaited(
      _lookupOriginAddress(point.latitude, point.longitude, fromGps: false),
    );
  }

  Future<void> _lookupOriginAddress(
    double latitude,
    double longitude, {
    required bool fromGps,
  }) async {
    final GeoapifyClient? client = ref.read(geoapifyClientProvider);
    final int token = ++_originToken;
    if (client == null) {
      if (mounted) {
        setState(() => _originLookingUp = false);
      }
      return;
    }

    final RepositoryResult<String> result = await client.reverse(
      latitude,
      longitude,
    );
    if (!mounted || token != _originToken) {
      return;
    }

    final String? address = result.valueOrNull;
    setState(() {
      _originLookingUp = false;
      if (address != null && address.trim().isNotEmpty) {
        _originLabel = address.trim();
      } else {
        _originLabel = fromGps ? AmpStrings.tripGpsOnly : AmpStrings.tripMapPin;
      }
    });
  }

  void _onDestinationChanged(String value) {
    _debounce?.cancel();
    final int token = ++_searchToken;
    setState(() {
      _destination = null;
      _suggestions = const <GeoPlace>[];
      _searching = false;
      _searchMessage = null;
      _destinationError = null;
      _clearPlan();
    });

    final GeoapifyClient? client = ref.read(geoapifyClientProvider);
    final String query = value.trim();
    if (client == null || query.length < AmpPolicy.searchMinimumCharacters) {
      return;
    }

    _debounce = Timer(
      Duration(milliseconds: AmpPolicy.searchDebounceMs),
      () async {
        if (!mounted || token != _searchToken) {
          return;
        }
        setState(() => _searching = true);
        final RepositoryResult<List<GeoPlace>> result = await client
            .autocomplete(query, biasLat: _originLat, biasLng: _originLng);
        if (!mounted || token != _searchToken) {
          return;
        }
        final RepositoryFailure<List<GeoPlace>>? failure = result.failureOrNull;
        final List<GeoPlace> places = result.valueOrNull ?? const <GeoPlace>[];
        setState(() {
          _searching = false;
          _suggestions = failure == null ? places : const <GeoPlace>[];
          _searchMessage = failure != null
              ? AmpStrings.tripSearchFailed
              : places.isEmpty
              ? AmpStrings.errorNoResults
              : null;
        });
      },
    );
  }

  Future<void> _resolveTypedDestination() async {
    final GeoapifyClient? client = ref.read(geoapifyClientProvider);
    final String query = _destinationController.text.trim();
    if (client == null || query.length < AmpPolicy.searchMinimumCharacters) {
      return;
    }

    _debounce?.cancel();
    final int token = ++_searchToken;
    setState(() {
      _searching = true;
      _searchMessage = null;
    });

    final RepositoryResult<GeoPlace> result = await client.forward(
      query,
      biasLat: _originLat,
      biasLng: _originLng,
    );
    if (!mounted || token != _searchToken) {
      return;
    }

    final GeoPlace? place = result.valueOrNull;
    if (place == null) {
      setState(() {
        _searching = false;
        _searchMessage = AmpStrings.errorNoResults;
      });
      return;
    }
    _chooseDestination(place);
  }

  void _chooseDestination(GeoPlace place) {
    _debounce?.cancel();
    _searchToken++;
    FocusScope.of(context).unfocus();
    final String label = _placeLabel(place);
    setState(() {
      _destination = place;
      _destinationController.text = label;
      _destinationController.selection = TextSelection.collapsed(
        offset: label.length,
      );
      _suggestions = const <GeoPlace>[];
      _searching = false;
      _searchMessage = null;
      _destinationError = null;
      _clearPlan();
    });
  }

  void _clearDestination() {
    _debounce?.cancel();
    _searchToken++;
    setState(() {
      _destinationController.clear();
      _destination = null;
      _suggestions = const <GeoPlace>[];
      _searching = false;
      _searchMessage = null;
      _destinationError = null;
      _clearPlan();
    });
  }

  void _onBatteryChanged(String value) {
    setState(() {
      _batteryError = null;
      _clearPlan();
    });
  }

  void _selectCorridor(double value) {
    if (_corridorKm == value) {
      return;
    }
    setState(() {
      _corridorKm = value;
      _clearPlan();
    });
  }

  void _selectPreference(String value) {
    if (_preference == value) {
      return;
    }
    setState(() {
      _preference = value;
      _clearPlan();
    });
  }

  void _widenCorridor() {
    final int index = _corridorOptions.indexOf(_corridorKm);
    if (index < 0 || index >= _corridorOptions.length - 1) {
      return;
    }
    _selectCorridor(_corridorOptions[index + 1]);
  }

  void _clearPlan() {
    _plan = null;
    _route = null;
    _planError = null;
    _plannedVehicleId = null;
    _plannedVehicleName = null;
  }

  Future<void> _planTrip() async {
    final GeoapifyClient? client = ref.read(geoapifyClientProvider);
    if (client == null) {
      setState(() => _planError = AmpStrings.tripMapSetupBody);
      return;
    }

    FocusScope.of(context).unfocus();
    final String destinationText = _destinationController.text.trim();
    final String? destinationError = TripPlannerRules.destinationError(
      destinationText,
      resolved: _destination != null,
    );
    final String? batteryError = TripPlannerRules.startSocError(
      _batteryController.text,
    );
    final bool missingOrigin = _originLat == null || _originLng == null;

    setState(() {
      _destinationError = destinationError;
      _batteryError = batteryError;
      _planError = missingOrigin ? AmpStrings.tripNeedsOrigin : null;
    });
    if (missingOrigin || destinationError != null || batteryError != null) {
      return;
    }

    final int startSoc = int.parse(_batteryController.text.trim());
    final double originLat = _originLat!;
    final double originLng = _originLng!;

    setState(() {
      _planning = true;
      _planError = null;
    });

    try {
      GeoPlace? selected = _destination;
      if (selected == null) {
        final RepositoryResult<GeoPlace> resolved = await client.forward(
          destinationText,
          biasLat: originLat,
          biasLng: originLng,
        );
        if (!mounted) {
          return;
        }
        final GeoPlace? place = resolved.valueOrNull;
        if (place == null) {
          setState(() {
            _planning = false;
            _planError = AmpStrings.tripRouteFailed;
          });
          return;
        }
        selected = place;
        final String label = _placeLabel(place);
        setState(() {
          _destination = place;
          _destinationController.text = label;
          _destinationController.selection = TextSelection.collapsed(
            offset: label.length,
          );
          _suggestions = const <GeoPlace>[];
          _searchMessage = null;
          _destinationError = null;
        });
      }
      final GeoPlace destination = selected;

      final RepositoryResult<DiscoveryData> catalogue = await ref.read(
        discoveryProvider.future,
      );
      if (!mounted) {
        return;
      }
      final RepositoryFailure<DiscoveryData>? catalogueFailure =
          catalogue.failureOrNull;
      if (catalogueFailure != null) {
        setState(() {
          _planning = false;
          _planError = catalogueFailure.message;
        });
        return;
      }
      final DiscoveryData data = catalogue.valueOrNull!;

      final RepositoryResult<DirectionsRoute> routed = await client.route(
        mode: TravelMode.driving,
        fromLat: originLat,
        fromLng: originLng,
        toLat: destination.latitude,
        toLng: destination.longitude,
      );
      if (!mounted) {
        return;
      }
      final DirectionsRoute? route = routed.valueOrNull;
      if (route == null || route.points.length < 2) {
        setState(() {
          _planning = false;
          _planError = AmpStrings.tripRouteFailed;
        });
        return;
      }

      final RoutePlanResult plan = RoutePlannerEngine.planRoute(
        origin: _originLabel ?? AmpStrings.tripMapPin,
        destination: _placeLabel(destination),
        originLat: originLat,
        originLng: originLng,
        destinationLat: destination.latitude,
        destinationLng: destination.longitude,
        totalDistanceKm: route.distanceKm,
        corridorKm: _corridorKm,
        startSoc: startSoc,
        socIsAuthoritative: true,
        socEstimatedFromProfile: false,
        preference: _preference,
        vehicle: data.vehicle,
        stations: data.entries
            .map((entry) => entry.station)
            .toList(growable: false),
        measuredDriveMinutes: route.effectiveDurationMinutes,
      );

      setState(() {
        _planning = false;
        _route = route;
        _plan = plan;
        _planError = null;
        _plannedVehicleId = data.vehicle?.id;
        _plannedVehicleName = _vehicleName(data.vehicle);
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _planning = false;
        _planError = AmpStrings.tripPlanFailed;
      });
    }
  }

  AmpBadgeTone _confidenceTone(String confidence) {
    return switch (confidence.trim().toUpperCase()) {
      RoutePlannerEngine.confidenceHigh => AmpBadgeTone.success,
      RoutePlannerEngine.confidenceMedium => AmpBadgeTone.info,
      _ => AmpBadgeTone.warning,
    };
  }

  String _vehicleName(Vehicle? vehicle) {
    if (vehicle == null) {
      return AmpStrings.tripDefaultVehicle;
    }
    final String name = vehicle.displayName.trim();
    return name.isEmpty ? AmpStrings.tripDefaultVehicle : name;
  }

  String _placeLabel(GeoPlace place) {
    final String label = place.label.trim();
    return label.isEmpty ? place.address.trim() : label;
  }

  String _stationName(ChargerStation station) {
    final String name = (station.name ?? '').trim();
    return name.isEmpty ? AmpStrings.unnamedCharger : name;
  }

  String? _stationAddress(ChargerStation station) {
    final String address = (station.address ?? '').trim();
    return address.isEmpty ? null : address;
  }
}

enum _CalloutTone { info, warning, success, error }

class _Callout extends StatelessWidget {
  const _Callout({
    required this.message,
    this.title,
    this.tone = _CalloutTone.info,
    this.action,
  });

  final String message;
  final String? title;
  final _CalloutTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final TextTheme text = Theme.of(context).textTheme;
    final (
      Color background,
      Color foreground,
      AmpIconName icon,
    ) = switch (tone) {
      _CalloutTone.info => (colors.infoTint, colors.info, AmpIconName.info),
      _CalloutTone.warning => (
        colors.busyTint,
        colors.busyInk,
        AmpIconName.alert,
      ),
      _CalloutTone.success => (
        colors.availableTint,
        colors.available,
        AmpIconName.check,
      ),
      _CalloutTone.error => (colors.errorTint, colors.error, AmpIconName.alert),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: foreground.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AmpIcon(icon, size: 18, color: foreground),
              const SizedBox(width: AmpTheme.spaceS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (title != null) ...<Widget>[
                      Text(
                        title!,
                        style: text.titleSmall?.copyWith(color: foreground),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      message,
                      style: text.bodySmall?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            action!,
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

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
