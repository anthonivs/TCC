// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tccapp/models/user.dart';
import '../models/group.dart';
import '../controllers/group_controller.dart';
import 'group_calendar_page.dart';
import 'group_management_page.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';
import '../utils/app_theme.dart'; // import do GroupCard

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final GroupController _groupController = GroupController();
  final AuthService _authService = AuthService();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.currentUser;
    if (mounted) setState(() => currentUser = user);
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto carrega o usuário
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lista de Grupos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isMaster = currentUser!.role == 'Master';
    final isLeader = currentUser!.role == 'Líder';

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Grupos')),
      body: StreamBuilder<List<Group>>(
        stream:
            isMaster
                ? _groupController.getAllGroups()
                : _groupController.getGroups(currentUser!.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Erro ao carregar grupos: ${snap.error}'),
            );
          }
          final groups = snap.data ?? [];
          if (groups.isEmpty) {
            return const Center(child: Text('Nenhum grupo encontrado.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final g = groups[i];
              // líder só deve editar/excluir se for líder DESSE grupo,
              // mas Master sempre pode tudo
              final canManage =
                  isMaster || (isLeader && g.leaderId == currentUser!.id);
              //isMaster || (isLeader && g.leader == currentUser!.id);

              return GroupCard(
                name: g.name,
                leader: g.leader,
                volunteersCount: g.volunteers.length,
                onCalendar:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupCalendarPage(group: g),
                      ),
                    ),
                // liberar edição para Master ou Líder daquele grupo
                onEdit:
                    canManage
                        ? () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupManagementPage(group: g),
                            ),
                          );
                          if (updated == true && mounted) setState(() {});
                        }
                        : null,
                // liberar exclusão para Master ou Líder daquele grupo
                onDelete:
                    canManage ? () => _confirmDeleteGroup(context, g) : null,
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
      builder:
          (_) => AlertDialog(
            title: const Text('Excluir Grupo'),
            content: Text('Tem certeza que deseja excluir "${group.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _groupController.deleteGroup(group);
                    if (!mounted) return;
                    Navigator.pop(context);
                    MessageUtils.showSuccess(context, 'Grupo excluído!');
                    setState(() {});
                  } catch (e) {
                    MessageUtils.showError(
                      context,
                      'Erro ao excluir grupo:\n$e',
                    );
                  }
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
