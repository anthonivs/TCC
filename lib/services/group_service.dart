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

  // Deleta um grupo e todos os seus eventos associados
  Future<void> deleteGroup(Group group) async {
    final batch = _firestore.batch();

    // Referência ao grupo
    final groupRef = _firestore.collection('groups').doc(group.id);
    batch.delete(groupRef);

    // Busca eventos associados ao grupo
    final eventsQuery = await _firestore
        .collection('events')
        .where('groupId', isEqualTo: group.id)
        .get();

    for (var doc in eventsQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Retorna grupos onde o usuário está listado
  Stream<List<Group>> getGroups(String userId) {
    print("🔍 Buscando grupos para o usuário: $userId");
    return _firestore
        .collection('groups')
        .where('userIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Group.fromMap(doc.data())).toList();
        });
  }
}
