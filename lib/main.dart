import 'package:firebase_core/firebase_core.dart'; 
import 'package:flutter/material.dart';
import 'views/login_page.dart'; 
import 'views/leader_home_page.dart'; 
import 'views/volunteer_home_page.dart'; 
import 'views/registration_page.dart'; 
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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