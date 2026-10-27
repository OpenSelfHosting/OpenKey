import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

typedef TokenRefresher = Future<bool> Function();

class ApiClient {
  ApiClient({
    http.Client? client,
    Duration? requestTimeout,
  })  : _client = client ?? http.Client(),
        _requestTimeout = requestTimeout ?? defaultRequestTimeout;

  /// Default HTTP timeout for sync/auth calls (connect + response).
  static const Duration defaultRequestTimeout = Duration(seconds: 60);

  final http.Client _client;
  final Duration _requestTimeout;
  String? baseUrl;
  String? accessToken;
  TokenRefresher? onUnauthorized;

  void configure({
    String? baseUrl,
    String? accessToken,
    TokenRefresher? onUnauthorized,
  }) {
    if (baseUrl != null) {
      this.baseUrl = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
    }
    if (accessToken != null) this.accessToken = accessToken;
    if (onUnauthorized != null) this.onUnauthorized = onUnauthorized;
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _request('POST', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> get(String path, {bool auth = true}) {
    return _request('GET', path, auth: auth);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _request('PATCH', path, body: body, auth: auth);
  }

  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) {
    return _request('DELETE', path, auth: auth);
  }

  /// Multipart POST (e.g. attachment ciphertext upload).
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required List<int> fileBytes,
    required String fileField,
    String filename = 'blob.bin',
    String? contentType,
    bool auth = true,
  }) async {
    return _send(
      () async {
        final uri = _uri(path);
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll(_headers(auth: auth, json: false));
        request.fields.addAll(fields);
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: filename,
          ),
        );
        // Preserve declared content-type as a form field when provided.
        if (contentType != null && contentType.isNotEmpty) {
          request.fields.putIfAbsent('content_type', () => contentType);
        }
        final streamed = await _client.send(request).timeout(_requestTimeout);
        return http.Response.fromStream(streamed);
      },
      auth: auth,
    );
  }

  /// Binary GET (e.g. attachment content stream).
  Future<Uint8List> getBytes(String path, {bool auth = true}) async {
    final response = await _raw(
      () async {
        final uri = _uri(path);
        return _client
            .get(uri, headers: _headers(auth: auth, json: false))
            .timeout(_requestTimeout);
      },
      auth: auth,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException(
      'HTTP ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) {
    return _send(
      () async {
        final uri = _uri(path);
        final headers = _headers(auth: auth, json: true);
        final encoded = body == null ? null : jsonEncode(body);
        switch (method) {
          case 'GET':
            return _client.get(uri, headers: headers).timeout(_requestTimeout);
          case 'POST':
            return _client
                .post(uri, headers: headers, body: encoded)
                .timeout(_requestTimeout);
          case 'PATCH':
            return _client
                .patch(uri, headers: headers, body: encoded)
                .timeout(_requestTimeout);
          case 'DELETE':
            return _client.delete(uri, headers: headers).timeout(_requestTimeout);
          default:
            throw ApiException('Unsupported method $method');
        }
      },
      auth: auth,
    );
  }

  Uri _uri(String path) {
    final root = baseUrl;
    if (root == null || root.isEmpty) {
      throw const ApiException('Server URL is not configured.');
    }
    return Uri.parse('$root$path');
  }

  Map<String, String> _headers({required bool auth, required bool json}) {
    final headers = <String, String>{
      'Accept': json ? 'application/json' : '*/*',
    };
    if (json) headers['Content-Type'] = 'application/json';
    if (auth && accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() run, {
    required bool auth,
  }) async {
    final response = await _raw(run, auth: auth);
    final dynamic raw =
        response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final Map<String, dynamic> decoded;
    if (raw is List) {
      decoded = {'items': raw};
    } else if (raw is Map<String, dynamic>) {
      decoded = raw;
    } else {
      decoded = {'value': raw};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final detail = decoded['detail']?.toString() ??
        decoded['message']?.toString() ??
        'HTTP ${response.statusCode}';
    throw ApiException(detail, statusCode: response.statusCode);
  }

  Future<http.Response> _raw(
    Future<http.Response> Function() run, {
    required bool auth,
  }) async {
    late http.Response response;
    try {
      response = await run();
    } on TimeoutException {
      throw const ApiException('Request timed out.');
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    }

    if (auth &&
        response.statusCode == 401 &&
        onUnauthorized != null &&
        accessToken != null) {
      final refreshed = await onUnauthorized!();
      if (refreshed) {
        try {
          response = await run();
        } on TimeoutException {
          throw const ApiException('Request timed out.');
        } on http.ClientException catch (e) {
          throw ApiException(e.message);
        }
      }
    }
    return response;
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
