import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:tccapp/services/event_service.dart';
import 'package:tccapp/models/event.dart';

import '../mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;
  late EventService eventService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    eventService = EventService(firestore: mockFirestore); // ✅ injeção correta
  });

  test('deve adicionar evento corretamente', () async {
    final event = Event(
      id: '1',
      title: 'Reunião',
      description: 'Descrição',
      groupId: 'grupo1',
      date: DateTime.now(),
      location: '',
      time: '',
    );

    when(mockFirestore.collection('events')).thenReturn(mockCollection);
    when(mockCollection.add(any)).thenAnswer((_) async => mockDocument);

    await eventService.addEvent(event);

    verify(mockCollection.add(event.toMap())).called(1);
  });

  test('deve deletar evento corretamente', () async {
    const eventId = 'abc123';

    when(mockFirestore.collection('events')).thenReturn(mockCollection);
    when(mockCollection.doc(eventId)).thenReturn(mockDocument);
    when(mockDocument.delete()).thenAnswer((_) async => {});

    await eventService.deleteEvent(eventId);

    verify(mockDocument.delete()).called(1);
  });

  test('deve alternar confirmação de presença do usuário', () async {
    const eventId = 'evento1';
    const userId = 'usuario123';
    final data = {
      'confirmedUserIds': [userId],
    };

    when(mockFirestore.collection('events')).thenReturn(mockCollection);
    when(mockCollection.doc(eventId)).thenReturn(mockDocument);
    when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(true);
    when(mockSnapshot.data()).thenReturn(data);
    when(mockDocument.update(any)).thenAnswer((_) async => {});

    await eventService.toggleUserAttendance(eventId, userId);

    verify(mockDocument.update({'confirmedUserIds': <String>[]})).called(1);
  });
}
