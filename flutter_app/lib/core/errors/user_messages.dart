import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../ui/strings.dart';

/// What a failure means to a person. One bucket per sentence.
enum UserMessageKind {
  offline,
  timeout,
  sessionExpired,
  permission,
  notFound,
  conflict,
  slotTaken,
  validation,
  rateLimited,
  server,
  mapUnavailable,
  noResults,
  authInvalidCredentials,
  authEmailUnconfirmed,
  authAlreadyRegistered,
  unknown,
}

/// The single place that turns a technical failure into plain language.
///
/// Nothing here returns exception text, a status code, a table name, a URL or
/// a key. Technical detail is logged as a type only in debug builds; the screen
/// gets a written sentence from [AmpStrings].
abstract final class UserMessages {
  /// The friendly sentence for any error, with an optional HTTP status.
  static String from(Object? error, {int? httpStatus}) {
    final UserMessageKind kind = classify(error, httpStatus: httpStatus);
    if (kDebugMode && error != null) {
      debugPrint('UserMessages: ${error.runtimeType} -> ${kind.name}');
    }
    return messageFor(kind);
  }

  /// For a stored technical message (a failed write, a gateway refusal).
  static String fromTechnical(String technicalText) {
    final UserMessageKind kind = _fromText(technicalText);
    return messageFor(
      kind == UserMessageKind.unknown ? UserMessageKind.server : kind,
    );
  }

  static String messageFor(UserMessageKind kind) {
    return switch (kind) {
      UserMessageKind.offline => AmpStrings.errorOffline,
      UserMessageKind.timeout => AmpStrings.errorTimeout,
      UserMessageKind.sessionExpired => AmpStrings.errorSessionExpired,
      UserMessageKind.permission => AmpStrings.errorPermission,
      UserMessageKind.notFound => AmpStrings.errorNotFound,
      UserMessageKind.conflict => AmpStrings.errorConflict,
      UserMessageKind.slotTaken => AmpStrings.errorSlotTaken,
      UserMessageKind.validation => AmpStrings.errorValidation,
      UserMessageKind.rateLimited => AmpStrings.errorRateLimited,
      UserMessageKind.server => AmpStrings.errorServer,
      UserMessageKind.mapUnavailable => AmpStrings.errorMapUnavailable,
      UserMessageKind.noResults => AmpStrings.errorNoResults,
      UserMessageKind.authInvalidCredentials =>
        AmpStrings.authInvalidCredentials,
      UserMessageKind.authEmailUnconfirmed => AmpStrings.authEmailUnconfirmed,
      UserMessageKind.authAlreadyRegistered => AmpStrings.authAlreadyRegistered,
      UserMessageKind.unknown => AmpStrings.errorUnknown,
    };
  }

  static UserMessageKind classify(
    Object? error, {
    int? httpStatus,
    String? technicalText,
  }) {
    if (technicalText != null && technicalText.trim().isNotEmpty) {
      final UserMessageKind fromContext = _fromText(technicalText);
      if (fromContext != UserMessageKind.unknown) {
        return fromContext;
      }
    }
    if (error is AuthException) {
      return _fromAuth(error);
    }
    if (error is PostgrestException) {
      return _fromPostgrest(error);
    }
    if (error is SocketException) {
      return UserMessageKind.offline;
    }
    if (error is TimeoutException) {
      return UserMessageKind.timeout;
    }
    if (error is http.ClientException) {
      return UserMessageKind.offline;
    }
    if (error is int) {
      return classifyHttp(error);
    }
    if (error != null) {
      final UserMessageKind fromError = _fromText(error.toString());
      if (fromError != UserMessageKind.unknown) {
        return fromError;
      }
    }
    if (httpStatus != null) {
      return classifyHttp(httpStatus);
    }
    return UserMessageKind.unknown;
  }

  static UserMessageKind classifyHttp(int status) {
    if (status <= 0) {
      return UserMessageKind.offline;
    }
    return switch (status) {
      400 || 422 => UserMessageKind.validation,
      401 => UserMessageKind.sessionExpired,
      403 => UserMessageKind.permission,
      404 => UserMessageKind.notFound,
      409 => UserMessageKind.conflict,
      429 => UserMessageKind.rateLimited,
      >= 500 => UserMessageKind.server,
      _ => UserMessageKind.unknown,
    };
  }

  static UserMessageKind _fromAuth(AuthException error) {
    final String code = (error.code ?? '').toLowerCase();
    final String text = error.message.toLowerCase();

    if (text.contains('authretryablefetch') ||
        text.contains('failed host lookup') ||
        text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('network is unreachable') ||
        text.contains('connection refused')) {
      return UserMessageKind.offline;
    }
    if (code == 'invalid_credentials' ||
        code == 'invalid_grant' ||
        text.contains('invalid login credentials') ||
        text.contains('invalid_credentials') ||
        text.contains('wrong password')) {
      return UserMessageKind.authInvalidCredentials;
    }
    if (code == 'email_not_confirmed' ||
        text.contains('email not confirmed') ||
        text.contains('email_not_confirmed')) {
      return UserMessageKind.authEmailUnconfirmed;
    }
    if (code == 'user_already_exists' ||
        code == 'email_exists' ||
        text.contains('already registered') ||
        text.contains('user already registered')) {
      return UserMessageKind.authAlreadyRegistered;
    }
    if (code == 'weak_password' ||
        code == 'validation_failed' ||
        code == 'email_address_invalid') {
      return UserMessageKind.validation;
    }
    if (code == 'session_not_found' ||
        code == 'refresh_token_not_found' ||
        code == 'session_expired' ||
        text.contains('jwt expired')) {
      return UserMessageKind.sessionExpired;
    }
    if (code == 'over_request_rate_limit' ||
        code == 'over_email_send_rate_limit') {
      return UserMessageKind.rateLimited;
    }

    final int? status = int.tryParse(error.statusCode ?? '');
    if (status != null) {
      if (status == 400 || status == 422) {
        return UserMessageKind.validation;
      }
      return classifyHttp(status);
    }
    return UserMessageKind.unknown;
  }

  static UserMessageKind _fromPostgrest(PostgrestException error) {
    final String code = (error.code ?? '').toUpperCase();
    final String text =
        '${error.message} ${error.details ?? ''} ${error.hint ?? ''}';

    if (code == '23505') {
      return _looksLikeSlot(text)
          ? UserMessageKind.slotTaken
          : UserMessageKind.conflict;
    }
    if (code == '42501') {
      return UserMessageKind.permission;
    }
    if (code == 'PGRST116') {
      return UserMessageKind.notFound;
    }
    if (code == 'PGRST301' || code == 'PGRST302') {
      return UserMessageKind.sessionExpired;
    }
    if (code == '23514' || code == '22P02' || code == '22007') {
      return UserMessageKind.validation;
    }

    final UserMessageKind fromText = _fromText(text);
    if (fromText != UserMessageKind.unknown) {
      return fromText;
    }
    // A PostgREST failure that carries no readable reason is still a server
    // failure, not a mystery for the person trying to book.
    return UserMessageKind.server;
  }

  static UserMessageKind _fromText(String raw) {
    final String text = raw.toLowerCase();

    if (_containsAny(text, <String>[
      'invalid login credentials',
      'invalid_credentials',
      'invalid grant',
      'wrong password',
      'incorrect password',
    ])) {
      return UserMessageKind.authInvalidCredentials;
    }
    if (_containsAny(text, <String>[
      'email not confirmed',
      'email_not_confirmed',
    ])) {
      return UserMessageKind.authEmailUnconfirmed;
    }
    if (_containsAny(text, <String>[
      'user_already_exists',
      'user already registered',
      'already registered',
      'email_exists',
    ])) {
      return UserMessageKind.authAlreadyRegistered;
    }
    if (_looksLikeSlot(text)) {
      return UserMessageKind.slotTaken;
    }
    if (text.contains('geoapify')) {
      if (_containsAny(text, <String>['api key', '401', '403', 'denied'])) {
        return UserMessageKind.mapUnavailable;
      }
      if (_containsAny(text, <String>['429', 'rate limit', 'credits'])) {
        return UserMessageKind.rateLimited;
      }
      if (_containsAny(text, <String>[
        'no route',
        'no matching place',
        'no address',
        'no results',
      ])) {
        return UserMessageKind.noResults;
      }
      if (_containsAny(text, <String>['http 5', 'unavailable'])) {
        return UserMessageKind.server;
      }
      if (_containsAny(text, <String>['http 400', 'bad request', 'invalid'])) {
        return UserMessageKind.validation;
      }
    }
    if (_containsAny(text, <String>[
      'socketexception',
      'could not reach',
      'unable to resolve host',
      'unknownhost',
      'failed to connect',
      'no address associated with hostname',
      'network is unreachable',
      'connection reset',
      'connection refused',
      'offline',
    ])) {
      return UserMessageKind.offline;
    }
    if (_containsAny(text, <String>['timed out', 'timeout', 'took too long'])) {
      return UserMessageKind.timeout;
    }
    if (_containsAny(text, <String>[
      'jwt expired',
      'session expired',
      'session_not_found',
      'refresh_token_not_found',
    ])) {
      return UserMessageKind.sessionExpired;
    }
    if (_containsAny(text, <String>[
      'permission denied',
      'row level security',
      'row-level security',
      'not authorized',
      'unauthorized',
      '42501',
    ])) {
      return UserMessageKind.permission;
    }
    if (_containsAny(text, <String>[
      'too many requests',
      'rate limit',
      'rate_limit',
      '429',
    ])) {
      return UserMessageKind.rateLimited;
    }
    if (_containsAny(text, <String>[
      'zero_results',
      'no route between',
      'no address found',
      'no matching place',
      'no results',
    ])) {
      return UserMessageKind.noResults;
    }
    if (_containsAny(text, <String>['not_found', 'not found', 'pgrst116'])) {
      return UserMessageKind.notFound;
    }
    if (_containsAny(text, <String>[
      'duplicate',
      'already exists',
      'conflict',
    ])) {
      return UserMessageKind.conflict;
    }
    if (_containsAny(text, <String>[
      'pgrst',
      'schema cache',
      'invalid input',
      'violates',
      'bad request',
      'syntax error',
    ])) {
      return UserMessageKind.validation;
    }
    return UserMessageKind.unknown;
  }

  static bool _looksLikeSlot(String text) {
    return _containsAny(text, <String>[
          'slot_unavailable',
          'slot unavailable',
          'slot taken',
          'slot is taken',
          'slot already',
          'already booked',
          'reservation_conflict',
          'time slot',
        ]) &&
        _containsAny(text, <String>[
          'slot',
          'book',
          'reserv',
          'taken',
          'unavailable',
        ]);
  }

  static bool _containsAny(String text, List<String> needles) {
    for (final String needle in needles) {
      if (text.contains(needle)) {
        return true;
      }
    }
    return false;
  }
}
