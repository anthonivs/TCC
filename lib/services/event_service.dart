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

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          final event = Event.fromMap(data, id: doc.id); 
          print('Evento convertido: ${event.description}');
          return event;
        } catch (e) {
          print('Erro ao converter evento: $e');
          return null;
        }
      }).whereType<Event>().toList();
    });
  }

  Stream<List<Event>> getAllEvents() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        print('DEBUG EVENTO: ${doc.data()}');
        try {
          return Event.fromMap(doc.data(), id: doc.id); 
        } catch (e) {
          print('Erro ao converter evento: $e');
          return null;
        }
      }).whereType<Event>().toList();
    });
  }
}
