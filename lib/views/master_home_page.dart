import 'package:flutter/material.dart';
import 'group_list_page.dart';
import 'group_management_page.dart';
import 'registration_page.dart';
import 'user_list_page.dart'; // import adicionado para visualizar usuários
// ignore: unused_import
import '../views/profile_page.dart'; // import adicionado para perfil

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.group_add),
                label: const Text('Cadastrar Grupo'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupManagementPage(group: null),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.group),
                label: const Text('Gerenciar Grupos'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GroupListPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar Voluntário/Líder'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegistrationPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Botão para visualizar usuários
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Visualizar Usuários'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserListPage()),
                  );
                },
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
