import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  Stream<List<Event>> getEvents(String groupId) {
    print('🔍 Buscando eventos para groupId: $groupId');

    return _firestore
        .collection('events')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) {
      print('📥 Total de eventos encontrados: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          print('📄 Evento bruto: $data');
          final event = Event.fromMap(data);
          print('✅ Evento convertido: ${event.description}');
          return event;
        } catch (e) {
          print('❌ Erro ao converter evento: $e');
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
          return Event.fromMap(doc.data());
        } catch (e) {
          print('Erro ao converter evento: $e');
          return null;
        }
      }).whereType<Event>().toList();
    });
  }
}
