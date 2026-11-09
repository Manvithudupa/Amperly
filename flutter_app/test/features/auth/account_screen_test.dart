import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/core/widgets/amp_badge.dart';
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

import '../../support/fake_role_store.dart';

void main() {
  testWidgets('renders identity, capacities and the active vehicle', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(460, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const AppUser profile = AppUser(
      id: 'user-1',
      name: 'Asha Rao',
      email: 'asha@example.com',
      role: 'CONSUMER',
      verificationStatus: 'VERIFIED',
    );
    const Vehicle vehicle = Vehicle(
      id: 'vehicle-1',
      userId: 'user-1',
      make: 'Tata',
      model: 'Nexon EV',
      batteryCapacityKwh: 40.5,
      connectorType: 'CCS2',
      typicalEfficiencyKmPerKwh: 6.5,
      batteryHealthPercent: 95,
      licensePlate: 'KA 01 EV 1234',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<AppUser>(profile),
          ),
          activeVehicleProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<Vehicle?>(vehicle),
          ),
          roleStoreProvider.overrideWithValue(
            FakeRoleStore(<String, AppRole>{'user-1': AppRole.consumer}),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const AccountScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Asha Rao'), findsOneWidget);
    expect(find.text('asha@example.com'), findsOneWidget);
    expect(find.text(AmpStrings.accountConsumer), findsWidgets);
    expect(find.text(AmpStrings.verified), findsOneWidget);
    expect(find.text('Tata Nexon EV'), findsOneWidget);
    expect(
      find.text(
        'CCS2 · ${vehicle.effectiveCapacityKwh.toStringAsFixed(1)} kWh usable',
      ),
      findsOneWidget,
    );
    expect(find.text('KA 01 EV 1234'), findsOneWidget);
    expect(find.text(AmpStrings.vehicleManage), findsOneWidget);
    expect(find.text(AmpStrings.authSignOut), findsOneWidget);
    expect(find.byType(AmpBadge), findsNothing);
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('a blocked profile carries the restriction notice', (
    WidgetTester tester,
  ) async {
    const AppUser blocked = AppUser(
      id: 'user-1',
      name: 'Asha Rao',
      email: 'asha@example.com',
      isBlocked: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<AppUser>(blocked),
          ),
          activeVehicleProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<Vehicle?>(null),
          ),
          roleStoreProvider.overrideWithValue(FakeRoleStore()),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const AccountScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.blockedTitle), findsOneWidget);
    expect(find.text(AmpStrings.blockedBody), findsOneWidget);
    expect(find.text(AmpStrings.accountNoVehicle), findsOneWidget);

    await tester.scrollUntilVisible(find.text(AmpStrings.authSignOut), 200);
    expect(find.text(AmpStrings.authSignOut), findsOneWidget);
  });

  testWidgets('an administrator sees only admin surfaces', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(460, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const AppUser admin = AppUser(
      id: 'admin-1',
      name: 'Admin',
      email: 'admin@amperly.app',
      role: 'ADMIN',
      verificationStatus: 'VERIFIED',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentProfileProvider.overrideWith(
            (Ref ref) async => const RepositorySuccess<AppUser>(admin),
          ),
          roleStoreProvider.overrideWithValue(
            FakeRoleStore(<String, AppRole>{'admin-1': AppRole.admin}),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const AccountScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.accountActingAs.toUpperCase()), findsOneWidget);
    expect(find.text(AmpStrings.accountSwitchRole), findsOneWidget);
    expect(find.text(AmpStrings.accountAdmin), findsWidgets);
    expect(find.text(AmpStrings.notificationsTitle), findsOneWidget);
    expect(find.text(AmpStrings.vehicleManage), findsNothing);
    expect(find.text(AmpStrings.hostTitle), findsNothing);
    expect(find.text(AmpStrings.accountChargingHistory), findsNothing);
    expect(find.text(AmpStrings.safetyTitle), findsNothing);
    expect(find.text(AmpStrings.accountNoVehicle), findsNothing);
  });
}
