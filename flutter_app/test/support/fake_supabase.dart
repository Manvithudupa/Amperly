import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

typedef FakeSupabaseHandler =
    FutureOr<http.StreamedResponse> Function(http.BaseRequest request);

/// Routes Supabase's HTTP calls to a test handler and records each request.
///
/// The app's repositories are `final class`, so a transport is the smallest
/// seam that lets a widget test run the real repository code and count RPCs.
class FakeSupabaseTransport extends http.BaseClient {
  FakeSupabaseTransport(this.handler);

  final FakeSupabaseHandler handler;
  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final http.StreamedResponse response = await handler(request);
    // PostgREST reads `response.request!.method` while parsing. A synthetic
    // response has no request of its own, so carry it through explicitly.
    return http.StreamedResponse(
      response.stream,
      response.statusCode,
      request: request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  int count(String method, String pathFragment) {
    return requests
        .where(
          (http.BaseRequest request) =>
              request.method == method &&
              request.url.path.contains(pathFragment),
        )
        .length;
  }
}

SupabaseClient fakeSupabaseClient(FakeSupabaseTransport transport) {
  return SupabaseClient(
    'http://127.0.0.1:1',
    'test-key',
    httpClient: transport,
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
}

http.StreamedResponse fakeJson(Object? body, {int status = 200}) {
  final String text = body == null ? '' : jsonEncode(body);
  return http.StreamedResponse(
    Stream<List<int>>.value(utf8.encode(text)),
    status,
    reasonPhrase: status == 204 ? 'No Content' : 'OK',
    headers: <String, String>{
      'content-type': 'application/json; charset=utf-8',
      // PostgREST's client reads this header on every table response.
      'content-range': '0-0/*',
    },
  );
}
