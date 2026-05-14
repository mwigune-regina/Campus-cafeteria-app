import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Thin wrapper around the http package that:
///   - Applies a 10s timeout so hung connections fail fast.
///   - Logs the URL + status to the debug console so misrouted requests are
///     obvious in the logs.
///   - Always returns a parsed `Map<String, dynamic>`. On any failure
///     (timeout, network, bad JSON) returns `{ success: false, message: ... }`
///     so callers can show a useful error instead of hanging.
class ApiClient {
  static const Duration _timeout = Duration(seconds: 10);

  static Future<Map<String, dynamic>> get(Uri uri, {Map<String, String>? headers}) {
    return _run('GET', uri, () => http.get(uri, headers: headers));
  }

  static Future<Map<String, dynamic>> post(Uri uri,
      {Map<String, String>? headers, Object? body}) {
    return _run('POST', uri, () => http.post(uri, headers: headers, body: body));
  }

  static Future<Map<String, dynamic>> put(Uri uri,
      {Map<String, String>? headers, Object? body}) {
    return _run('PUT', uri, () => http.put(uri, headers: headers, body: body));
  }

  static Future<Map<String, dynamic>> patch(Uri uri,
      {Map<String, String>? headers, Object? body}) {
    return _run('PATCH', uri, () => http.patch(uri, headers: headers, body: body));
  }

  static Future<Map<String, dynamic>> delete(Uri uri, {Map<String, String>? headers}) {
    return _run('DELETE', uri, () => http.delete(uri, headers: headers));
  }

  static Future<Map<String, dynamic>> _run(
    String method,
    Uri uri,
    Future<http.Response> Function() send,
  ) async {
    try {
      final res = await send().timeout(_timeout);
      debugPrint('[API] $method ${uri.toString()} -> ${res.statusCode}');
      try {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) return body;
        return {'success': false, 'message': 'Unexpected response shape'};
      } catch (_) {
        return {
          'success': false,
          'message': 'Bad response (status ${res.statusCode})',
        };
      }
    } on TimeoutException {
      debugPrint('[API] $method $uri -> TIMEOUT (10s)');
      return {
        'success': false,
        'message': 'Server did not respond. Check that the backend is running and reachable.',
      };
    } catch (e) {
      debugPrint('[API] $method $uri -> ERROR: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
