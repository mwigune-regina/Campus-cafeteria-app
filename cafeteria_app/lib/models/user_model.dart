class UserModel {
  final int id;
  final String username;
  final String email;
  final String role; // 'student' or 'admin'

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}
