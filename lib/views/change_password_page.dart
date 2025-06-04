import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authService.changePassword(_passwordController.text);
      if (!mounted) return;
      MessageUtils.showSuccess(context, 'Senha atualizada com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao alterar senha: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Atualizar Senha'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
