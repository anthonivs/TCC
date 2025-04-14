import '../models/group.dart';
import '../services/group_service.dart';

class GroupController {
  final GroupService _groupService = GroupService();

  Future<void> addGroup(Group group) async {
    await _groupService.addGroup(group);
  }

  Future<void> updateGroup(Group oldGroup, Group newGroup) async {
    await _groupService.updateGroup(oldGroup, newGroup);
  }

  Future<void> deleteGroup(Group group) async {
    try {
      await _groupService.deleteGroup(group);
      print('✅ Grupo ${group.name} deletado com seus eventos.');
    } catch (e) {
      print('❌ Erro ao deletar grupo: $e');
      rethrow;
    }
  }

  Stream<List<Group>> getGroups(String userId) {
    return _groupService.getGroups(userId);
  }
}
