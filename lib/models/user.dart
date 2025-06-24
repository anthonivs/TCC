/*class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> groupIds;
  final String? phone;
  final String? occupation;
  final String? description;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.groupIds,
    this.phone,
    this.occupation,
    this.description,
  });

  factory User.fromMap(Map<String, dynamic> data) => User(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        role: data['role'] as String,
        groupIds: List<String>.from(data['groupIds'] ?? []),
        phone: data['phone'] as String?,
        occupation: data['occupation'] as String?,
        description: data['description'] as String?,
      );

  Future<void>? get fcmToken => null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'groupIds': groupIds,
        'phone': phone,
        'occupation': occupation,
        'description': description,
      };
}*/
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> groupIds;
  final String? phone;
  final String? occupation;
  final String? description;
  final String? fcmToken; // 👈 ADICIONAR ESTE CAMPO

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.groupIds,
    this.phone,
    this.occupation,
    this.description,
    this.fcmToken, // 👈 ADICIONAR AQUI TAMBÉM
  });

  factory User.fromMap(Map<String, dynamic> data) => User(
    id: data['id'] as String,
    name: data['name'] as String,
    email: data['email'] as String,
    role: data['role'] as String,
    groupIds: List<String>.from(data['groupIds'] ?? []),
    phone: data['phone'] as String?,
    occupation: data['occupation'] as String?,
    description: data['description'] as String?,
    fcmToken: data['fcmToken'] as String?, // 👈 ADICIONAR AQUI TAMBÉM
  );
}
