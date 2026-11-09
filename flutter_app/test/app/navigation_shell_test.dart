import 'package:amperly/app/navigation_shell.dart';
import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/widgets/amp_bottom_bar.dart';
import 'package:amperly/features/auth/application/app_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('tab switches preserve the first branch text field', (
    WidgetTester tester,
  ) async {
    final GoRouter router = _shellRouter();

    await tester.pumpWidget(
      MaterialApp.router(theme: AmpTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AmpBottomBar), findsOneWidget);
    await tester.enterText(find.byKey(_discoverField), 'Udupi');
    expect(find.text('Udupi'), findsOneWidget);

    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(find.text('Trips page'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Udupi'), findsOneWidget);
    expect(find.text('Trips page'), findsNothing);
  });

  testWidgets('back on a non-first tab returns to the first tab', (
    WidgetTester tester,
  ) async {
    final GoRouter router = _shellRouter();

    await tester.pumpWidget(
      MaterialApp.router(theme: AmpTheme.light(), routerConfig: router),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Trips'));
    await tester.pumpAndSettle();
    expect(find.text('Trips page'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byKey(_discoverField), findsOneWidget);
    expect(find.text('Trips page'), findsNothing);
  });
}

const Key _discoverField = Key('discover-field');

GoRouter _shellRouter() {
  return GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AmpShellFrame(
              navigationShell: navigationShell,
              role: AppRole.consumer,
            ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) {
                  return Scaffold(body: TextField(key: _discoverField));
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/trips',
                builder: (BuildContext context, GoRouterState state) =>
                    const Scaffold(body: Text('Trips page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/bookings',
                builder: (BuildContext context, GoRouterState state) =>
                    const Scaffold(body: Text('Bookings page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/messages',
                builder: (BuildContext context, GoRouterState state) =>
                    const Scaffold(body: Text('Messages page')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/account',
                builder: (BuildContext context, GoRouterState state) =>
                    const Scaffold(body: Text('Account page')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
