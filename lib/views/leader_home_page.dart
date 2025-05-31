import 'package:flutter/material.dart';
import 'package:tccapp/models/user.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import 'registration_page.dart';
import 'user_list_page.dart';
import 'group_list_page.dart';
import '../widgets/unified_calendar.dart';

class LeaderHomePage extends StatefulWidget {
  const LeaderHomePage({super.key});

  @override
  State<LeaderHomePage> createState() => _LeaderHomePageState();
}

class _LeaderHomePageState extends State<LeaderHomePage> {
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

    if (user == null) {
      print('❌ Usuário não autenticado. Cancelando carregamento de eventos.');
      return;
    }

    print('🔍 Buscando grupos para o usuário: ${user.id}');

    try {
      final events = await _eventController.getUserRelatedEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar eventos: $e');
      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página do Líder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        // (sem alteração no menu)
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
              leading: const Icon(Icons.person_add),
              title: const Text('Cadastrar Voluntário'),
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
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Meus Grupos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupListPage()),
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
