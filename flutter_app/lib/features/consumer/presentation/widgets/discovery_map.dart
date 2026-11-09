import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../app/theme/amp_colors.dart';
import '../../../../app/theme/amp_theme.dart';
import '../../../../core/ui/strings.dart';
import '../../../../core/widgets/eyebrow.dart';
import '../../../../data/geoapify/geoapify_tiles.dart';
import '../../../../data/repositories/station_repository.dart';
import '../../../../domain/engines/station_visibility.dart';
import '../../application/discovery_providers.dart';

/// The map surface behind Discover.
///
/// Without a Geoapify key it says so in type instead of pretending to have a
/// map. With a key it plots only published coordinates, and each pin opens the
/// charger it represents.
class DiscoveryMap extends StatefulWidget {
  const DiscoveryMap({
    required this.entries,
    required this.config,
    required this.onSelect,
    super.key,
  });

  final List<StationCatalogueEntry> entries;
  final GeoapifyMapConfig? config;
  final ValueChanged<StationCatalogueEntry> onSelect;

  @override
  State<DiscoveryMap> createState() => _DiscoveryMapState();
}

class _DiscoveryMapState extends State<DiscoveryMap> {
  final MapController _controller = MapController();
  bool _ready = false;
  late String _signature;

  List<StationCatalogueEntry> get _plottable => widget.entries
      .where(
        (StationCatalogueEntry entry) => StationVisibility.hasValidCoordinates(
          entry.station.latitude,
          entry.station.longitude,
        ),
      )
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _signature = _currentSignature();
  }

  @override
  void didUpdateWidget(DiscoveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String next = _currentSignature();
    if (next == _signature) {
      return;
    }
    _signature = next;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fit();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _currentSignature() {
    return _plottable
        .map(
          (StationCatalogueEntry entry) =>
              '${entry.station.id}:${entry.station.latitude},${entry.station.longitude}',
        )
        .join('|');
  }

  LatLng get _initialCenter {
    final List<StationCatalogueEntry> points = _plottable;
    if (points.isEmpty) {
      return const LatLng(22.9734, 78.6569);
    }
    double latitude = 0;
    double longitude = 0;
    for (final StationCatalogueEntry entry in points) {
      latitude += entry.station.latitude;
      longitude += entry.station.longitude;
    }
    return LatLng(latitude / points.length, longitude / points.length);
  }

  void _fit() {
    if (!_ready) {
      return;
    }
    final List<StationCatalogueEntry> points = _plottable;
    if (points.isEmpty) {
      return;
    }
    final List<LatLng> coordinates = points
        .map(
          (StationCatalogueEntry entry) =>
              LatLng(entry.station.latitude, entry.station.longitude),
        )
        .toList(growable: false);
    try {
      if (coordinates.length == 1) {
        _controller.move(coordinates.single, 13);
      } else {
        final double height = MediaQuery.sizeOf(context).height;
        final double bottom = (height * 0.44).clamp(180, 360);
        _controller.fitCamera(
          CameraFit.coordinates(
            coordinates: coordinates,
            padding: EdgeInsets.fromLTRB(48, 140, 48, bottom),
          ),
        );
      }
    } on Object {
      // The map may not have a size yet; onMapReady runs the fit again.
    }
  }

  @override
  Widget build(BuildContext context) {
    final GeoapifyMapConfig? config = widget.config;
    if (config == null) {
      return const _MapPlaceholder();
    }

    final AmpColors colors = context.amp;
    final List<Marker> markers = <Marker>[
      for (final StationCatalogueEntry entry in _plottable)
        Marker(
          point: LatLng(entry.station.latitude, entry.station.longitude),
          width: 44,
          height: 48,
          child: _StationPin(entry: entry, onTap: () => widget.onSelect(entry)),
        ),
    ];

    return ColoredBox(
      color: colors.mapPlaceholder,
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _plottable.length == 1 ? 13 : 11,
          minZoom: 3,
          maxZoom: 18,
          backgroundColor: colors.mapPlaceholder,
          onMapReady: () {
            _ready = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _fit();
              }
            });
          },
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: config.tileUrlTemplate,
            userAgentPackageName: 'com.amperly.amperly_phone',
            maxNativeZoom: 19,
          ),
          if (markers.isNotEmpty) MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}

class _StationPin extends StatelessWidget {
  const _StationPin({required this.entry, required this.onTap});

  final StationCatalogueEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final int available = availablePortCount(entry);
    final Color status = available > 0 ? colors.available : colors.busy;
    final String name = (entry.station.name ?? '').trim().isEmpty
        ? AmpStrings.unnamedCharger
        : entry.station.name!.trim();

    return Semantics(
      button: true,
      label: '$name. ${availabilityLabel(entry)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: CustomPaint(
            size: const Size(32, 40),
            painter: _PinPainter(
              fill: colors.surface,
              status: status,
              dot: status,
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  const _PinPainter({
    required this.fill,
    required this.status,
    required this.dot,
  });

  final Color fill;
  final Color status;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = Offset(size.width / 2, 16);
    final Path head = Path()
      ..addOval(Rect.fromCircle(center: centre, radius: 13));
    final Path tail = Path()
      ..moveTo(size.width / 2 - 7, 24)
      ..lineTo(size.width / 2, size.height - 2)
      ..lineTo(size.width / 2 + 7, 24)
      ..close();
    final Path pin = Path.combine(PathOperation.union, head, tail);

    canvas.drawPath(pin, Paint()..color = fill);
    canvas.drawPath(
      pin,
      Paint()
        ..color = status
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(centre, 3.4, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) {
    return oldDelegate.fill != fill ||
        oldDelegate.status != status ||
        oldDelegate.dot != dot;
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    final AmpColors colors = context.amp;
    final double top = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: colors.mapPlaceholder),
        CustomPaint(painter: _PaperGridPainter(color: colors.divider)),
        Positioned(
          left: AmpTheme.screenPadding,
          right: AmpTheme.screenPadding,
          top: top + 116,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Eyebrow(AmpStrings.discoverMapMissingTitle),
              const SizedBox(height: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  AmpStrings.discoverMapMissingBody,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colors.inkSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaperGridPainter extends CustomPainter {
  const _PaperGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    const double step = 36;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
