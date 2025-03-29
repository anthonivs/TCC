import 'package:flutter/material.dart';
import 'package:tccapp/models/user.dart';
import '../models/group.dart';
import '../controllers/group_controller.dart';
import 'group_calendar_page.dart';
import 'group_management_page.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class GroupListPage extends StatelessWidget {
  final GroupController _groupController = GroupController();
  final AuthService _authService = AuthService();

  GroupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _authService.currentUser,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Lista de Grupos')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = userSnapshot.data;
        if (currentUser == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Lista de Grupos')),
            body: Center(child: Text('Usuário não autenticado.')),
          );
        }

        print("🔍 Buscando grupos para o usuário: ${currentUser.id}");

        return Scaffold(
          appBar: AppBar(
            title: Text('Lista de Grupos'),
          ),
          body: StreamBuilder<List<Group>>(
            stream: _groupController.getGroups(currentUser.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print("❌ Erro ao buscar grupos: ${snapshot.error}");
                return Center(child: Text('Erro ao carregar grupos: ${snapshot.error.toString()}'));
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
                        if (currentUser.role == 'Líder')
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupManagementPage(group: group),
                                ),
                              );

                              if (updated == true && context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => GroupListPage()),
                                );
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
                        if (currentUser.role == 'Líder')
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _confirmDeleteGroup(context, group);
                            },
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
                            ...group.volunteers.map((volunteer) => Text('- $volunteer')),
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
      },
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
                  await _groupController.deleteGroup(group);
                  if (context.mounted) {
                    MessageUtils.showSuccess(context, 'Grupo excluído com sucesso!');
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => GroupListPage()),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    MessageUtils.showError(context, 'Erro ao excluir grupo');
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
