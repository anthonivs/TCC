class Event {
  final String? id;
  final DateTime date;
  final String description;
  final String location;
  final String time;
  final String groupId;
  final List<String> confirmedUserIds;
  final List<String> assignedUserIds;

  Event({
    this.id,
    required this.date,
    required this.description,
    required this.location,
    required this.time,
    required this.groupId,
    this.confirmedUserIds = const [],
    this.assignedUserIds = const [],
    required String title,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'location': location,
      'time': time,
      'groupId': groupId,
      'confirmedUserIds': confirmedUserIds,
      'assignedUserIds': assignedUserIds,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map, {String? id}) {
    return Event(
      id: id,
      date: map['date'].toDate(),
      description: map['description'],
      location: map['location'],
      time: map['time'],
      groupId: map['groupId'],
      confirmedUserIds:
          map['confirmedUserIds'] != null
              ? List<String>.from(map['confirmedUserIds'])
              : [],
      assignedUserIds:
          map['assignedUserIds'] != null
              ? List<String>.from(map['assignedUserIds'])
              : [],
      title: '',
    );
  }
}
