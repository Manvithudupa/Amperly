import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/auth/application/app_role.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/auth/application/role_providers.dart';
import 'package:amperly/features/auth/presentation/account_screen.dart';
import 'package:amperly/features/consumer/application/vehicle_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_role_store.dart';

void main() {
  testWidgets('an administrator can switch to the consumer shell', (
    WidgetTester tester,
  ) async {
    final FakeRoleStore store = FakeRoleStore(<String, AppRole>{
      'admin-1': AppRole.admin,
    });
    final GoRouter router = _accountRouter('/admin/account');

    await _pump(
      tester,
      router,
      store,
      const AppUser(
        id: 'admin-1',
        name: 'Desk',
        role: 'ADMIN',
        verificationStatus: 'VERIFIED',
      ),
    );

    expect(find.text(AmpStrings.accountActingAs.toUpperCase()), findsOneWidget);
    await tester.tap(find.text(AmpStrings.accountSwitchRole));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.accountConsumer), findsOneWidget);
    expect(find.text(AmpStrings.accountHost), findsOneWidget);
    expect(find.text(AmpStrings.accountAdmin), findsWidgets);

    await tester.tap(find.text(AmpStrings.accountConsumer));
    await tester.pumpAndSettle();

    expect(find.text('Discover target'), findsOneWidget);
    expect(store.roles['admin-1'], AppRole.consumer);
  });

  testWidgets('a consumer is not offered the administrator role', (
    WidgetTester tester,
  ) async {
    final FakeRoleStore store = FakeRoleStore(<String, AppRole>{
      'user-1': AppRole.consumer,
    });
    final GoRouter router = _accountRouter('/account');

    await _pump(
      tester,
      router,
      store,
      const AppUser(
        id: 'user-1',
        name: 'Asha',
        role: 'CONSUMER',
        verificationStatus: 'VERIFIED',
      ),
      vehicleOverride: true,
    );

    await tester.tap(find.text(AmpStrings.accountSwitchRole));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.accountConsumer), findsWidgets);
    expect(find.text(AmpStrings.accountHost), findsOneWidget);
    expect(find.text(AmpStrings.accountAdmin), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  GoRouter router,
  FakeRoleStore store,
  AppUser user, {
  bool vehicleOverride = false,
}) async {
  tester.view.physicalSize = const Size(460, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentProfileProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<AppUser>(user),
        ),
        roleStoreProvider.overrideWithValue(store),
        if (vehicleOverride)
          activeVehicleProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<Vehicle?>(null),
          ),
      ],
      child: MaterialApp.router(theme: AmpTheme.light(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

GoRouter _accountRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/account',
        builder: (BuildContext context, GoRouterState state) =>
            const AccountScreen(),
      ),
      GoRoute(
        path: '/admin/account',
        builder: (BuildContext context, GoRouterState state) =>
            const AccountScreen(),
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
}
