import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/admin_repository.dart';
import 'package:amperly/data/repositories/host_repository.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/data/repositories/safety_repository.dart';
import 'package:amperly/domain/engines/host_analytics_engine.dart';
import 'package:amperly/features/admin/application/admin_providers.dart';
import 'package:amperly/features/admin/presentation/admin_desk_screen.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/common/application/notification_providers.dart';
import 'package:amperly/features/common/presentation/notifications_screen.dart';
import 'package:amperly/features/consumer/application/safety_providers.dart';
import 'package:amperly/features/consumer/presentation/report_screen.dart';
import 'package:amperly/features/consumer/presentation/safety_screen.dart';
import 'package:amperly/features/host/application/host_providers.dart';
import 'package:amperly/features/host/presentation/host_workspace_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('host workspace shows performance and station actions', (
    WidgetTester tester,
  ) async {
    const AppUser host = AppUser(id: 'host-1', name: 'Asha Rao', role: 'HOST');
    final HostAnalytics analytics = HostAnalyticsEngine.compute();
    final HostWorkspaceData data = HostWorkspaceData(
      stations: const <HostStationEntry>[],
      sessions: const <ChargingSession>[],
      reservations: const <Reservation>[],
      invoices: const <Invoice>[],
      disputes: const <Dispute>[],
      analytics: analytics,
    );

    await _pump(
      tester,
      HostWorkspaceScreen(),
      overrides: <Object>[
        currentProfileProvider.overrideWith(
          (Ref ref) async => const RepositorySuccess<AppUser>(host),
        ),
        hostWorkspaceProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<HostWorkspaceData>(data),
        ),
      ],
    );

    expect(find.text(AmpStrings.hostTitle), findsOneWidget);
    expect(find.text(AmpStrings.hostTabDashboard), findsOneWidget);
    expect(find.text(AmpStrings.hostIncomeLabel.toUpperCase()), findsOneWidget);
    expect(find.text(AmpStrings.hostTabStations), findsOneWidget);

    await tester.tap(find.text(AmpStrings.hostTabStations));
    await tester.pumpAndSettle();

    expect(find.text(AmpStrings.hostNoStationsTitle), findsOneWidget);
    expect(find.text(AmpStrings.hostAddStation), findsWidgets);
  });

  testWidgets('admin desk lists pending listings and reports', (
    WidgetTester tester,
  ) async {
    final ChargerStation pending = ChargerStation(
      id: 'station-1',
      name: 'Pending Charger',
      address: 'Nitte',
      hostName: 'Asha Rao',
      approvalStatus: 'PENDING',
      verificationLevel: 'LEVEL_1',
      portCount: 2,
    );
    final AdminDeskData data = AdminDeskData(
      pendingStations: <ChargerStation>[pending],
      disputes: const <AdminDisputeRow>[],
      consumerReports: const <AdminReportRow>[],
      hostReports: const <AdminReportRow>[],
      analytics: HostAnalyticsEngine.compute(),
    );

    await _pump(
      tester,
      const AdminDeskScreen(),
      overrides: <Object>[
        adminDeskProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<AdminDeskData>(data),
        ),
      ],
    );

    expect(find.text(AmpStrings.adminTitle), findsOneWidget);
    expect(find.text('Pending Charger'), findsOneWidget);
    expect(find.text(AmpStrings.adminApprove), findsOneWidget);

    await tester.tap(find.text(AmpStrings.adminTabReports).first);
    await tester.pumpAndSettle();

    expect(
      find.text(AmpStrings.adminReportsTitle.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(AmpStrings.adminReportsEmpty), findsNWidgets(2));
  });

  testWidgets('safety screen records contacts and SOS controls', (
    WidgetTester tester,
  ) async {
    final SafetyData data = SafetyData(
      contacts: const <TrustedContact>[
        TrustedContact(
          id: 'contact-1',
          userId: 'user-1',
          name: 'Ravi',
          phone: '9876543210',
        ),
      ],
      events: const <SafetyEvent>[],
      activeSharing: null,
    );

    await _pump(
      tester,
      const SafetyScreen(),
      overrides: <Object>[
        safetyDataProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<SafetyData>(data),
        ),
      ],
    );

    expect(find.text(AmpStrings.safetyTitle), findsOneWidget);
    expect(find.text(AmpStrings.safetySosButton), findsOneWidget);
    expect(find.text('Ravi'), findsOneWidget);
    expect(find.text(AmpStrings.safetyShareStart), findsOneWidget);
  });

  testWidgets('report screen names the charger and offers report types', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      const ReportScreen(
        stationId: 'station-1',
        stationName: 'Nitte Community Charger',
      ),
    );

    expect(find.text(AmpStrings.reportTitle), findsOneWidget);
    expect(find.text('Nitte Community Charger'), findsOneWidget);
    expect(find.text(AmpStrings.reportTypeUnsafe), findsOneWidget);
    expect(find.text(AmpStrings.reportSubmit), findsOneWidget);
  });

  testWidgets('notifications render unread rows and mark all action', (
    WidgetTester tester,
  ) async {
    final AppNotification notice = AppNotification(
      id: 'notice-1',
      userId: 'user-1',
      title: 'Booking confirmed',
      message: 'Your port is held.',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    await _pump(
      tester,
      const NotificationsScreen(),
      overrides: <Object>[
        notificationsProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<List<AppNotification>>(
            <AppNotification>[notice],
          ),
        ),
      ],
    );

    expect(find.text(AmpStrings.notificationsTitle), findsOneWidget);
    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.text(AmpStrings.notificationsMarkAll), findsOneWidget);
    expect(find.text(AmpStrings.notificationsUnread), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  List<Object> overrides = const <Object>[],
}) async {
  tester.view.physicalSize = const Size(460, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(theme: AmpTheme.light(), home: screen),
    ),
  );
  await tester.pumpAndSettle();
}
