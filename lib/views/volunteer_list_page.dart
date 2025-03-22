import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import '../models/user.dart'; 

class UserListPage extends StatelessWidget {
  final AuthService _authService = AuthService(); 

  UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Usuários'), 
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
          print('Usuários carregados: ${users.length}'); 

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.name),
                subtitle: Text('${user.email} - ${user.role}'), 
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final _ = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Excluir Usuário'),
                          content: Text('Tem certeza que deseja excluir ${user.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Excluir', style: TextStyle(color: Colors.red)),
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
        },
      ),
    );
  }
}