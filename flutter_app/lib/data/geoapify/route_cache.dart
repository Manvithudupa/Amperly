import 'dart:collection';

import '../../domain/policy.dart';
import 'geoapify_models.dart';

final class RouteCache {
  RouteCache({
    int capacity = AmpPolicy.routeCacheCapacity,
    int ttlMs = AmpPolicy.routeCacheTtlMinutes * 60 * 1000,
  }) : _capacity = capacity < 1 ? 1 : capacity,
       _ttlMs = ttlMs < 1 ? 1 : ttlMs;

  final int _capacity;
  final int _ttlMs;
  final LinkedHashMap<String, _CachedRoute> _entries =
      LinkedHashMap<String, _CachedRoute>();

  DirectionsRoute? get(String? key, int nowMs) {
    if (key == null) {
      return null;
    }
    final _CachedRoute? entry = _entries.remove(key);
    if (entry == null) {
      return null;
    }
    if (entry.expiresAtMs <= nowMs) {
      return null;
    }
    _entries[key] = entry;
    return entry.route;
  }

  void put(String? key, DirectionsRoute? route, int nowMs) {
    if (key == null || route == null) {
      return;
    }
    _entries.remove(key);
    _entries[key] = _CachedRoute(route, nowMs + _ttlMs);
    while (_entries.length > _capacity) {
      _entries.remove(_entries.keys.first);
    }
  }

  int get size => _entries.length;

  void clear() => _entries.clear();
}

final class _CachedRoute {
  const _CachedRoute(this.route, this.expiresAtMs);

  final DirectionsRoute route;
  final int expiresAtMs;
}
