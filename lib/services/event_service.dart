import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }

  Future<void> toggleUserAttendance(String eventId, String userId) async {
    final eventRef = _firestore.collection('events').doc(eventId);
    final snapshot = await eventRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final confirmed = List<String>.from(data['confirmedUserIds'] ?? []);

    if (confirmed.contains(userId)) {
      confirmed.remove(userId);
    } else {
      confirmed.add(userId);
    }

    await eventRef.update({'confirmedUserIds': confirmed});
  }

  Stream<List<Event>> getEvents(String groupId) {
    print('🔍 Buscando eventos para groupId: $groupId');

    return _firestore
        .collection('events')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
          print('Total de eventos encontrados: ${snapshot.docs.length}');

          return snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data();
                  final event = Event.fromMap(data, id: doc.id);
                  print('Evento convertido: ${event.description}');
                  return event;
                } catch (e) {
                  print('Erro ao converter evento: $e');
                  return null;
                }
              })
              .whereType<Event>()
              .toList();
        });
  }

  Stream<List<Event>> getAllEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            print('DEBUG EVENTO: ${doc.data()}');
            try {
              return Event.fromMap(doc.data(), id: doc.id);
            } catch (e) {
              print('Erro ao converter evento: $e');
              return null;
            }
          })
          .whereType<Event>()
          .toList();
    });
  }

  Future<List<Event>> getEventsForUserGroups(String userId) async {
    List<Event> allEvents = [];

    // Buscar grupos em que o usuário participa
    final groupsSnapshot = await _firestore.collection('groups').get();

    List<String> userGroupIds = [];

    for (var groupDoc in groupsSnapshot.docs) {
      final data = groupDoc.data();
      final groupId = groupDoc.id;

      try {
        final rawUserIds = data['userIds'];
        final members =
            rawUserIds is List ? List<String>.from(rawUserIds) : <String>[];
        final leaderId = data['leaderId'];

        print(
          '✅ Grupo OK: $groupId | Líder: $leaderId | Membros: ${members.length}',
        );

        if (members.contains(userId) || leaderId == userId) {
          userGroupIds.add(groupId);
        }
      } catch (e) {
        print('❌ ERRO no grupo $groupId → $e');
      }
    }

    // Buscar eventos de cada grupo separadamente com .where (respeita as regras do Firestore)
    for (String groupId in userGroupIds) {
      try {
        final snapshot =
            await _firestore
                .collection('events')
                .where('groupId', isEqualTo: groupId)
                .get();

        for (var doc in snapshot.docs) {
          allEvents.add(Event.fromMap(doc.data(), id: doc.id));
          print(
            '✅ Evento carregado do grupo $groupId: ${doc.data()['description']}',
          );
        }
      } catch (e) {
        print('❌ Erro ao buscar eventos do grupo $groupId → $e');
      }
    }

    return allEvents;
  }
}
