import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users_uberclone/core/model/drivers_model.dart';

import '../core/global/auth/auth.dart';
import '../core/model/address.dart';
import '../core/model/avail_drivers.dart';
import '../core/model/dir_details.dart';
import '../core/model/ride_request.dart';
import '../domain/firebase/firebase_methods.dart';
import '../domain/map/api_methods.dart';
import '../presentation/widgets/progress_dialog.dart';
import '../presentation/widgets/stars.dart';

enum Show {
  idleTime,
  lookingForDriver,
  driverFound,
  driverArrived,
  driverNotFound,
  rideDetailsContainer,
  requestRideContainer,
  paymentMethodSelection
}

class AppData with ChangeNotifier {
  double bottomPaddingOfMap = 0;
  bool close = false;

  bool premiumCarsAvail = false;
  bool poorCarsAvail = false;

  int _poorTripPrice = 0;
  int _premiumTripPrice = 0;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> _markersSet = {};

  Set<Circle> circlesSet = {};

  DirectionDetails? _tripDirectionDetails = DirectionDetails();

  GoogleMapController? newGoogleMapController;

  BitmapDescriptor? nearByIcon;

  Show _show = Show.idleTime;

  String _requestId = '';

  int timeCounter = 0;
  double percentage = 0;
  Timer? periodicTimer;
  StreamSubscription<QuerySnapshot>? requestStream;

  DriversModel driverModel = DriversModel();

  Address? _pickUpLocation = Address(placeName: 'Add Home');
  Address? _dropOffLocation = Address(placeName: '');
  String? _carType = "";

  String jobId = "";
  Map<String, dynamic> requestInfo = {};

  Show get show => _show;
  String get requestId => _requestId;

  int get poorTripPrice => _poorTripPrice;
  int get premiumTripPrice => _premiumTripPrice;
  List<String> sentNotification = [];

  String? get carType => _carType;
  Address? get pickUpLocation => _pickUpLocation;
  Address? get dropOffLocation => _dropOffLocation;
  DirectionDetails? get tripDirectionDetails => _tripDirectionDetails;

  Set<Marker> get markersSet => _markersSet;

  RideRequestModel rideRequestModel = RideRequestModel();

  StreamSubscription<List<DocumentSnapshot<Object?>>>? driversListen;

  Position? currentPosition;

  LocationPermission? permission;

  bool serviceEnabled = true;

  set requestId(String val) {
    _requestId = val;
    notifyListeners();
  }

  set show(Show val) {
    _show = val;
    notifyListeners();
  }

  set tripDirectionDetails(DirectionDetails? val) {
    _tripDirectionDetails = val;
    notifyListeners();
  }

  set poorTripPrice(int val) {
    _poorTripPrice = val;
    notifyListeners();
  }

  set premiumTripPrice(int val) {
    _premiumTripPrice = val;
    notifyListeners();
  }

  set markersSet(Set<Marker> val) {
    _markersSet = val;
    notifyListeners();
  }

  set updatePickUpLocation(Address pickUpAddress) {
    _pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  set updateDropOffLocation(Address dropOffLocation) {
    _dropOffLocation = dropOffLocation;
    notifyListeners();
  }

  set carType(String? val) {
    _carType = val;
    notifyListeners();
  }

  Future<void> cancelRideRequest() async {
    await FirebaseMethods.cancelRequest(jobId);
  }

  void displayRideDetailsContainer(context) async {
    await getPlaceDirection(context);

    _show = Show.rideDetailsContainer;
    bottomPaddingOfMap = 250.0;
    close = true;
    notifyListeners();
  }

  Future storeTokens() async {
    try {
      await FirebaseMethods.updateToken(currentUserInfo!.id!);
    } catch (e) {}
  }

  Future<void> requestForDrivers(String carType, context, String distance,
      String time, String amount) async {
    requestInfo = await FirebaseMethods.saveRideRequest(
        context, carType, distance, time, amount);
    jobId = requestInfo["requestId"];
    // PushNotificationService().sendNotification(tokenList, requestInfo);
    show = Show.requestRideContainer;
    bottomPaddingOfMap = 230.0;
    close = false;
    listNearDrivers.clear();

    notifyListeners();
  }

  resetApp(context) {
    close = false;
    show = Show.idleTime;
    bottomPaddingOfMap = 300.0;

    _carType = "";
    notifyListeners();
    listNearDrivers.clear();

    tokenList.clear();

    polylineSet.clear();
    markersSet.clear();
    circlesSet.clear();
    pLineCoordinates.clear();

    notifyListeners();

    locatePosition(context);
  }

  Future handleNotificationData(Map<String, dynamic> data) async {
    _show = Show.driverArrived;
    // _id = data["id"];
    notifyListeners();
  }

  //  Timer counter for driver request
  percentageCounter() {
    notifyListeners();
    periodicTimer = Timer.periodic(const Duration(seconds: 1), (time) {
      timeCounter = timeCounter + 1;
      percentage = timeCounter / 100;
      if (show == Show.driverFound) {
        timeCounter = 0;
        percentage = 0;
        time.cancel();
        notifyListeners();
      }
      if (timeCounter == 15 && show != Show.driverFound) {
        // hasRequestExpired = true;
        timeCounter = 0;
        percentage = 0;
        time.cancel();
        nextDriver();
        notifyListeners();
      }

      notifyListeners();
    });
  }

  nextDriver() {
    FirebaseMethods.updateRequest(requestId, "Waiting");
    notifyListeners();
  }

  Future<void> locatePosition(context) async {
    // Test if location services are enabled.

    await Geolocator.checkPermission();
    await Geolocator.requestPermission();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController
        ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    await ApiMethods.searchCoordinateAddress(position, context);

    getAvailableDrivers();
  }

  listenToRequest() async {
    requestStream =
        FirebaseMethods.requestStream().listen((querySnapshot) async {
      for (var doc in querySnapshot.docChanges) {
        Map<String, dynamic> c = doc.doc.data() as Map<String, dynamic>;

        if (c["requestId"] == requestId) {
          if (c['requestStatus'] == "NoReply") {
            show = Show.driverNotFound;
            requestStream!.cancel;
            periodicTimer!.cancel();
            notifyListeners();
          }
          if (c["requestStarted"] == true) {
            rideRequestModel = RideRequestModel.fromMap(c);
            percentageCounter();
            notifyListeners();

            if (c['driverId'] != "Waiting") {
              show = Show.lookingForDriver;
              driverModel = await FirebaseMethods.getDriverById(c['driverId']);
              bottomPaddingOfMap = 230.0;
              notifyListeners();
            }

            switch (c['requestStatus']) {
              case "Cancelled":
                break;
              case "Accepted":
                show = Show.driverFound;
                requestStream!.cancel;
                periodicTimer!.cancel();
                // _stopListeningToDriversStream();
                // _listenToDriver();
                notifyListeners();

                // showDriverBottomSheet(context);
                break;
              case "Expired":
                // showRequestExpiredAlert(context);
                break;
              case "Waiting":
                break;
              default:
                break;
            }
          }
        }
      }
    });
  }

  Future<void> getPlaceDirection(context) async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;
    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);
    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait ...",
            ));
    var details =
        await ApiMethods.placeDirectionDetails(pickUpLatLng, dropOffLatLng);
    tripDirectionDetails = details;
    Navigator.pop(context);

    addPolyLines(details);

    // makes the polines fit in the map to avoid scrolling
    LatLngBounds? latlngBounds = addLatLngBounds(pickUpLatLng, dropOffLatLng);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(latlngBounds!, 70));

    addMarkers(initialPos, pickUpLatLng, finalPos, dropOffLatLng);

    addCircle(pickUpLatLng, dropOffLatLng);
  }

  void addCircle(LatLng pickUpLatLng, LatLng dropOffLatLng) {
    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeColor: Colors.blueAccent,
        strokeWidth: 4,
        circleId: const CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropOffLatLng,
        radius: 12,
        strokeColor: Colors.deepPurple,
        strokeWidth: 4,
        circleId: const CircleId("dropOffId"));

    circlesSet.add(pickUpLocCircle);
    circlesSet.add(dropOffLocCircle);
  }

  void findDriverCircle(LatLng pickUpLatLng) {
    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickUpLatLng,
        radius: 12,
        strokeColor: Colors.blueAccent,
        strokeWidth: 4,
        circleId: const CircleId("pickUpId"));

    circlesSet.add(pickUpLocCircle);
  }

  void addMarkers(Address initialPos, LatLng pickUpLatLng, Address finalPos,
      LatLng dropOffLatLng) {
    Marker picUpLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        infoWindow:
            InfoWindow(title: initialPos.placeName, snippet: 'my Location'),
        position: pickUpLatLng,
        markerId: const MarkerId("pickUpId"));

    Marker dropOffLocMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow:
            InfoWindow(title: finalPos.placeName, snippet: 'DropOff Location'),
        position: dropOffLatLng,
        markerId: const MarkerId("dropOffId"));

    markersSet.add(picUpLocMarker);
    markersSet.add(dropOffLocMarker);
  }

  LatLngBounds? addLatLngBounds(LatLng pickUpLatLng, LatLng dropOffLatLng) {
    // makes the polines fit in the map to avoid scrolling
    LatLngBounds? latlngBounds;

    if (pickUpLatLng.latitude > dropOffLatLng.latitude &&
        pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latlngBounds =
          LatLngBounds(southwest: dropOffLatLng, northeast: pickUpLatLng);
    } else if (pickUpLatLng.longitude > dropOffLatLng.longitude) {
      latlngBounds = LatLngBounds(
          southwest: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude),
          northeast: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude));
    } else if (pickUpLatLng.latitude > dropOffLatLng.latitude) {
      latlngBounds = LatLngBounds(
          southwest: LatLng(dropOffLatLng.latitude, pickUpLatLng.longitude),
          northeast: LatLng(pickUpLatLng.latitude, dropOffLatLng.longitude));
    } else {
      latlngBounds =
          LatLngBounds(southwest: pickUpLatLng, northeast: dropOffLatLng);
    }
    return latlngBounds;
  }

  void addPolyLines(DirectionDetails? details) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylineResult =
        polylinePoints.decodePolyline(details!.encodedPoints!);

    pLineCoordinates.clear();
    if (decodePolylineResult.isNotEmpty) {
      for (var pointLatLng in decodePolylineResult) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }

    polylineSet.clear();

    Polyline polyline = Polyline(
        color: Colors.pink,
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        polylineId: const PolylineId("PolylineID"));

    polylineSet.add(polyline);
  }

  void getAvailableDrivers() {
    // get the collection reference or query
    var collectionReference = fireStore.collection('available_drivers');

    double radius = 50;
    String field = 'position';

    // Create a geoFirePoint
    GeoFirePoint center = geo.point(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude);

    listNearDrivers.clear();

    driversListen = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field)
        .listen((event) {
      if (listNearDrivers.isEmpty) {
        for (var val in event) {
          NearByAvailDrivers nearDrivers = NearByAvailDrivers();
          Map<String, dynamic> c = val.data() as Map<String, dynamic>;

          String carType = c["car_type"] ?? "";

          GeoPoint p = c["position"]["geopoint"];

          if (carType == "premium car") {
            premiumCarsAvail = true;
          }

          if (carType == "poor car") {
            poorCarsAvail = true;
          }

          nearDrivers.key = c["position"]["geohash"];
          nearDrivers.latitude = p.latitude;
          nearDrivers.longitude = p.longitude;
          nearDrivers.id = c["id"];
          nearDrivers.token = c["token"];
          nearDrivers.carType = carType;
          nearDrivers.disBtw = calculateDistance(p.latitude, p.longitude,
              pickUpLocation!.latitude, pickUpLocation!.longitude);

          listNearDrivers.add(nearDrivers);
        }
      }
      notifyListeners();

      updateAvailableDriversOnMap(listNearDrivers);

      notifyListeners();
    });
  }

  void listenToDriver(String driverId) {
    // get the collection reference or query
    var collectionReference = fireStore.collection('available_drivers');

    double radius = 50;
    String field = 'position';

    // Create a geoFirePoint
    GeoFirePoint center = geo.point(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude);

    listNearDrivers.clear();
    NearByAvailDrivers nearDrivers = NearByAvailDrivers();

    driversListen = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field)
        .listen((event) {
      for (var val in event) {
        Map<String, dynamic> c = val.data() as Map<String, dynamic>;

        if (c["id"] == driverId) {
          String carType = c["car_type"] ?? "";

          GeoPoint p = c["position"]["geopoint"];

          nearDrivers.key = c["position"]["geohash"];
          nearDrivers.latitude = p.latitude;
          nearDrivers.longitude = p.longitude;
          nearDrivers.id = c["id"];
          nearDrivers.token = c["token"];
          nearDrivers.carType = carType;
        }
      }

      notifyListeners();

      updateAvailableDriversOnMap(listNearDrivers);

      notifyListeners();
    });
  }

  void updateDriversOnMap(NearByAvailDrivers point) {
    markersSet.clear();

    Set<Marker> tMarkers = <Marker>{};

    LatLng driverAvailablePosition = LatLng(point.latitude!, point.longitude!);

    Marker marker = addCarMarkers(point, driverAvailablePosition);

    tMarkers.add(marker);
    notifyListeners();

    markersSet = tMarkers;
    notifyListeners();
  }

  void updateAvailableDriversOnMap(List<NearByAvailDrivers> point) {
    markersSet.clear();

    Set<Marker> tMarkers = <Marker>{};

    for (NearByAvailDrivers p in point) {
      LatLng driverAvailablePosition = LatLng(p.latitude!, p.longitude!);

      Marker marker = addCarMarkers(p, driverAvailablePosition);

      tMarkers.add(marker);
      notifyListeners();
    }

    markersSet = tMarkers;
    notifyListeners();
  }

  Marker addCarMarkers(NearByAvailDrivers p, LatLng driverAvailablePosition) {
    Marker marker = Marker(
      markerId: MarkerId('driver${p.key}'),
      position: driverAvailablePosition,
      icon: nearByIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      rotation: 0,
    );
    return marker;
  }

  void showSelectedCarTypeDriversOnMap() {
    // driversListen!.cancel();
    markersSet.clear();

    Set<Marker> tMarkers = <Marker>{};

    tokenList.clear();

    // sort the drivers acdording to distance
    if (listNearDrivers.length > 1) {
      listNearDrivers.sort((a, b) => a.disBtw!.compareTo(b.disBtw!));
    }

    for (var i = 0; i < listNearDrivers.length; i++) {
      if (listNearDrivers[i].carType == carType) {
        LatLng driverAvailablePosition =
            LatLng(listNearDrivers[i].latitude!, listNearDrivers[i].longitude!);

        Map<String, dynamic> c = {};
        c["driverId"] = listNearDrivers[i].id;
        c["tokenId"] = listNearDrivers[i].token;
        c["distance"] = listNearDrivers[i].disBtw;

        tokenList.add(c);

        Marker marker =
            addCarMarkers(listNearDrivers[i], driverAvailablePosition);

        tMarkers.add(marker);
        notifyListeners();
      }
    }

    markersSet = tMarkers;
    notifyListeners();
  }

  void createIconMarker(context) {
    if (nearByIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(10, 10));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, "assets/images/car_ios.png")
          .then((value) {
        nearByIcon = value;
      });
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  stars({required int votes, required double rating}) {
    if (votes == 0) {
      return const StarsWidget(
        numberOfStars: 0,
      );
    } else {
      double finalRate = rating / votes;
      return StarsWidget(
        numberOfStars: finalRate.floor(),
      );
    }
  }
}
