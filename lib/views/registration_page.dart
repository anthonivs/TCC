import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  String _role = 'Voluntário';
  bool _isLoading = false; 

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text;
      final password = _passwordController.text;
      final name = _nameController.text;

      if (password != _confirmPasswordController.text) {
        MessageUtils.showError(context, 'As senhas não coincidem. Por favor, tente novamente.');
        setState(() => _isLoading = false);
        return;
      }

      try {
        final user = await AuthService().register(email, password, name, _role);
        if (!mounted) return;
        if (user != null) {
          MessageUtils.showSuccess(context, 'Cadastro realizado com sucesso!');
          await Future.delayed(Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, '/login');
        }
      } catch (e) {
        if (!mounted) return;
        MessageUtils.showError(context, e.toString());
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Por favor, insira o nome' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira o email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Por favor, insira um email válido';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'A senha deve ter pelo menos 6 caracteres' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
                validator: (value) => value != _passwordController.text ? 'As senhas não coincidem' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                items: ['Voluntário', 'Líder']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) => setState(() => _role = value!),
                decoration: InputDecoration(labelText: 'Função'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      child: Text('Cadastrar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
