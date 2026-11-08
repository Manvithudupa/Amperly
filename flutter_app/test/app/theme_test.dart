import 'package:amperly/app/theme/amp_colors.dart';
import 'package:amperly/app/theme/amp_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('light theme installs AmpColors and the reading typeface', (
    WidgetTester tester,
  ) async {
    late AmpColors colors;
    late ThemeData theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: Builder(
          builder: (BuildContext context) {
            colors = context.amp;
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors.background, AmpColors.light.background);
    expect(colors.primary, AmpColors.light.primary);
    expect(theme.brightness, Brightness.light);
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
    expect(theme.textTheme.displayLarge?.fontFamily, AmpTheme.displayFont);
    expect(theme.textTheme.bodyLarge?.fontFamily, AmpTheme.uiFont);
    expect(theme.scaffoldBackgroundColor, AmpColors.light.background);
  });

  testWidgets('dark theme is a role swap, not an inverted filter', (
    WidgetTester tester,
  ) async {
    late AmpColors colors;
    late ThemeData theme;

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.dark(),
        home: Builder(
          builder: (BuildContext context) {
            colors = context.amp;
            theme = Theme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors.background, AmpColors.dark.background);
    expect(colors.ink, AmpColors.dark.ink);
    expect(colors.ink, isNot(AmpColors.light.ink));
    expect(theme.brightness, Brightness.dark);
    expect(theme.colorScheme.surfaceTint, Colors.transparent);
  });
}
