/// The raster tile layer used by the phone map.
///
/// The phone map uses Geoapify's raster tiles of the same OpenStreetMap-based
/// style as the Android Auto MapLibre surface. The app must never use
/// `tile.openstreetmap.org`: the OSM Foundation's tile servers do not permit
/// shipped applications.
final class GeoapifyMapConfig {
  const GeoapifyMapConfig({required this.style, required this.apiKey});

  static const String defaultStyle = 'osm-bright';
  static const String _tileBase = 'https://maps.geoapify.com/v1/tile';

  final String style;
  final String apiKey;

  bool get isConfigured => apiKey.trim().isNotEmpty;

  /// The XYZ template consumed by `flutter_map`.
  String get tileUrlTemplate {
    final String encodedKey = Uri.encodeQueryComponent(apiKey.trim());
    return '$_tileBase/$style/{z}/{x}/{y}.png?apiKey=$encodedKey';
  }

  static GeoapifyMapConfig? from({
    required String styleUrl,
    required String apiKey,
  }) {
    final String key = apiKey.trim();
    if (key.isEmpty) {
      return null;
    }
    return GeoapifyMapConfig(
      style: styleNameFromStyleUrl(styleUrl),
      apiKey: key,
    );
  }

  /// Finds the style id in both Geoapify URL shapes:
  /// `/v1/styles/osm-bright/style.json` and `/v1/tile/osm-bright/{z}/...`.
  static String styleNameFromStyleUrl(String? styleUrl) {
    final Uri? uri = Uri.tryParse((styleUrl ?? '').trim());
    if (uri == null) {
      return defaultStyle;
    }
    final List<String> segments = uri.pathSegments;
    for (int i = 0; i < segments.length - 1; i++) {
      if (segments[i] == 'styles' || segments[i] == 'tile') {
        final String candidate = segments[i + 1].trim();
        if (candidate.isNotEmpty &&
            RegExp(r'^[a-z0-9-]+$').hasMatch(candidate)) {
          return candidate;
        }
      }
    }
    return defaultStyle;
  }
}
