// master_home_page.dart
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

class MasterHomePage extends StatefulWidget {
  MasterHomePage({super.key});

  @override
  State<MasterHomePage> createState() => _MasterHomePageState();
}

class _MasterHomePageState extends State<MasterHomePage> {
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
        title: Text('Página do Master'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
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
              leading: Icon(Icons.group_add),
              title: Text('Cadastrar Grupo'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupManagementPage(group: null),
                    ),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Gerenciar Grupos'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GroupListPage()),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Cadastrar Voluntário/Líder'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegistrationPage()),
                  ),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Visualizar Usuários'),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserListPage()),
                  ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getAllEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
          final selectedEvents =
              _selectedDayEvents.isNotEmpty
                  ? _selectedDayEvents
                  : events
                      .where((e) => isSameDay(e.date, DateTime.now()))
                      .toList();

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                UnifiedCalendar(
                  events: events,
                  onDaySelected: (day, evts) {
                    setState(() {
                      _selectedDayEvents = evts;
                    });
                  },
                ),
                SizedBox(height: 16),
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
                        margin: EdgeInsets.symmetric(
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
                          subtitle: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                TextSpan(
                                  text: "Confirmados: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: "${event.confirmedUserIds.length}",
                                ),
                              ],
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
                                  Text(
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
                                      if (!snapshot.hasData)
                                        return Text("Carregando...");
                                      final assignedUsers =
                                          snapshot.data!
                                              .where(
                                                (u) => event.assignedUserIds
                                                    .contains(u.id),
                                              )
                                              .toList();

                                      if (assignedUsers.isEmpty)
                                        return Text(
                                          "Nenhum voluntário escalado.",
                                        );

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
                                                  SizedBox(width: 8),
                                                  Text(user.name),
                                                ],
                                              );
                                            }).toList(),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8),
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                          text: "Local: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: event.location),
                                      ],
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: [
                                        TextSpan(
                                          text: "Horário: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(text: event.time),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextButton.icon(
                                    icon: Icon(Icons.group_add),
                                    label: Text("Definir Escala"),
                                    onPressed: () async {
                                      final groupVolunteers =
                                          await AuthService().getUsersInGroup(
                                            event.groupId,
                                          );
                                      final selectedIds = [
                                        ...event.assignedUserIds,
                                      ];

                                      await showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text(
                                                'Escalar voluntários',
                                              ),
                                              content: SizedBox(
                                                width: double.maxFinite,
                                                child: StatefulBuilder(
                                                  builder:
                                                      (
                                                        context,
                                                        setState,
                                                      ) => ListView(
                                                        shrinkWrap: true,
                                                        children:
                                                            groupVolunteers.map((
                                                              user,
                                                            ) {
                                                              return CheckboxListTile(
                                                                title: Text(
                                                                  user.name,
                                                                ),
                                                                value: selectedIds
                                                                    .contains(
                                                                      user.id,
                                                                    ),
                                                                onChanged: (
                                                                  checked,
                                                                ) {
                                                                  setState(() {
                                                                    if (checked ==
                                                                        true) {
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
                                                      ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await _eventController
                                                        .assignVolunteersToEvent(
                                                          event.id!,
                                                          selectedIds,
                                                        );
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Salvar'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 8),
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
                                      : Padding(
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
