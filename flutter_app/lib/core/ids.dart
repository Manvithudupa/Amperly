import 'dart:math';

final Random _secureRandom = Random.secure();

/// A local identifier for an engine-produced row before it reaches Postgres.
String newId([String prefix = '']) {
  final StringBuffer buffer = StringBuffer(prefix);
  for (int i = 0; i < 16; i++) {
    buffer.write(_secureRandom.nextInt(16).toRadixString(16));
  }
  return buffer.toString();
}
