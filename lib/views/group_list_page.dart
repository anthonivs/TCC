import 'package:flutter/material.dart';
import 'package:tccapp/models/user.dart';
import '../models/group.dart';
import '../controllers/group_controller.dart';
import 'group_calendar_page.dart';
import 'group_management_page.dart';
import '../services/auth_service.dart';

class GroupListPage extends StatelessWidget {
  final GroupController _groupController = GroupController();
  final AuthService _authService = AuthService();

  GroupListPage({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Lista de Grupos'),
    ),
    body: StreamBuilder<List<Group>>(
      stream: _groupController.getGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar grupos: ${snapshot.error}'));
        }

        final groups = snapshot.data ?? [];

        return FutureBuilder<User?>(
          future: _authService.currentUser, 
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final currentUser = userSnapshot.data;

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
                      if (currentUser?.role == 'Líder')
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
                      if (currentUser?.role == 'Líder')
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _groupController.deleteGroup(group);
                Navigator.pop(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Grupo excluído com sucesso!')),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GroupListPage()),
                  );
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