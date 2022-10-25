import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/core/global/auth/auth.dart';
import 'package:users_uberclone/data_handler/app_data.dart';

import '../../core/model/users.dart';

class FirebaseMethods {
  static Future<String> saveRideRequest(BuildContext context, String carType, [bool mounted = true]) async {
    var rideRequestRef = fireStore.collection("ride_requests");
    String id = rideRequestRef.doc().id;

    if (!mounted) return '';

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

    Map<String, dynamic> rideInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "car_type": carType,
      "pick_up": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": currentUserInfo!.name,
      "rider_phone": currentUserInfo!.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName,
      "request_id": id,
      "request_cancelled": false,
    };

    await rideRequestRef.doc(id).set(rideInfoMap,);

    return id;
  }

  static Future<void> cancelRequest(String id) async{
   await fireStore.collection("ride_requests").doc(id).set({
      "request_cancelled": true,
    }, SetOptions(merge: true));
  }

  static Future<UsersModel> getCurrentUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;
    String uid = currentFirebaseUser!.uid;

    UsersModel users = UsersModel();
        await fireStore.collection("users_uber").doc(uid).get().then((value) {

      if (value != null) {
      users = UsersModel.fromMap(value.data());
      } else {
        return;
      }
    });
    return currentUserInfo = users;
  }

  static double createRandomNumber(int num){
    var random = Random();
    int radNumber = random.nextInt(num);
    return radNumber.toDouble();
  }

  static Stream<QuerySnapshot> requestStream() {
    CollectionReference reference = fireStore.collection("ride_requests");
    return reference.snapshots();
  }
}
