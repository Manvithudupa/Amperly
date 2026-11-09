import 'dart:async';

import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/admin_repository.dart';
import 'package:amperly/data/repositories/repository_providers.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/domain/engines/host_analytics_engine.dart';
import 'package:amperly/features/admin/application/admin_providers.dart';
import 'package:amperly/features/admin/presentation/admin_desk_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_supabase.dart';

AdminDeskData _deskData({
  List<ChargerStation> pendingStations = const <ChargerStation>[],
  List<AdminDisputeRow> disputes = const <AdminDisputeRow>[],
  List<AdminReportRow> consumerReports = const <AdminReportRow>[],
}) {
  return AdminDeskData(
    pendingStations: pendingStations,
    disputes: disputes,
    consumerReports: consumerReports,
    hostReports: const <AdminReportRow>[],
    analytics: HostAnalyticsEngine.compute(),
  );
}

Future<void> _pump(
  WidgetTester tester,
  AdminDeskScreen screen,
  SupabaseClient client,
  AdminDeskData data,
) async {
  tester.view.physicalSize = const Size(460, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(client),
        adminDeskProvider.overrideWith(
          (Ref ref) async => RepositorySuccess<AdminDeskData>(data),
        ),
      ],
      child: MaterialApp(theme: AmpTheme.light(), home: screen),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a second decline tap does not open another decision', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'POST' &&
          request.url.path.contains('decide_station_approval')) {
        await release.future;
      }
      return fakeJson('ok');
    });
    final ChargerStation pending = ChargerStation(
      id: 'station-1',
      name: 'Pending Charger',
      address: 'Nitte',
      hostName: 'Asha Rao',
      approvalStatus: 'PENDING',
      verificationLevel: 'LEVEL_1',
      portCount: 2,
    );

    await _pump(
      tester,
      const AdminDeskScreen(),
      fakeSupabaseClient(transport),
      _deskData(pendingStations: <ChargerStation>[pending]),
    );

    await tester.tap(find.text(AmpStrings.adminDecline));
    await tester.pumpAndSettle();
    expect(find.text(AmpStrings.adminConfirmDeclineTitle), findsOneWidget);

    await tester.tap(find.text(AmpStrings.adminDecline).last);
    await tester.pumpAndSettle();
    expect(transport.count('POST', 'decide_station_approval'), 1);

    await tester.tap(find.text(AmpStrings.adminDecline));
    await tester.pump();
    expect(find.text(AmpStrings.adminConfirmDeclineTitle), findsNothing);
    expect(transport.count('POST', 'decide_station_approval'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a second refund tap while pending does not ask again', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'POST' &&
          request.url.path.contains('resolve_dispute_refund')) {
        await release.future;
      }
      return fakeJson('ok');
    });
    final Dispute dispute = Dispute(
      id: 'dispute-1',
      status: 'OPEN',
      stationName: 'Test station',
      consumerName: 'Asha',
      reason: 'Meter reading mismatch',
    );

    await _pump(
      tester,
      const AdminDeskScreen(section: AdminDeskSection.reports),
      fakeSupabaseClient(transport),
      _deskData(
        disputes: <AdminDisputeRow>[
          AdminDisputeRow(
            dispute: dispute,
            evidence: const <MeterReading>[],
            session: null,
          ),
        ],
      ),
    );

    await tester.tap(find.text(AmpStrings.adminDisputeRefund));
    await tester.pumpAndSettle();
    expect(find.text(AmpStrings.adminConfirmRefundTitle), findsOneWidget);

    await tester.tap(find.text(AmpStrings.adminRefundAction));
    await tester.pumpAndSettle();
    expect(transport.count('POST', 'resolve_dispute_refund'), 1);

    await tester.tap(find.text(AmpStrings.adminDisputeRefund));
    await tester.pump();
    expect(find.text(AmpStrings.adminConfirmRefundTitle), findsNothing);
    expect(transport.count('POST', 'resolve_dispute_refund'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('a second report warning does not record twice', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'POST' &&
          request.url.path.contains('host_enforcements')) {
        await release.future;
      }
      return fakeJson(null, status: 204);
    });
    final Report report = Report(
      id: 'report-1',
      reporterId: 'consumer-1',
      targetHostId: 'host-1',
      reportType: 'Safety',
      description: 'Blocked charger bay',
      status: 'OPEN',
    );

    await _pump(
      tester,
      const AdminDeskScreen(section: AdminDeskSection.reports),
      fakeSupabaseClient(transport),
      _deskData(
        consumerReports: <AdminReportRow>[
          AdminReportRow(
            report: report,
            reporterName: 'Asha',
            targetName: 'Ravi',
            targetUserId: 'host-1',
            isHostReport: false,
          ),
        ],
      ),
    );

    await tester.tap(find.text(AmpStrings.adminReportWarning));
    await tester.pumpAndSettle();
    expect(find.text(AmpStrings.adminConfirmWarningTitle), findsOneWidget);

    await tester.tap(find.text(AmpStrings.adminWarningAction));
    await tester.pumpAndSettle();
    expect(transport.count('POST', 'host_enforcements'), 1);

    await tester.tap(find.text(AmpStrings.adminReportWarning));
    await tester.pump();
    expect(find.text(AmpStrings.adminConfirmWarningTitle), findsNothing);
    expect(transport.count('POST', 'host_enforcements'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });
}
