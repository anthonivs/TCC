import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Importe o AuthService
import 'registration_page.dart';
import 'group_management_page.dart';
import 'volunteer_list_page.dart';
import 'group_list_page.dart';

class LeaderHomePage extends StatelessWidget {
  const LeaderHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página do Líder'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout(); // Faz o logout
              Navigator.pushReplacementNamed(context, '/login'); // Redireciona para a tela de login
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Alinha os botões no topo
              crossAxisAlignment: CrossAxisAlignment.center, // Centraliza horizontalmente
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration'); // Navega para a tela de registro
                  },
                  child: Text('Cadastrar Voluntário/Líder'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupManagementPage()),
                    );
                  },
                  child: Text('Gerenciar Grupos'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VolunteerListPage()),
                    );
                  },
                  child: Text('Visualizar Voluntários'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupListPage()),
                    );
                  },
                  child: Text('Calendário de Atividades'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}