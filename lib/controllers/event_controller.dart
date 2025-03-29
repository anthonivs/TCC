import '../models/event.dart';
import '../services/event_service.dart';

class EventController {
  final EventService _eventService = EventService();

  Future<void> addEvent(Event event) {
    return _eventService.addEvent(event);
  }

  Stream<List<Event>> getEvents(String groupId) {
    return _eventService.getEvents(groupId);
  }

  Stream<List<Event>> getAllEvents() {
    return _eventService.getAllEvents();
  }
}
