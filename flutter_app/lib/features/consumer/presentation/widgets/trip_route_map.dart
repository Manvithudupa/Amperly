import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme/amp_colors.dart';
import '../../../../app/theme/amp_theme.dart';
import '../../../../core/ui/strings.dart';
import '../../../../core/widgets/amp_icon.dart';
import '../../../../data/geoapify/geoapify_models.dart';
import '../../../../data/geoapify/geoapify_tiles.dart';
import '../../../../domain/policy.dart';

/// A stop drawn on the phone map. Backups are hollow and never numbered,
/// because they are not part of the planned route.
final class TripMapStop {
  const TripMapStop({
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.backup = false,
  });

  final double latitude;
  final double longitude;
  final int sequence;
  final bool backup;
}

/// The Geoapify raster map for a trip.
///
/// The map is a viewport, not a route input: without an origin it opens on a
/// country-wide view so the driver can tap a real starting point. A missing
/// location never turns into a made-up origin here.
class TripRouteMap extends StatefulWidget {
  const TripRouteMap({
    required this.config,
    super.key,
    this.routePoints = const <GeoPoint>[],
    this.origin,
    this.destination,
    this.current,
    this.stops = const <TripMapStop>[],
    this.onTap,
    this.height = 280,
  });

  final GeoapifyMapConfig config;
  final List<GeoPoint> routePoints;
  final GeoPoint? origin;
  final GeoPoint? destination;
  final GeoPoint? current;
  final List<TripMapStop> stops;
  final ValueChanged<LatLng>? onTap;
  final double height;

  @override
  State<TripRouteMap> createState() => _TripRouteMapState();
}

class _TripRouteMapState extends State<TripRouteMap> {
  static const LatLng _countryView = LatLng(22.9734, 78.6569);

  final MapController _mapController = MapController();
  bool _ready = false;
  late String _signature;

  @override
  void initState() {
    super.initState();
    _signature = _routeSignature();
  }

  @override
  void didUpdateWidget(TripRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String next = _routeSignature();
    if (next == _signature) {
      return;
    }
    _signature = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fitRoute();
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _routeSignature() {
    final List<String> parts = <String>[
      if (widget.origin != null)
        'o:${widget.origin!.lat},${widget.origin!.lng}',
      if (widget.current != null)
        'c:${widget.current!.lat},${widget.current!.lng}',
      if (widget.destination != null)
        'd:${widget.destination!.lat},${widget.destination!.lng}',
      for (final TripMapStop stop in widget.stops)
        's:${stop.sequence}:${stop.backup}:${stop.latitude}:${stop.longitude}',
      if (widget.routePoints.isNotEmpty)
        'r:${widget.routePoints.length}:'
            '${widget.routePoints.first.lat},${widget.routePoints.first.lng}:'
            '${widget.routePoints.last.lat},${widget.routePoints.last.lng}',
    ];
    return parts.join('|');
  }

  List<LatLng> _focusPoints() {
    return <LatLng>[
      if (widget.origin != null) LatLng(widget.origin!.lat, widget.origin!.lng),
      for (final TripMapStop stop in widget.stops)
        if (!stop.backup) LatLng(stop.latitude, stop.longitude),
      if (widget.destination != null)
        LatLng(widget.destination!.lat, widget.destination!.lng),
    ];
  }

  void _fitRoute() {
    if (!_ready) {
      return;
    }
    final List<LatLng> points = _focusPoints();
    if (points.isEmpty) {
      return;
    }
    try {
      if (points.length == 1) {
        _mapController.move(points.first, 13);
      } else {
        _mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: points,
            padding: const EdgeInsets.all(44),
          ),
        );
      }
    } on Object {
      // The map can briefly lack a size during the first layout pass. The
      // onMapReady callback fits again once it has one.
    }
  }

  LatLng get _initialCenter {
    if (widget.origin != null) {
      return LatLng(widget.origin!.lat, widget.origin!.lng);
    }
    if (widget.destination != null) {
      return LatLng(widget.destination!.lat, widget.destination!.lng);
    }
    if (widget.routePoints.isNotEmpty) {
      final GeoPoint point = widget.routePoints.first;
      return LatLng(point.lat, point.lng);
    }
    return _countryView;
  }

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;

    final List<Marker> markers = <Marker>[
      if (widget.current != null)
        Marker(
          point: LatLng(widget.current!.lat, widget.current!.lng),
          width: 38,
          height: 38,
          child: _MarkerDot(
            color: colors.energy,
            borderColor: colors.surface,
            icon: AmpIconName.arrowRight,
            iconColor: colors.onEnergy,
          ),
        ),
      if (widget.origin != null && widget.current == null)
        Marker(
          point: LatLng(widget.origin!.lat, widget.origin!.lng),
          width: 34,
          height: 34,
          child: _MarkerDot(
            color: colors.primary,
            borderColor: colors.surface,
            icon: AmpIconName.pin,
            iconColor: colors.onPrimary,
          ),
        ),
      for (final TripMapStop stop in widget.stops)
        if (!stop.backup)
          Marker(
            point: LatLng(stop.latitude, stop.longitude),
            width: 30,
            height: 30,
            child: Semantics(
              label: '${AmpStrings.journeyChargingStop} ${stop.sequence}',
              child: _StopDot(
                sequence: stop.sequence,
                background: colors.primary,
                foreground: colors.onPrimary,
              ),
            ),
          ),
      for (final TripMapStop stop in widget.stops)
        if (stop.backup)
          Marker(
            point: LatLng(stop.latitude, stop.longitude),
            width: 28,
            height: 28,
            child: Semantics(
              label: AmpStrings.journeyBackup,
              child: _MarkerDot(
                color: colors.surface,
                borderColor: colors.outline,
                icon: AmpIconName.bolt,
                iconColor: colors.inkSecondary,
              ),
            ),
          ),
      if (widget.destination != null)
        Marker(
          point: LatLng(widget.destination!.lat, widget.destination!.lng),
          width: 34,
          height: 34,
          child: _MarkerDot(
            color: colors.energy,
            borderColor: colors.surface,
            icon: AmpIconName.pin,
            iconColor: colors.onEnergy,
          ),
        ),
    ];

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.mapPlaceholder,
        borderRadius: BorderRadius.circular(AmpTheme.radiusCard),
        border: Border.all(color: colors.divider),
      ),
      child: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: widget.origin != null ? 12 : 4.4,
              minZoom: 3,
              maxZoom: 18,
              onMapReady: () {
                _ready = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _fitRoute();
                  }
                });
              },
              onTap: widget.onTap == null
                  ? null
                  : (TapPosition position, LatLng point) =>
                        widget.onTap!(point),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: widget.config.tileUrlTemplate,
                userAgentPackageName: 'com.amperly.amperly_phone',
                maxNativeZoom: 19,
              ),
              if (widget.routePoints.length > 1)
                PolylineLayer(
                  polylines: <Polyline>[
                    Polyline(
                      points: <LatLng>[
                        for (final GeoPoint point in widget.routePoints)
                          LatLng(point.lat, point.lng),
                      ],
                      strokeWidth: 4,
                      color: colors.primary,
                    ),
                  ],
                ),
              if (markers.isNotEmpty) MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            left: AmpTheme.spaceS,
            right: AmpTheme.spaceS,
            bottom: AmpTheme.spaceS,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  AmpPolicy.mapAttribution,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: AmpTheme.uiFont,
                    fontSize: 9.5,
                    height: 1.25,
                    color: colors.inkSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerDot extends StatelessWidget {
  const _MarkerDot({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
  });

  final Color color;
  final Color borderColor;
  final AmpIconName icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(child: AmpIcon(icon, size: 17, color: iconColor)),
    );
  }
}

class _StopDot extends StatelessWidget {
  const _StopDot({
    required this.sequence,
    required this.background,
    required this.foreground,
  });

  final int sequence;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: context.amp.surface, width: 2),
      ),
      child: Text(
        '$sequence',
        style: TextStyle(
          fontFamily: AmpTheme.uiFont,
          fontSize: 12,
          height: 1,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
