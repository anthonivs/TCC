import 'package:flutter/material.dart';
import 'package:tccapp/controllers/event_controller.dart';
import 'package:tccapp/models/event.dart';
import 'package:tccapp/models/user.dart';
import 'package:tccapp/services/auth_service.dart';
import 'package:tccapp/widgets/unified_calendar.dart';
import 'group_list_page.dart';
import 'group_management_page.dart';
import 'registration_page.dart';
import 'user_list_page.dart';
// ignore: unused_import
import '../views/profile_page.dart';

class MasterHomePage extends StatefulWidget {
  const MasterHomePage({super.key});

  @override
  State<MasterHomePage> createState() => _MasterHomePageState();
}

class _MasterHomePageState extends State<MasterHomePage> {
  final EventController _eventController = EventController();
  User? currentUser;
  String? _expandedEventId;
  List<Event> _events = [];
  List<Event> _selectedDayEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final user = await AuthService().currentUser;
    final events =
        await _eventController.getAllEvents().first; // <- todos os eventos

    setState(() {
      currentUser = user;
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página do Master'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Cadastrar Grupo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GroupManagementPage(group: null),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Gerenciar Grupos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Cadastrar Voluntário/Líder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegistrationPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Visualizar Usuários'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserListPage()),
                );
              },
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    UnifiedCalendar(
                      events: _events,
                      onDaySelected: (day, events) {
                        setState(() {
                          _selectedDayEvents = events;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _selectedDayEvents.length,
                        itemBuilder: (context, index) {
                          final eventId = _selectedDayEvents[index].id;
                          final event = _events.firstWhere(
                            (e) => e.id == eventId,
                          ); // sempre atualizado
                          final isConfirmed = event.confirmedUserIds.contains(
                            currentUser?.id,
                          );

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
                                  _expandedEventId = expanded ? event.id : null;
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () async {
                                              final selectedDate = DateTime(
                                                event.date.year,
                                                event.date.month,
                                                event.date.day,
                                              );

                                              await _eventController
                                                  .toggleAttendance(event.id!);

                                              final updatedEvents =
                                                  await _eventController
                                                      .getUserRelatedEvents();

                                              final updatedEvent = updatedEvents
                                                  .firstWhere(
                                                    (e) => e.id == event.id,
                                                  );

                                              setState(() {
                                                _events = updatedEvents;
                                                _selectedDayEvents =
                                                    updatedEvents
                                                        .where(
                                                          (e) =>
                                                              e.date.year ==
                                                                  selectedDate
                                                                      .year &&
                                                              e.date.month ==
                                                                  selectedDate
                                                                      .month &&
                                                              e.date.day ==
                                                                  selectedDate
                                                                      .day,
                                                        )
                                                        .toList();
                                                _expandedEventId =
                                                    updatedEvent.id;
                                              });
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
                ),
              ),
    );
  }
}
