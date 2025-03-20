import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import 'group_management_page.dart';
import 'user_list_page.dart'; 
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
                    Navigator.pushNamed(context, '/registration'); 
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
                      MaterialPageRoute(builder: (context) => UserListPage()), 
                    );
                  },
                  child: Text('Visualizar Usuários'), 
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