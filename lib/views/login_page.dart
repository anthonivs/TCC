import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'registration_page.dart'; // Importe a tela de registro
import 'leader_home_page.dart'; 
import 'volunteer_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState(); // Nome da classe alterado
}

class LoginPageState extends State<LoginPage> { // Nome da classe alterado
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

void _login() async {
  if (_formKey.currentState!.validate()) {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final user = await AuthService().login(email, password);
      if (!mounted) return; // Verifica se o widget ainda está montado
      if (user != null) {
        // Redireciona com base no papel do usuário
        if (user.role == 'Líder') {
          Navigator.pushReplacementNamed(context, '/leaderHome'); // Redireciona para a tela do líder
        } else {
          Navigator.pushReplacementNamed(context, '/volunteerHome'); // Redireciona para a tela do voluntário
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credenciais inválidas. Por favor, tente novamente.')),
        );
      }
    } catch (e) {
      if (!mounted) return; // Verifica se o widget ainda está montado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    }
  }
}

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
              ),
              SizedBox(height: 10), // Espaço entre os botões
              TextButton(
                onPressed: _navigateToRegistration,
                child: Text('Não tem uma conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}