class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> groupIds;
  final String? fcmToken; 

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupIds = const [],
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'groupIds': groupIds,
      'fcmToken': fcmToken, 
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      groupIds: (map['groupIds'] is List)
          ? List<String>.from(map['groupIds'])
          : [],
      fcmToken: map['fcmToken'], 
    );
  }
}
