import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/auth/application/app_role.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/auth/application/role_providers.dart';
import 'package:amperly/features/auth/presentation/role_landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_role_store.dart';

void main() {
  testWidgets('a blocked profile lands on the restriction screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<AppUser>(
              AppUser(
                id: 'blocked-1',
                name: 'Blocked',
                email: 'blocked@example.com',
                isBlocked: true,
              ),
            ),
          ),
          roleStoreProvider.overrideWithValue(FakeRoleStore()),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const RoleLandingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.blockedTitle), findsWidgets);
    expect(find.text(AmpStrings.discoverTitle), findsNothing);
  });

  testWidgets('an administrator with no memory opens the admin queue', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpLanding(
      tester,
      const AppUser(id: 'admin-1', role: 'ADMIN'),
      FakeRoleStore(),
    );

    expect(router.routeInformationProvider.value.uri.path, '/admin/queue');
    expect(find.text('Admin target'), findsOneWidget);
  });

  testWidgets('the remembered host role is restored', (
    WidgetTester tester,
  ) async {
    final FakeRoleStore store = FakeRoleStore(<String, AppRole>{
      'user-1': AppRole.host,
    });
    final GoRouter router = await _pumpLanding(
      tester,
      const AppUser(id: 'user-1', role: 'CONSUMER'),
      store,
    );

    expect(router.routeInformationProvider.value.uri.path, '/host/dashboard');
    expect(find.text('Host target'), findsOneWidget);
  });
}

Future<GoRouter> _pumpLanding(
  WidgetTester tester,
  AppUser user,
  FakeRoleStore store,
) async {
  final GoRouter router = GoRouter(
    initialLocation: '/start',
    routes: <RouteBase>[
      GoRoute(
        path: '/start',
        builder: (BuildContext context, GoRouterState state) =>
            const RoleLandingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) =>
            const Text('Discover target'),
      ),
      GoRoute(
        path: '/host/dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const Text('Host target'),
      ),
      GoRoute(
        path: '/admin/queue',
        builder: (BuildContext context, GoRouterState state) =>
            const Text('Admin target'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentProfileProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<AppUser>(user),
        ),
        roleStoreProvider.overrideWithValue(store),
      ],
      child: MaterialApp.router(theme: AmpTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}
