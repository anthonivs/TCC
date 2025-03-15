import 'package:tccapp/models/event.dart';

class Group {
  final String id;
  final String name;
  final String? leader;
  final List<String> volunteers;
  final List<String> userIds;
  final List<Event> events; 

  Group({
    required this.id,
    required this.name,
    this.leader,
    required this.volunteers,
    this.userIds = const [],
    this.events = const [], 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'leader': leader,
      'volunteers': volunteers,
      'userIds': userIds,
      'events': events.map((event) => event.toMap()).toList(), // Converte eventos para Map
    };
  }

  // Cria um Group a partir de um Map (usado no Firestore)
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      leader: map['leader'],
      volunteers: List<String>.from(map['volunteers'] ?? []),
      userIds: List<String>.from(map['userIds'] ?? []),
      events: (map['events'] as List<dynamic>?)
              ?.map((event) => Event.fromMap(event))
              .toList() ??
          [], // Converte Map para eventos
    );
  }
}