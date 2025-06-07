import 'package:cloud_functions/cloud_functions.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventController {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    try {
      await _eventService.addEvent(event);

      final user = await _authService.currentUser;
      if (user == null || user.role != 'Líder') return;

      final allUsers = await _authService.getAllUsers();
      final groupUsers =
          allUsers.where((u) => u.groupIds.contains(event.groupId)).toList();
      final tokens =
          groupUsers.map((u) => u.fcmToken).whereType<String>().toList();

      if (tokens.isNotEmpty) {
        final callable = FirebaseFunctions.instance.httpsCallable(
          'sendGroupNotification',
        );
        await callable.call({
          'tokens': tokens,
          'title': 'Novo evento no grupo!',
          'body':
              'Você vai participar de: ${event.description} em ${event.date.day}/${event.date.month} às ${event.time}?',
        });
      }
    } catch (e) {
      throw 'Erro ao adicionar evento: $e';
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final user = await _authService.currentUser;
      if (user != null && user.role == 'Líder') {
        await _eventService.deleteEvent(eventId);
      } else {
        throw 'Apenas líderes podem deletar eventos.';
      }
    } catch (e) {
      throw 'Erro ao deletar evento: $e';
    }
  }

  Future<void> toggleAttendance(String eventId) async {
    try {
      final user = await _authService.currentUser;
      if (user == null) throw 'Usuário não autenticado.';

      await _eventService.toggleUserAttendance(eventId, user.id);
    } catch (e) {
      throw 'Erro ao atualizar presença: $e';
    }
  }

  Stream<List<Event>> getEvents(String groupId) {
    return _eventService.getEvents(groupId);
  }

  Stream<List<Event>> getAllEvents() {
    return _eventService.getAllEvents();
  }

  Future<List<Event>> getUserRelatedEvents() async {
    try {
      final user = await _authService.currentUser;
      if (user == null) return [];
      return await _eventService.getEventsForUserGroups(user.id);
    } catch (e) {
      throw 'Erro ao carregar eventos do usuário: $e';
    }
  }

  Future<void> assignVolunteersToEvent(
    String eventId,
    List<String> userIds,
  ) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'assignedUserIds': userIds,
      });
    } catch (e) {
      throw 'Erro ao escalar voluntários: $e';
    }
  }

  Stream<List<Event>> getUserRelatedEventsStream() async* {
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        yield [];
        return;
      }

      final groupsSnapshot = await _firestore.collection('groups').get();
      List<String> userGroupIds = [];

      for (var groupDoc in groupsSnapshot.docs) {
        final data = groupDoc.data();
        final groupId = groupDoc.id;

        try {
          final rawUserIds = data['userIds'];
          final members =
              rawUserIds is List ? List<String>.from(rawUserIds) : <String>[];
          final leaderId = data['leaderId'];

          if (members.contains(user.id) || leaderId == user.id) {
            userGroupIds.add(groupId);
          }
        } catch (_) {}
      }

      yield* _firestore
          .collection('events')
          .where(
            'groupId',
            whereIn: userGroupIds.isNotEmpty ? userGroupIds : ['dummy'],
          )
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => Event.fromMap(doc.data(), id: doc.id))
                    .toList(),
          );
    } catch (e) {
      throw 'Erro ao carregar eventos relacionados: $e';
    }
  }
}
