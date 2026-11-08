import 'dart:convert';

import 'geoapify_models.dart';

abstract final class GeoapifyPlaceParser {
  static List<GeoPlace> parseSuggestions(String? json, int limit) {
    if (json == null || json.trim().isEmpty) {
      return const <GeoPlace>[];
    }
    final List<dynamic>? features = _features(json);
    if (features == null) {
      return const <GeoPlace>[];
    }
    final List<GeoPlace> places = <GeoPlace>[];
    final int max = limit <= 0 ? 5 : limit;
    for (final dynamic raw in features) {
      if (raw is! Map) {
        continue;
      }
      final GeoPlace? place = _toPlace(Map<String, dynamic>.from(raw));
      if (place == null) {
        continue;
      }
      places.add(place);
      if (places.length >= max) {
        break;
      }
    }
    return List<GeoPlace>.unmodifiable(places);
  }

  static GeoPlace? parseFirstMatch(String? json) {
    final List<GeoPlace> places = parseSuggestions(json, 1);
    return places.isEmpty ? null : places.first;
  }

  static String parseFirstFormattedAddress(String? json) {
    if (json == null || json.trim().isEmpty) {
      return '';
    }
    final List<dynamic>? features = _features(json);
    if (features == null || features.isEmpty || features.first is! Map) {
      return '';
    }
    final Map<String, dynamic>? properties = _object(
      Map<String, dynamic>.from(features.first as Map),
      'properties',
    );
    return properties == null ? '' : _string(properties, 'formatted');
  }

  static List<dynamic>? _features(String json) {
    try {
      final dynamic parsed = jsonDecode(json);
      if (parsed is! Map) {
        return null;
      }
      final dynamic features = parsed['features'];
      return features is List ? features : null;
    } on FormatException {
      return null;
    }
  }

  static GeoPlace? _toPlace(Map<String, dynamic> feature) {
    final Map<String, dynamic>? properties = _object(feature, 'properties');
    if (properties == null) {
      return null;
    }
    double? latitude = _number(properties, 'lat');
    double? longitude = _number(properties, 'lon');
    if (latitude == null || longitude == null) {
      final Map<String, dynamic>? geometry = _object(feature, 'geometry');
      final dynamic coordinates = geometry?['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        // GeoJSON is [longitude, latitude].
        longitude = _asDouble(coordinates[0]);
        latitude = _asDouble(coordinates[1]);
      }
    }
    if (latitude == null || longitude == null) {
      return null;
    }

    final String formatted = _string(properties, 'formatted');
    final String line1 = _string(properties, 'address_line1');
    final String line2 = _string(properties, 'address_line2');
    final String label = line1.isNotEmpty
        ? line1
        : formatted.isNotEmpty
        ? formatted
        : line2;
    final String address = formatted.isNotEmpty
        ? formatted
        : line2.isNotEmpty
        ? line2
        : label;
    if (label.isEmpty) {
      return null;
    }
    return GeoPlace(
      placeId: _string(properties, 'place_id'),
      label: label,
      address: address,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static Map<String, dynamic>? _object(
    Map<String, dynamic> parent,
    String key,
  ) {
    final dynamic value = parent[key];
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  static String _string(Map<String, dynamic> parent, String key) {
    final dynamic value = parent[key];
    return value is String ? value : '';
  }

  static double? _number(Map<String, dynamic> parent, String key) =>
      _asDouble(parent[key]);

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
