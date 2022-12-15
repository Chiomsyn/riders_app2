import 'dart:convert';

class DriversModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? token;
  String? photo;
  int? votes;
  int? trips;
  double? rating;

  DriversModel(
      {this.id,
      this.name,
      this.email,
      this.photo,
      this.phone,
      this.token,
      this.votes,
      this.trips,
      this.rating});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photo': photo,
      'phone': phone,
      'token': token,
      'votes': votes,
      'trips': trips,
      'rating': rating
    };
  }

  factory DriversModel.fromMap(Map<String, dynamic>? map) {
    return DriversModel(
      id: map!['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photo: map['photo'] ?? '',
      token: map['token'] ?? '',
      votes: map['votes'] ?? 0,
      trips: map['trips'] ?? 0,
      rating: map['rating'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DriversModel.fromJson(String source) =>
      DriversModel.fromJson(json.decode(source));
}
