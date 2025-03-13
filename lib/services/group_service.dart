import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adiciona um novo grupo
  Future<void> addGroup(Group group) async {
    await _firestore.collection('groups').doc(group.id).set(group.toMap());
  }

  // Atualiza um grupo existente
  Future<void> updateGroup(Group oldGroup, Group newGroup) async {
    await _firestore.collection('groups').doc(newGroup.id).update(newGroup.toMap());
  }

  // Deleta um grupo
  Future<void> deleteGroup(Group group) async {
    await _firestore.collection('groups').doc(group.id).delete();
  }

  // Obtém todos os grupos
  Stream<List<Group>> getGroups() {
    return _firestore.collection('groups').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
    });
  }
}