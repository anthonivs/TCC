import 'package:flutter/material.dart';
import 'package:tccapp/models/user.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'leader_home_page.dart'; 
import 'volunteer_home_page.dart'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

@override
Widget build(BuildContext context) {
  return FutureBuilder<User?>(
    future: AuthService().currentUser, 
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final currentUser = snapshot.data;

      if (currentUser == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        });
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentUser.role == 'Líder') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LeaderHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => VolunteerHomePage()),
          );
        }
      });

      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}
}