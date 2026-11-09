import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/strings.dart';
import '../../../core/widgets/amp_bottom_bar.dart';

/// The administrator's three destinations.
///
/// Consumer discovery and host tools do not belong on an admin account, so the
/// shell mirrors the native desk instead of the five consumer tabs.
class AdminTabBar extends StatelessWidget {
  const AdminTabBar({required this.currentIndex, super.key});

  final int currentIndex;

  static const List<AmpBottomDestination> _destinations =
      <AmpBottomDestination>[
        AmpBottomDestination(AmpStrings.adminTabQueue),
        AmpBottomDestination(AmpStrings.adminTabReports),
        AmpBottomDestination(AmpStrings.navProfile),
      ];

  static const List<String> _routes = <String>[
    '/admin',
    '/admin/reports',
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
