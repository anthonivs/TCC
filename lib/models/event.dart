import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final DateTime date;
  final String description;
  final String location;
  final String time;
  final String groupId;

  Event({
    this.id,
    required this.date,
    required this.description,
    required this.location,
    required this.time,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'description': description,
      'location': location,
      'time': time,
      'groupId': groupId,
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
    );
  }
}
