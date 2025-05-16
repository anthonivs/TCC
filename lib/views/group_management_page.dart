import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../controllers/group_controller.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class GroupManagementPage extends StatefulWidget {
  final Group? group;

  const GroupManagementPage({super.key, this.group});

  @override
  State<GroupManagementPage> createState() => _GroupManagementPageState();
}

class _GroupManagementPageState extends State<GroupManagementPage> {
  final GroupController _groupController = GroupController();
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoading = true;
  List<User> _allUsers = [];
  List<User> _leaders = [];
  List<User> _volunteers = [];
  Set<String> _selectedVolunteerIds = {};
  String? _selectedLeaderId;

  @override
  void initState() {
    super.initState();
    // Se vier um grupo para edição, já preenchemos nome e seleções
    if (widget.group != null) {
      _nameController.text = widget.group!.name;
      _selectedVolunteerIds = widget.group!.userIds.toSet();
      _selectedLeaderId = widget.group!.leaderId;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _authService.getAllUsers();
      setState(() {
        _allUsers    = users;
        _leaders     = users.where((u) => u.role == 'Líder').toList();
        _volunteers  = users.where((u) => u.role == 'Voluntário').toList();
      });
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao carregar usuários: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _saveGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty || _selectedLeaderId == null) {
      MessageUtils.showInfo(context, 'Preencha o nome e selecione o líder.');
      return;
    }

    final selectedLeader =
        _leaders.firstWhere((u) => u.id == _selectedLeaderId);
    final volunteerNames = _allUsers
        .where((u) => _selectedVolunteerIds.contains(u.id))
        .map((u) => u.name)
        .toList();

    final newGroup = Group(
      id: widget.group?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: groupName,
      leader: selectedLeader.name,
      leaderId: selectedLeader.id,
      userIds:
          _selectedVolunteerIds.union({selectedLeader.id}).toList(),
      volunteers: volunteerNames,
      events: widget.group?.events ?? [],
    );

    try {
      if (widget.group == null) {
        await _groupController.addGroup(newGroup);
        MessageUtils.showSuccess(context, 'Grupo criado com sucesso!');
      } else {
        await _groupController.updateGroup(widget.group!, newGroup);
        MessageUtils.showSuccess(context, 'Grupo atualizado com sucesso!');
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao salvar grupo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'Criar Grupo' : 'Editar Grupo'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration:
                        InputDecoration(labelText: 'Nome do Grupo'),
                  ),
                  const SizedBox(height: 16),
                  Text('Líder do Grupo',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedLeaderId,
                    hint: Text('Selecione um líder'),
                    items: _leaders
                        .map((leader) => DropdownMenuItem(
                              value: leader.id,
                              child: Text(leader.name),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedLeaderId = value),
                  ),
                  const SizedBox(height: 16),
                  Text('Voluntários:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView(
                      children: _volunteers.map((user) {
                        return CheckboxListTile(
                          title: Text(user.name),
                          value:
                              _selectedVolunteerIds.contains(user.id),
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedVolunteerIds.add(user.id);
                              } else {
                                _selectedVolunteerIds.remove(user.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveGroup,
                      child: Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
