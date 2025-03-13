import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/volunteer.dart';

class VolunteerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adiciona um voluntário
  Future<void> addVolunteer(Volunteer volunteer) async {
    await _firestore.collection('volunteers').doc(volunteer.email).set(volunteer.toMap());
  }

  // Obtém todos os voluntários
  Stream<List<Volunteer>> getVolunteers() {
    return _firestore.collection('volunteers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Volunteer.fromMap(doc.data()); // Removido o cast desnecessário
      }).toList();
    });
  }
}