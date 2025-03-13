class Volunteer {
  final String name;
  final String email;
  final String role;

  Volunteer({required this.name, required this.email, required this.role});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
    };
  }

  factory Volunteer.fromMap(Map<String, dynamic> map) {
    return Volunteer(
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }
}