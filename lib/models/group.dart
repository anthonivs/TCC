import 'event.dart';

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
    required this.leader,
    required this.volunteers,
    required this.userIds,
    required this.events,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'leader': leader,
      'volunteers': volunteers,
      'userIds': userIds,
      'events': events.map((event) => event.toMap()).toList(),
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      leader: map['leader'],
      volunteers: List<String>.from(map['volunteers'] ?? []),
      userIds: List<String>.from(map['userIds'] ?? []),
      events: (map['events'] is List)
          ? List<Event>.from(
              (map['events'] as List)
                  .where((e) => e is Map<String, dynamic>)
                  .map((e) => Event.fromMap(e)))
          : [],
    );
  }
}
