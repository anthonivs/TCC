import 'event.dart';

class Group {
  final String id; // Adicione este campo
  final String name;
  final String? leader;
  final List<String> volunteers;
  final List<Event> events;
  final List<String> userIds;

  Group({
    required this.id, // Adicione este campo
    required this.name,
    this.leader,
    required this.volunteers,
    List<Event>? events,
    this.userIds = const [],
  }) : events = events ?? [];

  // Converte um Group para um Map (usado no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Adicione o ID ao mapa
      'name': name,
      'leader': leader,
      'volunteers': volunteers,
      'events': events.map((event) => event.toMap()).toList(),
      'userIds': userIds,
    };
  }

  // Cria um Group a partir de um Map (usado no Firestore)
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'], // Adicione o ID ao construtor
      name: map['name'],
      leader: map['leader'],
      volunteers: List<String>.from(map['volunteers'] ?? []),
      events: (map['events'] as List<dynamic>?)
              ?.map((event) => Event.fromMap(event))
              .toList() ??
          [],
      userIds: List<String>.from(map['userIds'] ?? []),
    );
  }
}