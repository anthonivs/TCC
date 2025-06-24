import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tccapp/services/group_service.dart';
import 'package:tccapp/models/group.dart';

import '../mocks.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockGroupCollection;
  late MockCollectionReference<Map<String, dynamic>> mockEventCollection;
  late MockDocumentReference<Map<String, dynamic>> mockGroupDoc;
  late MockDocumentReference<Map<String, dynamic>> mockEventDoc;
  late MockFirestoreBatch mockBatch;

  late GroupService groupService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockGroupCollection = MockCollectionReference<Map<String, dynamic>>();
    mockEventCollection = MockCollectionReference<Map<String, dynamic>>();
    mockGroupDoc = MockDocumentReference<Map<String, dynamic>>();
    mockEventDoc = MockDocumentReference<Map<String, dynamic>>();
    mockBatch = MockFirestoreBatch();

    groupService = GroupService(firestore: mockFirestore);
  });

  test('deve adicionar grupo corretamente', () async {
    final group = Group(
      id: 'grupo1',
      name: 'Grupo Teste',
      leader: 'João',
      leaderId: 'lider1',
      userIds: ['u1', 'u2'],
      volunteers: ['v1'],
      events: null,
    );

    when(mockFirestore.collection('groups')).thenReturn(mockGroupCollection);
    when(mockGroupCollection.doc(group.id)).thenReturn(mockGroupDoc);
    when(mockGroupDoc.set(group.toMap())).thenAnswer((_) async => {});

    await groupService.addGroup(group);

    verify(mockGroupDoc.set(group.toMap())).called(1);
  });

  test('deve atualizar grupo corretamente', () async {
    final oldGroup = Group(
      id: 'grupo1',
      name: 'Grupo Antigo',
      leader: 'João',
      leaderId: 'lider1',
      userIds: ['u1'],
      volunteers: ['v1'],
      events: null,
    );

    final newGroup = Group(
      id: 'grupo1',
      name: 'Grupo Novo',
      leader: 'Maria',
      leaderId: 'lider2',
      userIds: ['u1', 'u3'],
      volunteers: ['v1', 'v2'],
      events: null,
    );

    when(mockFirestore.collection('groups')).thenReturn(mockGroupCollection);
    when(mockGroupCollection.doc(newGroup.id)).thenReturn(mockGroupDoc);
    when(mockGroupDoc.update(newGroup.toMap())).thenAnswer((_) async => {});

    await groupService.updateGroup(oldGroup, newGroup);

    verify(mockGroupDoc.update(newGroup.toMap())).called(1);
  });

  test('deve deletar grupo e seus eventos associados', () async {
    final group = Group(
      id: 'grupoX',
      name: 'Grupo X',
      leader: 'Líder X',
      leaderId: 'lx',
      userIds: ['u1'],
      volunteers: ['v1'],
      events: null,
    );

    final mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    final mockEventDocSnap = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    final mockEventQuery = MockQuery<Map<String, dynamic>>();

    when(mockFirestore.collection('groups')).thenReturn(mockGroupCollection);
    when(mockFirestore.collection('events')).thenReturn(mockEventCollection);
    when(mockGroupCollection.doc(group.id)).thenReturn(mockGroupDoc);
    when(
      mockEventCollection.where('groupId', isEqualTo: group.id),
    ).thenReturn(mockEventQuery);
    when(mockEventQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockEventDocSnap]);
    when(mockEventDocSnap.reference).thenReturn(mockEventDoc);
    when(mockFirestore.batch()).thenReturn(mockBatch);
    when(mockBatch.delete(any)).thenReturn(null);
    when(mockBatch.commit()).thenAnswer((_) async => {});

    await groupService.deleteGroup(group);

    verify(mockBatch.delete(mockEventDoc)).called(1);
    verify(mockBatch.delete(mockGroupDoc)).called(1);
    verify(mockBatch.commit()).called(1);
  });
}
