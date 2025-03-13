import 'package:flutter/material.dart';
import '../controllers/volunteer_controller.dart';
import '../models/volunteer.dart';

class VolunteerListPage extends StatelessWidget {
  final VolunteerController _volunteerController = VolunteerController();

  VolunteerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Voluntários'),
      ),
      body: StreamBuilder<List<Volunteer>>(
        stream: _volunteerController.getVolunteers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar voluntários'));
          }

          final volunteers = snapshot.data ?? [];

          return ListView.builder(
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final volunteer = volunteers[index];
              return ListTile(
                title: Text(volunteer.name),
                subtitle: Text(volunteer.email),
              );
            },
          );
        },
      ),
    );
  }
}