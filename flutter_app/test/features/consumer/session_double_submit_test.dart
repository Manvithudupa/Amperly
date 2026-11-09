import 'dart:async';

import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_providers.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/application/session_providers.dart';
import 'package:amperly/features/consumer/presentation/charging_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_supabase.dart';

SessionData _sessionData({
  required String reservationStatus,
  required String sessionStatus,
}) {
  final int startMs = DateTime.now()
      .subtract(const Duration(hours: 1))
      .millisecondsSinceEpoch;
  return SessionData(
    consumer: const AppUser(id: 'consumer-1'),
    reservation: Reservation(
      id: 'reservation-1',
      consumerId: 'consumer-1',
      stationId: 'station-1',
      stationName: 'Test charger',
      portId: 'port-1',
      status: reservationStatus,
      startTimeMs: startMs,
      endTimeMs: startMs + 3600000,
    ),
    station: const ChargerStation(
      id: 'station-1',
      hostId: 'host-1',
      name: 'Test charger',
      verificationLevel: AmpPolicy.level2SimulatedSmartMeter,
      pricePerKwh: 18,
      serviceFee: 5,
      gatewayFee: 4,
    ),
    session: ChargingSession(
      id: 'session-1',
      reservationId: 'reservation-1',
      stationId: 'station-1',
      stationName: 'Test charger',
      startingMeterKwh: 100,
      status: sessionStatus,
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  SessionData data,
  SupabaseClient client,
) async {
  tester.view.physicalSize = const Size(460, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supabaseClientProvider.overrideWithValue(client),
        sessionDataProvider(
          'reservation-1',
        ).overrideWith((Ref ref) async => RepositorySuccess<SessionData>(data)),
      ],
      child: MaterialApp(
        theme: AmpTheme.light(),
        home: const ChargingSessionScreen(reservationId: 'reservation-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a rapid second start tap sends one status request', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'PATCH' &&
          request.url.path.contains('charging_sessions')) {
        await release.future;
      }
      return fakeJson(null, status: 204);
    });

    await _pump(
      tester,
      _sessionData(
        reservationStatus: AmpPolicy.statusCheckedIn,
        sessionStatus: AmpPolicy.statusCheckedIn,
      ),
      fakeSupabaseClient(transport),
    );

    expect(find.text(AmpStrings.sessionStartChargingAction), findsOneWidget);
    await tester.tap(find.text(AmpStrings.sessionStartChargingAction));
    await tester.tap(find.text(AmpStrings.sessionStartChargingAction));
    await tester.pump();

    expect(transport.count('PATCH', 'charging_sessions'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('keyboard submit during settlement sends one finalize RPC', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'POST' &&
          request.url.path.contains('finalize_charging_session')) {
        await release.future;
      }
      return fakeJson('settled');
    });

    await _pump(
      tester,
      _sessionData(
        reservationStatus: AmpPolicy.statusCharging,
        sessionStatus: AmpPolicy.statusCharging,
      ),
      fakeSupabaseClient(transport),
    );

    final Finder field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, '110.0');
    await tester.pump();

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(transport.count('POST', 'finalize_charging_session'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });
}
