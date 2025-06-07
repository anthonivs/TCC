import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../models/group.dart';
import '../utils/show_message.dart';

class RegistrationPage extends StatefulWidget {
  final bool isSelfRegistration;
  const RegistrationPage({super.key, this.isSelfRegistration = false});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  List<Group> _groups = [];
  String? _selectedGroupId;

  List<String> _availableRoles = [];
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    _loadUserRoleOptions();
  }

  Future<void> _loadGroups() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('groups').get();
      final groups =
          snapshot.docs.map((doc) {
            return Group.fromMap({...doc.data(), 'id': doc.id});
          }).toList();

      if (mounted) {
        setState(() {
          _groups = groups;
          _selectedGroupId = groups.isNotEmpty ? groups.first.id : null;
        });
      }
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao carregar grupos.');
    }
  }

  Future<void> _loadUserRoleOptions() async {
    final current = await _authService.currentUser;

    List<String> roles;
    if (widget.isSelfRegistration || current == null) {
      roles = ['Voluntário'];
    } else if (current.role == 'Master') {
      roles = ['Voluntário', 'Líder'];
    } else {
      roles = ['Voluntário'];
    }

    if (mounted) {
      setState(() {
        _availableRoles = roles;
        _selectedRole = roles.first;
      });
    }
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null ||
        (_selectedRole == 'Voluntário' && _selectedGroupId == null)) {
      MessageUtils.showError(
        context,
        'Preencha todos os campos obrigatórios antes de cadastrar.',
      );
      return;
    }

    try {
      await _authService.register(
        _emailController.text,
        _passwordController.text,
        name: _nameController.text,
        role: _selectedRole!,
        groupIds: (_selectedGroupId != null) ? [_selectedGroupId!] : [],
      );

      if (!mounted) return;
      MessageUtils.showSuccess(context, 'Usuário cadastrado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();

      if (message.contains('email-already-in-use')) {
        MessageUtils.showError(
          context,
          'Este e-mail já está em uso por outra conta.',
        );
      } else if (message.contains('invalid-email')) {
        MessageUtils.showError(context, 'E-mail inválido.');
      } else if (message.contains('weak-password')) {
        MessageUtils.showError(
          context,
          'Senha fraca. Use no mínimo 6 caracteres.',
        );
      } else {
        MessageUtils.showError(
          context,
          'Erro ao cadastrar: ${message.replaceAll('Exception: ', '')}',
        );
      }
    }
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (v) =>
                        v != null && v.contains('@') ? null : 'Email inválido',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator:
                    (v) =>
                        v != null && v.length >= 6
                            ? null
                            : 'Senha com mínimo de 6 caracteres',
              ),
              const SizedBox(height: 12),

              if (_availableRoles.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Usuário',
                  ),
                  value: _selectedRole,
                  items:
                      _availableRoles.map((role) {
                        return DropdownMenuItem(value: role, child: Text(role));
                      }).toList(),
                  onChanged: (v) => setState(() => _selectedRole = v),
                  validator:
                      (v) => v == null ? 'Escolha um tipo de usuário' : null,
                ),
                const SizedBox(height: 12),
              ],

              if (_selectedRole == 'Voluntário' || _groups.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Selecionar Grupo',
                  ),
                  value: _selectedGroupId,
                  items:
                      _groups.map((g) {
                        return DropdownMenuItem(
                          value: g.id,
                          child: Text(g.name),
                        );
                      }).toList(),
                  onChanged: (v) => setState(() => _selectedGroupId = v),
                  validator: (v) {
                    if (_selectedRole == 'Voluntário') {
                      return v == null ? 'Escolha um grupo' : null;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

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
}
