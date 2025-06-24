/*import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
    } catch (e) {
      throw 'Erro ao adicionar evento: $e';
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw 'Erro ao deletar evento: $e';
    }
  }

  Future<void> toggleUserAttendance(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final snapshot = await eventRef.get();

      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final confirmed = List<String>.from(data['confirmedUserIds'] ?? []);

      if (confirmed.contains(userId)) {
        confirmed.remove(userId);
      } else {
        confirmed.add(userId);
      }

      await eventRef.update({'confirmedUserIds': confirmed});
    } catch (e) {
      throw 'Erro ao confirmar presença: $e';
    }
  }

  Stream<List<Event>> getEvents(String groupId) {
    try {
      return _firestore
          .collection('events')
          .where('groupId', isEqualTo: groupId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) {
                  try {
                    return Event.fromMap(doc.data(), id: doc.id);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<Event>()
                .toList();
          });
    } catch (e) {
      throw 'Erro ao buscar eventos do grupo: $e';
    }
  }

  Stream<List<Event>> getAllEvents() {
    try {
      return _firestore.collection('events').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return Event.fromMap(doc.data(), id: doc.id);
              } catch (_) {
                return null;
              }
            })
            .whereType<Event>()
            .toList();
      });
    } catch (e) {
      throw 'Erro ao buscar todos os eventos: $e';
    }
  }

  Future<List<Event>> getEventsForUserGroups(String userId) async {
    List<Event> allEvents = [];
    List<String> userGroupIds = [];

    try {
      final groupsSnapshot = await _firestore.collection('groups').get();

      for (var groupDoc in groupsSnapshot.docs) {
        final data = groupDoc.data();
        final groupId = groupDoc.id;

        final rawUserIds = data['userIds'];
        final members =
            rawUserIds is List ? List<String>.from(rawUserIds) : <String>[];
        final leaderId = data['leaderId'];

        if (members.contains(userId) || leaderId == userId) {
          userGroupIds.add(groupId);
        }
      }

      for (String groupId in userGroupIds) {
        final snapshot =
            await _firestore
                .collection('events')
                .where('groupId', isEqualTo: groupId)
                .get();

        for (var doc in snapshot.docs) {
          try {
            allEvents.add(Event.fromMap(doc.data(), id: doc.id));
          } catch (_) {}
        }
      }

      return allEvents;
    } catch (e) {
      throw 'Erro ao buscar eventos dos grupos do usuário: $e';
    }
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore;

  EventService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
    } catch (e) {
      throw 'Erro ao adicionar evento: $e';
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw 'Erro ao deletar evento: $e';
    }
  }

  Future<void> toggleUserAttendance(String eventId, String userId) async {
    try {
      final eventRef = _firestore.collection('events').doc(eventId);
      final snapshot = await eventRef.get();

      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final confirmed = List<String>.from(data['confirmedUserIds'] ?? []);

      if (confirmed.contains(userId)) {
        confirmed.remove(userId);
      } else {
        confirmed.add(userId);
      }

      await eventRef.update({'confirmedUserIds': confirmed});
    } catch (e) {
      throw 'Erro ao confirmar presença: $e';
    }
  }

  Stream<List<Event>> getEvents(String groupId) {
    try {
      return _firestore
          .collection('events')
          .where('groupId', isEqualTo: groupId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) {
                  try {
                    return Event.fromMap(doc.data(), id: doc.id);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<Event>()
                .toList();
          });
    } catch (e) {
      throw 'Erro ao buscar eventos do grupo: $e';
    }
  }

  Stream<List<Event>> getAllEvents() {
    try {
      return _firestore.collection('events').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) {
              try {
                return Event.fromMap(doc.data(), id: doc.id);
              } catch (_) {
                return null;
              }
            })
            .whereType<Event>()
            .toList();
      });
    } catch (e) {
      throw 'Erro ao buscar todos os eventos: $e';
    }
  }

  Future<List<Event>> getEventsForUserGroups(String userId) async {
    List<Event> allEvents = [];
    List<String> userGroupIds = [];

    try {
      final groupsSnapshot = await _firestore.collection('groups').get();

      for (var groupDoc in groupsSnapshot.docs) {
        final data = groupDoc.data();
        final groupId = groupDoc.id;

        final rawUserIds = data['userIds'];
        final members =
            rawUserIds is List ? List<String>.from(rawUserIds) : <String>[];
        final leaderId = data['leaderId'];

        if (members.contains(userId) || leaderId == userId) {
          userGroupIds.add(groupId);
        }
      }

      for (String groupId in userGroupIds) {
        final snapshot =
            await _firestore
                .collection('events')
                .where('groupId', isEqualTo: groupId)
                .get();

        for (var doc in snapshot.docs) {
          try {
            allEvents.add(Event.fromMap(doc.data(), id: doc.id));
          } catch (_) {}
        }
      }

      return allEvents;
    } catch (e) {
      throw 'Erro ao buscar eventos dos grupos do usuário: $e';
    }
  }
}
