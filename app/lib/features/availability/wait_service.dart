import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class WaitApi {
  WaitApi(this.baseUrl, {http.Client? transport}) : _http = transport ?? http.Client();
  final String baseUrl;
  final http.Client _http;
  String? _token;
  bool get signedIn => _token != null;
  final authChanges = StreamController<void>.broadcast();

  Future<Map<String, dynamic>> request(String method, String path, [Map<String, dynamic>? body]) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Content-Type'] = 'application/json';
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    if (body != null) request.body = jsonEncode(body);
    final response = await (() async {
      return http.Response.fromStream(await _http.send(request));
    })().timeout(const Duration(seconds: 15));
    if (response.statusCode == 401 && _token != null) {
      _token = null;
      authChanges.add(null);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) throw ApiFailure(response.statusCode);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> signIn(String email, String password) async {
    final result = await request('POST', '/v1/auth/login', {'email': email, 'password': password});
    _token = result['access_token'] as String;
    authChanges.add(null);
  }
  Future<void> signOut() async {
    try { await request('POST', '/v1/auth/logout'); }
    finally { _token = null; authChanges.add(null); }
  }
  Future<void> checkOwner() async { await request('GET', '/v1/auth/me'); }
  Future<Map<String, dynamic>?> save(Map<String, dynamic> values, int version) async {
    try { return await request('PUT', '/v1/wait', {...values, 'version': version}); }
    on ApiFailure catch (error) { if (error.status == 409) return null; rethrow; }
  }
  WebSocketChannel connect() {
    final uri = Uri.parse('$baseUrl/v1/wait/stream');
    return WebSocketChannel.connect(uri.replace(scheme: uri.scheme == 'https' ? 'wss' : 'ws'));
  }
  void close() { _http.close(); authChanges.close(); }
}

class ApiFailure implements Exception {
  ApiFailure(this.status);
  final int status;
}

class WaitService {
  static WaitApi? client;
  static const url = String.fromEnvironment('SPLASH_API_URL');
  static Future<void> initialize() async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (uri.scheme != 'https' && !(uri.scheme == 'http' && ['localhost', '127.0.0.1', '10.0.2.2'].contains(uri.host))) {
      throw ArgumentError('Use HTTPS for the Splash API');
    }
    client = WaitApi(url.replaceAll(RegExp(r'/+$'), ''));
  }
  static Future<Map<String, dynamic>> read() => client!.request('GET', '/v1/wait');
}

class WaitSnapshot {
  WaitSnapshot(this.row, this.serverNow, this.received);
  final Map<String, dynamic>? row;
  final DateTime serverNow;
  final DateTime received;

  DateTime now(DateTime deviceNow) => serverNow.add(deviceNow.difference(received));
  String status(DateTime deviceNow) {
    final value = row;
    if (value == null) return 'unknown';
    final expires = DateTime.tryParse(value['expires_at']?.toString() ?? '');
    final updated = DateTime.tryParse(value['updated_at']?.toString() ?? '');
    final time = now(deviceNow);
    if (expires == null || updated == null || !expires.isAfter(time) || updated.isAfter(time.add(const Duration(minutes: 1)))) return 'unknown';
    final status = value['status'];
    if (!['available', 'moderate', 'busy', 'closed'].contains(status)) return 'unknown';
    if (status != 'closed') {
      final min = value['wait_min'];
      final max = value['wait_max'];
      if (min is! int || max is! int || min < 0 || max < min || max > 240) return 'unknown';
    }
    return status as String;
  }
}
