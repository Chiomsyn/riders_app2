import 'dart:convert';

class UsersModel {
  String? id;
  String? email;
  String? name;
  String? phone;
  UsersModel({
    this.id,
    this.email,
    this.name,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory UsersModel.fromMap(Map<String, dynamic>? map) {
    return UsersModel(
      id: map!['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UsersModel.fromJson(String source) =>
      UsersModel.fromJson(json.decode(source));
}
