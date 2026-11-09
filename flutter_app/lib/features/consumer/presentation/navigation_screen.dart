import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/amp_colors.dart';
import '../../../app/theme/amp_theme.dart';
import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_button.dart';
import '../../../core/widgets/amp_scaffold.dart';
import '../../../core/widgets/big_number.dart';
import '../../../core/widgets/eyebrow.dart';
import '../../../core/widgets/hairline.dart';
import '../../../core/widgets/text_action.dart';
import '../../../data/geoapify/geoapify_client.dart';
import '../../../data/geoapify/geoapify_models.dart';
import '../../../data/geoapify/geoapify_tiles.dart';
import '../application/trip_providers.dart';
import 'widgets/trip_route_map.dart';

/// A planned stop shown during navigation.
final class NavigationStop {
  const NavigationStop({
    required this.sequence,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final int sequence;
  final String name;
  final double latitude;
  final double longitude;
}

/// The route and context handed to [NavigationScreen].
final class NavigationTrip {
  const NavigationTrip({
    required this.label,
    required this.route,
    this.stops = const <NavigationStop>[],
    this.planId,
    this.mode = TravelMode.driving,
  });

  final String label;
  final DirectionsRoute route;
  final List<NavigationStop> stops;
  final String? planId;
  final TravelMode mode;
}

/// In-app guidance over the planned road route.
///
/// This build has no live turn-by-turn GPS feed, so progress is simulated along
/// the same route the planner drew. Remaining distance and time are estimates,
/// never a claim of live traffic.
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({required this.trip, super.key});

  final NavigationTrip trip;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  static const Duration _tick = Duration(seconds: 2);
  static const double _progressStep = 0.02;

  Timer? _timer;
  double _progress = 0.02;
  bool _arrived = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted || _arrived) {
        return;
      }
      setState(() {
        _progress = math.min(1, _progress + _progressStep);
        if (_progress >= 1) {
          _arrived = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  DirectionsRoute get _route => widget.trip.route;

  GeoPoint get _currentPoint {
    final List<GeoPoint> points = _route.points;
    if (points.isEmpty) {
      return GeoPoint(_route.originLat, _route.originLng);
    }
    final int index = (_progress * (points.length - 1)).round().clamp(
      0,
      points.length - 1,
    );
    return points[index];
  }

  RouteStep? get _currentStep {
    final List<RouteStep> steps = _route.steps;
    if (steps.isEmpty) {
      return null;
    }
    final int index = (_progress * steps.length).floor().clamp(
      0,
      steps.length - 1,
    );
    return steps[index];
  }

  int get _currentStepNumber {
    if (_route.steps.isEmpty) {
      return 0;
    }
    return ((_progress * _route.steps.length).floor().clamp(
          0,
          _route.steps.length - 1,
        )) +
        1;
  }

  double get _remainingKm => _route.distanceKm * (1 - _progress);

  int get _remainingMinutes =>
      math.max(1, (_route.effectiveDurationMinutes * (1 - _progress)).ceil());

  void _arriveNow() {
    _timer?.cancel();
    setState(() {
      _progress = 1;
      _arrived = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final GeoapifyMapConfig? mapConfig = ref.watch(geoapifyMapConfigProvider);
    final TextTheme text = Theme.of(context).textTheme;
    final AmpColors colors = context.amp;
    final RouteStep? step = _currentStep;

    return AmpScaffold(
      title: AmpStrings.navigationTitle,
      subtitle: widget.trip.mode == TravelMode.walking
          ? AmpStrings.navigationWalkingTo(widget.trip.label)
          : widget.trip.label,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AmpTheme.screenPadding,
          AmpTheme.spaceS,
          AmpTheme.screenPadding,
          AmpTheme.spaceXxl,
        ),
        children: <Widget>[
          if (mapConfig != null)
            TripRouteMap(
              config: mapConfig,
              routePoints: _route.points,
              origin: GeoPoint(_route.originLat, _route.originLng),
              destination: GeoPoint(
                _route.destinationLat,
                _route.destinationLng,
              ),
              current: _currentPoint,
              stops: <TripMapStop>[
                for (final NavigationStop stop in widget.trip.stops)
                  TripMapStop(
                    latitude: stop.latitude,
                    longitude: stop.longitude,
                    sequence: stop.sequence,
                  ),
              ],
              height: 300,
            )
          else
            _NavNotice(message: AmpStrings.tripMapSetupBody),
          const SizedBox(height: AmpTheme.spaceM),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 4,
              color: colors.primary,
              backgroundColor: colors.surfaceVariant,
            ),
          ),
          const SizedBox(height: AmpTheme.spaceM),
          if (_arrived) ...<Widget>[
            Text(AmpStrings.navigationArrivedTitle, style: text.displaySmall),
            const SizedBox(height: AmpTheme.spaceS),
            Text(AmpStrings.navigationArrivedBody, style: text.bodyMedium),
          ] else ...<Widget>[
            const Eyebrow(AmpStrings.navigationNextInstruction),
            const SizedBox(height: 6),
            Text(
              step == null || step.instruction.trim().isEmpty
                  ? AmpStrings.navigationNoSteps
                  : step.instruction,
              style: text.displaySmall,
            ),
            if (step != null && _stepMeta(step).isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(_stepMeta(step), style: text.bodySmall),
            ],
            if (_route.steps.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                AmpStrings.navigationStep(
                  _currentStepNumber,
                  _route.steps.length,
                ),
                style: text.bodySmall,
              ),
            ],
          ],
          const SizedBox(height: AmpTheme.spaceM),
          const Hairline(),
          const SizedBox(height: AmpTheme.spaceM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: BigNumber(
                  value: _remainingKm.toStringAsFixed(1),
                  unit: AmpStrings.km,
                  label: AmpStrings.navigationRemaining,
                  size: 42,
                ),
              ),
              const SizedBox(width: AmpTheme.spaceM),
              Expanded(
                child: BigNumber(
                  value: '$_remainingMinutes',
                  unit: AmpStrings.tripJourneyUnit,
                  label: AmpStrings.navigationEta,
                  size: 42,
                ),
              ),
            ],
          ),
          const SizedBox(height: AmpTheme.spaceM),
          const Hairline(),
          if (widget.trip.stops.isNotEmpty) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceM),
            const Eyebrow(AmpStrings.tripStopsTitle),
            const SizedBox(height: AmpTheme.spaceS),
            for (final NavigationStop stop in widget.trip.stops)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  AmpStrings.navigationStopLine(stop.sequence, stop.name),
                  style: text.bodyMedium,
                ),
              ),
          ],
          const SizedBox(height: AmpTheme.spaceM),
          Text(AmpStrings.navigationSimulationNote, style: text.bodySmall),
          if (!_arrived) ...<Widget>[
            const SizedBox(height: AmpTheme.spaceS),
            TextAction(AmpStrings.navigationArriveNow, onPressed: _arriveNow),
          ],
        ],
      ),
      bottomBar: AmpButton(
        label: _arrived ? AmpStrings.navigationDone : AmpStrings.navigationStop,
        variant: _arrived ? AmpButtonVariant.primary : AmpButtonVariant.tonal,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  String _stepMeta(RouteStep step) {
    return <String>[
      if (step.distanceText.trim().isNotEmpty) step.distanceText.trim(),
      if (step.durationText.trim().isNotEmpty) step.durationText.trim(),
    ].join(' · ');
  }
}

class _NavNotice extends StatelessWidget {
  const _NavNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AmpTheme.spaceM),
      decoration: BoxDecoration(
        color: colors.busyTint,
        borderRadius: BorderRadius.circular(AmpTheme.radiusField),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colors.ink),
      ),
    );
  }
}
