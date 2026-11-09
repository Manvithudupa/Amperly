import 'dart:async';

import 'package:amperly/app/theme/amp_theme.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_providers.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/common/application/notification_providers.dart';
import 'package:amperly/features/common/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../support/fake_supabase.dart';

void main() {
  testWidgets('a second Mark all tap sends one request', (
    WidgetTester tester,
  ) async {
    final Completer<void> release = Completer<void>();
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method == 'PATCH' &&
          request.url.path.contains('notifications')) {
        await release.future;
      }
      return fakeJson(null, status: 204);
    });
    final AppNotification notice = AppNotification(
      id: 'notice-1',
      userId: 'profile-1',
      title: 'Booking confirmed',
      message: 'Your port is held.',
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    tester.view.physicalSize = const Size(460, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(
            fakeSupabaseClient(transport),
          ),
          currentProfileProvider.overrideWith(
            (Ref ref) async =>
                const RepositorySuccess<AppUser>(AppUser(id: 'profile-1')),
          ),
          notificationsProvider.overrideWith(
            (Ref ref) async => RepositorySuccess<List<AppNotification>>(
              <AppNotification>[notice],
            ),
          ),
        ],
        child: MaterialApp(
          theme: AmpTheme.light(),
          home: const NotificationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AmpStrings.notificationsMarkAll));
    await tester.tap(find.text(AmpStrings.notificationsMarkAll));
    await tester.pump();

    expect(transport.count('PATCH', 'notifications'), 1);

    release.complete();
    await tester.pumpAndSettle();
  });
}
