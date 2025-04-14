
class Group {
  final String id;
  final String name;
  final String leader; // nome do líder
  final String leaderId; // <== ADICIONE ESTE CAMPO
  final List<String> userIds;
  final List<String> volunteers;

  Group({
    required this.id,
    required this.name,
    required this.leader,
    required this.leaderId, // <== ADICIONE ESTE CAMPO
    required this.userIds,
    required this.volunteers,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      leader: map['leader'],
      leaderId: map['leaderId'], // <== ADICIONE ESTE CAMPO
      userIds: List<String>.from(map['userIds']),
      volunteers: List<String>.from(map['volunteers']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'leader': leader,
      'leaderId': leaderId, // <== ADICIONE ESTE CAMPO
      'userIds': userIds,
      'volunteers': volunteers,
    };
  }
}