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
import '../../../core/location/location_flow.dart';
import '../../../core/ui/input_formatters.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_field.dart';
import '../../../core/widgets/amp_icon.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/amp_snackbar.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/milestone_line.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_dot_label.dart';
import '../../../core/widgets/text_action.dart';
import '../../../core/widgets/text_filter_row.dart';
import '../../../core/widgets/unsaved_changes_guard.dart';
import '../../../data/geoapify/geoapify_client.dart';
import '../../../data/geoapify/geoapify_models.dart';
import '../../../data/geoapify/geoapify_tiles.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/journey_repository.dart';
import '../../../data/repositories/repository_result.dart';
import '../../../domain/engines/route_planner_engine.dart';
import '../../../domain/policy.dart';
import '../../auth/application/profile_providers.dart';
import '../application/battery_providers.dart';
import '../application/discovery_providers.dart';
import '../application/journey_mapper.dart';
import '../application/journey_providers.dart';
import '../application/trip_planner_rules.dart';
import '../application/trip_providers.dart';
import 'navigation_screen.dart';
import 'widgets/saved_trip_card.dart';
import 'widgets/trip_route_map.dart';

/// The phone trip planner.
///
/// The map supplies a real road route, but the charger plan comes from the
/// shared [RoutePlannerEngine], so the phone and Android Auto follow the same
/// reserve, corridor and 45 km/h policy. A completed plan is written to the
/// shared route tables so the car can read it after the app restarts.
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
  bool _locationNeedsSettings = false;
  bool _locating = false;
  bool _originLookingUp = false;
  bool _dirty = false;

  String? _batteryError;
  double _corridorKm = 10;
  String _preference = RoutePlannerEngine.prefFastest;

  DirectionsRoute? _route;
  RoutePlanResult? _plan;
  String? _planError;
  String? _saveWarning;
  bool _planning = false;
  String? _plannedVehicleId;
  String? _plannedVehicleName;
  bool _showPlanningDetails = false;
  bool _lastDestinationLoaded = false;

  @override
  void initState() {
    super.initState();
    final int? storedBattery = ref.read(batterySocProvider);
    if (storedBattery != null) {
      _batteryController.text = '$storedBattery';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_prefillLastDestination());
      if (ref.read(geoapifyMapConfigProvider) == null) {
        return;
      }
      unawaited(_useCurrentLocation(explainFirst: false));
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
    final SavedJourney? savedJourney = ref
        .watch(savedJourneyProvider)
        .asData
        ?.value
        .valueOrNull;

    if (mapConfig == null) {
      return AmpScaffold(
        title: AmpStrings.tripsTitle,
        subtitle: AmpStrings.tripsSubtitle,
        body: _mapSetup(context),
      );
    }

    return AmpUnsavedChangesGuard(
      hasUnsavedChanges: _dirty,
      onDiscard: () {
        if (mounted) {
          context.go('/home');
        }
      },
      child: AmpScaffold(
        title: AmpStrings.tripsTitle,
        subtitle: AmpStrings.tripsSubtitle,
        body: _form(
          context,
          mapConfig: mapConfig,
          vehicle: data?.vehicle,
          garageLoading: catalogue.isLoading && data == null,
          savedJourney: savedJourney,
        ),
        bottomBar: AmpButton(
          label: _planning
              ? AmpStrings.tripPlanning
              : AmpStrings.tripPlanAction,
          loading: _planning,
          onPressed: _planning ? null : _planTrip,
        ),
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
    required SavedJourney? savedJourney,
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
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
        AmpTheme.screenPadding,
        AmpTheme.spaceM,
        AmpTheme.screenPadding,
        AmpTheme.spaceXxl,
      ),
      children: <Widget>[
        if (_plan == null && savedJourney != null) ...<Widget>[
          SavedTripCard(
            journey: savedJourney,
            onResume: () => _resumeSavedTrip(savedJourney),
          ),
        ],
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
          _Callout(
            message: _locationMessage!,
            tone: _CalloutTone.warning,
            action: _locationNeedsSettings
                ? TextAction(
                    AmpStrings.locationPermissionOpenSettings,
                    onPressed: _openLocationSettings,
                  )
                : null,
          ),
          const SizedBox(height: AmpTheme.spaceS),
        ],
        Row(
          children: <Widget>[
            TextAction(
              AmpStrings.tripUseLocation,
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
          maxLength: 120,
          errorText: _destinationError,
          validator: (String? value) {
            final String text = (value ?? '').trim();
            return text.isNotEmpty && _destination == null
                ? AmpStrings.tripDestinationRequired
                : null;
          },
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
            child: Text(AmpStrings.tripSearching, style: text.bodySmall),
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
          textInputAction: TextInputAction.done,
          inputFormatters: <TextInputFormatter>[AmpInputFormatters.digits],
          maxLength: 3,
          validator: TripPlannerRules.startSocError,
          onChanged: _onBatteryChanged,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: AmpTheme.spaceM),
        _vehicleCard(context, vehicle, garageLoading),
        _SectionHeader(AmpStrings.tripPreferencesTitle),
        Eyebrow(AmpStrings.tripCorridorLabel),
        const SizedBox(height: 2),
        TextFilterRow<double>(
          options: <TextFilterOption<double>>[
            for (final double option in _corridorOptions)
              TextFilterOption<double>(
                value: option,
                label: AmpStrings.tripCorridorOption(option.round()),
              ),
          ],
          selected: _corridorKm,
          onSelected: _selectCorridor,
        ),
        const SizedBox(height: AmpTheme.spaceM),
        Eyebrow(AmpStrings.tripPreferenceLabel),
        const SizedBox(height: 2),
        TextFilterRow<String>(
          options: <TextFilterOption<String>>[
            for (final (String value, String label) in _preferenceOptions)
              TextFilterOption<String>(value: value, label: label),
          ],
          selected: _preference,
          onSelected: _selectPreference,
        ),
        if (_planError != null) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          _Callout(message: _planError!, tone: _CalloutTone.error),
        ],
        if (_saveWarning != null) ...<Widget>[
          const SizedBox(height: AmpTheme.spaceM),
          _Callout(message: _saveWarning!, tone: _CalloutTone.warning),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Eyebrow(AmpStrings.tripVehiclePlanningFor),
              const SizedBox(height: 3),
              if (garageLoading)
                Semantics(
                  label: AmpStrings.tripLoadingVehicle,
                  child: const SkeletonLine(widthFactor: 0.55),
                )
              else
                Text(_vehicleName(vehicle), style: text.titleSmall),
              if (!garageLoading && vehicle == null) ...<Widget>[
                const SizedBox(height: 4),
                Text(AmpStrings.tripNoVehicle, style: text.bodySmall),
              ],
              const SizedBox(height: 2),
              TextAction(
                AmpStrings.tripManageVehicles,
                onPressed: () => context.push('/vehicles'),
              ),
            ],
          ),
        ),
        const Hairline(),
      ],
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
      if (route != null) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceM),
        AmpButton(
          label: AmpStrings.tripStartNavigation,
          icon: AmpIconName.pin,
          variant: AmpButtonVariant.tonal,
          onPressed: () => _startNavigation(plan, route),
        ),
      ],
      if (plan.noStopWarning != null) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceM),
        _Callout(
          title: AmpStrings.tripNoSafeTitle,
          message: plan.noStopWarning!,
          tone: _CalloutTone.warning,
          action: _corridorKm < _corridorOptions.last
              ? TextAction(
                  AmpStrings.tripWiderSearch,
                  onPressed: _widenCorridor,
                )
              : null,
        ),
      ] else if (plan.plannedStops.isEmpty) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceM),
        Text(AmpStrings.tripNoChargingStops, style: text.bodySmall),
      ],
      const SizedBox(height: AmpTheme.spaceM),
      Eyebrow(AmpStrings.tripRoadTitle),
      const SizedBox(height: AmpTheme.spaceM),
      _timeline(context, plan),
      const SizedBox(height: AmpTheme.spaceM),
      const Hairline(),
      Align(
        alignment: Alignment.centerLeft,
        child: TextAction(
          _showPlanningDetails
              ? AmpStrings.tripHideDetails
              : AmpStrings.tripHowWeGotThis,
          onPressed: () =>
              setState(() => _showPlanningDetails = !_showPlanningDetails),
          underline: false,
        ),
      ),
      if (_showPlanningDetails) ..._planningDetails(context, plan, route),
    ];
  }

  void _startNavigation(RoutePlanResult plan, DirectionsRoute route) {
    context.push(
      '/navigation',
      extra: NavigationTrip(
        label: plan.destination,
        route: route,
        stops: <NavigationStop>[
          for (final PlannedStop stop in plan.plannedStops)
            NavigationStop(
              sequence: stop.sequence,
              name: _stationName(stop.station),
              latitude: stop.station.latitude,
              longitude: stop.station.longitude,
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    BuildContext context,
    RoutePlanResult plan,
    Vehicle? vehicle,
  ) {
    final TextTheme text = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AmpTheme.spaceM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BigNumber(
                value: '${plan.totalJourneyMinutes}',
                unit: AmpStrings.tripJourneyUnit,
                label: AmpStrings.tripTotalJourney,
                size: 54,
              ),
              const SizedBox(height: 8),
              Text(
                AmpStrings.tripSummary(
                  AmpFormat.km(plan.totalDistanceKm),
                  AmpFormat.duration(Duration(minutes: plan.driveMinutes)),
                  AmpFormat.duration(Duration(minutes: plan.chargingMinutes)),
                  AmpFormat.duration(
                    Duration(minutes: plan.totalJourneyMinutes),
                  ),
                ),
                style: text.bodySmall,
              ),
              const SizedBox(height: AmpTheme.spaceM),
              StatusDotLabel(
                AmpStrings.tripConfidenceLabel(plan.confidence),
                detail: '${plan.candidates.length} chargers considered',
                tone: _confidenceTone(plan.confidence),
              ),
              const SizedBox(height: 6),
              Text(
                AmpStrings.tripConfidenceLine(
                  AmpStrings.tripConfidenceLabel(plan.confidence),
                  plan.corridorKm.round(),
                  plan.candidates.length,
                  plan.excluded.length,
                ),
                style: text.bodySmall,
              ),
              const SizedBox(height: AmpTheme.spaceS),
              Text(
                '${AmpStrings.tripVehiclePlanningFor} · '
                '${_vehicleName(vehicle)}',
                style: text.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(AmpStrings.tripEstimateNotice, style: text.bodySmall),
            ],
          ),
        ),
        const Hairline(),
      ],
    );
  }

  Widget _timeline(BuildContext context, RoutePlanResult plan) {
    final List<PlannedStop> markers =
        <PlannedStop>[...plan.plannedStops, ...plan.backups]..sort(
          (PlannedStop a, PlannedStop b) =>
              a.distanceAlongRouteKm.compareTo(b.distanceAlongRouteKm),
        );
    final List<MilestoneStop> stops = <MilestoneStop>[
      MilestoneStop(
        distanceKm: 0,
        title: plan.origin,
        detail: AmpStrings.journeyStart,
        batteryPercent: plan.startSoc,
      ),
      for (final PlannedStop stop in markers) _milestone(stop),
      MilestoneStop(
        distanceKm: plan.totalDistanceKm,
        title: plan.destination,
        detail: AmpStrings.journeyArrival,
        batteryPercent: plan.arrivalTargetSoc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MilestoneLine(stops: stops, animate: true),
        if (markers.isNotEmpty) ...<Widget>[
          const SizedBox(height: 4),
          Wrap(
            spacing: AmpTheme.spaceL,
            runSpacing: 0,
            children: <Widget>[
              for (final PlannedStop stop in markers)
                TextAction(
                  '${AmpStrings.tripViewCharger} · '
                  '${_stationName(stop.station)}',
                  onPressed: () => context.push('/chargers/${stop.station.id}'),
                ),
            ],
          ),
        ],
      ],
    );
  }

  MilestoneStop _milestone(PlannedStop stop) {
    final String? address = _stationAddress(stop.station);
    final String soc = AmpStrings.tripStopSoc(
      stop.arrivalSoc,
      stop.departureSoc,
    );
    final String detail = stop.backup
        ? '${AmpStrings.journeyBackup} · $soc'
        : '$soc · ${stop.chargingMinutes} min · '
              '${AmpFormat.rupees(stop.estimatedCost)}';
    return MilestoneStop(
      distanceKm: stop.distanceAlongRouteKm,
      title: _stationName(stop.station),
      detail: address == null ? detail : '$detail\n$address',
      batteryPercent: stop.arrivalSoc,
      backup: stop.backup,
    );
  }

  List<Widget> _planningDetails(
    BuildContext context,
    RoutePlanResult plan,
    DirectionsRoute? route,
  ) {
    final TextTheme text = Theme.of(context).textTheme;
    return <Widget>[
      const SizedBox(height: AmpTheme.spaceM),
      Eyebrow(AmpStrings.tripAssumptionsTitle),
      const SizedBox(height: AmpTheme.spaceS),
      for (final String assumption in plan.assumptions)
        Padding(
          padding: const EdgeInsets.only(bottom: AmpTheme.spaceS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('—', style: text.bodySmall),
              const SizedBox(width: AmpTheme.spaceS),
              Expanded(child: Text(assumption, style: text.bodySmall)),
            ],
          ),
        ),
      if (plan.excluded.isNotEmpty) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceS),
        Eyebrow(AmpStrings.tripExcludedTitle),
        const SizedBox(height: AmpTheme.spaceS),
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
      if (route != null) ...<Widget>[
        const SizedBox(height: AmpTheme.spaceM),
        Eyebrow(AmpStrings.tripDirectionsTitle),
        const SizedBox(height: AmpTheme.spaceS),
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
    ];
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

  Future<void> _useCurrentLocation({bool explainFirst = true}) async {
    if (_locating) {
      return;
    }
    setState(() {
      _locating = true;
      _locationMessage = null;
      _locationNeedsSettings = false;
    });

    final DeviceLocationFix fix = await requestDeviceLocation(
      context,
      ref.read(deviceLocationServiceProvider),
      explainFirst: explainFirst,
    );
    if (!mounted) {
      return;
    }

    if (!fix.hasPosition) {
      setState(() {
        _locating = false;
        _locationNeedsSettings =
            fix.status == DeviceLocationStatus.permissionDeniedForever;
        _locationMessage = switch (fix.status) {
          DeviceLocationStatus.permissionDeniedForever =>
            AmpStrings.locationPermissionForever,
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
      _locationNeedsSettings = false;
      if (explainFirst) {
        _dirty = true;
      }
      _originLat = fix.latitude;
      _originLng = fix.longitude;
      _originLabel = AmpStrings.tripCurrentLocation;
      _originLookingUp = true;
      _clearPlan();
    });
    await _lookupOriginAddress(fix.latitude, fix.longitude, fromGps: true);
  }

  Future<void> _openLocationSettings() async {
    await ref.read(deviceLocationServiceProvider).openSettings();
  }

  void _setOriginFromMap(LatLng point) {
    setState(() {
      _dirty = true;
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
      _dirty = true;
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
      _dirty = true;
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
      _dirty = true;
      _batteryError = null;
      _clearPlan();
    });
  }

  void _selectCorridor(double value) {
    if (_corridorKm == value) {
      return;
    }
    setState(() {
      _dirty = true;
      _corridorKm = value;
      _clearPlan();
    });
  }

  void _selectPreference(String value) {
    if (_preference == value) {
      return;
    }
    setState(() {
      _dirty = true;
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
    _showPlanningDetails = false;
    _saveWarning = null;
  }

  Future<void> _planTrip() async {
    if (_planning) {
      return;
    }
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
      _saveWarning = null;
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
      unawaited(_persistPlan(plan, data, destination));
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

  Future<void> _persistPlan(
    RoutePlanResult result,
    DiscoveryData data,
    GeoPlace destination,
  ) async {
    final JourneyRepository? repository = ref.read(journeyRepositoryProvider);
    final RepositoryResult<AppUser> profileResult = await ref.read(
      currentProfileProvider.future,
    );
    if (!mounted) {
      return;
    }
    final AppUser? profile = profileResult.valueOrNull;
    if (repository == null || profile == null) {
      setState(() => _saveWarning = AmpStrings.tripSaveFailed);
      return;
    }

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final RoutePlan plan = JourneyMapper.toRoutePlan(
      result: result,
      consumerId: profile.id,
      vehicleId: data.vehicle?.id,
      destinationPlaceId: destination.placeId,
      nowMs: nowMs,
    );
    final RepositoryResult<SavedJourney> saved = await repository
        .saveActivePlan(
          consumerId: profile.id,
          plan: plan,
          stops: JourneyMapper.toRouteStops(planId: plan.id, result: result),
        );
    if (!mounted) {
      return;
    }
    if (saved.failureOrNull != null) {
      setState(() => _saveWarning = AmpStrings.tripSaveFailed);
      return;
    }

    ref.invalidate(savedJourneyProvider);
    ref.read(batterySocProvider.notifier).setSoc(result.startSoc);
    setState(() {
      _dirty = false;
      _saveWarning = null;
    });

    final Vehicle? vehicle = data.vehicle;
    if (vehicle == null) {
      return;
    }
    final RepositoryResult<bool> recorded = await repository
        .recordBatteryConfirmation(
          vehicleId: vehicle.id,
          tripPlanId: plan.id,
          estimatedSoc: result.startSoc,
          actualSoc: result.startSoc,
          timestampMs: nowMs,
          latitude: result.originLat,
          longitude: result.originLng,
        );
    if (!mounted) {
      return;
    }
    if (recorded.failureOrNull != null) {
      setState(() => _saveWarning = AmpStrings.tripBatteryRecordFailed);
    }
  }

  Future<void> _prefillLastDestination() async {
    if (_lastDestinationLoaded) {
      return;
    }
    _lastDestinationLoaded = true;
    if (_destinationController.text.trim().isNotEmpty || _destination != null) {
      return;
    }
    try {
      final RepositoryResult<SavedJourney?> result = await ref.read(
        savedJourneyProvider.future,
      );
      final RoutePlan? plan = result.valueOrNull?.plan;
      final String label = (plan?.destination ?? '').trim();
      if (!mounted ||
          plan == null ||
          label.isEmpty ||
          (plan.destinationLat == 0 && plan.destinationLng == 0) ||
          _destinationController.text.trim().isNotEmpty ||
          _destination != null) {
        return;
      }
      setState(() {
        _destination = GeoPlace(
          placeId: plan.googlePlaceId ?? '',
          label: label,
          address: label,
          latitude: plan.destinationLat,
          longitude: plan.destinationLng,
        );
        _destinationController.text = label;
        _destinationController.selection = TextSelection.collapsed(
          offset: label.length,
        );
      });
    } on Object {
      // The saved destination is a convenience; planning still works without
      // it and the ordinary form validation covers an empty destination.
    }
  }

  void _resumeSavedTrip(SavedJourney journey) {
    final RoutePlan plan = journey.plan;
    final int savedBattery = plan.plannedStartSoc;
    final int battery = savedBattery < 0
        ? 0
        : savedBattery > 100
        ? 100
        : savedBattery;
    final String origin = (plan.origin ?? '').trim();
    final String destination = (plan.destination ?? '').trim();
    final String preference =
        _preferenceOptions.any(
          ((String, String) option) => option.$1 == plan.preference,
        )
        ? plan.preference!
        : RoutePlannerEngine.prefFastest;

    setState(() {
      _dirty = true;
      _originLat = plan.originLat;
      _originLng = plan.originLng;
      _originLabel = origin.isEmpty ? AmpStrings.tripMapPin : origin;
      _locationMessage = null;
      _locating = false;
      _originLookingUp = false;
      _destination = GeoPlace(
        placeId: plan.googlePlaceId ?? '',
        label: destination,
        address: destination,
        latitude: plan.destinationLat,
        longitude: plan.destinationLng,
      );
      _destinationController.text = destination;
      _destinationController.selection = TextSelection.collapsed(
        offset: destination.length,
      );
      _batteryController.text = '$battery';
      _batteryError = null;
      _corridorKm = _nearestCorridor(plan.corridorKm);
      _preference = preference;
      _suggestions = const <GeoPlace>[];
      _searching = false;
      _searchMessage = null;
      _destinationError = null;
      _clearPlan();
    });
    ref.read(batterySocProvider.notifier).setSoc(battery);
    AmpSnackbar.show(
      context,
      AmpStrings.tripResumeReady,
      tone: AmpSnackbarTone.success,
    );
  }

  double _nearestCorridor(double saved) {
    return _corridorOptions.reduce(
      (double a, double b) => (a - saved).abs() <= (b - saved).abs() ? a : b,
    );
  }

  StatusDotTone _confidenceTone(String confidence) {
    return switch (confidence.trim().toUpperCase()) {
      RoutePlannerEngine.confidenceHigh => StatusDotTone.available,
      RoutePlannerEngine.confidenceMedium => StatusDotTone.neutral,
      _ => StatusDotTone.busy,
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
        borderRadius: BorderRadius.circular(AmpTheme.radiusField),
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
      child: Eyebrow(label),
    );
  }
}
