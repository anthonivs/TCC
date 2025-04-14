import 'package:cloud_functions/cloud_functions.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';

class EventController {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  Future<void> addEvent(Event event) async {
    await _eventService.addEvent(event);

    final user = await _authService.currentUser;
    if (user == null || user.role != 'Líder') return;

    final allUsers = await _authService.getAllUsers();
    final groupUsers = allUsers.where((u) => u.groupIds.contains(event.groupId)).toList();
    final tokens = groupUsers.map((u) => u.fcmToken).whereType<String>().toList();

    if (tokens.isNotEmpty) {
      final callable = FirebaseFunctions.instance.httpsCallable('sendGroupNotification');
      await callable.call({
        'tokens': tokens,
        'title': 'Novo evento no grupo!',
        'body':
            'Você vai participar de: ${event.description} em ${event.date.day}/${event.date.month} às ${event.time}?'
      });
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final user = await _authService.currentUser;
    if (user != null && user.role == "Líder") {
      await _eventService.deleteEvent(eventId);
    } else {
      throw Exception("Apenas líderes podem deletar eventos.");
    }
  }

  Future<void> toggleAttendance(String eventId) async {
    final user = await _authService.currentUser;
    if (user == null) return;

    await _eventService.toggleUserAttendance(eventId, user.id);
  }

  Stream<List<Event>> getEvents(String groupId) {
    return _eventService.getEvents(groupId);
  }

  Stream<List<Event>> getAllEvents() {
    return _eventService.getAllEvents();
  }
}
