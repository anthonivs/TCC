import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../utils/show_message.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _occupationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body:
          _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _occupationCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Ocupação',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'O que você mais gosta de fazer na igreja',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _loadUser() async {
    final user = await _authService.currentUser;
    setState(() {
      _currentUser = user;
      _nameCtrl.text = user?.name ?? '';
      _phoneCtrl.text = user?.phone ?? '';
      _occupationCtrl.text = user?.occupation ?? '';
      _descCtrl.text = user?.description ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _authService.updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        occupation:
            _occupationCtrl.text.trim().isEmpty
                ? null
                : _occupationCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      );
      await _loadUser(); // Recarrega dados atualizados
      if (!mounted) return;
      MessageUtils.showSuccess(context, 'Perfil atualizado com sucesso!');
    } catch (e) {
      if (!mounted) return;
      MessageUtils.showError(context, e.toString());
    }
  }
}
