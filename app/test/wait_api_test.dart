import 'dart:async';
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
  test('a delayed rejection from an old session keeps the new owner signed in', () async {
    final rejected = Completer<http.Response>();
    final started = Completer<void>();
    var logins = 0;
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      if (request.url.path.endsWith('/login')) {
        return http.Response(jsonEncode({'access_token': 'token-${++logins}'}), 200);
      }
      if (request.headers['Authorization'] == 'Bearer token-1') {
        started.complete();
        return rejected.future;
      }
      expect(request.headers['Authorization'], 'Bearer token-2');
      return http.Response('{}', 200);
    }));
    addTearDown(api.close);
    await api.signIn('first@example.test', 'test-password');
    final oldRequest = expectLater(api.checkOwner(), throwsA(isA<ApiFailure>()));
    await started.future;
    await api.signIn('second@example.test', 'test-password');
    rejected.complete(http.Response('{}', 401));
    await oldRequest;
    expect(api.signedIn, isTrue);
    await api.checkOwner();
  });

  test('sign-out prevents an unfinished login from restoring access', () async {
    final login = Completer<http.Response>();
    final started = Completer<void>();
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      if (request.url.path.endsWith('/login')) {
        started.complete();
        return login.future;
      }
      return http.Response('{}', 200);
    }));
    addTearDown(api.close);
    final signingIn = api.signIn('owner@example.test', 'test-password');
    await started.future;
    await api.signOut();
    login.complete(http.Response(jsonEncode({'access_token': 'late-token'}), 200));
    await signingIn;
    expect(api.signedIn, isFalse);
  });

  test('sign-out clears access immediately and cannot clear a later login', () async {
    final logout = Completer<http.Response>();
    final started = Completer<void>();
    var logins = 0;
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      if (request.url.path.endsWith('/login')) {
        return http.Response(jsonEncode({'access_token': 'token-${++logins}'}), 200);
      }
      if (request.url.path.endsWith('/logout')) {
        expect(request.headers['Authorization'], 'Bearer token-1');
        started.complete();
        return logout.future;
      }
      expect(request.headers['Authorization'], 'Bearer token-2');
      return http.Response('{}', 200);
    }));
    addTearDown(api.close);
    await api.signIn('first@example.test', 'test-password');
    final signingOut = api.signOut();
    expect(api.signedIn, isFalse);
    await started.future;
    await api.signIn('second@example.test', 'test-password');
    logout.complete(http.Response('{}', 200));
    await signingOut;
    expect(api.signedIn, isTrue);
    await api.checkOwner();
  });

  test('the latest login wins when responses arrive out of order', () async {
    final first = Completer<http.Response>();
    final started = Completer<void>();
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      if (request.url.path.endsWith('/login')) {
        if (jsonDecode(request.body)['email'] == 'first@example.test') {
          started.complete();
          return first.future;
        }
        return http.Response(jsonEncode({'access_token': 'latest-token'}), 200);
      }
      expect(request.headers['Authorization'], 'Bearer latest-token');
      return http.Response('{}', 200);
    }));
    addTearDown(api.close);
    final firstLogin = api.signIn('first@example.test', 'test-password');
    await started.future;
    await api.signIn('second@example.test', 'test-password');
    first.complete(http.Response(jsonEncode({'access_token': 'older-token'}), 200));
    await firstLogin;
    await api.checkOwner();
  });

  test('closing the client invalidates an unfinished login', () async {
    final response = Completer<http.Response>();
    final started = Completer<void>();
    final api = WaitApi('https://api.example.test', transport: MockClient((request) async {
      started.complete();
      return response.future;
    }));
    final login = api.signIn('owner@example.test', 'test-password');
    await started.future;
    api.close();
    response.complete(http.Response(jsonEncode({'access_token': 'late-token'}), 200));
    await login;
    expect(api.signedIn, isFalse);
  });

}
