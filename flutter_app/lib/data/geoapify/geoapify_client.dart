import 'dart:collection';

import 'package:http/http.dart' as http;

import '../../core/errors/user_messages.dart';
import '../../domain/policy.dart';
import '../repositories/repository_result.dart';
import 'geoapify_models.dart';
import 'geoapify_place_parser.dart';
import 'geoapify_route_parser.dart';
import 'request_throttle.dart';
import 'route_cache.dart';

enum TravelMode {
  driving('drive', 45),
  walking('walk', 5);

  const TravelMode(this.requestMode, this.estimateSpeedKmh);

  final String requestMode;
  final double estimateSpeedKmh;

  String get label => this == TravelMode.walking ? 'walking' : 'driving';
}

final class GeoapifyClient {
  GeoapifyClient({
    required this.apiKey,
    http.Client? httpClient,
    RouteCache? routeCache,
    RequestThrottle? throttle,
    int Function()? clock,
  }) : _http = httpClient ?? http.Client(),
       _routeCache = routeCache ?? RouteCache(),
       _throttle = throttle ?? RequestThrottle(),
       _clock = clock ?? (() => DateTime.now().millisecondsSinceEpoch);

  static const String baseUrl = 'api.geoapify.com';
  static const int addressCacheCapacity = 64;

  final String apiKey;
  final http.Client _http;
  final RouteCache _routeCache;
  final RequestThrottle _throttle;
  final int Function() _clock;
  final LinkedHashMap<String, String> _addresses =
      LinkedHashMap<String, String>();

  bool get isConfigured => apiKey.trim().isNotEmpty;

  Future<RepositoryResult<List<GeoPlace>>> autocomplete(
    String text, {
    double? biasLat,
    double? biasLng,
    int limit = AmpPolicy.searchSuggestionLimit,
  }) async {
    final String query = text.trim();
    if (query.length < AmpPolicy.searchMinimumCharacters) {
      return const RepositorySuccess<List<GeoPlace>>(<GeoPlace>[]);
    }
    if (!isConfigured) {
      return RepositoryFailure<List<GeoPlace>>(
        kind: UserMessageKind.mapUnavailable,
        message: UserMessages.messageFor(UserMessageKind.mapUnavailable),
      );
    }
    try {
      final Uri uri = autocompleteUri(
        query,
        limit: limit,
        biasLat: biasLat,
        biasLng: biasLng,
      );
      final String body = await _get(uri);
      return RepositorySuccess<List<GeoPlace>>(
        GeoapifyPlaceParser.parseSuggestions(body, limit),
      );
    } on Object catch (error) {
      return RepositoryFailure<List<GeoPlace>>.from(error);
    }
  }

  Future<RepositoryResult<GeoPlace>> forward(
    String text, {
    double? biasLat,
    double? biasLng,
  }) async {
    final RepositoryResult<List<GeoPlace>> result = await autocomplete(
      text,
      biasLat: biasLat,
      biasLng: biasLng,
      limit: 1,
    );
    if (result case RepositoryFailure<List<GeoPlace>> failure) {
      return RepositoryFailure<GeoPlace>(
        kind: failure.kind,
        message: failure.message,
        cause: failure.cause,
      );
    }
    final List<GeoPlace> places = result.valueOrNull ?? const <GeoPlace>[];
    if (places.isEmpty) {
      return RepositoryFailure<GeoPlace>(
        kind: UserMessageKind.noResults,
        message: UserMessages.messageFor(UserMessageKind.noResults),
      );
    }
    return RepositorySuccess<GeoPlace>(places.first);
  }

  Future<RepositoryResult<String>> reverse(
    double latitude,
    double longitude,
  ) async {
    final String key = cacheKey(latitude, longitude);
    final String? cached = _addresses.remove(key);
    if (cached != null && cached.isNotEmpty) {
      _addresses[key] = cached;
      return RepositorySuccess<String>(cached);
    }
    if (!isConfigured) {
      return RepositoryFailure<String>(
        kind: UserMessageKind.mapUnavailable,
        message: UserMessages.messageFor(UserMessageKind.mapUnavailable),
      );
    }
    try {
      final Uri uri =
          Uri.https(baseUrl, '/v1/geocode/reverse', <String, String>{
            'lat': latitude.toStringAsFixed(6),
            'lon': longitude.toStringAsFixed(6),
            'lang': 'en',
            'apiKey': apiKey,
          });
      final String address = GeoapifyPlaceParser.parseFirstFormattedAddress(
        await _get(uri),
      );
      if (address.isEmpty) {
        return RepositoryFailure<String>(
          kind: UserMessageKind.noResults,
          message: UserMessages.messageFor(UserMessageKind.noResults),
        );
      }
      _addresses[key] = address;
      while (_addresses.length > addressCacheCapacity) {
        _addresses.remove(_addresses.keys.first);
      }
      return RepositorySuccess<String>(address);
    } on Object catch (error) {
      return RepositoryFailure<String>.from(error);
    }
  }

  Future<RepositoryResult<DirectionsRoute>> route({
    required TravelMode mode,
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    if (!isConfigured) {
      return RepositoryFailure<DirectionsRoute>(
        kind: UserMessageKind.mapUnavailable,
        message: UserMessages.messageFor(UserMessageKind.mapUnavailable),
      );
    }
    final String key = cacheKeyFor(mode, fromLat, fromLng, toLat, toLng);
    final int now = _clock();
    final DirectionsRoute? cached = _routeCache.get(key, now);
    if (cached != null) {
      return RepositorySuccess<DirectionsRoute>(cached);
    }
    try {
      final int waitMs = _throttle.reserveDelayMs(now);
      if (waitMs > 0) {
        await Future<void>.delayed(
          Duration(milliseconds: waitMs.clamp(0, 1000)),
        );
      }
      final Uri uri = Uri.https(baseUrl, '/v1/routing', <String, String>{
        'waypoints':
            '${fromLat.toStringAsFixed(6)},${fromLng.toStringAsFixed(6)}|'
            '${toLat.toStringAsFixed(6)},${toLng.toStringAsFixed(6)}',
        'mode': mode.requestMode,
        'details': 'instruction_details',
        'apiKey': apiKey,
      });
      final DirectionsRoute route = GeoapifyRouteParser.parse(await _get(uri));
      _routeCache.put(key, route, _clock());
      return RepositorySuccess<DirectionsRoute>(route);
    } on Object catch (error) {
      return RepositoryFailure<DirectionsRoute>.from(error);
    }
  }

  Future<RepositoryResult<DirectionsRoute>> routeToAddress({
    required TravelMode mode,
    required double fromLat,
    required double fromLng,
    required String destination,
  }) async {
    final RepositoryResult<GeoPlace> place = await forward(
      destination,
      biasLat: fromLat,
      biasLng: fromLng,
    );
    if (place case RepositoryFailure<GeoPlace> failure) {
      return RepositoryFailure<DirectionsRoute>(
        kind: failure.kind,
        message: failure.message,
        cause: failure.cause,
      );
    }
    final GeoPlace? match = place.valueOrNull;
    if (match == null) {
      return RepositoryFailure<DirectionsRoute>(
        kind: UserMessageKind.noResults,
        message: UserMessages.messageFor(UserMessageKind.noResults),
      );
    }
    return route(
      mode: mode,
      fromLat: fromLat,
      fromLng: fromLng,
      toLat: match.latitude,
      toLng: match.longitude,
    );
  }

  Uri autocompleteUri(
    String text, {
    int limit = AmpPolicy.searchSuggestionLimit,
    double? biasLat,
    double? biasLng,
  }) {
    final Map<String, String> query = <String, String>{
      'text': text.trim(),
      'limit':
          (limit < 1
                  ? 1
                  : limit > 5
                  ? 5
                  : limit)
              .toString(),
      'lang': 'en',
      'filter': AmpPolicy.geocodingCountryFilter,
    };
    if (biasLat != null &&
        biasLng != null &&
        biasLat.isFinite &&
        biasLng.isFinite) {
      // Geoapify's proximity bias is longitude first.
      query['bias'] =
          'proximity:${biasLng.toStringAsFixed(6)},'
          '${biasLat.toStringAsFixed(6)}';
    }
    query['apiKey'] = apiKey;
    return Uri.https(baseUrl, '/v1/geocode/autocomplete', query);
  }

  static String cacheKey(double latitude, double longitude) =>
      '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

  static String cacheKeyFor(
    TravelMode mode,
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    return '${mode.requestMode}:${cacheKey(fromLat, fromLng)}:'
        '${cacheKey(toLat, toLng)}';
  }

  Future<String> _get(Uri uri) async {
    final http.Response response = await _http
        .get(uri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeoapifyException(
        _technicalHttpFailure(response.statusCode),
        httpStatus: response.statusCode,
      );
    }
    return response.body;
  }

  static String _technicalHttpFailure(int code) {
    if (code == 401 || code == 403) {
      return 'Geoapify rejected the API key (HTTP $code).';
    }
    if (code == 429) {
      return 'Geoapify rate limit or daily credits exhausted (HTTP 429).';
    }
    if (code == 400) {
      return 'Geoapify rejected the request as invalid (HTTP 400).';
    }
    if (code >= 500) {
      return 'Geoapify is unavailable (HTTP $code).';
    }
    return 'Geoapify returned HTTP $code.';
  }

  void dispose() => _http.close();
}
