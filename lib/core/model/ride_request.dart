import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequestModel {
  String? requestId;
  String? riderName;
  String? driverId;
  String? dropoffAddress;
  String? dropOffLat;
  String? dropOffLng;
  String? pickUpLat;
  String? pickUpLng;
  Distance? distance;

  RideRequestModel({
    this.requestId,
    this.riderName,
    this.driverId,
    this.dropoffAddress,
    this.dropOffLat,
    this.dropOffLng,
    this.pickUpLat,
    this.pickUpLng,
    this.distance,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'riderName': riderName,
      'driverId': driverId,
      'dropoffAddress': dropoffAddress,
      'dropOffLat': dropOffLat,
      'dropOffLng': dropOffLng,
      'pickUpLat': pickUpLat,
      'pickUpLng': pickUpLng,
      'distance': distance,
    };
  }

  factory RideRequestModel.fromMap(Map<String, dynamic>? map) {
    // String _d = map!["destination"];
    return RideRequestModel(
      requestId: map!['requestId'] ?? '',
      riderName: map['riderName'] ?? '',
      driverId: map['driverId'] ?? '',
      dropoffAddress: map["dropoffAddress "] ?? '',
      dropOffLat: map['dropOffLat'] ?? '',
      dropOffLng: map['dropOffLng'] ?? '',
      pickUpLat: map['pickUpLat'] ?? '',
      pickUpLng: map['pickUpLng'] ?? '',
      distance: Distance.fromMap({
        "text": map["distance"]["text"],
        "duration": map["distance"]["duration"]
      }),
    );
  }

  String toJson() => json.encode(toMap());

  factory RideRequestModel.fromJson(String source) =>
      RideRequestModel.fromJson(json.decode(source));
}

class Distance {
  String? text;
  String? value;

  Distance.fromMap(Map<String, dynamic>? data) {
    text = data!["text"];
    value = data["duration"];
  }

  Map<String, dynamic>? toMap() => {"text": text, "duration": value};
}

class RequestModelFirebase {
  String? id;
  String? riderName;
  String? riderId;
  String? driverId;
  String? requestStatus;
  String? dropOffLat;
  String? dropOffLng;
  String? pickUpLat;
  String? pickUpLng;
  Map? destination;

  RequestModelFirebase({
    this.id,
    this.riderName,
    this.riderId,
    this.driverId,
    this.requestStatus,
    this.dropOffLat,
    this.dropOffLng,
    this.pickUpLat,
    this.pickUpLng,
    this.destination,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': id,
      'riderName': riderName,
      'riderId': riderId,
      'driverId': driverId,
      'request_status': requestStatus,
      'dropOffLat': dropOffLat,
      'dropOffLng': dropOffLng,
      'pickUpLat': pickUpLat,
      'pickUpLng': pickUpLng,
      'destination': destination,
    };
  }

  factory RequestModelFirebase.fromMap(Map<String, dynamic>? map) {
    return RequestModelFirebase(
      id: map!['requestId'] ?? '',
      riderName: map['username'] ?? '',
      riderId: map['riderId'] ?? '',
      driverId: map['driverId'] ?? '',
      requestStatus: map['request_status'] ?? '',
      dropOffLat: map['dropOffLat'] ?? '',
      dropOffLng: map['dropOffLng'] ?? '',
      pickUpLat: map['pickUpLat'] ?? '',
      pickUpLng: map['pickUpLng'] ?? '',
      destination: map['destination'] ?? {},
    );
  }
  String toJson() => json.encode(toMap());

  factory RequestModelFirebase.fromJson(String source) =>
      RequestModelFirebase.fromJson(json.decode(source));

  LatLng getPickUpCoordinates() =>
      LatLng(double.parse(pickUpLat!), double.parse(pickUpLng!));

  LatLng getDropOffCoordinates() =>
      LatLng(double.parse(dropOffLat!), double.parse(dropOffLng!));
}
