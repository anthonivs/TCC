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
  GroupManagementPageState createState() => GroupManagementPageState();
}

class GroupManagementPageState extends State<GroupManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final GroupController _groupController = GroupController();
  final AuthService _authService = AuthService();

  String _groupName = '';
  String? _selectedLeader;
  List<String> _selectedVolunteers = [];

  @override
  void initState() {
    super.initState();
    if (widget.group != null) {
      _groupName = widget.group!.name;
      _selectedLeader = widget.group!.leader;
      _selectedVolunteers = List.from(widget.group!.volunteers);
    }
  }

  void _createOrUpdateGroup(List<User> users) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = await _authService.currentUser;
      if (currentUser == null) {
        MessageUtils.showError(context, 'Usuário não está logado.');
        return;
      }

      final volunteerIds = users
          .where((user) => _selectedVolunteers.contains(user.name))
          .map((user) => user.id)
          .toList();

      final newGroup = Group(
        id: widget.group?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _groupName,
        leader: _selectedLeader,
        volunteers: _selectedVolunteers,
        userIds: [currentUser.id, ...volunteerIds], 
        events: widget.group?.events ?? [], 
      );

      try {
        if (widget.group == null) {
          await _groupController.addGroup(newGroup);
        } else {
          await _groupController.updateGroup(widget.group!, newGroup);
        }
        MessageUtils.showSuccess(context, 'Grupo salvo com sucesso!');
        Navigator.pop(context, true);
      } catch (e) {
        MessageUtils.showError(context, 'Erro ao salvar grupo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group == null ? 'Criar Grupo' : 'Editar Grupo'),
      ),
      body: StreamBuilder<List<User>>(
        stream: _authService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar usuários: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Nome do Grupo'),
                    initialValue: _groupName,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome do grupo';
                      }
                      return null;
                    },
                    onSaved: (value) => _groupName = value!,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Líder do Grupo'),
                    value: _selectedLeader,
                    items: users
                        .where((user) => user.role == 'Líder')
                        .map((leader) => DropdownMenuItem(
                              value: leader.name,
                              child: Text(leader.name),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedLeader = value),
                  ),
                  SizedBox(height: 16),
                  Text('Voluntários:'),
                  Expanded(
                    child: ListView(
                      children: users
                          .where((user) => user.role == 'Voluntário')
                          .map((volunteer) => CheckboxListTile(
                                title: Text(volunteer.name),
                                value: _selectedVolunteers.contains(volunteer.name),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    if (selected == true) {
                                      _selectedVolunteers.add(volunteer.name);
                                    } else {
                                      _selectedVolunteers.remove(volunteer.name);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _createOrUpdateGroup(users), 
                    child: Text(widget.group == null ? 'Criar Grupo' : 'Salvar Alterações'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
