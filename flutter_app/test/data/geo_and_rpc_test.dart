import 'dart:convert';

import 'package:amperly/data/geoapify/geoapify_client.dart';
import 'package:amperly/data/geoapify/geoapify_models.dart';
import 'package:amperly/data/geoapify/geoapify_place_parser.dart';
import 'package:amperly/data/geoapify/geoapify_route_parser.dart';
import 'package:amperly/data/geoapify/request_sequence.dart';
import 'package:amperly/data/geoapify/request_throttle.dart';
import 'package:amperly/data/geoapify/route_cache.dart';
import 'package:amperly/data/models/models.dart';
import 'package:amperly/data/repositories/profile_repository.dart';
import 'package:amperly/data/repositories/rpc_repository.dart';
import 'package:amperly/domain/policy.dart';
import 'package:flutter_test/flutter_test.dart';

const String autocompleteFixture = '''
{"features":[
 {"properties":{"place_id":"p1","formatted":"MG Road, Bengaluru","address_line1":"MG Road","lat":12.975,"lon":77.606},
  "geometry":{"coordinates":[77.606,12.975]}},
 {"properties":{"formatted":"Second place","lat":12.9,"lon":77.5}}
]}
''';

const String routeFixture = '''
{"features":[{"properties":{
  "distance":1500,"time":120,
  "legs":[{"steps":[{"distance":1500,"time":120,"from_index":1,
    "instruction":{"text":"Turn left","type":"turn-left"}}]}]
},"geometry":{"type":"LineString","coordinates":[[77.1,12.1],[77.2,12.2]]}}]}
''';

void main() {
  test('place parser reads lat/lon, geometry fallback and limits', () {
    final places = GeoapifyPlaceParser.parseSuggestions(autocompleteFixture, 5);
    expect(places.length, 2);
    expect(places.first.label, 'MG Road');
    expect(places.first.latitude, 12.975);
    expect(places.first.longitude, 77.606);

    final fallback = GeoapifyPlaceParser.parseSuggestions(
      '{"features":[{"properties":{"formatted":"Fallback"},"geometry":{"coordinates":[77.5,12.9]}}]}',
      5,
    );
    expect(fallback.single.latitude, 12.9);
    expect(fallback.single.longitude, 77.5);
    expect(GeoapifyPlaceParser.parseSuggestions('not json', 5), isEmpty);
  });

  test(
    'route parser flips GeoJSON order, keeps steps and never claims traffic',
    () {
      final route = GeoapifyRouteParser.parse(routeFixture);
      expect(route.points.length, 2);
      expect(route.points.first, const GeoPoint(12.1, 77.1));
      expect(route.distanceKm, 1.5);
      expect(route.durationMinutes, 2);
      expect(route.durationInTrafficMinutes, 0);
      expect(route.steps.single.instruction, 'Turn left');
      expect(route.steps.single.startLat, 12.2);
      expect(route.approximate, isFalse);
      expect(
        () => GeoapifyRouteParser.parse('{}'),
        throwsA(isA<GeoapifyException>()),
      );
    },
  );

  test(
    'autocomplete URI keeps proximity longitude-first and country filter',
    () {
      final client = GeoapifyClient(apiKey: 'test-key');
      final uri = client.autocompleteUri(
        'MG Road',
        limit: 5,
        biasLat: 12.9,
        biasLng: 77.6,
      );
      expect(uri.queryParameters['filter'], AmpPolicy.geocodingCountryFilter);
      expect(uri.queryParameters['bias'], 'proximity:77.600000,12.900000');
      expect(uri.queryParameters['apiKey'], 'test-key');
      expect(uri.queryParameters['limit'], '5');
      client.dispose();
    },
  );

  test('route cache expires and evicts least recently used entries', () {
    final cache = RouteCache(capacity: 2, ttlMs: 1000);
    final route = DirectionsRoute.straightLineEstimate(12, 77, 13, 78, 45);
    cache.put('a', route, 0);
    cache.put('b', route, 0);
    expect(cache.get('a', 500), same(route));
    cache.put('c', route, 600);
    expect(cache.size, 2);
    expect(cache.get('b', 700), isNull);
    expect(cache.get('a', 2000), isNull);
  });

  test('throttle allows four starts and delays the fifth', () {
    final throttle = RequestThrottle();
    for (int i = 0; i < 4; i++) {
      expect(throttle.reserveDelayMs(0), 0);
    }
    expect(throttle.reserveDelayMs(0), 1000);
    expect(throttle.inWindow(1001), 1);
  });

  test('request sequence discards stale answers', () {
    final sequence = RequestSequence();
    final first = sequence.next();
    final second = sequence.next();
    expect(sequence.isCurrent(first), isFalse);
    expect(sequence.isCurrent(second), isTrue);
  });

  test('models preserve exact PostgREST keys and defaults', () {
    final station = ChargerStation.fromJson(<String, dynamic>{
      'id': 'st_1',
      'pricePerKwh': 18,
      'approvalStatus': 'APPROVED',
      'connectorTypes': 'CCS_2_DC,TYPE_2_AC',
      'serverUpdatedAt': '2026-11-08T00:00:00Z',
    });
    expect(station.serviceFee, 0);
    expect(station.isPaused, isFalse);
    expect(station.connectorTypeList.length, 2);
    expect(station.toJson()['serverUpdatedAt'], '2026-11-08T00:00:00Z');

    final notification = AppNotification.fromJson(<String, dynamic>{
      'id': 'n1',
      'userId': 'u1',
      'title': 'Approved',
      'isRead': false,
      'createdAtMs': 1,
    });
    expect(notification.userId, 'u1');
    expect(notification.toJson()['createdAtMs'], 1);
  });

  test('profile fallback writes the exact old self-profile row', () {
    final row = ProfileRepository.newUserProfileRow(
      id: 'u1',
      email: 'a@b.c',
      displayName: 'A',
    );
    expect(
      row.keys,
      containsAll(<String>[
        'id',
        'authUserId',
        'email',
        'name',
        'phone',
        'role',
        'organizationName',
        'verificationStatus',
        'isBlocked',
      ]),
    );
    expect(row['role'], AmpPolicy.roleConsumer);
    expect(jsonEncode(row), contains('authUserId'));
  });

  test('RPC payloads match the schema parameter names exactly', () {
    final create = RpcPayloads.createReservation(
      id: 'r1',
      stationId: 'st1',
      portId: 'p1',
      startMs: 10,
      endMs: 20,
      bookingCode: 'AMP-ABC234',
    );
    expect(create.keys, <String>[
      'p_id',
      'p_station_id',
      'p_port_id',
      'p_start_ms',
      'p_end_ms',
      'p_booking_code',
    ]);
    expect(
      RpcPayloads.finalizeChargingSession(
        sessionId: 's',
        reservationId: 'r',
        startMeterKwh: 1,
        endMeterKwh: 2,
        isSimulated: true,
        meterReadingId: 'm',
        invoiceId: 'i',
      ).keys,
      contains('p_is_simulated'),
    );
    expect(
      RpcPayloads.decideStationApproval(stationId: 'st', approve: true),
      <String, Object?>{'p_station_id': 'st', 'p_approve': true},
    );
    expect(
      RpcPayloads.applyHostEnforcement(
        disputeId: 'd',
        action: AmpPolicy.enforcementWarning,
        fineAmount: 0,
        note: 'n',
      ).keys,
      contains('p_fine_amount'),
    );
  });
}
