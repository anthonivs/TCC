import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tccapp/controllers/event_controller.dart';
import 'package:tccapp/models/event.dart';
import 'package:tccapp/models/user.dart';
import 'package:tccapp/services/event_service.dart';
import 'package:tccapp/services/auth_service.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  late MockEventService mockEventService;
  late MockAuthService mockAuthService;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseFunctions mockFunctions;
  late EventController controller;

  setUp(() {
    mockEventService = MockEventService();
    mockAuthService = MockAuthService();
    mockFirestore = MockFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();

    controller = EventController(
      eventService: mockEventService,
      authService: mockAuthService,
      firestore: mockFirestore,
      functions: mockFunctions,
    );
  });

  test(
    'addEvent deve chamar EventService e enviar notificações se usuário for Líder',
    () async {
      final user = User(
        id: 'u1',
        name: 'João',
        email: 'joao@gmail.com',
        role: 'Líder',
        groupIds: ['g1'],
        fcmToken:
            'fj7lpTxKQd-Xc7u6YE7m1b:APA91bG31IAt09_WMtTE6iVPsy5vxWPLNxR8-7RUQB5Hq2csPkFjxsVpqJ94Zvh5MhEyL60iNomXFq0zgtkyJ-UYosusvfGzluIwH3aZw4yMUc7oYoYwPyA',
      );

      final event = Event(
        id: '1',
        description: 'Desc',
        date: DateTime(2025, 6, 19),
        groupId: 'g1',
        location: 'Local',
        time: '20:00',
        title: 'Título',
      );

      final callable = MockHttpsCallable();

      when(mockEventService.addEvent(any)).thenAnswer((_) async {});
      when(mockAuthService.currentUser).thenAnswer((_) async => user);
      when(mockAuthService.getAllUsers()).thenAnswer((_) async => [user]);
      when(
        mockFunctions.httpsCallable('sendGroupNotification'),
      ).thenReturn(callable);
      when(
        callable.call(any),
      ).thenAnswer((_) async => MockHttpsCallableResult());

      await controller.addEvent(event);

      // Verifica se addEvent foi chamado com Event correto
      final captured = verify(mockEventService.addEvent(captureAny)).captured;
      expect(captured, isNotEmpty);
      final capturedEvent = captured.first as Event;
      expect(capturedEvent.id, equals('1'));
      expect(capturedEvent.title, equals('Título'));

      // Verifica se a notificação foi enviada com o token esperado
      final notificationPayload =
          verify(callable.call(captureAny)).captured.single;
      expect(
        notificationPayload['tokens'],
        contains(
          'fj7lpTxKQd-Xc7u6YE7m1b:APA91bG31IAt09_WMtTE6iVPsy5vxWPLNxR8-7RUQB5Hq2csPkFjxsVpqJ94Zvh5MhEyL60iNomXFq0zgtkyJ-UYosusvfGzluIwH3aZw4yMUc7oYoYwPyA',
        ),
      );
    },
  );

  test(
    'deleteEvent deve chamar EventService apenas se usuário for Líder',
    () async {
      final user = User(
        id: 'u1',
        name: 'João',
        email: 'joao@gmail.com',
        role: 'Líder',
        groupIds: ['g1'],
        fcmToken:
            'fj7lpTxKQd-Xc7u6YE7m1b:APA91bG31IAt09_WMtTE6iVPsy5vxWPLNxR8-7RUQB5Hq2csPkFjxsVpqJ94Zvh5MhEyL60iNomXFq0zgtkyJ-UYosusvfGzluIwH3aZw4yMUc7oYoYwPyA',
      );

      when(mockAuthService.currentUser).thenAnswer((_) async => user);
      when(mockEventService.deleteEvent('event123')).thenAnswer((_) async {});

      await controller.deleteEvent('event123');

      verify(mockEventService.deleteEvent('event123')).called(1);
    },
  );

  test(
    'toggleAttendance chama toggleUserAttendance com userId correto',
    () async {
      final user = User(
        id: 'u3',
        name: 'Carlos',
        email: 'carlos@gmail.com',
        role: 'Voluntário',
        groupIds: ['g3'],
      );

      when(mockAuthService.currentUser).thenAnswer((_) async => user);
      when(
        mockEventService.toggleUserAttendance('eventX', 'u3'),
      ).thenAnswer((_) async {});

      await controller.toggleAttendance('eventX');

      verify(mockEventService.toggleUserAttendance('eventX', 'u3')).called(1);
    },
  );
}
