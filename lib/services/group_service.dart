import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';

class GroupService {
  final FirebaseFirestore _firestore;

  GroupService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Adiciona um novo grupo
  Future<void> addGroup(Group group) async {
    try {
      await _firestore.collection('groups').doc(group.id).set(group.toMap());
    } catch (e) {
      throw 'Erro ao adicionar grupo: $e';
    }
  }

  // Atualiza um grupo existente
  Future<void> updateGroup(Group oldGroup, Group newGroup) async {
    try {
      await _firestore
          .collection('groups')
          .doc(newGroup.id)
          .update(newGroup.toMap());
    } catch (e) {
      throw 'Erro ao atualizar grupo: $e';
    }
  }

  // Deleta um grupo e todos os seus eventos associados
  Future<void> deleteGroup(Group group) async {
    final batch = _firestore.batch();

    try {
      final groupRef = _firestore.collection('groups').doc(group.id);

      final eventsQuery =
          await _firestore
              .collection('events')
              .where('groupId', isEqualTo: group.id)
              .get();

      for (var doc in eventsQuery.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(groupRef);

      await batch.commit();
    } catch (e) {
      throw 'Erro ao deletar grupo e eventos associados: $e';
    }
  }

  // Retorna grupos onde o usuário está listado
  Stream<List<Group>> getGroups(String userId) {
    try {
      return _firestore
          .collection('groups')
          .where('userIds', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => Group.fromMap({...doc.data(), 'id': doc.id}))
                .toList();
          });
    } catch (e) {
      throw 'Erro ao buscar grupos do usuário: $e';
    }
  }

  // Retorna todos os grupos
  Stream<List<Group>> getAllGroups() {
    try {
      return _firestore.collection('groups').snapshots().map((snap) {
        return snap.docs
            .map((doc) => Group.fromMap({...doc.data(), 'id': doc.id}))
            .toList();
      });
    } catch (e) {
      throw 'Erro ao buscar todos os grupos: $e';
    }
  }
}
