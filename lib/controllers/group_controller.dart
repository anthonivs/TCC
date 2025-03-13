import '../models/group.dart';
import '../services/group_service.dart';

class GroupController {
  final GroupService _groupService = GroupService(); // Cria uma instância do GroupService

  // Adiciona um novo grupo
  Future<void> addGroup(Group group) async {
    await _groupService.addGroup(group);
  }

  // Atualiza um grupo existente
  Future<void> updateGroup(Group oldGroup, Group newGroup) async {
    await _groupService.updateGroup(oldGroup, newGroup);
  }

  // Deleta um grupo
  Future<void> deleteGroup(Group group) async {
    await _groupService.deleteGroup(group);
  }

  // Obtém todos os grupos (retorna um Stream)
  Stream<List<Group>> getGroups() {
    return _groupService.getGroups();
  }
}