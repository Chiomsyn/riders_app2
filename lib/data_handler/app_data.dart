import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/model/address.dart';
import '../domain/firebase/firebase_methods.dart';

class AppData with ChangeNotifier{

  int timeCounter = 0;
  double percentage = 0;
  Timer? periodicTimer;
  bool lookingForDriver = false;
  bool driverFound = false;
  bool driverArrived = false;
  bool alertsOnUi = false;
  StreamSubscription<QuerySnapshot>? requestStream;

  Address? _pickUpLocation = Address(placeName: 'Add Home');
  Address? _dropOffLocation = Address(placeName: '');
  String? _carType = "";

  String? get carType => _carType;
  Address? get pickUpLocation => _pickUpLocation;
  Address? get dropOffLocation => _dropOffLocation;

  set updatePickUpLocation(Address pickUpAddress){
    _pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  set updateDropOffLocation(Address dropOffLocation){
    _dropOffLocation = dropOffLocation;
    notifyListeners();
  }

  set carType(String? val){
    _carType = val;
    notifyListeners();
  }



  //  Timer counter for driver request
  percentageCounter({required String requestId, required BuildContext context}) {
    lookingForDriver = true;
    notifyListeners();
    periodicTimer = Timer.periodic(Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      print("====== GOOOO $timeCounter");
      if (timeCounter == 100) {
        timeCounter = 0;
        percentage = 0;
        lookingForDriver = false;
        FirebaseMethods.cancelRequest(requestId);
        time.cancel();
        if (alertsOnUi) {
          Navigator.pop(context);
          alertsOnUi = false;
          notifyListeners();
        }
        requestStream!.cancel();
      }
      notifyListeners();
    });
  }

  listenToRequest({required String id, required BuildContext context}) async {
    requestStream = FirebaseMethods.requestStream().listen((querySnapshot) {
      querySnapshot.docChanges.forEach((doc) async {
        // if (doc.doc.data['id'] == id) {
        //   rideRequestModel = RideRequestModel.fromMap(doc.doc.data());
        //   notifyListeners();
        //   switch (doc.doc.data['status']) {
        //     case CANCELLED:
        //       break;
        //     case ACCEPTED:
        //       if (lookingForDriver) Navigator.pop(context);
        //       lookingForDriver = false;
        //       driverModel = await _driverService
        //           .getDriverById(doc.document.data['driverId']);
        //       periodicTimer.cancel();
        //       clearPoly();
        //       _stopListeningToDriversStream();
        //       _listenToDriver();
        //       show = Show.DRIVER_FOUND;
        //       notifyListeners();
        //
        //       // showDriverBottomSheet(context);
        //       break;
        //     case EXPIRED:
        //       showRequestExpiredAlert(context);
        //       break;
        //     default:
        //       break;
        //   }
        // }
      });
    });
  }


}