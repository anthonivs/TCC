import '../models/group.dart';
import '../services/group_service.dart';

class GroupController {
  final GroupService _groupService = GroupService();

  Future<void> addGroup(Group group) async {
    try {
      await _groupService.addGroup(group);
    } catch (e) {
      throw 'Erro ao adicionar grupo: $e';
    }
  }

  Future<void> updateGroup(Group oldGroup, Group newGroup) async {
    try {
      await _groupService.updateGroup(oldGroup, newGroup);
    } catch (e) {
      throw 'Erro ao atualizar grupo: $e';
    }
  }

  Future<void> deleteGroup(Group group) async {
    try {
      await _groupService.deleteGroup(group);
    } catch (e) {
      throw 'Erro ao deletar grupo: $e';
    }
  }

  Stream<List<Group>> getGroups(String userId) {
    try {
      return _groupService.getGroups(userId);
    } catch (e) {
      throw 'Erro ao carregar grupos do usuário: $e';
    }
  }

  Stream<List<Group>> getAllGroups() {
    try {
      return _groupService.getAllGroups();
    } catch (e) {
      throw 'Erro ao carregar todos os grupos: $e';
    }
  }
}
