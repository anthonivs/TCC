import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Importe o AuthService
import 'group_list_page.dart';

class VolunteerHomePage extends StatelessWidget {
  const VolunteerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página do Voluntário'),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GroupListPage()),
                    );
                  },
                  child: Text('Calendário de Atividades'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Implementar visualização do perfil do voluntário
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Funcionalidade em desenvolvimento.')),
                    );
                  },
                  child: Text('Meu Perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}