import 'dart:math' as math;

import 'package:amperly/app/theme/amp_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('light theme text contrast', () {
    test('named text pairs meet WCAG AA', () {
      _expectReadablePairs(AmpColors.light);
    });
  });

  group('dark theme text contrast', () {
    test('named text pairs meet WCAG AA', () {
      _expectReadablePairs(AmpColors.dark);
    });
  });
}

void _expectReadablePairs(AmpColors c) {
  final List<(String, Color, Color)> pairs = <(String, Color, Color)>[
    ('ink on background', c.ink, c.background),
    ('ink on surface', c.ink, c.surface),
    ('inkSecondary on background', c.inkSecondary, c.background),
    ('inkSecondary on surface', c.inkSecondary, c.surface),
    ('inkSecondary on surfaceVariant', c.inkSecondary, c.surfaceVariant),
    ('primary on background', c.primary, c.background),
    ('primary on surface', c.primary, c.surface),
    ('onPrimary on primary', c.onPrimary, c.primary),
    ('onPrimaryTint on primaryTint', c.onPrimaryTint, c.primaryTint),
    ('availableInk on availableTint', c.availableInk, c.availableTint),
    ('availableInk on surface', c.availableInk, c.surface),
    ('busyInk on busyTint', c.busyInk, c.busyTint),
    ('busyInk on background', c.busyInk, c.background),
    ('busyInk on energyTint', c.busyInk, c.energyTint),
    ('error on errorTint', c.error, c.errorTint),
    ('error on background', c.error, c.background),
    ('onError on error', c.onError, c.error),
    ('info on infoTint', c.info, c.infoTint),
    ('info on background', c.info, c.background),
    ('onEnergy on energy', c.onEnergy, c.energy),
    (
      'onInverseSurface on inverseSurface',
      c.onInverseSurface,
      c.inverseSurface,
    ),
  ];

  for (final (String name, Color foreground, Color background) in pairs) {
    expect(
      _ratio(foreground, background),
      greaterThanOrEqualTo(4.5),
      reason: '$name must meet WCAG AA for body text',
    );
  }
}

double _ratio(Color foreground, Color background) {
  final double first = foreground.computeLuminance();
  final double second = background.computeLuminance();
  final double lighter = math.max(first, second);
  final double darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}
