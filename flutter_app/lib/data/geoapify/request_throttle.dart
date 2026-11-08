import 'dart:collection';

import '../../domain/policy.dart';

final class RequestThrottle {
  RequestThrottle({
    int maxPerWindow = AmpPolicy.routingStartsPerSecond,
    int windowMs = 1000,
  }) : _maxPerWindow = maxPerWindow < 1 ? 1 : maxPerWindow,
       _windowMs = windowMs < 1 ? 1 : windowMs;

  final int _maxPerWindow;
  final int _windowMs;
  final ListQueue<int> _starts = ListQueue<int>();

  int reserveDelayMs(int nowMs) {
    _prune(nowMs);
    if (_starts.length < _maxPerWindow) {
      _starts.addLast(nowMs);
      return 0;
    }
    final int startAt = _starts.first + _windowMs;
    final int reservedAt = startAt < nowMs ? nowMs : startAt;
    _starts.addLast(reservedAt);
    return reservedAt - nowMs;
  }

  int inWindow(int nowMs) {
    _prune(nowMs);
    return _starts.length;
  }

  void _prune(int nowMs) {
    while (_starts.isNotEmpty && _starts.first <= nowMs - _windowMs) {
      _starts.removeFirst();
    }
  }
}
