class Group {
  final String id;
  final String name;
  final String leader;
  final String leaderId;
  final List<String> userIds;
  final List<String> volunteers;

  Group({
    required this.id,
    required this.name,
    required this.leader,
    required this.leaderId,
    required this.userIds,
    required this.volunteers,
    required events,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      leader: map['leader'],
      leaderId: map['leaderId'],
      userIds: List<String>.from(map['userIds']),
      volunteers: List<String>.from(map['volunteers']),
      events: null,
    );
  }

  get events => null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'leader': leader,
      'leaderId': leaderId,
      'userIds': userIds,
      'volunteers': volunteers,
    };
  }
}
