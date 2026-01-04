import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:next_health_hub/shared/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Criamos o Mock manualmente para não depender do build_runner / .mocks.dart
class MockClient extends Mock implements http.Client {
  @override
  Future<http.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) =>
      super.noSuchMethod(
        Invocation.method(#post, [url], {
          #headers: headers,
          #body: body,
          #encoding: encoding,
        }),
        returnValue: Future.value(http.Response('', 200)),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiClient apiClient;
  late MockClient mockClient;

  setUpAll(() async {
    // Carrega um env fake para os testes
    dotenv.testLoad(fileInput: '''
      API_BASE_URL=https://api.test.com/
      PROXY=proxy
      USERNAME_API=user
      PASSWORD_API=pass
      CODEPROJETC_API=code
    ''');
  });

  setUp(() {
    mockClient = MockClient();
    apiClient = ApiClient(client: mockClient);
    SharedPreferences.setMockInitialValues({});
  });

  group('ApiClient - post', () {
    test('deve enviar as credenciais corretas no body', () async {
      final requestBody = {"patientId": "123"};

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'success': true}), 200));

      await apiClient.post('test_service', requestBody);

      final captured = verify(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: captureAnyNamed('body'),
      )).captured.single as String;

      final decodedBody = jsonDecode(captured);
      expect(decodedBody['service'], 'test_service');
      expect(decodedBody['request']['username'], 'user');
      expect(decodedBody['request']['patientId'], '123');
    });

    test('deve adicionar Header de Authorization se houver token', () async {
      SharedPreferences.setMockInitialValues({'patientToken': 'token_xyz'});

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'success': true}), 200));

      await apiClient.post('test_service', {});

      final capturedHeaders = verify(mockClient.post(
        any,
        headers: captureAnyNamed('headers'),
        body: anyNamed('body'),
      )).captured.single as Map<String, String>;

      expect(capturedHeaders['Authorization'], 'Bearer token_xyz');
    });

    test('deve lançar exceção se o status code não for 200', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error message', 404));

      expect(
            () => apiClient.post('test_service', {}),
        throwsA(isA<Exception>()),
      );
    });
  });
}
