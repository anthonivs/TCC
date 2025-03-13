import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adiciona um evento
  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  // Obtém eventos para um dia específico
  Stream<List<Event>> getEventsForDay(DateTime day) {
    return _firestore
        .collection('events')
        .where('date', isEqualTo: day.toIso8601String())
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data()); // Remova o cast explícito
      }).toList();
    });
  }
}