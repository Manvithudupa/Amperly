import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/consumer/application/vehicle_providers.dart';
import 'package:amperly/features/consumer/presentation/vehicle_garage_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the empty garage with an add action', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleGarageProvider.overrideWith(
            (Ref ref) async =>
                const RepositorySuccess<List<Vehicle>>(<Vehicle>[]),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const VehicleGarageScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.vehicleEmptyTitle), findsOneWidget);
    expect(find.text(AmpStrings.vehicleEmptyBody), findsOneWidget);
    expect(find.text(AmpStrings.vehicleAdd), findsOneWidget);
  });

  testWidgets('shows an active vehicle with its planning figures', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
    final String stats = AmpStrings.vehicleCardStats(
      vehicle.effectiveCapacityKwh,
      vehicle.effectiveEfficiencyKmPerKwh,
      (vehicle.effectiveCapacityKwh * vehicle.effectiveEfficiencyKmPerKwh)
          .round(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vehicleGarageProvider.overrideWith(
            (Ref ref) async =>
                const RepositorySuccess<List<Vehicle>>(<Vehicle>[vehicle]),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const VehicleGarageScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tata Nexon EV'), findsOneWidget);
    expect(find.text('KA 01 EV 1234 · CCS2'), findsOneWidget);
    expect(find.text(AmpStrings.vehicleActiveBadge), findsOneWidget);
    expect(find.text(stats), findsOneWidget);
    expect(find.text(AmpStrings.vehicleUseThis), findsNothing);
    expect(find.text(AmpStrings.vehicleAdd), findsOneWidget);
  });
}
