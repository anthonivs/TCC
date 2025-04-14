class Event {
  final String? id;
  final DateTime date;
  final String description;
  final String location;
  final String time;
  final String groupId;
  final List<String> confirmedUserIds; // ✅ novo campo

  Event({
    this.id,
    required this.date,
    required this.description,
    required this.location,
    required this.time,
    required this.groupId,
    this.confirmedUserIds = const [], // valor padrão
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'location': location,
      'time': time,
      'groupId': groupId,
      'confirmedUserIds': confirmedUserIds, // salva no Firestore
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
      confirmedUserIds: map['confirmedUserIds'] != null
          ? List<String>.from(map['confirmedUserIds'])
          : [],
    );
  }
}
