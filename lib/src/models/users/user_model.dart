class Users {
  final String id;
  final String username;
  final String? display;
  final String? picture;
  final String role;
  final bool status;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.id,
    required this.username,
    required this.display,
    required this.picture,
    required this.role,
    required this.status,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'] as String,
      username: json['username'] as String,
      display: json['display'] as String,
      picture: json['picture'] as String,
      role: json['role'] as String,
      status: json['status'] as bool,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display': display,
      'picture': picture,
      'role': role,
      'status': status,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

List<Users> parseUsers(List<dynamic> data) {
  return data.map((json) => Users.fromJson(json as Map<String, dynamic>)).toList();
}
