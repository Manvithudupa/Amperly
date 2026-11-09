import 'dart:async';

import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_providers.dart';
import 'package:amperly/domain/policy.dart';
import 'package:amperly/features/consumer/presentation/booking_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../support/fake_supabase.dart';

class _CancellationHarness extends ConsumerWidget {
  const _CancellationHarness({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () =>
              confirmBookingCancellation(context, ref, reservation),
          child: const Text('Start cancellation'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('a second cancel tap waits for the in-flight request', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'POST' &&
          request.url.path.contains('cancel_reservation')) {
        await release.future;
        return fakeJson('cancelled');
      }
      return fakeJson(null, status: 204);
    });

    final int startMs = DateTime.now()
        .add(const Duration(hours: 5))
        .millisecondsSinceEpoch;
    final Reservation reservation = Reservation(
      id: 'reservation-1',
      stationId: 'station-1',
      startTimeMs: startMs,
      endTimeMs: startMs + 3600000,
      status: AmpPolicy.statusReserved,
    );

    tester.view.physicalSize = const Size(460, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(
            fakeSupabaseClient(transport),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: _CancellationHarness(reservation: reservation),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start cancellation'));
    await tester.pumpAndSettle();
    expect(find.text(AmpStrings.bookingCancelTitle), findsOneWidget);

    await tester.tap(find.text(AmpStrings.bookingCancelAction));
    await tester.pumpAndSettle();
    expect(transport.count('POST', 'cancel_reservation'), 1);

    await tester.tap(find.text('Start cancellation'));
    await tester.pump();
    expect(find.text(AmpStrings.bookingCancelTitle), findsNothing);
    expect(transport.count('POST', 'cancel_reservation'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });
}
