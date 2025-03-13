import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import '../services/auth_service.dart';

class GroupCalendarPage extends StatefulWidget {
  final Group group;

  // Construtor corrigido com parâmetro 'key' e marcado como 'const'
  const GroupCalendarPage({super.key, required this.group});

  @override
  GroupCalendarPageState createState() => GroupCalendarPageState();
}

// Renomeando a classe para remover o '_' (tornando-a pública)
class GroupCalendarPageState extends State<GroupCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final AuthService _authService = AuthService();
  final EventController _eventController = EventController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

void _checkAccess() async {
  final user = await _authService.currentUser; // Aguarda a resolução do Future
  if (user == null || !widget.group.userIds.contains(user.id)) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Você não tem acesso a este grupo.')),
    );
  }
}

  void _addEvent() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione um dia no calendário.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String newEvent = '';
        String newLocation = '';
        String newTime = '';

        return AlertDialog(
          title: Text('Adicionar Evento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Descrição do evento'),
                onChanged: (value) {
                  newEvent = value;
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Localização do evento'),
                onChanged: (value) {
                  newLocation = value;
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(hintText: 'Horário do evento (ex: 14:00)'),
                onChanged: (value) {
                  newTime = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newEvent.isNotEmpty && newLocation.isNotEmpty && newTime.isNotEmpty) {
                  final event = Event(
                    date: _selectedDay!,
                    description: newEvent,
                    location: newLocation,
                    time: newTime,
                  );
                  _eventController.addEvent(event);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, preencha todos os campos.')),
                  );
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário do Grupo ${widget.group.name}'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getEvents(), // Stream de todos os eventos
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar eventos.'));
          }

          final allEvents = snapshot.data ?? [];

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2022, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                eventLoader: (day) {
                  return allEvents.where((event) => isSameDay(event.date, day)).toList();
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: allEvents
                      .where((event) => isSameDay(event.date, _selectedDay ?? _focusedDay))
                      .map((event) => ListTile(
                            title: Text(event.description),
                            subtitle: Text('Local: ${event.location}\nHorário: ${event.time}'),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: Icon(Icons.add),
      ),
    );
  }
}