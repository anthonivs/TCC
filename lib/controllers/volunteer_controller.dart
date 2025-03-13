import '../models/volunteer.dart';
import '../services/volunteer_service.dart';

class VolunteerController {
  final VolunteerService _volunteerService = VolunteerService();

  Future<void> addVolunteer(Volunteer volunteer) async {
    await _volunteerService.addVolunteer(volunteer);
  }

  Stream<List<Volunteer>> getVolunteers() {
    return _volunteerService.getVolunteers();
  }
}