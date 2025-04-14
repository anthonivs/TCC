import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';

class GroupCalendarPage extends StatefulWidget {
  final Group group;

  const GroupCalendarPage({super.key, required this.group});

  @override
  GroupCalendarPageState createState() => GroupCalendarPageState();
}

class GroupCalendarPageState extends State<GroupCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final AuthService _authService = AuthService();
  final EventController _eventController = EventController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
    print('Abrindo calendário para o grupo: ${widget.group.id}');
  }

  void _checkAccess() async {
    final user = await _authService.currentUser;
    if (user == null || !widget.group.userIds.contains(user.id)) {
      if (!mounted) return;
      Navigator.pop(context);
      MessageUtils.showError(context, 'Você não tem acesso a este grupo.');
    }
  }

  void _addEvent() {
    if (_selectedDay == null) {
      MessageUtils.showInfo(context, 'Por favor, selecione um dia no calendário.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String newEvent = '';
        String newLocation = '';
        TimeOfDay? selectedTime;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Adicionar Evento'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(hintText: 'Descrição do evento'),
                  onChanged: (value) => newEvent = value,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(hintText: 'Localização do evento'),
                  onChanged: (value) => newLocation = value,
                ),
                SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      hintText: 'Horário do evento',
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      selectedTime != null ? selectedTime!.format(context) : 'Selecione o horário',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (newEvent.isNotEmpty && newLocation.isNotEmpty && selectedTime != null) {
                    final event = Event(
                      date: DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day),
                      description: newEvent,
                      location: newLocation,
                      time: selectedTime!.format(context),
                      groupId: widget.group.id,
                    );
                    try {
                      await _eventController.addEvent(event);
                      if (!mounted) return;
                      Navigator.pop(context);
                      MessageUtils.showSuccess(context, 'Evento adicionado com sucesso!');
                    } catch (e) {
                      if (!mounted) return;
                      MessageUtils.showError(context, 'Erro ao adicionar evento.');
                    }
                  } else {
                    MessageUtils.showInfo(context, 'Por favor, preencha todos os campos.');
                  }
                },
                child: Text('Salvar'),
              ),
            ],
          ),
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
        stream: _eventController.getEvents(widget.group.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('ERRO DO SNAPSHOT: ${snapshot.error}');
            final errorMsg = snapshot.error.toString().contains('permission-denied')
                ? 'Permissão negada. Verifique as regras do Firestore.'
                : 'Erro ao carregar eventos.';
            return Center(child: Text(errorMsg));
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
                onFormatChanged: (format) => setState(() => _calendarFormat = format),
                eventLoader: (day) => allEvents.where((event) => isSameDay(event.date, day)).toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: allEvents
                      .where((event) => isSameDay(event.date, _selectedDay ?? _focusedDay))
                      .map((event) => ListTile(
                            title: Text(event.description),
                            subtitle: Text('Local: ${event.location}\nHorário: ${event.time}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await _eventController.deleteEvent(event.id!);
                                  if (!mounted) return;
                                  MessageUtils.showSuccess(context, 'Evento excluído com sucesso!');
                                } catch (e) {
                                  if (!mounted) return;
                                  MessageUtils.showError(context, 'Erro ao excluir evento.');
                                }
                              },
                            ),
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
