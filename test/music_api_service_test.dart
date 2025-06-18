import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:epico/manage/api_manage.dart';

void main() {
  group('MusicApiService', () {
    test('loginUser returns token when request succeeds', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '${MusicApiService.baseUrl}/user/login');
        return http.Response(jsonEncode({'token': 'abc'}), 200);
      });

      final service = MusicApiService(client: client);
      final result = await service.loginUser('email', 'pass');

      expect(result['token'], equals('abc'));
    });

    test('userInfo returns map when request succeeds', () async {
      final client = MockClient((request) async {
        expect(request.headers['token'], 'cookie');
        return http.Response(jsonEncode({'email': 'test@example.com'}), 200);
      });

      final service = MusicApiService(client: client);
      final result = await service.userInfo('cookie');

      expect(result['email'], equals('test@example.com'));
    });
  });
}
