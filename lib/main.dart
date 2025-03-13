import 'package:firebase_core/firebase_core.dart'; // Importe o Firebase Core
import 'package:flutter/material.dart';
import 'views/login_page.dart'; // Importe sua página de login
import 'views/leader_home_page.dart'; // Importe a tela do líder
import 'views/volunteer_home_page.dart'; // Importe a tela do voluntário
import 'views/registration_page.dart'; // Importe a tela de registro
import 'firebase_options.dart'; // Importe as opções do Firebase geradas pelo flutterfire_cli

void main() async {
  // Garante que o Flutter esteja inicializado antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções específicas da plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Executa o aplicativo
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão de Voluntários',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Rota inicial
      routes: {
        '/login': (context) => LoginPage(), // Rota para a tela de login
        '/leaderHome': (context) => LeaderHomePage(), // Rota para a tela do líder
        '/volunteerHome': (context) => VolunteerHomePage(), // Rota para a tela do voluntário
        '/registration': (context) => RegistrationPage(), // Rota para a tela de registro
      },
      onUnknownRoute: (settings) {
        // Redireciona para a tela de login caso a rota não seja encontrada
        return MaterialPageRoute(builder: (context) => LoginPage());
      },
    );
  }
}