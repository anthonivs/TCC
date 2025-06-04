import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserProfilePage extends StatefulWidget {
  final User user;

  const UserProfilePage({super.key, required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  List<String> groupNames = [];

  @override
  void initState() {
    super.initState();
    _loadGroupNames();
  }

  Future<void> _loadGroupNames() async {
    final firestore = FirebaseFirestore.instance;

    if (widget.user.groupIds.isEmpty) {
      setState(() {
        groupNames = [];
      });
      return;
    }

    final names = <String>[];

    for (final groupId in widget.user.groupIds) {
      final doc = await firestore.collection('groups').doc(groupId).get();
      final name = doc.data()?['name'];
      if (name is String) names.add(name);
    }

    setState(() {
      groupNames = names;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _infoTile('Nome', user.name),
            _infoTile('Email', user.email),
            _infoTile('Telefone', user.phone ?? 'Não informado'),
            _infoTile('Cargo', user.role),
            _infoTile('Ocupação', user.occupation ?? 'Não informada'),
            _infoTile(
              'Grupos',
              groupNames.isEmpty
                  ? 'Nenhum grupo associado'
                  : groupNames.join(', '),
            ),
            _infoTile('Descrição', user.description ?? 'Não informada'),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
