import 'package:flutter/material.dart';
import 'package:tccapp/views/user_profile_page.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../utils/show_message.dart';

class UserListPage extends StatelessWidget {
  final AuthService _authService = AuthService();

  UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Usuários')),
      body: StreamBuilder<List<User>>(
        stream: _authService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar usuários: ${snapshot.error}'),
            );
          }

          final users = snapshot.data ?? [];

          return FutureBuilder<User?>(
            future: _authService.currentUser,
            builder: (context, currentUserSnapshot) {
              if (currentUserSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final currentUser = currentUserSnapshot.data;
              final role = currentUser?.role;
              final canDelete = role == 'Líder' || role == 'Master';

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final isCurrentUser = currentUser?.id == user.id;

                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('${user.email} - ${user.role}'),
                    trailing:
                        (canDelete || isCurrentUser)
                            ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => _confirmDeleteUser(
                                    context,
                                    user,
                                    canDelete,
                                    isCurrentUser,
                                  ),
                            )
                            : null,
                    onTap: () {
                      if (canDelete) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserProfilePage(user: user),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteUser(
    BuildContext context,
    User user,
    bool canDelete,
    bool isCurrentUser,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text('Tem certeza que deseja excluir ${user.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      String message;

      if (isCurrentUser) {
        final password = await _showPasswordDialog(context);
        if (password == null) return;

        message = await _authService.deleteUserAccount(
          targetUserId: user.id,
          currentUserPassword: password,
          isLeader: canDelete,
        );
      } else {
        message = await _authService.deleteUserAccount(
          targetUserId: user.id,
          isLeader: canDelete,
        );
      }

      if (!context.mounted) return;
      MessageUtils.showSuccess(context, message);

      await Future.delayed(const Duration(seconds: 1));

      if (!context.mounted) return;
      if (isCurrentUser) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      } else {
        Navigator.pushReplacementNamed(context, '/leaderHome');
      }
    } catch (e) {
      _showErrorMessage(context, e.toString());
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmação de Senha'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Digite sua senha para confirmar',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.pop(context, passwordController.text),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    MessageUtils.showError(context, message);
  }
}
