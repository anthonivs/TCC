import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final user = await AuthService().login(email, password);

      // debug: veja no console qual role chegou
      debugPrint('📋 [LoginPage] user.role = ${user?.role}');

      if (!mounted) return;
      if (user != null) {
        // limpa toda a stack e retorna ao AuthGate ("/"),
        // que vai exibir a home correta conforme user.role
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        MessageUtils.showError(context, 'Credenciais inválidas.');
      }
    } catch (e) {
      if (!mounted) return;
      MessageUtils.showError(context, 'Erro ao fazer login: $e');
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistrationPage(isSelfRegistration: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Por favor, insira o email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Por favor, insira a senha';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Entrar'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _navigateToRegistration,
                child: const Text('Não tem uma conta? Cadastre-se'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: const Text('Esqueceu sua senha?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
