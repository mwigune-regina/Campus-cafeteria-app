class UserModel {
  final int id;
  final String username;
  final String email;
  final String role; // 'student' or 'admin'
  final String? avatarUrl; // server-relative path, e.g. /uploads/avatars/x.jpg
  final String? registrationNumber;
  final int? yearOfStudy;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.registrationNumber,
    this.yearOfStudy,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      avatarUrl: json['avatar_url'],
      registrationNumber: json['registration_number'],
      yearOfStudy: json['year_of_study'] is String
          ? int.tryParse(json['year_of_study'])
          : json['year_of_study'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'avatar_url': avatarUrl,
      'registration_number': registrationNumber,
      'year_of_study': yearOfStudy,
    };
  }

  UserModel copyWith({
    String? avatarUrl,
    String? registrationNumber,
    int? yearOfStudy,
  }) {
    return UserModel(
      id: id,
      username: username,
      email: email,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
    );
  }
}