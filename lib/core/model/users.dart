import 'dart:convert';

class UsersModel {
  String? id;
  String? email;
  String? name;
  String? phone;
  String? token;
  String? status;
  UsersModel({
    this.id,
    this.email,
    this.name,
    this.phone,
    this.token,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'status': status,
    };
  }

  factory UsersModel.fromMap(Map<String, dynamic>? map) {
    return UsersModel(
      id: map!['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      token: map['token'] ?? '',
      status: map['status'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UsersModel.fromJson(String source) =>
      UsersModel.fromJson(json.decode(source));
}
