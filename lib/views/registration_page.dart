import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/group.dart';
import '../utils/show_message.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  List<Group>  _groups           = [];
  String?      _selectedGroupId;

  List<String> _availableRoles   = [];
  String?      _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadUserRoleOptions();
  }

  Future<void> _loadGroups() async {
    final snapshot = await FirebaseFirestore.instance.collection('groups').get();
    final groups = snapshot.docs.map((doc) {
      return Group.fromMap({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();

    setState(() {
      _groups = groups;
      // pré-seleciona o primeiro grupo
      if (_groups.isNotEmpty && _selectedGroupId == null) {
        _selectedGroupId = _groups.first.id;
      }
    });
  }

  Future<void> _loadUserRoleOptions() async {
    final current = await _authService.currentUser;

    List<String> roles;
    if (current == null) {
      // usuário novo: só pode se cadastrar como Voluntário
      roles = ['Voluntário'];
    } else if (current.role == 'Master') {
      // Master cadastra Líder e Voluntário
      roles = ['Voluntário', 'Líder'];
    } else {
      // Líder cadastra só Voluntário
      roles = ['Voluntário'];
    }

    setState(() {
      _availableRoles = roles;
      // pré-seleciona a primeira opção
      _selectedRole = roles.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v != null && v.contains('@') ? null : 'Email inválido',
              ),
              const SizedBox(height: 12),

              // Senha
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) => v != null && v.length >= 6
                    ? null
                    : 'Senha com mínimo de 6 caracteres',
              ),
              const SizedBox(height: 12),

              // Tipo de Usuário (role)
              if (_availableRoles.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Tipo de Usuário'),
                  value: _selectedRole,
                  items: _availableRoles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedRole = v),
                  validator: (v) => v == null ? 'Escolha um tipo de usuário' : null,
                ),
                const SizedBox(height: 12),
              ],

              // Selecionar Grupo
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Selecionar Grupo'),
                value: _selectedGroupId,
                items: _groups.map((g) {
                  return DropdownMenuItem(
                    value: g.id,
                    child: Text(g.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedGroupId = v),
                validator: (v) => v == null ? 'Escolha um grupo' : null,
              ),
              const SizedBox(height: 24),

              // Botão Cadastrar
              ElevatedButton(
                onPressed: _onRegister,
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // validação extra
    if (_selectedRole == null || _selectedGroupId == null) {
      MessageUtils.showError(context, 'Preencha todos os campos antes de cadastrar.');
      return;
    }

    try {
      await _authService.register(
        _emailController.text,
        _passwordController.text,
        name:     _nameController.text,
        role:     _selectedRole!,             // garantido não-null
        groupIds: [_selectedGroupId!],       // garantido não-null
      );
      if (!context.mounted) return;
      MessageUtils.showSuccess(context, 'Usuário cadastrado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      MessageUtils.showError(context, e.toString());
    }
  }
}
