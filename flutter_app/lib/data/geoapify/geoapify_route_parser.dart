import 'dart:convert';

import 'geoapify_models.dart';

abstract final class GeoapifyRouteParser {
  static DirectionsRoute parse(String json) {
    final dynamic root;
    try {
      root = jsonDecode(json);
    } on FormatException {
      throw const GeoapifyException(
        'Geoapify returned an unexpected response.',
      );
    }
    if (root is! Map) {
      throw const GeoapifyException(
        'Geoapify returned an unexpected response.',
      );
    }
    final dynamic features = root['features'];
    if (features is! List || features.isEmpty || features.first is! Map) {
      throw const GeoapifyException(
        'Geoapify found no route between those points.',
      );
    }
    final Map<String, dynamic> feature = Map<String, dynamic>.from(
      features.first as Map,
    );
    final dynamic propertiesRaw = feature['properties'];
    if (propertiesRaw is! Map) {
      throw const GeoapifyException(
        'Geoapify returned a route with no usable geometry.',
      );
    }
    final Map<String, dynamic> properties = Map<String, dynamic>.from(
      propertiesRaw,
    );
    final List<GeoPoint> points = _geometryPoints(feature);
    if (points.length < 2) {
      throw const GeoapifyException(
        'Geoapify returned a route with no usable geometry.',
      );
    }
    final double distanceMeters = _number(properties, 'distance', 0);
    final double durationSeconds = _number(properties, 'time', 0);
    return DirectionsRoute(
      points: List<GeoPoint>.unmodifiable(points),
      distanceKm: distanceMeters / 1000,
      durationMinutes: (durationSeconds / 60).round(),
      durationInTrafficMinutes: 0,
      startAddress: '',
      endAddress: '',
      steps: List<RouteStep>.unmodifiable(_steps(properties, points)),
      approximate: false,
    );
  }

  static List<GeoPoint> _geometryPoints(Map<String, dynamic> feature) {
    final List<GeoPoint> points = <GeoPoint>[];
    final dynamic geometryRaw = feature['geometry'];
    if (geometryRaw is! Map) {
      return points;
    }
    final Map<String, dynamic> geometry = Map<String, dynamic>.from(
      geometryRaw,
    );
    final String type = (geometry['type'] as String? ?? '').toLowerCase();
    final dynamic coordinates = geometry['coordinates'];
    if (coordinates is! List) {
      return points;
    }
    if (type == 'multilinestring') {
      for (final dynamic part in coordinates) {
        if (part is List) {
          _appendPoints(points, part);
        }
      }
    } else {
      _appendPoints(points, coordinates);
    }
    return points;
  }

  static void _appendPoints(List<GeoPoint> target, List<dynamic> coordinates) {
    for (final dynamic raw in coordinates) {
      if (raw is! List || raw.length < 2) {
        continue;
      }
      final double? lng = _asDouble(raw[0]);
      final double? lat = _asDouble(raw[1]);
      if (lng == null || lat == null) {
        continue;
      }
      final GeoPoint point = GeoPoint(lat, lng);
      if (target.isNotEmpty &&
          (target.last.lat - point.lat).abs() < 1e-7 &&
          (target.last.lng - point.lng).abs() < 1e-7) {
        continue;
      }
      target.add(point);
    }
  }

  static List<RouteStep> _steps(
    Map<String, dynamic> properties,
    List<GeoPoint> points,
  ) {
    final List<RouteStep> steps = <RouteStep>[];
    final dynamic legs = properties['legs'];
    if (legs is! List) {
      return steps;
    }
    for (final dynamic legRaw in legs) {
      if (legRaw is! Map) {
        continue;
      }
      final dynamic legSteps = legRaw['steps'];
      if (legSteps is! List) {
        continue;
      }
      for (final dynamic stepRaw in legSteps) {
        if (stepRaw is! Map) {
          continue;
        }
        final Map<String, dynamic> step = Map<String, dynamic>.from(stepRaw);
        final dynamic instructionRaw = step['instruction'];
        final Map<String, dynamic> instruction = instructionRaw is Map
            ? Map<String, dynamic>.from(instructionRaw)
            : const <String, dynamic>{};
        final int fromIndex = _number(step, 'from_index', -1).toInt();
        final bool hasPoint = fromIndex >= 0 && fromIndex < points.length;
        steps.add(
          RouteStep(
            instruction: instruction['text'] as String? ?? '',
            distanceText: _distanceText(_number(step, 'distance', 0)),
            durationText: _durationText(_number(step, 'time', 0)),
            maneuver: instruction['type'] as String? ?? '',
            startLat: hasPoint ? points[fromIndex].lat : 0,
            startLng: hasPoint ? points[fromIndex].lng : 0,
          ),
        );
      }
    }
    return steps;
  }

  static String _distanceText(double metres) {
    if (metres < 1000) {
      return '${metres.toStringAsFixed(0)} m';
    }
    return '${(metres / 1000).toStringAsFixed(1)} km';
  }

  static String _durationText(double seconds) {
    int minutes = (seconds / 60).round();
    if (minutes < 1) {
      minutes = 1;
    }
    return '$minutes min';
  }

  static double _number(
    Map<String, dynamic> parent,
    String key,
    double fallback,
  ) {
    final dynamic value = parent[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
