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
    await _groupService.deleteGroup(group);
  }

  Stream<List<Group>> getGroups() {
    return _groupService.getGroups();
  }
}