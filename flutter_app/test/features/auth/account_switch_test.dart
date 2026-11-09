import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/repository_providers.dart';
import 'package:amperly/data/repositories/repository_result.dart';
import 'package:amperly/features/auth/application/profile_providers.dart';
import 'package:amperly/features/auth/application/session_controller.dart';
import 'package:amperly/features/common/application/notification_providers.dart';
import 'package:amperly/features/consumer/application/booking_providers.dart';
import 'package:amperly/features/consumer/application/vehicle_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../support/fake_supabase.dart';

class _SwitchingSessionController extends SessionController {
  _SwitchingSessionController(this._initial);

  final SessionSnapshot _initial;

  @override
  SessionSnapshot build() => _initial;

  void switchTo(SessionSnapshot snapshot) => state = snapshot;
}

SessionSnapshot _signedIn(String userId) {
  final Session? session = Session.fromJson(<String, dynamic>{
    'access_token': 'access-$userId',
    'token_type': 'bearer',
    'expires_in': 3600,
    'expires_at':
        DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
        1000,
    'refresh_token': 'refresh-$userId',
    'user': <String, dynamic>{
      'id': userId,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': '$userId@example.com',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{'name': userId},
      'created_at': DateTime.now().toIso8601String(),
    },
  });
  expect(session, isNotNull, reason: 'test session JSON did not parse');
  return SessionSnapshot.fromSession(session);
}

void main() {
  test('switching accounts drops the previous account data', () async {
    final FakeSupabaseTransport transport = FakeSupabaseTransport((
      http.BaseRequest request,
    ) async {
      if (request.method != 'GET') {
        return fakeJson(null, status: 204);
      }
      final String path = request.url.path;
      final String consumerId = request.url.queryParameters['consumerId'] ?? '';
      final String userId = request.url.queryParameters['userId'] ?? '';

      if (path.contains('/rest/v1/reservations')) {
        if (consumerId.contains('profile-a')) {
          return fakeJson(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'reservation-a',
              'consumerId': 'profile-a',
              'status': 'RESERVED',
            },
          ]);
        }
        if (consumerId.contains('profile-b')) {
          return fakeJson(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'reservation-b',
              'consumerId': 'profile-b',
              'status': 'RESERVED',
            },
          ]);
        }
        return fakeJson(<Map<String, dynamic>>[]);
      }
      if (path.contains('/rest/v1/vehicles')) {
        if (userId.contains('profile-a')) {
          return fakeJson(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'vehicle-a',
              'userId': 'profile-a',
              'make': 'A',
              'isActive': true,
            },
          ]);
        }
        if (userId.contains('profile-b')) {
          return fakeJson(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'vehicle-b',
              'userId': 'profile-b',
              'make': 'B',
              'isActive': true,
            },
          ]);
        }
        return fakeJson(<Map<String, dynamic>>[]);
      }
      if (path.contains('/rest/v1/notifications')) {
        if (userId.contains('profile-a')) {
          return fakeJson(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'notice-a',
              'userId': 'profile-a',
              'title': 'A',
              'isRead': false,
              'createdAtMs': 1,
            },
          ]);
        }
        if (userId.contains('profile-b')) {
          return fakeJson(<Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'notice-b',
              'userId': 'profile-b',
              'title': 'B',
              'isRead': false,
              'createdAtMs': 2,
            },
          ]);
        }
        return fakeJson(<Map<String, dynamic>>[]);
      }
      return fakeJson(<Map<String, dynamic>>[]);
    });

    final ProviderContainer container = ProviderContainer(
      overrides: [
        supabaseClientProvider.overrideWithValue(fakeSupabaseClient(transport)),
        sessionProvider.overrideWith(
          () => _SwitchingSessionController(_signedIn('user-a')),
        ),
        currentProfileProvider.overrideWith((Ref ref) async {
          final SessionSnapshot session = ref.watch(sessionProvider);
          final String userId = session.userId ?? '';
          return RepositorySuccess<AppUser>(
            AppUser(
              id: userId == 'user-a' ? 'profile-a' : 'profile-b',
              name: userId,
            ),
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final firstReservations = await container.read(
      consumerReservationsProvider.future,
    );
    expect(
      firstReservations.failureOrNull,
      isNull,
      reason:
          '${firstReservations.failureOrNull?.message} / '
          '${firstReservations.failureOrNull?.cause}',
    );
    expect(firstReservations.valueOrNull!.single.consumerId, 'profile-a');
    final firstNotices = await container.read(notificationsProvider.future);
    expect(firstNotices.valueOrNull!.single.userId, 'profile-a');
    final firstVehicles = await container.read(vehicleGarageProvider.future);
    expect(firstVehicles.valueOrNull!.single.id, 'vehicle-a');

    final SessionController session = container.read(sessionProvider.notifier);
    (session as _SwitchingSessionController).switchTo(_signedIn('user-b'));

    final secondReservations = await container.read(
      consumerReservationsProvider.future,
    );
    expect(secondReservations.valueOrNull!.single.consumerId, 'profile-b');
    expect(
      secondReservations.valueOrNull!.any(
        (Reservation reservation) => reservation.consumerId == 'profile-a',
      ),
      isFalse,
    );

    final secondNotices = await container.read(notificationsProvider.future);
    expect(secondNotices.valueOrNull!.single.userId, 'profile-b');
    expect(
      secondNotices.valueOrNull!.any(
        (AppNotification notice) => notice.userId == 'profile-a',
      ),
      isFalse,
    );

    final secondVehicles = await container.read(vehicleGarageProvider.future);
    expect(secondVehicles.valueOrNull!.single.id, 'vehicle-b');
    expect(
      secondVehicles.valueOrNull!.any(
        (Vehicle vehicle) => vehicle.id == 'vehicle-a',
      ),
      isFalse,
    );
  });
}
