class UserLocal {
  final String id;
  final String username;
  final String? display;
  final String? picture;
  final bool status;
  final String role;
  final String token;

  UserLocal({
    required this.id,
    required this.username,
    required this.display,
    required this.picture,
    required this.status,
    required this.role,
    required this.token,
  });

  factory UserLocal.fromMap(Map<String, dynamic> map) {
    return UserLocal(
      id: map['id'] as String,
      username: map['username'] as String,
      display: map['display'] as String,
      picture: map['picture'] as String,
      status: map['status'] as bool,
      role: map['role'] as String,
      token: map['token'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'display': display,
      'picture': picture,
      'status': status,
      'role': role,
      'token': token,
    };
  }
}
