import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:tccapp/services/auth_service.dart';

import 'mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseFunctions mockFunctions;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();

    authService = AuthService(
      auth: mockAuth,
      firestore: mockFirestore,
      functions: mockFunctions,
    );
  });

  test(
    'deve instanciar AuthService corretamente com dependências mockadas',
    () {
      expect(authService, isA<AuthService>());
    },
  );

  test(
    'deve lançar erro traduzido se e-mail for inválido no registro',
    () async {
      // Simula: nenhum usuário autenticado no momento (auto-registro)
      when(mockAuth.currentUser).thenReturn(null);

      // Simula erro ao tentar criar usuário
      when(
        mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        firebase_auth.FirebaseAuthException(
          code: 'invalid-email',
          message: 'Email format is invalid',
        ),
      );

      // Valida se o erro lançado está no formato esperado
      expect(
        () async => await authService.register(
          'emailinvalido',
          '123456',
          name: 'Teste',
          role: 'Voluntário',
          groupIds: ['grupo1'],
        ),
        throwsA(
          predicate((e) => e is String && e.contains('Erro ao cadastrar:')),
        ),
      );
    },
  );
}
