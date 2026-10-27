import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:openkey_app/src/core/network/api_client.dart';

void main() {
  test('ApiClient times out slow responses', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      await Future<void>.delayed(const Duration(seconds: 2));
      request.response
        ..statusCode = 200
        ..write(jsonEncode({'ok': true}));
      await request.response.close();
    });

    final port = server.port;
    final client = ApiClient(
      requestTimeout: const Duration(milliseconds: 200),
    )..configure(baseUrl: 'http://127.0.0.1:$port');

    expect(
      () => client.get('/slow'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Request timed out.',
        ),
      ),
    );
  });

  test('ApiClient returns JSON for successful GET', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      request.response
        ..statusCode = 200
        ..write(jsonEncode({'hello': 'world'}));
      await request.response.close();
    });

    final port = server.port;
    final client = ApiClient()..configure(baseUrl: 'http://127.0.0.1:$port');

    final body = await client.get('/ok', auth: false);
    expect(body['hello'], 'world');
  });
}
