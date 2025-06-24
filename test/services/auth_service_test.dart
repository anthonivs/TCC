import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:tccapp/services/auth_service.dart';
import 'package:tccapp/models/user.dart' as app_user;
import '../mocks.mocks.dart';
import '../mocks.mocks.mocks.dart'; // ✅ Corrigido: apenas 1 import dos mocks

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseFunctions mockFunctions;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseMessaging mockMessaging;
  late MockCollectionReference<Map<String, dynamic>> mockUserCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDoc;
  late MockUserCredential mockUserCredential;
  late firebase_auth.User mockFirebaseUser;
  late AuthService authService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();
    mockAuth = MockFirebaseAuth();
    mockMessaging = MockFirebaseMessaging();
    mockUserCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDoc = MockDocumentReference<Map<String, dynamic>>();
    mockUserCredential = MockUserCredential();
    mockFirebaseUser = MockUser();

    authService = AuthServiceTestable(
      auth: mockAuth,
      firestore: mockFirestore,
      functions: mockFunctions,
      messaging: mockMessaging,
    );
  });

  test('login com sucesso retorna User do app', () async {
    const email = 'test@example.com';
    const password = 'senha123';
    const userId = 'user123';

    final userData = {
      'id': userId,
      'name': 'João',
      'email': email,
      'role': 'Líder',
      'groupIds': [],
    };

    when(
      mockAuth.signInWithEmailAndPassword(email: email, password: password),
    ).thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.uid).thenReturn(userId);
    when(mockFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(userId)).thenReturn(mockUserDoc);
    when(mockUserDoc.get()).thenAnswer((_) async {
      final snap = MockDocumentSnapshot<Map<String, dynamic>>();
      when(snap.exists).thenReturn(true);
      when(snap.data()).thenReturn(userData);
      return snap;
    });
    when(mockMessaging.getToken()).thenAnswer((_) async => 'fcmToken123');

    final user = await authService.login(email, password);

    expect(user, isA<app_user.User>());
    expect(user?.id, userId);
  });

  test('register com e-mail inválido lança exceção traduzida', () async {
    when(
      mockAuth.createUserWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ),
    ).thenThrow(firebase_auth.FirebaseAuthException(code: 'invalid-email'));
    when(mockAuth.currentUser).thenReturn(null);

    expect(
      () => authService.register(
        'invalido',
        '123456',
        name: 'Teste',
        role: 'Voluntário',
        groupIds: [],
      ),
      throwsA(contains('e-mail inválido')),
    );
  });

  test('updateProfile atualiza dados corretamente', () async {
    const uid = 'user1';
    final mockUser = MockUser();

    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn(uid);
    when(mockFirestore.collection('users')).thenReturn(mockUserCollection);
    when(mockUserCollection.doc(uid)).thenReturn(mockUserDoc);
    when(mockUserDoc.update(any)).thenAnswer((_) async => {});

    await authService.updateProfile(
      name: 'Novo Nome',
      phone: '123',
      occupation: 'Dev',
      description: 'Descrição',
    );

    verify(
      mockUserDoc.update({
        'name': 'Novo Nome',
        'phone': '123',
        'occupation': 'Dev',
        'description': 'Descrição',
      }),
    ).called(1);
  });
}

/// Classe com mocks injetáveis para teste
class AuthServiceTestable extends AuthService {
  final firebase_auth.FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final FirebaseMessaging messaging;

  AuthServiceTestable({
    required this.auth,
    required this.firestore,
    required this.functions,
    required this.messaging,
  }) : super(auth: auth, firestore: firestore, functions: functions);

  @override
  firebase_auth.FirebaseAuth get _auth => auth;

  @override
  FirebaseFirestore get _firestore => firestore;

  @override
  FirebaseFunctions get _functions => functions;

  @override
  FirebaseMessaging get messagingInstance => messaging;
}
