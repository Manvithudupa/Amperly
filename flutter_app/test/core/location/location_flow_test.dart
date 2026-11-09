import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/location/device_location.dart';
import 'package:amperly/core/location/location_flow.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('explains before opening the system permission prompt', (
    WidgetTester tester,
  ) async {
    final _FakeLocationService service = _FakeLocationService(
      permission: DeviceLocationPermission.denied,
      fix: const DeviceLocationFix.found(13.34, 74.74),
    );
    DeviceLocationFix? result;

    await tester.pumpWidget(
      _Harness(
        service: service,
        onResult: (DeviceLocationFix fix) => result = fix,
      ),
    );

    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.locationPermissionTitle), findsOneWidget);
    expect(find.text(AmpStrings.locationPermissionBody), findsOneWidget);
    expect(service.checkCalls, 1);
    expect(service.currentCalls, 0);

    await tester.tap(find.text(AmpStrings.locationPermissionNotNow));
    await tester.pumpAndSettle();

    expect(result?.status, DeviceLocationStatus.permissionDenied);
    expect(service.currentCalls, 0);
  });

  testWidgets('requests the position only after the explanation is allowed', (
    WidgetTester tester,
  ) async {
    final _FakeLocationService service = _FakeLocationService(
      permission: DeviceLocationPermission.denied,
      fix: const DeviceLocationFix.found(13.34, 74.74),
    );
    DeviceLocationFix? result;

    await tester.pumpWidget(
      _Harness(
        service: service,
        onResult: (DeviceLocationFix fix) => result = fix,
      ),
    );

    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();
    expect(service.currentCalls, 0);

    await tester.tap(find.text(AmpStrings.locationPermissionAllow));
    await tester.pumpAndSettle();

    expect(service.currentCalls, 1);
    expect(result?.hasPosition, isTrue);
    expect(result?.latitude, 13.34);
    expect(result?.longitude, 74.74);
  });

  testWidgets('a silent startup check never opens the system prompt', (
    WidgetTester tester,
  ) async {
    final _FakeLocationService service = _FakeLocationService(
      permission: DeviceLocationPermission.denied,
      fix: const DeviceLocationFix.found(13.34, 74.74),
    );
    DeviceLocationFix? result;

    await tester.pumpWidget(
      _Harness(
        service: service,
        explainFirst: false,
        onResult: (DeviceLocationFix fix) => result = fix,
      ),
    );

    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.locationPermissionTitle), findsNothing);
    expect(result?.status, DeviceLocationStatus.permissionDenied);
    expect(service.checkCalls, 1);
    expect(service.currentCalls, 0);
  });

  testWidgets('a permanent denial returns recovery state without prompting', (
    WidgetTester tester,
  ) async {
    final _FakeLocationService service = _FakeLocationService(
      permission: DeviceLocationPermission.deniedForever,
      fix: const DeviceLocationFix.found(13.34, 74.74),
    );
    DeviceLocationFix? result;

    await tester.pumpWidget(
      _Harness(
        service: service,
        onResult: (DeviceLocationFix fix) => result = fix,
      ),
    );

    await tester.tap(find.text('Find'));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.locationPermissionTitle), findsNothing);
    expect(result?.status, DeviceLocationStatus.permissionDeniedForever);
    expect(service.currentCalls, 0);
  });
}

class _Harness extends StatelessWidget {
  const _Harness({
    required this.service,
    required this.onResult,
    this.explainFirst = true,
  });

  final DeviceLocationService service;
  final ValueChanged<DeviceLocationFix> onResult;
  final bool explainFirst;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AmpTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async {
              final DeviceLocationFix fix = await requestDeviceLocation(
                context,
                service,
                explainFirst: explainFirst,
              );
              onResult(fix);
            },
            child: const Text('Find'),
          ),
        ),
      ),
    );
  }
}

class _FakeLocationService implements DeviceLocationService {
  _FakeLocationService({required this.permission, required this.fix});

  final DeviceLocationPermission permission;
  final DeviceLocationFix fix;
  int checkCalls = 0;
  int currentCalls = 0;

  @override
  Future<DeviceLocationPermission> checkPermission() async {
    checkCalls += 1;
    return permission;
  }

  @override
  Future<DeviceLocationFix> current() async {
    currentCalls += 1;
    return fix;
  }

  @override
  Future<bool> openSettings() async => true;
}
