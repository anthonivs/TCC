import '../models/event.dart';
import '../services/event_service.dart';
import '../services/auth_service.dart';

class EventController {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  Future<void> addEvent(Event event) async {
    await _eventService.addEvent(event);
  }

  Future<void> deleteEvent(String eventId) async {
    final user = await _authService.currentUser;
    if (user != null && user.role == "Líder") {
      await _eventService.deleteEvent(eventId);
    } else {
      throw Exception("Apenas líderes podem deletar eventos.");
    }
  }

  Stream<List<Event>> getEvents(String groupId) {
    return _eventService.getEvents(groupId);
  }

  Stream<List<Event>> getAllEvents() {
    return _eventService.getAllEvents();
  }
}
