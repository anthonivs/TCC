import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (!mounted) return;
      MessageUtils.showSuccess(
        context,
        'Um link de redefinição foi enviado para seu email.',
      );
      Navigator.pop(context);
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao enviar link: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Informe seu email para receber o link de redefinição de senha:',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o email';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sendResetLink,
                child: const Text('Enviar link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
