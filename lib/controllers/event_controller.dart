import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adiciona um evento
  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add(event.toMap());
  }

  // Obtém todos os eventos como um Stream
  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromMap(doc.data()); // Remova o cast explícito
      }).toList();
    });
  }
}