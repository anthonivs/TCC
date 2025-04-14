import 'package:flutter/material.dart';
import 'package:tccapp/models/user.dart';
import '../models/group.dart';
import '../controllers/group_controller.dart';
import 'group_calendar_page.dart';
import 'group_management_page.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final GroupController _groupController = GroupController();
  final AuthService _authService = AuthService();

  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.currentUser;
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Lista de Grupos')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Grupos'),
      ),
      body: StreamBuilder<List<Group>>(
        stream: _groupController.getGroups(currentUser!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("❌ Erro ao buscar grupos: ${snapshot.error}");
            return Center(child: Text('Erro ao carregar grupos: ${snapshot.error}'));
          }

          final groups = snapshot.data ?? [];

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ExpansionTile(
                title: Text(group.name),
                subtitle: Text('Líder: ${group.leader}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentUser!.role == 'Líder')
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroupManagementPage(group: group),
                            ),
                          );
                          if (updated == true && mounted) {
                            setState(() {}); // recarrega os grupos
                          }
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupCalendarPage(group: group),
                          ),
                        );
                      },
                    ),
                    if (currentUser!.role == 'Líder')
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _confirmDeleteGroup(context, group),
                      ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voluntários:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...group.volunteers.map((v) => Text('- $v')),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDeleteGroup(BuildContext context, Group group) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir Grupo'),
          content: Text('Tem certeza que deseja excluir o grupo "${group.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  print('🗑️ Excluindo grupo ${group.id}');
                  await _groupController.deleteGroup(group);
                  if (!mounted) return;
                  Navigator.pop(context);
                  MessageUtils.showSuccess(context, 'Grupo excluído com sucesso!');
                  setState(() {}); // recarrega a lista de grupos
                } catch (e) {
                  print('❌ Erro ao excluir grupo: $e');
                  if (mounted) {
                    MessageUtils.showError(context, 'Erro ao excluir grupo: $e');
                  }
                }
              },
              child: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
