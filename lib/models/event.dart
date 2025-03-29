import 'package:cloud_firestore/cloud_firestore.dart';

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
      'date': Timestamp.fromDate(date),
      'description': description,
      'location': location,
      'time': time,
      'groupId': groupId,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];

    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      throw Exception('Data inválida no evento');
    }

    return Event(
      date: date,
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      time: map['time'] ?? '',
      groupId: map['groupId'] ?? '',
    );
  }
}
