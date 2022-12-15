import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/core/global/auth/auth.dart';
import 'package:users_uberclone/data_handler/app_data.dart';

import '../../core/model/drivers_model.dart';
import '../../core/model/users.dart';

class FirebaseMethods {
  static Future<Map<String, dynamic>> saveRideRequest(BuildContext context,
      String carType, String distance, String duration, String amount,
      [bool mounted = true]) async {
    var rideRequestRef = fireStore.collection("ride_requests");
    String id = rideRequestRef.doc().id;

    Provider.of<AppData>(context, listen: false).requestId = id;

    if (!mounted) return {};

    var pickUp = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropOffLocation;

    Map pickUpLocMap = {
      "latitude": pickUp!.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropOffLocMap = {
      "latitude": dropOff!.latitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map tripDistance = {
      "text": distance,
      "duration": duration,
    };

    Map<String, dynamic> rideInfoMap = {
      "driverId": "Waiting",
      "paymentMethod": "cash",
      "carType": carType,
      "distance": tripDistance,
      "price": amount,
      "pickUp": pickUpLocMap,
      "pickupAddress": pickUp.placeName,
      "driversInfo": tokenList,
      "dropoff": dropOffLocMap,
      "createdAt": DateTime.now().toString(),
      "riderName": currentUserInfo!.name,
      "riderId": currentUserInfo!.id,
      "riderPhone": currentUserInfo!.phone,
      "dropoffAddress": dropOff.placeName,
      "requestId": id,
      "requestStatus": "Pending",
      "requestStarted": false,
    };

    await rideRequestRef.doc(id).set(
          rideInfoMap,
        );

    return rideInfoMap;
  }

  static void updateRequest(requestId, status) {
    fireStore.collection("ride_requests").doc(requestId).set({
      "driverId": status,
      "requestStatus": "Pending",
    }, SetOptions(merge: true));
  }

  static Future<DriversModel> getDriverById(String id) =>
      fireStore.collection("drivers").doc(id).get().then((doc) {
        return DriversModel.fromMap(doc.data());
      });

  static Future<void> cancelRequest(String id) async {
    await fireStore.collection("ride_requests").doc(id).set({
      "requestStatus": "Cancelled",
    }, SetOptions(merge: true));
  }

  static Future<void> updateToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    print(token);
    print("help me");
    await fireStore
        .collection("users_uber")
        .doc(userId)
        .set({"token": token, "phone": token}, SetOptions(merge: true));
  }

  static Future<UsersModel> getCurrentUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    String uid = currentFirebaseUser!.uid;

    String? token = await FirebaseMessaging.instance.getToken();

    UsersModel users = UsersModel();
    await fireStore.collection("users_uber").doc(uid).get().then((value) {
      if (value != null) {
        users = UsersModel.fromMap(value.data());
      } else {
        return;
      }
    });

    await fireStore.collection("users_uber").doc(uid).set(
        {"token": token, "phone": "+2348166879923"}, SetOptions(merge: true));
    return currentUserInfo = users;
  }

  static double createRandomNumber(int num) {
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

  static Stream<QuerySnapshot> requestStream() {
    CollectionReference reference = fireStore.collection("ride_requests");
    return reference.snapshots();
  }

  static Future<Map<String, dynamic>> getRideAddedPrice() async {
    Map<String, dynamic> data = {};

    await fireStore.collection("ride_price").get().then((value) {
      var val = value.docs;

      for (var element in val) {
        data = element.data();
      }
    });

    return data;
  }
}
