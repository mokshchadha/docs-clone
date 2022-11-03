import 'dart:convert';

class User {
  final String email;
  final String profilePicture;
  final String name;
  final String uid;
  final String token;

  User(
      {required this.email,
      required this.uid,
      required this.name,
      required this.profilePicture,
      required this.token});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'profilePicture': profilePicture,
      'uid': uid,
      'token': token,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      uid: map['_id'] ?? '',
      token: map['token'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? email,
    String? name,
    String? profilePicture,
    String? uid,
    String? token,
  }) {
    return User(
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }
}
