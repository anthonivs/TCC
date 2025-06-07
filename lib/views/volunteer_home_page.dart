import 'package:flutter/material.dart';
import 'package:tccapp/controllers/event_controller.dart';
import 'package:tccapp/models/event.dart';
import 'package:tccapp/widgets/unified_calendar.dart';
import '../services/auth_service.dart';
import 'group_list_page.dart';
import '../views/profile_page.dart';
import '../models/user.dart';

class VolunteerHomePage extends StatefulWidget {
  const VolunteerHomePage({super.key});

  @override
  State<VolunteerHomePage> createState() => _VolunteerHomePageState();
}

class _VolunteerHomePageState extends State<VolunteerHomePage> {
  final EventController _eventController = EventController();
  User? currentUser;
  String? _expandedEventId;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService().currentUser;
    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página do Voluntário'),
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
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendário de Atividades'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getUserRelatedEventsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
          final selectedEvents =
              events.where((e) => isSameDay(e.date, _selectedDay)).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                UnifiedCalendar(
                  events: events,
                  onDaySelected: (day, evts) {
                    setState(() {
                      _selectedDay = day;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedEvents[index];
                      final isConfirmed = event.confirmedUserIds.contains(
                        currentUser?.id,
                      );
                      final isAssigned = event.assignedUserIds.contains(
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
                            "Confirmados: ${event.confirmedUserIds.length}",
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Local: ${event.location}"),
                                  Text("Horário: ${event.time}"),
                                  const SizedBox(height: 8),
                                  isAssigned
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            onPressed: () async {
                                              await _eventController
                                                  .toggleAttendance(event.id!);
                                              setState(() {
                                                _expandedEventId = event.id;
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
                                      )
                                      : const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: Text(
                                          'Você não está escalado para este evento.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
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
          );
        },
      ),
    );
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
