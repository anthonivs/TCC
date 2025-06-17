import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Event> _selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService().currentUser;
    setState(() => currentUser = user);
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
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegistrationPage()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Visualizar Usuários'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserListPage()),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Meus Grupos'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroupListPage()),
                  ),
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
              _selectedDayEvents.isNotEmpty
                  ? _selectedDayEvents
                  : events
                      .where((e) => isSameDay(e.date, DateTime.now()))
                      .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                UnifiedCalendar(
                  events: events,
                  onDaySelected:
                      (day, evts) => setState(() => _selectedDayEvents = evts),
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
                          onExpansionChanged:
                              (expanded) => setState(
                                () =>
                                    _expandedEventId =
                                        expanded ? event.id : null,
                              ),
                          title: Text(event.description),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        const TextSpan(
                                          text: "Confirmados: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              "${event.confirmedUserIds.length}",
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Voluntários escalados:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  StreamBuilder<List<User>>(
                                    stream: AuthService().getUsersInGroupStream(
                                      event.groupId,
                                    ),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const Text("Carregando...");
                                      }
                                      final assignedUsers =
                                          snapshot.data!
                                              .where(
                                                (u) => event.assignedUserIds
                                                    .contains(u.id),
                                              )
                                              .toList();

                                      if (assignedUsers.isEmpty) {
                                        return const Text(
                                          "Nenhum voluntário escalado.",
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children:
                                            assignedUsers.map((user) {
                                              final isUserConfirmed = event
                                                  .confirmedUserIds
                                                  .contains(user.id);
                                              return Row(
                                                children: [
                                                  Icon(
                                                    isUserConfirmed
                                                        ? Icons.check_circle
                                                        : Icons.cancel,
                                                    color:
                                                        isUserConfirmed
                                                            ? Colors.green
                                                            : Colors.red,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(user.name),
                                                ],
                                              );
                                            }).toList(),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    icon: const Icon(Icons.group_add),
                                    label: const Text("Definir Escala"),
                                    onPressed: () async {
                                      // 🔄 Recarrega o evento atualizado do Firestore
                                      final eventSnap =
                                          await FirebaseFirestore.instance
                                              .collection('events')
                                              .doc(event.id)
                                              .get();
                                      final eventData = eventSnap.data();
                                      if (eventData == null) return;

                                      final updatedAssignedIds =
                                          List<String>.from(
                                            eventData['assignedUserIds'] ?? [],
                                          );

                                      final groupVolunteers =
                                          await AuthService().getUsersInGroup(
                                            event.groupId,
                                          );
                                      final selectedIds = [
                                        ...updatedAssignedIds,
                                      ];

                                      await showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: const Text(
                                                'Escalar voluntários',
                                              ),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: StatefulBuilder(
                                                  builder: (
                                                    context,
                                                    setStateDialog,
                                                  ) {
                                                    return ListView(
                                                      shrinkWrap: true,
                                                      children:
                                                          groupVolunteers.map((
                                                            user,
                                                          ) {
                                                            final isSelected =
                                                                selectedIds
                                                                    .contains(
                                                                      user.id,
                                                                    );
                                                            return CheckboxListTile(
                                                              title: Text(
                                                                user.name,
                                                              ),
                                                              value: isSelected,
                                                              onChanged: (
                                                                checked,
                                                              ) {
                                                                setStateDialog(() {
                                                                  if (checked ==
                                                                          true &&
                                                                      !selectedIds
                                                                          .contains(
                                                                            user.id,
                                                                          )) {
                                                                    selectedIds
                                                                        .add(
                                                                          user.id,
                                                                        );
                                                                  } else {
                                                                    selectedIds
                                                                        .remove(
                                                                          user.id,
                                                                        );
                                                                  }
                                                                });
                                                              },
                                                            );
                                                          }).toList(),
                                                    );
                                                  },
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _eventController
                                                        .assignVolunteersToEvent(
                                                          event.id!,
                                                          selectedIds,
                                                        );
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      _selectedDayEvents =
                                                          []; // força o uso da lista atualizada vinda do StreamBuilder
                                                      _expandedEventId =
                                                          event.id!;
                                                    });
                                                  },
                                                  child: const Text('Salvar'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  isAssigned
                                      ? TextButton.icon(
                                        onPressed: () async {
                                          await _eventController
                                              .toggleAttendance(event.id!);
                                          setState(
                                            () => _expandedEventId = event.id,
                                          );
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

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
