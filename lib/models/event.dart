class Event {
  final DateTime date;
  final String description;
  final String location;
  final String time;
  final String groupId;

  Event({
    required this.date,
    required this.description,
    required this.location,
    required this.time,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'description': description,
      'location': location,
      'time': time,
      'groupId': groupId,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      date: DateTime.parse(map['date']),
      description: map['description'],
      location: map['location'],
      time: map['time'],
      groupId: map['groupId'],
    );
  }
}