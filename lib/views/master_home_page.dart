import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'group_management_page.dart';
import 'registration_page.dart';
import 'user_list_page.dart';
// ignore: unused_import
import '../views/profile_page.dart';

class MasterHomePage extends StatelessWidget {
  const MasterHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página do Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Cadastrar Grupo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GroupManagementPage(group: null),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Gerenciar Grupos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Cadastrar Voluntário/Líder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Visualizar Usuários'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserListPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(child: Text('Selecione uma opção no menu')),
    );
  }
}
