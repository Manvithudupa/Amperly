import 'dart:async';
import 'dart:io';

import 'package:amperly/core/errors/user_messages.dart';
import 'package:amperly/core/ui/strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('classify', () {
    test('transport failures are offline or timeout', () {
      expect(
        UserMessages.classify(SocketException('Failed host lookup')),
        UserMessageKind.offline,
      );
      expect(
        UserMessages.classify(http.ClientException('Connection closed')),
        UserMessageKind.offline,
      );
      expect(
        UserMessages.classify(TimeoutException('slow')),
        UserMessageKind.timeout,
      );
    });

    test('HTTP statuses map to their buckets', () {
      expect(UserMessages.classifyHttp(401), UserMessageKind.sessionExpired);
      expect(UserMessages.classifyHttp(403), UserMessageKind.permission);
      expect(UserMessages.classifyHttp(404), UserMessageKind.notFound);
      expect(UserMessages.classifyHttp(409), UserMessageKind.conflict);
      expect(UserMessages.classifyHttp(422), UserMessageKind.validation);
      expect(UserMessages.classifyHttp(429), UserMessageKind.rateLimited);
      expect(UserMessages.classifyHttp(503), UserMessageKind.server);
      expect(UserMessages.classifyHttp(0), UserMessageKind.offline);
    });

    test('PostgREST constraints are mapped without exposing SQL', () {
      expect(
        UserMessages.classify(
          const PostgrestException(
            message: 'duplicate key value violates unique constraint',
            code: '23505',
          ),
        ),
        UserMessageKind.conflict,
      );
      expect(
        UserMessages.classify(
          const PostgrestException(
            message: 'slot_unavailable: that slot is taken',
            code: 'P0001',
          ),
        ),
        UserMessageKind.slotTaken,
      );
      expect(
        UserMessages.classify(
          const PostgrestException(message: 'No rows found', code: 'PGRST116'),
        ),
        UserMessageKind.notFound,
      );
      expect(
        UserMessages.classify(
          const PostgrestException(
            message: 'new row violates row-level security policy',
            code: '42501',
          ),
        ),
        UserMessageKind.permission,
      );
      expect(
        UserMessages.classify(
          const PostgrestException(
            message: 'new row for relation violates check constraint',
            code: '23514',
          ),
        ),
        UserMessageKind.validation,
      );
      expect(
        UserMessages.classify(
          const PostgrestException(message: 'upstream unavailable'),
        ),
        UserMessageKind.server,
      );
    });

    test('auth failures have their own sentences', () {
      expect(
        UserMessages.classify(
          const AuthException(
            'Invalid login credentials',
            statusCode: '400',
            code: 'invalid_credentials',
          ),
        ),
        UserMessageKind.authInvalidCredentials,
      );
      expect(
        UserMessages.classify(
          const AuthException(
            'Email not confirmed',
            statusCode: '400',
            code: 'email_not_confirmed',
          ),
        ),
        UserMessageKind.authEmailUnconfirmed,
      );
      expect(
        UserMessages.classify(
          const AuthException(
            'User already registered',
            statusCode: '422',
            code: 'user_already_exists',
          ),
        ),
        UserMessageKind.authAlreadyRegistered,
      );
      expect(
        UserMessages.classify(
          const AuthException('JWT expired', statusCode: '401'),
        ),
        UserMessageKind.sessionExpired,
      );
      expect(
        UserMessages.classify(
          const AuthException(
            'AuthRetryableFetchException: failed host lookup',
          ),
        ),
        UserMessageKind.offline,
      );
      expect(
        UserMessages.classify(
          const AuthException('Forbidden', statusCode: '403'),
        ),
        UserMessageKind.permission,
      );
      expect(
        UserMessages.classify(
          const AuthException(
            'Signup requires a valid password',
            statusCode: '422',
          ),
        ),
        UserMessageKind.validation,
      );
    });

    test('Geoapify failures are map or result failures, never raw', () {
      expect(
        UserMessages.classify(Exception('Geoapify routing failed: 401 denied')),
        UserMessageKind.mapUnavailable,
      );
      expect(
        UserMessages.classify(
          Exception('Geoapify routing failed: no route between points'),
        ),
        UserMessageKind.noResults,
      );
      expect(
        UserMessages.fromTechnical('Geoapify autocomplete: 429 credits'),
        AmpStrings.errorRateLimited,
      );
    });

    test('unknown failures still get a written sentence', () {
      expect(
        UserMessages.classify(const FormatException('bad')),
        UserMessageKind.unknown,
      );
      expect(
        UserMessages.from(const FormatException('bad')),
        AmpStrings.errorUnknown,
      );
    });
  });

  group('messages', () {
    test('every kind has copy and it never leaks technical text', () {
      final Map<UserMessageKind, String> expected = <UserMessageKind, String>{
        UserMessageKind.offline: AmpStrings.errorOffline,
        UserMessageKind.timeout: AmpStrings.errorTimeout,
        UserMessageKind.sessionExpired: AmpStrings.errorSessionExpired,
        UserMessageKind.permission: AmpStrings.errorPermission,
        UserMessageKind.notFound: AmpStrings.errorNotFound,
        UserMessageKind.conflict: AmpStrings.errorConflict,
        UserMessageKind.slotTaken: AmpStrings.errorSlotTaken,
        UserMessageKind.validation: AmpStrings.errorValidation,
        UserMessageKind.rateLimited: AmpStrings.errorRateLimited,
        UserMessageKind.server: AmpStrings.errorServer,
        UserMessageKind.mapUnavailable: AmpStrings.errorMapUnavailable,
        UserMessageKind.noResults: AmpStrings.errorNoResults,
        UserMessageKind.authInvalidCredentials:
            AmpStrings.authInvalidCredentials,
        UserMessageKind.authEmailUnconfirmed: AmpStrings.authEmailUnconfirmed,
        UserMessageKind.authAlreadyRegistered: AmpStrings.authAlreadyRegistered,
        UserMessageKind.unknown: AmpStrings.errorUnknown,
      };

      for (final MapEntry<UserMessageKind, String> entry in expected.entries) {
        final String message = UserMessages.messageFor(entry.key);
        expect(message, entry.value);
        expect(message.trim(), isNotEmpty);

        final String lowered = message.toLowerCase();
        for (final String forbidden in <String>[
          'exception',
          'postgrest',
          'sql',
          '23505',
          'http',
          'geoapify',
          'supabase',
          'stack trace',
        ]) {
          expect(
            lowered,
            isNot(contains(forbidden)),
            reason: '${entry.key.name} leaked "$forbidden"',
          );
        }
      }
    });

    test('classifying an object returns only copy', () {
      final Object error = SocketException(
        'Failed host lookup: abcdefgh.supabase.co',
      );
      final String message = UserMessages.from(error);
      expect(message, AmpStrings.errorOffline);
      expect(message, isNot(contains('supabase')));
      expect(message, isNot(contains('abcdefgh')));
    });
  });
}
