import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/widgets/amp_bottom_bar.dart';
import 'package:amperly/core/widgets/amp_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('every destination shows an icon and label', (
    WidgetTester tester,
  ) async {
    final List<int> taps = <int>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AmpTheme.light(),
        home: Scaffold(
          bottomNavigationBar: AmpBottomBar(
            destinations: const <AmpBottomDestination>[
              AmpBottomDestination(
                label: 'Discover',
                icon: AmpIconName.compass,
              ),
              AmpBottomDestination(label: 'Trips', icon: AmpIconName.route),
              AmpBottomDestination(label: 'Bookings', icon: AmpIconName.ticket),
              AmpBottomDestination(label: 'Messages', icon: AmpIconName.chat),
              AmpBottomDestination(label: 'Profile', icon: AmpIconName.user),
            ],
            currentIndex: 0,
            onSelected: taps.add,
          ),
        ),
      ),
    );

    expect(find.byType(AmpIcon), findsNWidgets(5));
    for (final String label in <String>[
      'Discover',
      'Trips',
      'Bookings',
      'Messages',
      'Profile',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('Messages'));
    expect(taps, <int>[3]);
  });
}
