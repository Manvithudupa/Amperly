import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_bottom_bar.dart';

/// The five top-level consumer destinations.
///
/// Tab taps replace the current route instead of pushing another page, so the
/// bar stays visible and no back arrow appears on a top-level screen.
class ConsumerTabBar extends StatelessWidget {
  const ConsumerTabBar({required this.currentIndex, super.key});

  final int currentIndex;

  static const List<AmpBottomDestination> _destinations =
      <AmpBottomDestination>[
        AmpBottomDestination(AmpStrings.navDiscover),
        AmpBottomDestination(AmpStrings.navTrips),
        AmpBottomDestination(AmpStrings.navBookings),
        AmpBottomDestination(AmpStrings.navMessages),
        AmpBottomDestination(AmpStrings.navProfile),
      ];

  static const List<String> _routes = <String>[
    '/home',
    '/trips',
    '/bookings',
    '/messages',
    '/account',
  ];

  @override
  Widget build(BuildContext context) {
    return AmpBottomBar(
      destinations: _destinations,
      currentIndex: currentIndex,
      onSelected: (int index) {
        if (index == currentIndex) {
          return;
        }
        context.go(_routes[index]);
      },
    );
  }
}
