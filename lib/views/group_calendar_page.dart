import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/group.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import '../services/auth_service.dart';
import '../utils/show_message.dart';
import '../models/user.dart';

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

  User? _currentUser;
  List<User> _groupUsers = [];
  String? _expandedEventId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.currentUser;
    final allUsers = await _authService.getAllUsers();
    final groupUsers = allUsers.where((u) => widget.group.userIds.contains(u.id)).toList();

    setState(() {
      _currentUser = user;
      _groupUsers = groupUsers;
    });
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
      body: _currentUser == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Event>>(
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
                            .map((event) {
                              final isConfirmed = event.confirmedUserIds.contains(_currentUser!.id);
                              final isLeader = _currentUser!.role == 'Líder';
                              final confirmedUsers = _groupUsers
                                  .where((u) => event.confirmedUserIds.contains(u.id))
                                  .map((u) => '- ${u.name}')
                                  .join('\n');

                              return Card(
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: ExpansionTile(
                                  key: ValueKey(event.id),
                                  initiallyExpanded: _expandedEventId == event.id,
                                  onExpansionChanged: (expanded) {
                                    setState(() {
                                      _expandedEventId = expanded ? event.id : null;
                                    });
                                  },
                                  title: Text(event.description),
                                  subtitle: Text('Confirmados: ${event.confirmedUserIds.length}'),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Local: ${event.location}'),
                                          Text('Horário: ${event.time}'),
                                          const SizedBox(height: 8),
                                          if (isLeader && confirmedUsers.isNotEmpty)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Confirmados:',
                                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                                Text(confirmedUsers),
                                              ],
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () async {
                                                  await _eventController.toggleAttendance(event.id!);
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  isConfirmed ? Icons.cancel : Icons.check_circle,
                                                  color: isConfirmed ? Colors.red : Colors.green,
                                                ),
                                                label: Text(
                                                  isConfirmed ? 'Cancelar presença' : 'Confirmar presença',
                                                  style: TextStyle(
                                                    color: isConfirmed ? Colors.red : Colors.green,
                                                  ),
                                                ),
                                              ),
                                              if (isLeader)
                                                IconButton(
                                                  icon: Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () async {
                                                    try {
                                                      await _eventController.deleteEvent(event.id!);
                                                      if (!mounted) return;
                                                      MessageUtils.showSuccess(
                                                          context, 'Evento excluído com sucesso!');
                                                    } catch (e) {
                                                      if (!mounted) return;
                                                      MessageUtils.showError(context, 'Erro ao excluir evento.');
                                                    }
                                                  },
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            })
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
