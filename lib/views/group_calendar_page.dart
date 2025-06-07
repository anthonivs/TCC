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
  State<GroupCalendarPage> createState() => GroupCalendarPageState();
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
    try {
      final user = await _authService.currentUser;
      final allUsers = await _authService.getAllUsers();
      final groupUsers =
          allUsers.where((u) => widget.group.userIds.contains(u.id)).toList();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _groupUsers = groupUsers;
        });
      }
    } catch (e) {
      MessageUtils.showError(context, 'Erro ao carregar dados do grupo.');
    }
  }

  void _addEvent() {
    if (_selectedDay == null) {
      MessageUtils.showInfo(context, 'Selecione um dia no calendário.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        String newEvent = '';
        String newLocation = '';
        TimeOfDay? selectedTime;

        return StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('Adicionar Evento'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: 'Descrição'),
                      onChanged: (value) => newEvent = value,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Local'),
                      onChanged: (value) => newLocation = value,
                    ),
                    const SizedBox(height: 16),
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
                        decoration: const InputDecoration(
                          hintText: 'Horário',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          selectedTime != null
                              ? selectedTime!.format(context)
                              : 'Selecione o horário',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      if (newEvent.isEmpty ||
                          newLocation.isEmpty ||
                          selectedTime == null) {
                        MessageUtils.showInfo(
                          context,
                          'Preencha todos os campos.',
                        );
                        return;
                      }

                      final event = Event(
                        date: DateTime(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                        ),
                        description: newEvent,
                        location: newLocation,
                        time: selectedTime!.format(context),
                        groupId: widget.group.id,
                      );

                      try {
                        await _eventController.addEvent(event);
                        if (!mounted) return;
                        Navigator.pop(context);
                        MessageUtils.showSuccess(context, 'Evento adicionado!');
                      } catch (e) {
                        if (!mounted) return;
                        MessageUtils.showError(
                          context,
                          'Erro ao adicionar evento.',
                        );
                      }
                    },
                    child: const Text('Salvar'),
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
      appBar: AppBar(title: Text('Calendário do Grupo ${widget.group.name}')),
      body:
          _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<Event>>(
                stream: _eventController.getEvents(widget.group.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    final errorMsg =
                        snapshot.error.toString().contains('permission-denied')
                            ? 'Permissão negada. Verifique as regras do Firestore.'
                            : 'Erro ao carregar eventos.';
                    return Center(child: Text(errorMsg));
                  }

                  final allEvents = snapshot.data ?? [];
                  final dayEvents =
                      allEvents
                          .where(
                            (e) =>
                                isSameDay(e.date, _selectedDay ?? _focusedDay),
                          )
                          .toList();

                  return Column(
                    children: [
                      TableCalendar(
                        locale: 'pt_BR',
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate:
                            (day) => isSameDay(_selectedDay!, day),
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
                        eventLoader:
                            (day) =>
                                allEvents
                                    .where((e) => isSameDay(e.date, day))
                                    .toList(),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: dayEvents.length,
                          itemBuilder: (context, index) {
                            final event = dayEvents[index];
                            final isConfirmed = event.confirmedUserIds.contains(
                              _currentUser!.id,
                            );
                            final isLeader = _currentUser!.role == 'Líder';
                            final confirmedUsers = _groupUsers
                                .where(
                                  (u) => event.confirmedUserIds.contains(u.id),
                                )
                                .map((u) => '- ${u.name}')
                                .join('\n');

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ExpansionTile(
                                key: ValueKey(event.id),
                                initiallyExpanded: _expandedEventId == event.id,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _expandedEventId =
                                        expanded ? event.id : null;
                                  });
                                },
                                title: Text(event.description),
                                subtitle: Text(
                                  'Confirmados: ${event.confirmedUserIds.length}',
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Local: ${event.location}'),
                                        Text('Horário: ${event.time}'),
                                        const SizedBox(height: 8),
                                        if (isLeader &&
                                            confirmedUsers.isNotEmpty) ...[
                                          const Text(
                                            'Confirmados:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(confirmedUsers),
                                          const SizedBox(height: 8),
                                        ],
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            TextButton.icon(
                                              onPressed: () async {
                                                await _eventController
                                                    .toggleAttendance(
                                                      event.id!,
                                                    );
                                                setState(() {});
                                              },
                                              icon: Icon(
                                                isConfirmed
                                                    ? Icons.cancel
                                                    : Icons.check_circle,
                                                color:
                                                    isConfirmed
                                                        ? Colors.red
                                                        : Colors.green,
                                              ),
                                              label: Text(
                                                isConfirmed
                                                    ? 'Cancelar presença'
                                                    : 'Confirmar presença',
                                                style: TextStyle(
                                                  color:
                                                      isConfirmed
                                                          ? Colors.red
                                                          : Colors.green,
                                                ),
                                              ),
                                            ),
                                            if (isLeader)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    await _eventController
                                                        .deleteEvent(event.id!);
                                                    if (!mounted) return;
                                                    MessageUtils.showSuccess(
                                                      context,
                                                      'Evento excluído!',
                                                    );
                                                  } catch (e) {
                                                    if (!mounted) return;
                                                    MessageUtils.showError(
                                                      context,
                                                      'Erro ao excluir evento.',
                                                    );
                                                  }
                                                },
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
