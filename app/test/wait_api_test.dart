import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:splash_auto_app/features/availability/wait_service.dart';

void main() {
  test('owner token is used for API calls and cleared after rejection', () async {
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      if (request.url.path.endsWith('/login')) return http.Response(jsonEncode({'access_token': 'test-token'}), 200);
      expect(request.headers['Authorization'], 'Bearer test-token');
      return http.Response('{}', 401);
    }));
    await api.signIn('owner@example.test', 'test-password');
    expect(api.signedIn, isTrue);
    await expectLater(api.checkOwner(), throwsA(isA<ApiFailure>()));
    expect(api.signedIn, isFalse);
    api.close();
  });
  test('conflicting saves never report success', () async {
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      expect(jsonDecode(request.body)['version'], 4);
      return http.Response('{}', 409);
    }));
    expect(await api.save({'status': 'closed'}, 4), isNull);
    api.close();
  });
}
