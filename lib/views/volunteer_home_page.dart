import 'package:flutter/material.dart';
import '../services/auth_service.dart';
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
              await AuthService().logout(); 
              Navigator.pushReplacementNamed(context, '/login'); 
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center, 
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
                 const SizedBox(height: 16),
              // Botão para acessar o perfil
              ],
            ),
          ),
        ),
      ),
    );
  }
}